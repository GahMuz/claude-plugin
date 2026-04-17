---
name: sdd-init
description: "This skill should be used when the user invokes '/sdd-init' to initialize a project for spec-driven development, set up '.sdd/' directory, configure project languages, check LSP servers, or scaffold rules-references skill."
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
- Orchestrateur (coordination des vagues) : `sonnet`
- Implémenteur de tâches (écriture de code TDD) : `sonnet`
- Réviseur de code (quality gate) : `opus`
- Analyse approfondie (investigation architecture) : `opus`
- Vérificateur de plan (couverture TDD) : `haiku`
- Validateur de design (SOLID + contrats) : `sonnet`
- Auditeur spec/code (cohérence finale) : `sonnet`
- Générateur de documentation : `haiku`
- Analyse qualité du code : `sonnet`
- Analyse architecturale : `opus`
- Analyse conformité RGPD/DORA : `sonnet`

"Garder les valeurs par défaut ? (oui/non)"
If non, let user customize each.

### Step 6: Create .sdd/
```bash
mkdir -p .sdd/specs .sdd/docs .sdd/analyses .sdd/local .sdd/decisions
```

Initialize `.sdd/specs/registry.md`:
```markdown
# Registre des specs

| Identifiant | Titre | Période | Statut | Requirement | Design | Plan |
|-------------|-------|---------|--------|-------------|--------|------|
```

Initialize `.sdd/decisions/registry.md`:
```markdown
# Registre des ADRs

| Numéro | Identifiant | Titre | Période | Statut |
|--------|-------------|-------|---------|--------|
```

Write `.sdd/config.json`:
```json
{
  "schemaVersion": "<version cible du plugin — fichier migrations/v*.md le plus élevé>",
  "languages": ["<selected>"],
  "pipelineReviews": true,
  "parallelTaskLimit": 0,
  "models": {
    "orchestrator": "sonnet",
    "task-implementer": "sonnet",
    "code-reviewer": "opus",
    "deep-dive": "opus",
    "planner": "haiku",
    "design-validator": "sonnet",
    "spec-reviewer": "sonnet",
    "doc-generator": "haiku",
    "analyse-quality": "sonnet",
    "analyse-architecture": "opus",
    "analyse-compliance": "sonnet",
    "graph-builder-java": "haiku",
    "graph-query": "haiku"
  },
  "graph": {
    "enabled": false,
    "stacks": [],
    "sourcePaths": {},
    "stalenessThresholdDays": 7,
    "moduleThreshold": 25,
    "serviceThreshold": 30
  },
  "createdAt": "<ISO-8601>"
}
```

Note : `graph.enabled` reste `false` jusqu'à ce que le plugin sdd-graph soit installé et configuré (voir Step 11).

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

### Step 10: Proposer sdd-graph (si Java détecté)

Si `java` est dans les langages sélectionnés ET si le plugin `sdd-graph` est installé (vérifier avec `Glob("**/.claude-plugin/plugin.json")` → chercher `"name": "sdd-graph"`) :

Proposer la configuration du graphe :
```
🔍 Le plugin sdd-graph est disponible.
Il pré-calcule les graphes de dépendances Java (endpoints, entités, services, modules)
pour réduire la consommation de tokens et activer l'analyse d'impact dans les specs.

Configurer maintenant ? (recommandé pour les projets Spring Boot)
```

Si oui :
- Demander le chemin des sources Java (détecter automatiquement `src/main/java` si présent, sinon demander)
- Mettre à jour `config.json` :
  ```json
  "graph": {
    "enabled": true,
    "stacks": ["java"],
    "sourcePaths": { "java": "<chemin détecté>" },
    "stalenessThresholdDays": 7
  }
  ```
- Proposer de construire les graphes immédiatement :
  ```
  Lancer /graph-build --java maintenant pour indexer le codebase ?
  (Recommandé avant le premier /spec new — réduit les tokens de 60-80% sur les specs Java)
  ```

Si non ou si plugin absent : laisser `graph.enabled: false`, ne pas insister.

### Step 11: Report

```
Projet initialisé pour le développement spec-driven :
- Langages : <liste>
- Statut LSP : <statut par langage>
- Modèles : orchestrateur=<model>, implémenteur=<model>, réviseur=<model>, investigation=<model>
- Graphe sdd-graph : <activé avec sourcePath | non configuré>
- Configuration : .sdd/config.json
- Règles projet : .claude/skills/rules-references/

Prochaine étape : personnalisez les règles dans .claude/skills/rules-references/references/rules.md, puis lancez /spec new <titre>.
```

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/spec new <titre>` | Démarrer le premier spec |
| `/sdd-status` | Vue d'ensemble de tous les specs |
