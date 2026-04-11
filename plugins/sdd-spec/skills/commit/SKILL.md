---
name: commit
description: "This skill should be used when the user invokes '/commit' to generate a structured, purpose-driven commit message with risk assessment and breaking changes. Analyses staged/unstaged changes, categorizes files, and produces a French commit message following conventional commit format."
argument-hint: "[ticket ID, feature name, or notes]"
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# Smart Commit Message Generator

Generate a structured, purpose-driven commit message with risk assessment and breaking changes.

**Additional context**: $ARGUMENTS (optional: ticket ID, feature name, or notes)

---

## Step 1: GATHER CHANGES

Run these git commands:
- `git status` — modified, added, deleted files
- `git diff --staged` — staged changes (if any)
- `git diff` — unstaged changes
- `git diff --stat` — summary per file
- `git log --oneline -5` — recent commits for style context

If nothing is staged, show what will be committed and ask confirmation.

## Step 2: ANALYZE CHANGES

Categorize each changed file:

| Category | Files | Impact |
|----------|-------|--------|
| Entity (`**/entity/*.java`) | ... | Schema change |
| Liquibase (`**/changelog/*.xml`) | ... | Migration required |
| Service (`**/service/**/*.java`) | ... | Business logic |
| Controller (`**/rest/*.java`) | ... | API surface |
| DTO (`**/dto/*.java`) | ... | Contract change |
| Test (`**/test/**/*.java`) | ... | Quality |
| Config (`*.yml`, `*.xml`, `pom.xml`) | ... | Infrastructure |

Assess:
- **Purpose**: new feature, bug fix, refactor, chore, schema change, security fix
- **Scope**: which module(s) are affected
- **Breaking changes**: do any changes modify public APIs, entity schemas, or existing behavior?
- **Risk level**:
  - LOW: tests only, docs, config
  - MEDIUM: new code, no schema change
  - HIGH: entity changes, Liquibase, security/@PreAuthorize changes

## Step 3: GENERATE COMMIT MESSAGE

**Langue** : Le message de commit est rédigé en français (sauf le type et le scope qui restent en anglais).
**IMPORTANT** : Ne JAMAIS ajouter de mention Co-Authored-By, Claude, Anthropic, assistant ou IA dans le message de commit.

Format :
```
{type}({scope}): {résumé concis — impératif, < 72 chars}

{1-3 phrases expliquant POURQUOI ce changement a été fait, pas CE QUI a changé}

Changements :
- {changement significatif 1}
- {changement significatif 2}
- {changement significatif 3 si nécessaire}

Ruptures :
- {description — ou "Aucune"}

Risque : {LOW|MEDIUM|HIGH} — {justification en 1 ligne}
```

### Type values
| Type | When to use |
|------|-------------|
| feat | New feature or capability |
| fix | Bug fix |
| refactor | Code restructuring without behavior change |
| schema | Entity + Liquibase migration |
| security | Tenant isolation, @PreAuthorize, auth changes |
| test | Test additions/modifications only |
| chore | Build, config, dependency changes |
| docs | Documentation only |

### Scope values
Module short name: `account`, `member`, `organization`, `global`, `base`, `common`, `auth`, `liquibase`.
Cross-module: `multi` or list 2-3 most important.

### Règles
- Première ligne < 72 caractères
- Mode impératif : "ajouter", "corriger", "mettre à jour"
- Liste des changements : éléments significatifs uniquement
- Section Ruptures : JAMAIS omise — écrire "Aucune" explicitement
- Risque : schema = HIGH, nouveaux endpoints = MEDIUM, tests seuls = LOW, sécurité = HIGH
- **JAMAIS** de Co-Authored-By, Claude, Anthropic, assistant, IA dans le message

## Step 4: PRESENT AND CONFIRM

Présenter le message de commit. Demander : "On commit ? (oui / modifier / annuler)"

If "oui":
- Stage relevant files (exclude build artifacts, .env)
- Commit with the message
- Show commit hash

## Step 5: RAPPELS POST-COMMIT
- si java
  - Si fichiers entity modifiés : "Vérifier que le changelog Liquibase est inclus"
  - Si fichiers controller modifiés : "Vérifier la couverture @PreAuthorize"
  - Si risque HIGH : "Envisager de lancer `/review` avant de pusher"
