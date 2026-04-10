# Phase : Implementation

Report all progress in French.

## Process

### Step 1: Read Configuration
From `.specs/config.json`:
- `parallelTaskLimit`: max concurrent agents (0 = unlimited)
- `pipelineReviews`: overlap reviews with next batch
- `models`: model assignments per agent

### Step 2: Capture Baseline Tests
Before any implementation, run the full test suite in the worktree and save results:
- Execute the project's test command (detect from package.json/pom.xml/composer.json)
- Record: total tests, passed, failed, skipped
- Save to `.specs/<spec-id>/baseline-tests.json`
- If tests already fail: warn user "Attention : X tests échouent déjà dans la baseline. Les échecs existants ne seront pas comptés comme changements cassants."
- Create initial `log.md` entry: "Phase d'implémentation démarrée. Baseline : X tests passent."

### Step 3: Dispatch Orchestrator
Delegate all wave execution to the orchestrator agent:

```
Agent({
  description: "Orchestrer l'implémentation de <spec-id>",
  subagent_type: "spec-driven-dev:orchestrator",
  model: <from config.models.orchestrator, default "opus">,
  prompt: "Spec: <spec-id>
    Plan: .specs/<spec-id>/plan.md
    Design: .specs/<spec-id>/design.md
    Requirements: .specs/<spec-id>/requirement.md
    Config: .specs/config.json
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
- Transition to finishing phase

### Error Handling
- Orchestrator reports critical review issues → present to user in French, ask how to proceed
- Orchestrator reports phantom completions → log and present to user
- Orchestrator fails entirely → report error, suggest `/spec resume`
