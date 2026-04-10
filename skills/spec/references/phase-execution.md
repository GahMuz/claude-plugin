# Phase : Implementation

Report all progress in French.

## Process

### Step 1: Read Configuration
From `.specs/config.json`:
- `parallelTaskLimit`: max concurrent agents (0 = unlimited)
- `pipelineReviews`: overlap reviews with next batch
- `models`: model assignments per agent

### Step 2: Dispatch Orchestrator
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

### Step 3: Monitor and Report
After orchestrator completes:
- Read updated plan.md to confirm all subtasks are `[x]`
- Read state.json progress for final counts
- Run full test suite in worktree
- Report: "Toutes les sous-tâches terminées. Suite de tests : X tests passent."
- Transition to finishing phase

### Error Handling
- Orchestrator reports critical review issues → present to user in French, ask how to proceed
- Orchestrator reports phantom completions → log and present to user
- Orchestrator fails entirely → report error, suggest `/spec resume`
