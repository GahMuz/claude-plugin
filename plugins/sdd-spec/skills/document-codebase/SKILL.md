---
name: document-codebase
description: "This skill should be used when the user invokes '/document-codebase' to generate cached module documentation, reduce token consumption on large codebases, create architecture summaries, or pre-generate module docs before implementation."
argument-hint: "[module-name | --all]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# Documentation cache du codebase

Generate cached module summaries to reduce token consumption by 80-90% on repeat tasks. All output in French.

## Purpose

For large codebases (1000+ files), exploring files on every task wastes tokens. Pre-generate concise module docs that Claude reads instead of exploring raw files.

## Process

### Step 1: Identify Target
- Argument = module name → document that module
- `--all` → document all detected modules
- No argument → ask: "Quel module documenter ? Ou `--all` pour tout le projet."

### Step 2: Detect Project Structure
Scan the codebase to identify modules/packages/domains:
- **Node/TS**: top-level `src/` directories, `packages/` workspace members
- **PHP**: `src/` namespace directories, Symfony bundles
- **Java**: Maven modules (`pom.xml`), Gradle subprojects, package directories

### Step 3: Generate Module Summary
For each module, generate a concise summary (200-300 lines max):

```markdown
# Module : <nom>

> Généré le : <ISO-8601>
> Fichiers : <count>

## Entités / Modèles

| Nom | Fichier | Champs clés |
|-----|---------|-------------|
| User | src/entities/User.ts | id, email, name, createdAt |

## Services

| Nom | Fichier | Méthodes principales |
|-----|---------|---------------------|
| UserService | src/services/UserService.ts | create, getById, update, delete |

## Points d'entrée (API / Routes)

| Route | Méthode | Fichier | Description |
|-------|---------|---------|-------------|
| /api/users | GET | src/controllers/UserController.ts | Liste des utilisateurs |

## Dépendances inter-modules

- Dépend de : <modules>
- Utilisé par : <modules>

## Notes

- <patterns spécifiques, conventions locales>
```

### Step 4: Save Documentation
Save to `.specs/docs/module-<name>.md`.
Create `.specs/docs/` directory if it doesn't exist.

For `--all`, also generate `.specs/docs/architecture-overview.md`:
```markdown
# Vue d'ensemble de l'architecture

> Généré le : <ISO-8601>

## Modules

| Module | Fichiers | Entités | Services | Routes |
|--------|----------|---------|----------|--------|
| <name> | <count> | <count> | <count> | <count> |

## Graphe de dépendances

<ASCII diagram of module dependencies>

## Taille par module

<ranked list, flag modules > 500 files as LARGE>
```

### Step 5: Report
"Documentation générée :
- Module(s) : <list>
- Fichiers : `.specs/docs/`
- Tokens économisés : ~80-90% sur les tâches futures de ces modules.

Les agents liront ces docs au lieu d'explorer les fichiers bruts."

## Usage by Other Skills

During implementation, the orchestrator and task-implementer should:
1. Check if `.specs/docs/module-<name>.md` exists for the target module
2. If yes: read the cached doc instead of exploring the module's files
3. If no: explore normally (and suggest running `/document-codebase` afterward)
