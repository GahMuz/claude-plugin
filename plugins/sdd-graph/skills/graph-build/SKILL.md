---
name: graph-build
description: "This skill should be used when the user invokes '/graph-build' to build or refresh structural code graphs (endpoint flows, entity models, service call graph, module dependencies). Supports Java Spring Boot. Produces JSON artifacts in .sdd/graph/ for use by sdd-spec agents and /graph-query."
argument-hint: "[--java] [--all] [--incremental] [--graphs endpoint-flow,entity-model,service-call,module-dep,type-hierarchy,config-env]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# Construction des graphes structurels

> Plugin : sdd-graph v1.0.0

Pré-calculer les graphes du codebase Java Spring Boot et les stocker sous `.sdd/graph/`. Ces artifacts réduisent la consommation de tokens et activent l'analyse d'impact dans sdd-spec.

## Répertoire de sortie

```
.sdd/graph/
├── manifest.json
├── index.md
├── endpoint-flow.json
├── entity-model.json
├── service-call.json
└── module-dep.json
```

## Step 0 : Parser les arguments

- `--java` → BUILD_JAVA (graphes P1 par défaut : endpoint-flow, entity-model, service-call, module-dep)
- `--all` → BUILD_JAVA (actuellement seul stack supporté)
- `--incremental` → BUILD_INCREMENTAL (rebuild uniquement les graphes stale)
- `--graphs <liste>` → limiter aux graphes spécifiés (ex: `--graphs type-hierarchy,config-env` pour les graphes P2)
- aucun argument → détecter les stacks disponibles, proposer la commande appropriée

**Graphes P1** (construits par défaut avec `--java`) : `endpoint-flow`, `entity-model`, `service-call`, `module-dep`
**Graphes P2** (opt-in via `--graphs`) : `type-hierarchy`, `config-env`

## Step 1 : Détecter le stack Java

```bash
find . -maxdepth 4 -name "pom.xml" | head -10
find . -maxdepth 4 -name "build.gradle" -o -name "build.gradle.kts" | head -10
```

Si aucun fichier trouvé : "Aucun projet Java (Maven/Gradle) détecté dans ce répertoire."

Identifier la structure :
- **Multi-module Maven** : `pom.xml` racine avec `<modules>` ET des `pom.xml` dans les sous-dossiers
- **Mono-module Maven** : un seul `pom.xml`
- **Gradle** : `build.gradle` ou `build.gradle.kts` avec `settings.gradle`

Identifier `sourcePaths.java` :
- Maven standard : `src/main/java`
- Multi-module : noter les chemins par sous-module
- Gradle : vérifier `sourceSets` dans `build.gradle`, sinon supposer `src/main/java`

## Step 2 : Lire le manifest existant

- Lire `.sdd/graph/manifest.json` si existant
- Sinon : manifest vide (tous les graphes à `null`)

## Step 3 : Évaluer la fraîcheur (mode --incremental)

Pour chaque graphe existant dans le manifest :

```bash
git log <lastCommit>..HEAD -- <sourcePaths.java> --oneline
```

Si output non vide → graphe stale.

Règles d'invalidation ciblée :
- Changements `*.java` avec `@Entity` détectés → invalider `entity-model`, `endpoint-flow`
- Changements `*.java` avec `@Service` → invalider `service-call`, `module-dep`
- Changements `*.java` avec `@RestController`/`@Controller` → invalider `endpoint-flow`
- Si `pluginVersion` du manifest != version actuelle → invalider tous les graphes

En mode `--java` ou `--all` : ignorer la fraîcheur, tout reconstruire.

## Step 4 : Dispatcher graph-builder-java

Construire la liste `graphs` à transmettre selon les arguments :
- Mode `--java` ou `--all` sans `--graphs` → `["endpoint-flow", "entity-model", "service-call", "module-dep"]`
- Mode `--graphs <liste>` → utiliser la liste fournie
- Mode `--incremental` → uniquement les graphes stale identifiés en Step 3

```
Agent({
  description: "Construire les graphes Java",
  subagent_type: "sdd-graph:graph-builder-java",
  model: <config.models.graph-builder ou "haiku" par défaut>,
  prompt: "
    rootPath: <répertoire courant>
    sourcePath: <sourcePaths.java>
    outputPath: .sdd/graph/
    graphs: <liste des graphes à construire>

    Lire references/scan-java.md pour le protocole de scanning.
    Lire references/templates.md pour les schémas JSON cibles.
  "
})
```

Attendre le résultat avant de passer à Step 5.

## Step 5 : Mettre à jour le manifest

Après réception du résultat de l'agent :

1. Mettre à jour chaque graphe construit dans `manifest.graphs` :
   - `builtAt` : timestamp ISO-8601 courant
   - `lastCommit` : hash retourné par l'agent
   - `entryCount` : compte retourné par l'agent
   - `status` : `"fresh"`
2. Mettre à jour `updatedAt`, `stacks`, `sourcePaths`
3. Écrire `.sdd/graph/manifest.json`
4. Générer `.sdd/graph/index.md` (template dans `references/templates.md` section "index.md")

## Step 6 : Reporter

```
Graphes construits :
- endpoint-flow : <N> endpoints
- entity-model  : <N> entités
- service-call  : <N> nœuds, <M> edges
- module-dep    : <N> modules

Répertoire : .sdd/graph/
Utilisation : /graph-query <question> ou injection automatique via sdd-spec.
```

Si des warnings ont été retournés par l'agent, les afficher.

## Commandes disponibles

| Commande | Description |
|----------|-------------|
| `/graph-build --java` | Construire les 4 graphes P1 Java |
| `/graph-build --graphs type-hierarchy,config-env` | Construire les graphes P2 |
| `/graph-build --incremental` | Reconstruire uniquement les graphes obsolètes |
| `/graph-status` | Afficher l'état du manifest |
| `/graph-query <question>` | Interroger les graphes |
