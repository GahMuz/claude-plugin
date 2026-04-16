---
name: graph-build
description: "This skill should be used when the user invokes '/graph-build' to build or refresh structural code graphs (endpoint flows, entity models, service call graph, module dependencies). Supports Java Spring Boot. Dispatches one agent per module in parallel. Produces JSON artifacts in .sdd/graph/."
argument-hint: "[--java] [--all] [--incremental] [--module <nom>] [--graphs endpoint-flow,entity-model,service-call,module-dep,type-hierarchy,config-env]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# Construction des graphes structurels

> Plugin : sdd-graph v1.0.0

Pré-calculer les graphes du codebase Java Spring Boot. Pour les codebases volumineux, dispatch **un agent par module en parallèle** — chaque agent écrit ses partiels dans `.sdd/graph/partial/<module>/`, le skill assemble les JSON finaux.

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
    ├── <module-a>/
    │   ├── endpoints.json
    │   ├── entities.json
    │   ├── service-nodes.json
    │   ├── service-edges.json
    │   └── module-imports.json
    └── <module-b>/
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

### 1d. Évaluer la fraîcheur (mode --incremental)

Pour chaque module, vérifier si ses partiels sont à jour :

```bash
git log <lastCommit>..HEAD -- <modulePath> --oneline
```

Si output non vide → module stale → à reconstruire.
En mode `--java` ou `--module` : ignorer la fraîcheur, toujours reconstruire.

## Step 2 : Lire le manifest existant

Lire `.sdd/graph/manifest.json` si existant, sinon créer un manifest vide.

## Step 3 : Dispatch parallèle — un agent par module

Pour chaque module à construire, dispatcher en parallèle :

```
Agent({
  description: "Graphe module <nom>",
  subagent_type: "sdd-graph:graph-builder-java",
  model: <config.models.graph-builder ou "haiku">,
  prompt: "
    module: <nom>
    modulePath: <sourcePath>/<chemin/vers/module>
    rootPackage: <com.acme>
    outputPath: .sdd/graph/partial/<nom>/
    graphs: <liste des graphes à construire>

    Lire references/scan-java.md pour le protocole de scanning.
    Lire references/templates.md pour les schémas JSON des partiels.
  "
})
```

Attendre que **tous** les agents soient terminés avant de passer à Step 4.

Afficher la progression : "Scanning <N> modules en parallèle : user, order, payment..."

## Step 4 : Assembler les JSON finaux depuis les partiels

Lire tous les fichiers partiels générés et assembler les JSON finaux.

### 4a. `endpoint-flow.json`

Pour chaque module, lire `.sdd/graph/partial/<module>/endpoints.json`.
Concaténer tous les tableaux `endpoints[]`.
Renuméroter les `id` : `ep_001`, `ep_002`, ... (séquentiel global).
Écrire `.sdd/graph/endpoint-flow.json`.

### 4b. `entity-model.json`

Pour chaque module, lire `.sdd/graph/partial/<module>/entities.json`.
Concaténer tous les tableaux `entities[]`.
Écrire `.sdd/graph/entity-model.json`.

### 4c. `service-call.json`

Pour chaque module :
- Lire `partial/<module>/service-nodes.json` → ajouter à `nodes[]`
- Lire `partial/<module>/service-edges.json` → ajouter à `edges[]`

Dédupliquer les nœuds par `id` (un service référencé par plusieurs modules n'apparaît qu'une fois).
Écrire `.sdd/graph/service-call.json`.

### 4d. `module-dep.json`

Pour chaque module, lire `.sdd/graph/partial/<module>/module-imports.json`.
Structure partielle :
```json
{ "module": "user", "importsFrom": { "notification": 3, "shared": 12 } }
```

Assembler :
- `modules[]` : un objet par module avec `id`, `name`, `path`, `package`
- `couplingMatrix` : agréger tous les `importsFrom`
- Calculer `dependsOn` : modules où le poids > 0
- Calculer `usedBy` : inverser les `dependsOn` de tous les modules

Écrire `.sdd/graph/module-dep.json`.

### 4e. Graphes P2 (si demandés)

Même logique pour `type-hierarchy` et `config-env` :
- `partial/<module>/type-nodes.json` → assembler `type-hierarchy.json`
- `partial/<module>/config-usages.json` → assembler `config-env.json` (dédupliquer par clé)

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
Graphes construits — <N> modules scannés en parallèle

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
