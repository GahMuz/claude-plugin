---
name: graph-build
description: "This skill should be used when the user invokes '/graph-build' to build or refresh structural code graphs (endpoint flows, entity models, service call graphs, module dependencies). Supports Java Spring Boot. Dispatches one agent per module in parallel. Produces JSON artifacts in .sdd/graph/."
argument-hint: "[--java] [--all] [--incremental] [--module <nom>] [--graphs endpoint-flow,entity-model,service-call,module-dep,type-hierarchy,config-env]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# Construction des graphes structurels

> Plugin : sdd-graph v1.0.0

Pré-calculer les graphes du codebase Java Spring Boot. Pour les codebases volumineux, dispatch **un agent par unité de scan en parallèle** — chaque agent écrit ses partiels dans `.sdd/graph/partial/<scanName>/`, le skill assemble les JSON finaux en agrégeant par module logique.

## Répertoire de sortie

```
.sdd/graph/
├── manifest.json
├── index.md
├── endpoint-flow.json       ← assemblé depuis les partiels
├── entity-model.json        ← assemblé depuis les partiels
├── service-call.json        ← assemblé depuis les partiels
├── module-dep.json          ← assemblé depuis les partiels
└── partial/
    ├── <scanName-a>/
    │   ├── endpoints.json
    │   ├── entities.json
    │   ├── service-nodes.json
    │   ├── service-edges.json
    │   └── module-imports.json
    └── <scanName-b>/
        └── ...
```

## Step 0 : Parser les arguments

- `--java` → BUILD_JAVA (modules : tous)
- `--all` → BUILD_JAVA
- `--module <nom>` → BUILD_MODULE (un seul module ciblé)
- `--incremental` → BUILD_INCREMENTAL (uniquement les modules stale)
- `--graphs <liste>` → limiter aux graphes spécifiés (P2 : `type-hierarchy`, `config-env`)
- aucun argument → détecter les stacks, afficher les modules disponibles, demander confirmation

**Graphes P1** (construits par défaut) : `endpoint-flow`, `entity-model`, `service-call`, `module-dep`
**Graphes P2** (opt-in via `--graphs`) : `type-hierarchy`, `config-env`

## Step 1 : Détecter le stack Java et les modules

### 1a. Confirmer la présence Java

```bash
find . -maxdepth 4 -name "pom.xml" | head -10
find . -maxdepth 4 -name "build.gradle" -o -name "build.gradle.kts" | head -10
```

Si rien trouvé : "Aucun projet Java détecté."

Identifier `sourcePath` :
- Maven mono/multi : `src/main/java`
- Gradle : vérifier `sourceSets`, sinon supposer `src/main/java`

### 1b. Détecter le package racine

```bash
grep -rn "^package " --include="*.java" <sourcePath> | head -50
```

Identifier le préfixe commun (ex: `com.acme`). Ce sera `rootPackage`.

### 1c. Détecter les modules

```bash
find <sourcePath> -mindepth 3 -maxdepth 3 -type d | sort
```

Les répertoires de premier niveau sous le package racine = modules.
Convertir le chemin en nom de module (dernier segment du répertoire).

Exemple : `src/main/java/com/acme/user` → module `user`, package `com.acme.user`

Si `--module <nom>` : filtrer pour ne garder que ce module. Erreur si non trouvé.

Afficher : "Modules détectés : user, order, payment, notification, shared (<N> total)"

### 1d. Mesurer la taille des modules et décider du découpage

Seuil : lire `graph.moduleThreshold` dans `.sdd/config.json` (défaut : **50**).

Pour chaque module, compter les fichiers Java avec annotations clés :
```bash
grep -rn "@Entity\|@Service\|@RestController\|@Controller\|@Repository" --include="*.java" -l <modulePath> | wc -l
```

Si le compte dépasse le seuil → **découper par sous-package** :
```bash
find <modulePath> -mindepth 1 -maxdepth 1 -type d | sort
```

Chaque sous-répertoire direct = un sous-module de scanning.
Nommage : `<module>-<souspackage>` (ex: `core-user`, `core-order`).
`outputPath` : `.sdd/graph/partial/<module>-<souspackage>/`

Si aucun sous-répertoire (module plat) → dispatcher quand même un seul agent, noter en warning que le module est volumineux.

Résultat : une liste d'**unités de scan**, chacune avec :
- `scanName` : `<module>` ou `<module>-<souspackage>`
- `moduleName` : `<module>` (pour le merge — reste le module logique)
- `scanPath` : chemin effectivement scanné
- `outputPath` : `.sdd/graph/partial/<scanName>/`

### 1e. Évaluer la fraîcheur (mode --incremental)

Pour chaque unité de scan, vérifier si ses partiels sont à jour :

```bash
git log <lastCommit>..HEAD -- <scanPath> --oneline
```

Si output non vide → unité stale → à reconstruire.
En mode `--java` ou `--module` : ignorer la fraîcheur, toujours reconstruire.

### 1f. Vérifier l'intégrité des partiels existants

Appliquer à toutes les unités **non déjà marquées stale** (fraîcheur OK mais données potentiellement incomplètes).
Sauter en mode `--java` ou `--module` (rebuild total de toute façon).

Pour chaque unité avec des partiels existants, comparer le nombre d'objets JSON vs le nombre de fichiers annotés dans le code :

**Entités** (si `entity-model` dans `graphs`) :
```bash
grep -rn "@Entity" --include="*.java" -l <scanPath> | wc -l
```
Lire `.sdd/graph/partial/<scanName>/entities.json` → compter `entities[]`.
Si `entities[].length < annotatedFileCount` → marquer stale, raison : `"entities incomplètes (<N> JSON / <M> fichiers)"`

**Services + Repositories** (si `service-call` dans `graphs`) :
```bash
grep -rn "@Service\|@Repository\|extends JpaRepository\|extends CrudRepository" --include="*.java" -l <scanPath> | wc -l
```
Lire `.sdd/graph/partial/<scanName>/service-nodes.json` → compter `nodes[]`.
Si `nodes[].length < annotatedFileCount` → marquer stale, raison : `"service-nodes incomplets (<N> JSON / <M> fichiers)"`

**Controllers** (si `endpoint-flow` dans `graphs`) :
```bash
grep -rn "@RestController\|@Controller" --include="*.java" -l <scanPath> | wc -l
```
Lire `.sdd/graph/partial/<scanName>/endpoints.json` → compter les `module` distincts (proxy de fichiers traités).
Si le fichier endpoints.json est vide (`endpoints: []`) alors que des controllers existent → marquer stale.

Afficher un résumé des unités détectées incomplètes :
```
Intégrité vérifiée — 2 unités incomplètes détectées :
  core-domain : entities incomplètes (1 JSON / 14 fichiers)
  user        : service-nodes incomplets (0 JSON / 8 fichiers)
→ Ces unités seront reconstruites même sans changement git.
```

## Step 2 : Lire le manifest existant

Lire `.sdd/graph/manifest.json` si existant, sinon créer un manifest vide.

## Step 3 : Dispatch parallèle — un agent par unité de scan

Pour chaque unité de scan identifiée en Step 1d, dispatcher en parallèle :

```
Agent({
  description: "Graphe <scanName>",
  subagent_type: "sdd-graph:graph-builder-java",
  model: <config.models.graph-builder ou "haiku">,
  prompt: "
    module: <moduleName>
    scanName: <scanName>
    modulePath: <scanPath>
    rootPackage: <rootPackage>
    outputPath: .sdd/graph/partial/<scanName>/
    graphs: <liste des graphes à construire>
  "
})
```

Attendre que **tous** les agents soient terminés avant de passer à Step 4.

Afficher la progression :
```
Scanning <N> unités en parallèle :
  Modules normaux : user, order, payment (< seuil)
  Modules découpés : core → core-domain, core-service, core-controller, core-repository
```

## Step 4 : Assembler les JSON finaux depuis les partiels

Lire tous les fichiers partiels générés et assembler les JSON finaux.

Les partiels sont organisés par `scanName`. Plusieurs `scanName` peuvent correspondre au même `moduleName` logique (modules découpés en sous-packages). L'assemblage agrège par `moduleName`.

Construire d'abord la table de correspondance `scanName → moduleName` issue du Step 1d.

### 4a. `endpoint-flow.json`

Pour chaque unité de scan, lire `.sdd/graph/partial/<scanName>/endpoints.json`.
Concaténer tous les tableaux `endpoints[]` (toutes unités confondues).
Renuméroter les `id` : `ep_001`, `ep_002`, ... (séquentiel global).
Écrire `.sdd/graph/endpoint-flow.json`.

### 4b. `entity-model.json`

Pour chaque unité de scan, lire `.sdd/graph/partial/<scanName>/entities.json`.
Concaténer tous les tableaux `entities[]`.
Écrire `.sdd/graph/entity-model.json`.

### 4c. `service-call.json`

Pour chaque unité de scan :
- Lire `partial/<scanName>/service-nodes.json` → ajouter à `nodes[]`
- Lire `partial/<scanName>/service-edges.json` → ajouter à `edges[]`

Dédupliquer les nœuds par `id` (un service référencé par plusieurs unités de scan n'apparaît qu'une fois).
Écrire `.sdd/graph/service-call.json`.

### 4d. `module-dep.json`

Pour chaque unité de scan, lire `.sdd/graph/partial/<scanName>/module-imports.json`.
Structure partielle :
```json
{ "module": "user", "importsFrom": { "notification": 3, "shared": 12 } }
```

Le champ `module` dans le partiel est le `moduleName` logique (pas le `scanName`).

Agréger par `moduleName` logique :
- Si plusieurs unités de scan partagent le même `moduleName` (ex: `core-domain` et `core-service` → `core`), fusionner leurs `importsFrom` en additionnant les poids.

Assembler :
- `modules[]` : un objet par **module logique** (dédupliqué) avec `id`, `name`, `path`, `package`
- `couplingMatrix` : agréger tous les `importsFrom` fusionnés
- Calculer `dependsOn` : modules où le poids > 0
- Calculer `usedBy` : inverser les `dependsOn` de tous les modules

Écrire `.sdd/graph/module-dep.json`.

### 4e. Graphes P2 (si demandés)

Même logique pour `type-hierarchy` et `config-env` :
- `partial/<scanName>/type-nodes.json` → assembler `type-hierarchy.json`
- `partial/<scanName>/config-usages.json` → assembler `config-env.json` (dédupliquer par clé)

## Step 5 : Mettre à jour le manifest

Récupérer le lastCommit global :
```bash
git log -1 --format=%H -- <sourcePath>
```

Mettre à jour `manifest.json` :
- `updatedAt`, `stacks`, `sourcePaths`
- Pour chaque graphe assemblé : `builtAt`, `lastCommit`, `entryCount`, `status: "fresh"`

Générer `.sdd/graph/index.md` (template dans `references/templates.md`).

## Step 6 : Reporter

```
Graphes construits — <N> unités de scan (<M> modules logiques)

- endpoint-flow : <N> endpoints
- entity-model  : <N> entités
- service-call  : <N> nœuds, <M> edges
- module-dep    : <N> modules

Répertoire : .sdd/graph/
Modules : <liste>
Utilisation : /graph-query <question> ou injection automatique via sdd-spec.
```

Si des warnings ont été retournés par des agents, les afficher groupés par module.

## Commandes disponibles

| Commande | Description |
|----------|-------------|
| `/graph-build --java` | Scanner tous les modules Java en parallèle |
| `/graph-build --module user` | Scanner uniquement le module `user` |
| `/graph-build --incremental` | Reconstruire uniquement les modules modifiés |
| `/graph-build --graphs type-hierarchy,config-env` | Construire les graphes P2 |
| `/graph-status` | Afficher l'état du manifest |
| `/graph-query <question>` | Interroger les graphes |
