# Phase : Implementation

Report all progress in French.

## Process

### Step 1: Read Configuration
From `.sdd/config.json`:
- `parallelTaskLimit`: max concurrent agents (0 = unlimited)
- `pipelineReviews`: overlap reviews with next batch
- `models`: model assignments per agent

### Step 2: Verify Baseline Exists
Check that `.sdd/specs/<spec-path>/baseline-tests.json` exists (captured during worktree phase).
- If missing: capture now (run test suite, save results)
- If exists: read and report "Baseline existante : X tests."
- Append log.md entry: "Phase d'implémentation démarrée."

### Step 3: Dispatch Orchestrator
Delegate all wave execution to the orchestrator agent:

```
Agent({
  description: "Orchestrer l'implémentation de <spec-id>",
  subagent_type: "sdd-spec:spec-orchestrator",
  model: <from config.models.orchestrator, default "opus">,
  prompt: "Spec: <spec-id>
    Plan: .sdd/specs/<spec-path>/plan.md
    Design: .sdd/specs/<spec-path>/design.md
    Requirements: .sdd/specs/<spec-path>/requirement.md
    Config: .sdd/config.json
    Worktree: .worktrees/<spec-id>
    Rules: .claude/skills/rules-references/references/rules.md (if exists)
    Execute all waves, update checkboxes, run phantom checks, dispatch reviews."
})
```

The orchestrator handles all internal steps: wave building, parallel agent dispatch, checkpoint verification, phantom detection, code review, progress reporting. See `agents/orchestrator.md` for the full process.

### Step 4: Monitor and Report
After orchestrator completes:
- Read updated plan.md to confirm all subtasks are `[x]`
- Read state.json progress for final counts
- Run full test suite in worktree
- **Breaking change detection**: Compare results against `baseline-tests.json`. Tests that passed in baseline but now fail = potential breaking changes. For each:
  - Ask user: "Le test `<name>` passait avant l'implémentation et échoue maintenant. Bug ou changement cassant intentionnel ?"
  - If breaking change: record in `baseline-tests.json` `breakingChanges` array with test name, file, reason, taskId
  - If bug: report for fix before finishing
- Append log.md entry: "Implémentation terminée. X/Y sous-tâches complétées. Z changements cassants documentés."
- Report: "Toutes les sous-tâches terminées. Suite de tests : X tests passent. Y changements cassants documentés."

### Step 5: Dispatch Spec Reviewer
Dispatcher d'abord en mode rapport uniquement :
```
Agent({
  description: "Revue spec/code de <spec-id>",
  subagent_type: "sdd-spec:spec-reviewer",
  model: <from config.models.code-reviewer, default "sonnet">,
  prompt: "specId: <spec-id>
    specPath: <spec-path>
    worktreePath: .worktrees/<spec-id>
    fix: false"
})
```

Présenter le rapport à l'utilisateur.
Si le rapport contient des corrections proposées : demander "Appliquer ces corrections ? (oui/non)"
- Si oui : redispatcher avec `fix: true`
- Si non : continuer sans appliquer

Selon la recommandation finale :
- "prêt pour finishing" → transition to finishing phase
- "corrections nécessaires" → présenter le rapport, demander comment procéder
- "re-planification requise" → retour en phase planning

### Error Handling
- Orchestrator reports critical review issues → present to user in French, ask how to proceed
- Orchestrator reports phantom completions → log and present to user
- Orchestrator fails entirely → report error, suggest `/spec open`
