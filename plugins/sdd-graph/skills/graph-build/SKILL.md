---
name: graph-build
description: "This skill should be used when the user invokes '/graph-build' to build or refresh structural code graphs (endpoint flows, entity models, service call graphs, module dependencies). Supports Java Spring Boot. Dispatches one agent per module in parallel. Produces JSON artifacts in .sdd/graph/."
argument-hint: "[--java] [--all] [--incremental] [--module <nom>] [--graphs endpoint-flow,entity-model,service-call,module-dep,type-hierarchy,config-env]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# Construction des graphes structurels

> Plugin : sdd-graph v1.0.0

Pré-calculer les graphes du codebase Java Spring Boot. Pour les codebases volumineux, dispatch **un agent par unité de scan en parallèle** — chaque agent écrit ses partiels dans `.sdd/graph/partial/<scanName>/`, le skill assemble les JSON finaux en agrégeant par module logique.

Les modules avec beaucoup de services reçoivent un **dispatch séparé en batches** pour Pass 3 (service-call), évitant la saturation de contexte haiku.

## Répertoire de sortie

```
.sdd/graph/
├── manifest.json
├── index.md
├── endpoint-flow.json
├── entity-model.json
├── service-call.json
├── module-dep.json
└── partial/
    ├── <scanName>/
    │   ├── endpoints.json
    │   ├── entities.json
    │   ├── service-nodes.json        ← direct ou absent si batché
    │   ├── service-edges.json        ← direct ou absent si batché
    │   ├── module-imports.json
    │   └── services-batch-001/       ← présent si Pass 3 a été batchée
    │       ├── service-nodes.json
    │       └── service-edges.json
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

Lire dans `.sdd/config.json` :
- `graph.moduleThreshold` (défaut : **25**) — seuil pour découper en sous-packages
- `graph.serviceThreshold` (défaut : **30**) — seuil pour batcher Pass 3 séparément

Pour chaque module, compter les fichiers Java avec annotations clés :
```bash
grep -rn "@Entity\|@Service\|@RestController\|@Controller\|@Repository" --include="*.java" -l <modulePath> | wc -l
```

Si le compte dépasse `moduleThreshold` → **découper par sous-package** :
```bash
find <modulePath> -mindepth 1 -maxdepth 1 -type d | sort
```

Chaque sous-répertoire direct = un sous-module de scanning.
Nommage : `<module>-<souspackage>` (ex: `core-user`, `core-order`).

Si aucun sous-répertoire (module plat) → un seul agent, noter en warning.

Résultat : une liste d'**unités de scan**, chacune avec :
- `scanName` : `<module>` ou `<module>-<souspackage>`
- `moduleName` : `<module>` (pour le merge — reste le module logique)
- `scanPath` : chemin effectivement scanné
- `outputPath` : `.sdd/graph/partial/<scanName>/`

Pour chaque unité, compter les fichiers service/repository :
```bash
grep -rn "@Service\|@Repository\|extends JpaRepository\|extends CrudRepository\|extends PagingAndSortingRepository" --include="*.java" -l <scanPath> | wc -l
```

Si `serviceFileCount > serviceThreshold` → marquer `needsServiceBatch: true` et stocker la liste des fichiers service.

### 1e. Évaluer la fraîcheur (mode --incremental)

Pour chaque unité de scan, vérifier si ses partiels sont à jour :

```bash
git log <lastCommit>..HEAD -- <scanPath> --oneline
```

Si output non vide → unité stale → à reconstruire.
En mode `--java` ou `--module` : ignorer la fraîcheur, toujours reconstruire.

### 1f. Vérifier l'intégrité des partiels existants

Appliquer à toutes les unités **non déjà marquées stale**.
Sauter en mode `--java` ou `--module` (rebuild total de toute façon).

Pour chaque unité avec des partiels existants, comparer JSON vs fichiers annotés :

**Entités** (si `entity-model` dans `graphs`) :
```bash
grep -rn "@Entity" --include="*.java" -l <scanPath> | wc -l
```
Lire `partial/<scanName>/entities.json` → compter `entities[]`.
Si `entities[].length < annotatedFileCount` → marquer stale.

**Services + Repositories** (si `service-call` dans `graphs`) :
```bash
grep -rn "@Service\|@Repository\|extends JpaRepository\|extends CrudRepository" --include="*.java" -l <scanPath> | wc -l
```
Compter les nœuds service dans `partial/<scanName>/service-nodes.json` ET dans tous les `partial/<scanName>/services-batch-*/service-nodes.json`.
Si total `nodes[].length < annotatedFileCount` → marquer stale.

**Controllers** (si `endpoint-flow` dans `graphs`) :
```bash
grep -rn "@RestController\|@Controller" --include="*.java" -l <scanPath> | wc -l
```
Si `endpoints.json` est vide (`endpoints: []`) alors que des controllers existent → marquer stale.

Afficher un résumé :
```
Intégrité vérifiée — 2 unités incomplètes détectées :
  core-domain : entities incomplètes (1 JSON / 14 fichiers)
  user        : service-nodes incomplets (0 JSON / 8 fichiers)
→ Ces unités seront reconstruites.
```

## Step 2 : Lire le manifest existant

Lire `.sdd/graph/manifest.json` si existant, sinon créer un manifest vide.

## Step 3 : Dispatch parallèle

### 3a. Dispatch principal — passes 1, 2, 4 (entities + endpoints + imports)

Pour **toutes** les unités de scan à (re)construire, dispatcher en parallèle :

```
Agent({
  description: "Graphe <scanName> (entities+endpoints+imports)",
  subagent_type: "sdd-graph:graph-builder-java",
  model: <config.models.graph-builder ou "haiku">,
  prompt: "
    module: <moduleName>
    scanName: <scanName>
    modulePath: <scanPath>
    rootPackage: <rootPackage>
    outputPath: .sdd/graph/partial/<scanName>/
    graphs: <liste des graphes sans service-call si needsServiceBatch, sinon liste complète>
  "
})
```

Si `needsServiceBatch: false` → inclure `service-call` dans la liste `graphs` (agent traite tout).
Si `needsServiceBatch: true` → exclure `service-call` (Pass 3 sera traitée séparément en 3b).

### 3b. Dispatch services en batches (unités volumineuses uniquement)

Pour chaque unité avec `needsServiceBatch: true` :

1. Récupérer la liste des fichiers service/repository (collectée en Step 1d).
2. Découper en batches de `serviceThreshold` fichiers : `batch-001`, `batch-002`, ...
3. Dispatcher en parallèle UN AGENT PAR BATCH :

```
Agent({
  description: "Services <scanName> batch-<N>/<total>",
  subagent_type: "sdd-graph:graph-builder-java",
  model: <config.models.graph-builder ou "haiku">,
  prompt: "
    module: <moduleName>
    scanName: <scanName>
    modulePath: <scanPath>
    rootPackage: <rootPackage>
    outputPath: .sdd/graph/partial/<scanName>/services-batch-<N>/
    graphs: service-call
    serviceFiles:
      - <chemin/vers/ServiceA.java>
      - <chemin/vers/ServiceB.java>
      - ...
  "
})
```

Les agents batch tournent EN PARALLÈLE avec les agents du Step 3a.

Afficher la progression :
```
Scanning <N> unités en parallèle :
  Modules normaux   : user, order, payment
  Modules découpés  : core → core-domain, core-service, core-controller
  Batches services  : organization-core → 12 batches × 30 fichiers
```

Attendre que **tous** les agents (3a + 3b) soient terminés avant de passer à Step 4.

## Step 4 : Assembler les JSON finaux depuis les partiels

Les partiels sont organisés par `scanName`. Plusieurs `scanName` peuvent correspondre au même `moduleName` logique. L'assemblage agrège par `moduleName`.

Construire d'abord la table de correspondance `scanName → moduleName` issue du Step 1d.

### 4a. `endpoint-flow.json`

Pour chaque unité de scan, lire `partial/<scanName>/endpoints.json`.
Concaténer tous les `endpoints[]`.
Renuméroter les `id` : `ep_001`, `ep_002`, ... (séquentiel global).
Écrire `.sdd/graph/endpoint-flow.json`.

### 4b. `entity-model.json`

Pour chaque unité de scan, lire `partial/<scanName>/entities.json`.
Concaténer tous les `entities[]`.
Écrire `.sdd/graph/entity-model.json`.

### 4c. `service-call.json`

Pour chaque unité de scan, collecter les nœuds et edges depuis deux sources :

**Source directe** (unités sans batch) :
- `partial/<scanName>/service-nodes.json` → ajouter à `nodes[]`
- `partial/<scanName>/service-edges.json` → ajouter à `edges[]`

**Source batchée** (unités avec `services-batch-*/`) :
```bash
find .sdd/graph/partial/<scanName>/ -name "service-nodes.json" -path "*/services-batch-*"
find .sdd/graph/partial/<scanName>/ -name "service-edges.json" -path "*/services-batch-*"
```
Lire chaque fichier et ajouter à `nodes[]` / `edges[]`.

Dédupliquer les nœuds par `id` (un service référencé dans plusieurs batches n'apparaît qu'une fois).
Écrire `.sdd/graph/service-call.json`.

### 4d. `module-dep.json`

Pour chaque unité de scan, lire `partial/<scanName>/module-imports.json`.
Agréger par `moduleName` logique — fusionner les `importsFrom` en additionnant les poids si plusieurs scan units partagent le même module.

Assembler :
- `modules[]` : un objet par module logique avec `id`, `name`, `path`, `package`
- `couplingMatrix` : agréger tous les `importsFrom`
- Calculer `dependsOn` (poids > 0) et `usedBy` (inverse)

Écrire `.sdd/graph/module-dep.json`.

### 4e. Graphes P2 (si demandés)

- `partial/<scanName>/type-nodes.json` → assembler `type-hierarchy.json`
- `partial/<scanName>/config-usages.json` → assembler `config-env.json` (dédupliquer par clé)

## Step 5 : Mettre à jour le manifest

```bash
git log -1 --format=%H -- <sourcePath>
```

Mettre à jour `manifest.json` :
- `updatedAt`, `stacks`, `sourcePaths`
- Pour chaque graphe assemblé : `builtAt`, `lastCommit`, `entryCount`, `status: "fresh"`

Générer `.sdd/graph/index.md` (template dans `references/templates.md`).

## Step 6 : Reporter

```
Graphes construits — <N> unités de scan (<M> modules logiques, <K> batches services)

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
| `/graph-build --incremental` | Reconstruire uniquement les modules modifiés ou incomplets |
| `/graph-build --graphs type-hierarchy,config-env` | Construire les graphes P2 |
| `/graph-status` | Afficher l'état du manifest |
| `/graph-query <question>` | Interroger les graphes |
