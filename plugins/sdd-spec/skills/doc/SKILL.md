---
name: doc
description: "This skill should be used when the user invokes '/doc' to generate module documentation, analyse code quality, track doc freshness, or reduce token consumption on large codebases. Supports incremental updates via git diff and parallel generation."
argument-hint: "<module> | --all | update | analyse <module> | status"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# Documentation et analyse du codebase

> Version : 1.0.0

Générer de la documentation structurée par module et feature pour réduire la consommation de tokens de 80-90%. Toute sortie en **français**.

## Répertoire de sortie

```
.specs/doc/
├── manifest.json
├── index.md
├── modules/
│   ├── <module>/
│   │   ├── module-<module>.md
│   │   ├── feature-<feature>.md
│   │   ├── analyse-<module>.md
│   │   ├── improvement-<module>.md
│   │   └── missing-rules-<module>.md
```

## Step 0 : Parser les arguments

Extraire la sous-commande :
- `<nom-module>` → GENERATE_MODULE
- `--all` → GENERATE_ALL
- `update` → UPDATE
- `analyse <nom-module>` → ANALYSE
- `status` → STATUS
- aucun argument → demander : "Quelle commande ? `<module>`, `--all`, `update`, `analyse <module>`, ou `status`."

## Détection des modules (étape partagée)

Scanner le codebase pour identifier les modules/packages/domaines :
- **PHP/Symfony** : répertoires namespace sous `src/`, bundles Symfony
- **Node/TS** : répertoires top-level sous `src/`, membres `packages/` workspace
- **Java** : modules Maven (`pom.xml`), sous-projets Gradle, répertoires package

### Détection des features

Au sein de chaque module, identifier les features (sous-domaines fonctionnels) :
- **PHP/Symfony** : sous-répertoires au sein d'un namespace module contenant des classes
- **Node/TS** : sous-répertoires sous le `src/` d'un module
- **Java** : sous-packages sous un module

Heuristique : un répertoire contenant au moins 2 fichiers source constitue une feature.

## Règles de fraîcheur

Un document est **obsolète** quand :
1. `skill_version` du doc != version courante du skill (1.0.0)
2. `generated_at` date de plus de 30 jours
3. `git log <last_commit>..HEAD -- <path>` contient des commits (code modifié)

## Manifest

Fichier : `.specs/doc/manifest.json`
Schema : voir `references/templates.md` section "Schema : manifest.json"

Lire le manifest existant ou en créer un nouveau. Mettre à jour après chaque génération.

## Routage des sous-commandes

### GENERATE_MODULE / GENERATE_ALL
Lire et suivre `references/generate-module.md`.

### UPDATE
Lire et suivre `references/update.md`.

### ANALYSE
Lire et suivre `references/analyse.md`.

### STATUS
Lire et suivre `references/status.md`.

## Commandes disponibles

| Commande | Description |
|----------|-------------|
| `/doc <module>` | Documenter un module (incrémental par défaut) |
| `/doc --all` | Documenter tous les modules |
| `/doc update` | Lister et regénérer les docs obsolètes |
| `/doc analyse <module>` | Analyser anti-patterns, violations, améliorations |
| `/doc status` | Afficher l'état du manifest |

## Utilisation par les autres skills

Pendant l'implémentation, l'orchestrateur et le task-implementer doivent :
1. Vérifier si `.specs/doc/modules/<name>/module-<name>.md` existe pour le module cible
2. Si oui : lire la doc cached au lieu d'explorer les fichiers bruts
3. Si non : explorer normalement et suggérer `/doc <module>` après
