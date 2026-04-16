---
name: spec-review
description: "This skill should be used when the user invokes '/spec-review' to manually trigger a spec-vs-code consistency audit on the active spec. Detects phantom completions, unmarked completions, missing implementations, unsatisfied acceptance criteria, and project rule violations."
argument-hint: "[--no-fix]"
context: fork
allowed-tools: ["Read", "Agent"]
---

# Revue manuelle du spec actif

All output in French.

## Process

1. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail — "Aucun spec actif. Lancez `/spec open <titre>` pour en ouvrir un."
2. Read `state.json` from the active spec to get `currentPhase` and `worktreePath`.
3. Dispatch the spec-reviewer agent in report-only mode (fix: false always for initial dispatch):

```
Agent({
  description: "Revue spec/code de <spec-id>",
  subagent_type: "sdd-spec:spec-reviewer",
  prompt: "specId: <spec-id>
    specPath: <spec-path>
    worktreePath: <worktreePath or null if not yet in implementation>
    fix: false
    interactive: true"
})
```

4. Present the agent's report to the user.

5. If the report contains proposed corrections AND `--no-fix` was NOT passed:
   Ask: "Appliquer ces corrections ? (oui/non)"
   - If oui: dispatch the agent again with `fix: true` and `interactive: true`, and confirm the corrections applied.
   - If non: done — report presented, no changes made.

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/sdd-status` | Vue d'ensemble de tous les specs |
| `/spec recap` | Briefing complet de la spec active avec contexte |
