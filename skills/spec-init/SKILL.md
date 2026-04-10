---
name: spec-init
description: "This skill should be used when the user invokes '/spec-init' to initialize a project for spec-driven development, set up '.specs/' directory, configure project languages, check LSP servers, or scaffold rules-references skill."
argument-hint: ""
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

# Project Initialization

All communication with user in French.

## Process

### Step 1: Check Existing Config
Check if `.specs/config.json` exists:
- Exists → show config, ask: "Reconfigurer ou garder la configuration existante ?"
- Missing → proceed

### Step 2: Select Languages
Present options (auto-detect from project files):
- `php` — PHP (detect: `composer.json`)
- `node-typescript` — Node.js / TypeScript (detect: `package.json`)
- `java` — Java (detect: `pom.xml`, `build.gradle`)

"Quels langages utilise ce projet ? (sélectionnez un ou plusieurs)"
Show detected languages as suggestions.

### Step 3: Check LSP Servers
For each selected language, check availability:

**PHP:** Look for `intelephense` or `phpactor`.
**Node/TypeScript:** Look for `typescript-language-server` or `tsserver`.
**Java:** Look for `jdtls` (Eclipse JDT Language Server).

Report: "Statut LSP : PHP ✓, Node ✗ (non configuré), Java ✓"
Offer to help configure missing LSP servers.

### Step 4: Configure Execution
- "Limite de sous-tâches en parallèle ? (0 = illimité)" → default 0
- "Activer le pipeline de revues ? (revoir le lot N pendant l'implémentation du lot N+1)" → default oui

### Step 5: Create .specs/
```bash
mkdir -p .specs
```

Write `.specs/config.json`:
```json
{
  "languages": ["<selected>"],
  "pipelineReviews": true,
  "parallelTaskLimit": 0,
  "createdAt": "<ISO-8601>"
}
```

### Step 6: Update .gitignore
Add `.worktrees/` to `.gitignore` if not present.
Do NOT gitignore `.specs/`.

### Step 7: Scaffold Rules-References Skill
Create skeleton in `.claude/skills/rules-references/`:

Write `.claude/skills/rules-references/SKILL.md`:
```markdown
---
name: Rules References
description: This skill should be used when checking "project rules", "coding conventions", "project standards", or when validating design decisions against project-specific constraints. Lazy-loads project-specific rules.
---

# Règles et conventions du projet

Fichiers de référence dans `references/` :
- **`references/coding-standards.md`** — Style de code, nommage, patterns
- **`references/architecture.md`** — Décisions d'architecture, limites
- **`references/testing.md`** — Conventions de test, couverture requise

Ajouter des fichiers markdown dans `references/` pour enrichir les règles.
```

Create placeholders:
- `references/coding-standards.md` → "# Standards de code\n\nÀ compléter par l'équipe."
- `references/architecture.md` → "# Architecture\n\nÀ compléter par l'équipe."
- `references/testing.md` → "# Tests\n\nÀ compléter par l'équipe."

### Step 8: Report
"Projet initialisé pour le développement spec-driven :
- Langages : <liste>
- Statut LSP : <statut par langage>
- Configuration : `.specs/config.json`
- Template de règles : `.claude/skills/rules-references/`

Prochaine étape : complétez les règles dans `.claude/skills/rules-references/references/`, puis lancez `/spec new <titre>`."
