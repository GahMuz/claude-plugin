---
name: spec-init
description: "This skill should be used when the user invokes '/spec-init' to initialize a project for spec-driven development, set up '.sdd/' directory, configure project languages, check LSP servers, or scaffold rules-references skill."
argument-hint: ""
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

# Project Initialization

All communication with user in French.

## Process

### Step 1: Check Existing Config
Check if `.sdd/config.json` exists:
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

### Step 5: Configure Models
Present default model assignments per agent:
- Orchestrateur (coordination, ne code jamais) : `opus`
- Implémenteur de tâches (écriture de code) : `sonnet`
- Réviseur de code (revue qualité) : `sonnet`
- Analyse approfondie (investigation architecture) : `opus`

"Garder les valeurs par défaut ? (oui/non)"
If non, let user customize each.

### Step 6: Create .sdd/
```bash
mkdir -p .sdd/specs .sdd/docs .sdd/local
```

Initialize `.sdd/specs/registry.md`:
```markdown
# Registre des specs

| Identifiant | Titre | Période | Statut | Requirement | Design | Plan |
|-------------|-------|---------|--------|-------------|--------|------|
```

Write `.sdd/config.json`:
```json
{
  "schemaVersion": "<version cible du plugin — fichier migrations/v*.md le plus élevé>",
  "languages": ["<selected>"],
  "pipelineReviews": true,
  "parallelTaskLimit": 0,
  "models": {
    "orchestrator": "opus",
    "task-implementer": "sonnet",
    "code-reviewer": "sonnet",
    "deep-dive": "opus"
  },
  "createdAt": "<ISO-8601>"
}
```

### Step 7: Update .gitignore
Add to `.gitignore` if not present:
- `.worktrees/`
- `.sdd/local/`

Do NOT gitignore `.sdd/` itself — only `.sdd/local/` is excluded from commits.

### Step 8: Scaffold Rules-References Skill
Create skeleton in `.claude/skills/rules-references/`:

Write `.claude/skills/rules-references/SKILL.md`:
```markdown
---
name: Rules References
description: This skill should be used when checking "project rules", "coding conventions", "project standards", "règles projet", or when validating design, implementation, or code review against project-specific constraints. Actively enforced during planning, implementation, and review phases.
---

# Règles et conventions du projet

Ce skill est activement vérifié à chaque étape du workflow spec-driven :
- **Planification** : les règles sont intégrées dans le plan
- **Implémentation** : les agents ne chargent que les fichiers pertinents pour la sous-tâche
- **Revue de code** : le réviseur vérifie chaque règle, violations = CRITIQUE

## Index des références (index vivant — maintenir à jour)

Cet index permet le chargement paresseux : les agents lisent cette liste pour déterminer quel fichier charger selon le contexte de la sous-tâche.

| Fichier | Domaine | Charger quand |
|---------|---------|---------------|
| `references/rules.md` | Transversal | Toujours (règles de base) |

Cet index s'enrichit automatiquement via la rétrospective à la fin de chaque spec.
Exemples de fichiers ajoutés au fil du temps :
- `rules-controller.md` — Règles contrôleurs/routes → charger pour sous-tâches contrôleur
- `rules-service.md` — Règles services → charger pour sous-tâches service
- `rules-entity.md` — Règles entités/modèles → charger pour sous-tâches entité
- `rules-test.md` — Règles tests → charger pour sous-tâches test
- `rules-security.md` — Règles sécurité → charger pour sous-tâches auth/sécurité
```

Write `.claude/skills/rules-references/references/rules.md`:
```markdown
# Règles transversales (vérifiables)

Chaque règle est vérifiable par grep, glob ou revue de code.

## Règles non-négociables

- [ ] Pas de secrets en dur (mots de passe, clés API, tokens)
- [ ] Pas de console.log / var_dump / System.out.println oubliés
- [ ] Imports suivent les conventions du projet
- [ ] Gestion d'erreurs explicite (pas de catch vide)
- [ ] Pas de modification de fichiers générés automatiquement
- [ ] Texte UI dans la langue du projet
- [ ] Pas de dépendances ajoutées sans justification

## Portes de qualité

- [ ] Tests passent
- [ ] Linter passe
- [ ] Typecheck passe (si applicable)
- [ ] Revue de code approuvée par lot
- [ ] Pas de vulnérabilités de sécurité connues

## Contraintes d'architecture

- [ ] Placement des fichiers suit les conventions
- [ ] Séparation des couches respectée
- [ ] Appels API via la couche service

À personnaliser par l'équipe.
```

No placeholder files created — `rules-*.md` domain files are created organically by the retrospective step as the team learns from each spec.

### Step 9: Suggest Guard Skills
Explain the guard skills pattern (in French):
"Les 'guard skills' sont des skills de validation dédiés aux invariants critiques du projet. Exemples :
- `guard-security` — audit de sécurité (authentification, autorisation, injection)
- `guard-data-isolation` — isolation des données (multi-tenant, RGPD)
- `guard-api-contract` — conformité des contrats API

Créez-les dans `.claude/skills/guard-<nom>/SKILL.md` avec `allowed-tools: [Read, Grep, Glob]` (lecture seule).
Le réviseur de code les invoquera automatiquement lors des revues."

Ask: "Voulez-vous créer un guard skill maintenant ? (non par défaut)"

### Step 10: Report

```
Projet initialisé pour le développement spec-driven :
- Langages : <liste>
- Statut LSP : <statut par langage>
- Modèles : orchestrateur=<model>, implémenteur=<model>, réviseur=<model>, investigation=<model>
- Configuration : .sdd/config.json
- Règles projet : .claude/skills/rules-references/

Prochaine étape : personnalisez les règles dans .claude/skills/rules-references/references/rules.md, puis lancez /spec new <titre>.
```

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/spec new <titre>` | Démarrer le premier spec |
| `/spec-status` | Vue d'ensemble de tous les specs |
