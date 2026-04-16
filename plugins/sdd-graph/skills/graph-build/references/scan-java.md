# Protocole de scanning Java Spring Boot

Procédure pour l'agent `graph-builder-java`. Exécuter les 5 passes dans l'ordre. Toutes les sorties en **JSON** dans `.sdd/graph/`.

## Pré-requis

L'agent reçoit :
- `rootPath` : répertoire racine du projet
- `sourcePath` : chemin vers les sources Java (ex: `src/main/java`)
- `outputPath` : `.sdd/graph/`
- `graphs` : liste des graphes à construire

Initialiser les structures de données en mémoire :
- `endpoints = []`
- `entities = []`
- `serviceNodes = []`, `serviceEdges = []`
- `modules = []`, `couplingMatrix = {}`

---

## Pass 0 : Détection du package racine

```bash
grep -rn "^package " --include="*.java" <sourcePath> | head -50
```

Identifier le préfixe commun de tous les packages (ex: `com.acme`).
Ce sera `rootPackage` dans `module-dep.json`.

Identifier les modules : sous-packages directs du rootPackage (ex: `com.acme.user`, `com.acme.order`).
Ce sont les répertoires de premier niveau sous la racine de packages.

```bash
find <sourcePath> -mindepth 3 -maxdepth 3 -type d | head -30
```

Chaque répertoire = un module potentiel. Ignorer les répertoires `config`, `common`, `shared`, `util` comme modules — les traiter comme `shared`.

---

## Pass 1 : Extraction des entités JPA (`entity-model.json`)

Si `entity-model` absent de la liste `graphs` → sauter cette passe.

### 1a. Lister les fichiers entity

```bash
grep -rn "@Entity" --include="*.java" -l <sourcePath>
```

### 1b. Pour chaque fichier entity : lire et extraire

Lire le fichier. Extraire :

**Nom de la classe** :
```
grep "^public class \|^public abstract class \|^class " <fichier>
```

**Table** :
```
grep "@Table" <fichier>
```
→ extraire `name=` si présent. Sinon, convertir le nom de classe en snake_case.

**Héritage** :
```
grep "extends " <fichier>
```
→ si `extends <NomEntite>`, noter `parentEntity`.

**Stratégie d'héritage** :
```
grep "@Inheritance" <fichier>
```
→ extraire `strategy=`.

**Champs** :
Pour chaque ligne contenant `@Id`, `@Column`, `@OneToMany`, `@ManyToOne`, `@ManyToMany`, `@OneToOne`, `@JoinColumn` :
- Lire la ligne suivante pour obtenir le nom et type du champ
- Extraire l'annotation complète (avec paramètres)
- Pour les relations : extraire `mappedBy`, `fetch`, `cascade` si présents

### 1c. Construire l'objet entity

Suivre le schéma `entity-model.json` de `references/templates.md`.
Déduire `module` depuis le package du fichier (segment après `rootPackage`).

Ajouter à `entities[]`.

---

## Pass 2 : Extraction des endpoints (`endpoint-flow.json`)

Si `endpoint-flow` absent de la liste `graphs` → sauter cette passe.

### 2a. Lister les fichiers controller

```bash
grep -rn "@RestController\|@Controller" --include="*.java" -l <sourcePath>
```

### 2b. Pour chaque fichier controller : extraire

**Path de base** :
```
grep "@RequestMapping" <fichier>
```
→ extraire la valeur (ex: `/api/v1/users`). Peut être absent.

**Pour chaque méthode avec mapping HTTP** :
```
grep -n "@GetMapping\|@PostMapping\|@PutMapping\|@DeleteMapping\|@PatchMapping" <fichier>
```
Pour chaque occurrence :
- Extraire le path de l'annotation (ex: `"/{id}"`)
- Construire le path complet : `basePath + methodPath`
- Lire les lignes suivantes pour trouver la signature de la méthode (nom, type de retour, paramètres)
- Extraire `@RequestBody` param → `requestDto`
- Extraire le type de retour → `responseDto`
- Extraire `@PreAuthorize` ou `@Secured` si présents → `security`

**Services injectés dans ce controller** :
```
grep -n "private final \|@Autowired" <fichier>
```
→ Identifier les services (classes dont le nom finit par `Service`)

**Pour chaque service injecté** :
- Lire le fichier du service correspondant (localiser via Glob `**/<ServiceName>.java`)
- Extraire ses repositories injectés (classes finissant par `Repository`)
- Pour chaque repository : en déduire l'entité (ex: `UserRepository` → `User`)

### 2c. Construire l'objet endpoint

```json
{
  "id": "ep_<index 3 chiffres>",
  "method": "<HTTP_METHOD>",
  "path": "<path complet>",
  "module": "<module du controller>",
  "controller": { ... },
  "services": [ ... ],
  "repositories": [ ... ],
  "entities": [ ... ],
  "tables": [ ... ],
  "requestDto": "<nom ou null>",
  "responseDto": "<nom>",
  "security": [ ... ]
}
```

Pour les `tables` : croiser les entités avec les données extraites en Pass 1.

Ajouter à `endpoints[]`.

---

## Pass 3 : Extraction du graphe de services (`service-call.json`)

Si `service-call` absent de la liste `graphs` → sauter cette passe.

### 3a. Lister les fichiers service

```bash
grep -rn "@Service" --include="*.java" -l <sourcePath>
```

Également inclure les repositories :
```bash
grep -rn "@Repository\|extends JpaRepository\|extends CrudRepository\|extends PagingAndSortingRepository" --include="*.java" -l <sourcePath>
```

### 3b. Pour chaque service : extraire les dépendances injectées

Lire le fichier. Appliquer **les deux stratégies** — un même projet peut mélanger les deux styles.

---

**Stratégie A — Injection par champ (`@Autowired` field)**

```java
@Autowired
private UserRepository userRepository;

@Autowired
private EmailService emailService;
```

Grep :
```bash
grep -n "@Autowired" <fichier>
```
Pour chaque occurrence :
1. Lire la ligne suivante (ou les lignes suivantes si @Autowired est sur une ligne seule)
2. Si la ligne contient `private <Type> <nom>` → extraire `Type` comme dépendance injectée
3. Filtrer : ne garder que les types finissant par `Service`, `Repository`, `Component`, `Manager`, ou `Client`
4. `injectionType: "field"`

---

**Stratégie B — Injection par constructeur**

```java
// Forme 1 : constructeur unique (Spring détecte automatiquement)
@Service
public class UserService {
    private final EmailService emailService;
    private final UserRepository userRepository;

    public UserService(EmailService emailService, UserRepository userRepository) { ... }
}

// Forme 2 : constructeur annoté @Autowired
@Service
public class OrderService {
    @Autowired
    public OrderService(UserService userService, PaymentService paymentService) { ... }
}
```

Grep — trouver le constructeur de la classe (nom de classe extrait en 3a) :
```bash
grep -n "public <NomClasse>(" <fichier>
```
Pour chaque occurrence :
1. Lire les lignes de la signature du constructeur (peut s'étendre sur plusieurs lignes jusqu'au `{`)
2. Extraire chaque paramètre de type `<Type> <nom>` — plusieurs par ligne possible
3. Filtrer : ne garder que les types finissant par `Service`, `Repository`, `Component`, `Manager`, ou `Client`
4. `injectionType: "constructor"`

**Priorité :** si un type est détecté par les deux stratégies sur le même fichier, ne créer qu'un seul edge avec `injectionType: "constructor"` (la déclaration `private final` + constructeur est la forme canonique).

---

**Résultat attendu :** pour un service qui mélange les deux styles :
```java
@Service
public class MixedService {
    private final UserRepository userRepository;  // constructeur
    @Autowired
    private EmailService emailService;            // field

    public MixedService(UserRepository userRepository) { ... }
}
```
→ 2 edges : `MixedService → UserRepository (constructor)`, `MixedService → EmailService (field)`

### 3c. Construire les nœuds et edges

**Nœud** : un nœud par service/repository unique.
```json
{
  "id": "svc_<NomClasse>",
  "name": "<NomClasse>",
  "file": "<chemin relatif>",
  "module": "<module>",
  "type": "service"
}
```
Pour les repositories : `"id": "repo_<NomClasse>"`, `"type": "repository"`.

**Edge** : une edge par dépendance injectée.
```json
{
  "from": "svc_<ClasseAppelante>",
  "to": "svc_<ClasseAppelee>",
  "callSite": "<fichier>:<ligne de l'injection>",
  "injectionType": "constructor"
}
```

Ajouter nœuds à `serviceNodes[]` et edges à `serviceEdges[]`.

---

## Pass 4 : Extraction des dépendances inter-modules (`module-dep.json`)

Si `module-dep` absent de la liste `graphs` → sauter cette passe.

### 4a. Pour chaque module identifié en Pass 0

Lister les imports cross-module dans les fichiers du module :

```bash
grep -rhn "^import <rootPackage>\." --include="*.java" <sourcePath>/<module>/
```

Pour chaque import :
- Extraire le sous-package cible (segment après `rootPackage`)
- Si ce sous-package est un autre module → incrémenter `couplingMatrix[mod_<source>][mod_<cible>]`

### 4b. Construire les modules

```json
{
  "id": "mod_<nom>",
  "name": "<nom>",
  "path": "<sourcePath>/<nom>",
  "package": "<rootPackage>.<nom>",
  "dependsOn": [],
  "usedBy": []
}
```

Remplir `dependsOn` depuis `couplingMatrix` (modules où le poids > 0).
Calculer `usedBy` en inversant les `dependsOn` de tous les modules.

---

## Pass 5 : Extraction de la hiérarchie de types (`type-hierarchy.json`)

Si `type-hierarchy` absent de la liste `graphs` → sauter cette passe.

### 5a. Lister les interfaces du projet

```bash
grep -rn "^public interface \|^interface " --include="*.java" -l <sourcePath>
```

Pour chaque fichier interface :
- Extraire le nom de l'interface
- Extraire les interfaces parentes (`extends <Interface1>, <Interface2>`) — filtrer pour ne garder que celles du projet (contenant `rootPackage`)

### 5b. Trouver les implémenteurs

Pour chaque interface :
```bash
grep -rn "implements.*<NomInterface>" --include="*.java" <sourcePath>
```
→ Lister les fichiers qui implémentent cette interface (filtrer les classes abstraites — `abstract class`)

### 5c. Lister les classes abstraites du projet

```bash
grep -rn "^public abstract class \|^abstract class " --include="*.java" -l <sourcePath>
```

Pour chaque classe abstraite :
```bash
grep -rn "extends <NomClasseAbstraite>" --include="*.java" <sourcePath>
```
→ Lister les sous-classes concrètes du projet

### 5d. Construire le graphe

Suivre le schéma `type-hierarchy.json` de `references/templates.md`.
Ne garder que les interfaces/classes abstraites ayant au moins un implémenteur/sous-classe dans le projet.
Ignorer les interfaces purement techniques sans implémenteur (ex: `Serializable`, `Comparable`).

---

## Pass 6 : Extraction de la configuration (`config-env.json`)

Si `config-env` absent de la liste `graphs` → sauter cette passe.

### 6a. Trouver les usages @Value dans les sources Java

```bash
grep -rn "@Value" --include="*.java" <sourcePath>
```

Pour chaque occurrence :
- Extraire la clé de propriété depuis `@Value("${<clé>}")` ou `@Value("${<clé>:<défaut>}")`
- Extraire le nom de la classe et du champ
- Déduire le module depuis le package

### 6b. Trouver les fichiers de configuration

```bash
find . -name "application.yml" -o -name "application.properties" -o -name "application-*.yml" -o -name "application-*.properties" | head -10
```

Pour chaque fichier trouvé :
- Lire le fichier
- Extraire les clés définies (ex: `app.security.jwt.secret: ...`)
- Pour les `.yml` : clés hiérarchiques → reconstituer en notation pointée (ex: `app.security.jwt.secret`)
- Pour les `.properties` : déjà en notation pointée

### 6c. Croiser usages et définitions

Pour chaque clé extraite des `@Value` :
- Vérifier si elle est définie dans l'un des fichiers de config → noter `source`
- Si non trouvée dans les configs → noter `source: "non-définie"` et ajouter un warning

Construire le tableau `properties[]` selon le schéma `config-env.json` de `references/templates.md`.

---

## Pass 7 : Écriture des artifacts

### Récupérer le lastCommit global

```bash
git log -1 --format=%H -- <sourcePath>
```

### Écrire les fichiers JSON

Pour chaque graphe demandé, suivre le schéma dans `references/templates.md` et écrire :

- `.sdd/graph/endpoint-flow.json` (si `endpoint-flow` dans `graphs`)
- `.sdd/graph/entity-model.json` (si `entity-model` dans `graphs`)
- `.sdd/graph/service-call.json` (si `service-call` dans `graphs`)
- `.sdd/graph/module-dep.json` (si `module-dep` dans `graphs`)
- `.sdd/graph/type-hierarchy.json` (si `type-hierarchy` dans `graphs`)
- `.sdd/graph/config-env.json` (si `config-env` dans `graphs`)

Créer le répertoire `.sdd/graph/` si nécessaire :
```bash
mkdir -p .sdd/graph
```

### Retourner les métadonnées

```
lastCommit: <hash>
graphs:
  endpoint-flow: <N> endpoints
  entity-model: <N> entités
  service-call: <N> nœuds, <M> edges
  module-dep: <N> modules
  type-hierarchy: <N> interfaces, <M> classes abstraites
  config-env: <N> propriétés
warnings:
  - <tout cas ambigu ou non résolu>
```

---

## Cas limites et conventions

| Situation | Comportement |
|-----------|-------------|
| Classe `@Service` sans constructeur public ni `@Autowired` | Nœud créé, aucun edge |
| Même type détecté par @Autowired ET constructeur | Un seul edge, `injectionType: "constructor"` |
| Constructeur avec @Autowired ET paramètres multi-lignes | Lire jusqu'au `)` ou `{` pour obtenir tous les params |
| Interface avec un seul implémenteur | Inclure dans type-hierarchy (valeur élevée pour DI) |
| Clé @Value non définie dans application.yml | Inclure avec `source: "non-définie"`, ajouter warning |
| Path `@RequestMapping` avec variable (`${app.base-path}`) | Conserver la valeur littérale, noter en warning |
| Entité sans `@Table` | Utiliser le nom de classe en snake_case comme table |
| Repository générique sans entité détectable | Créer le nœud repository sans entité associée |
| Import vers une lib externe (non-`rootPackage`) | Ignorer pour `module-dep` |
| Plusieurs `@RestController` dans un même package | Agréger sous le même module |
| `@RequestMapping` au niveau classe + méthode | Concaténer les paths (ex: `/api/v1` + `/{id}`) |
