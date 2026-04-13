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

1. Read `.sdd/local/active.json`. If absent: fail — "Aucun spec actif. Lancez `/spec open <titre>` pour en ouvrir un."
2. Read `state.json` from the active spec to get `currentPhase` and `worktreePath`.
3. Dispatch the spec-reviewer agent:

```
Agent({
  description: "Revue spec/code de <spec-id>",
  subagent_type: "sdd-spec:spec-reviewer",
  prompt: "specId: <spec-id>
    specPath: <spec-path>
    worktreePath: <worktreePath or null if not yet in implementation>
    fix: <true unless --no-fix was passed>"
})
```

4. Present the agent's report to the user.

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/spec-status` | Vue d'ensemble de tous les specs |
| `/spec recap` | Briefing complet de la spec active avec contexte |
