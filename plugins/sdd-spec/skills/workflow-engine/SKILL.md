---
name: Workflow Engine
description: This skill should be used when managing "spec phases", "workflow state", "phase transitions", "state.json", "approve requirements", "approve design", "approve plan", "suspend spec", "resume spec", or when determining the current phase of a spec-driven development workflow. Provides phase definitions, state machine rules, and transition logic.
---

# Workflow Engine

Manage the phase-based workflow for spec-driven development.

**Language rule:** All communication with the user must be in French.

## Phase Sequence

| # | Phase | Condition d'avancement | Produit |
|---|-------|----------------------|---------|
| 1 | requirements | Approbation utilisateur | requirement.md |
| 2 | design | Approbation utilisateur | design.md |
| 3 | worktree | Automatique après design | Branche + worktree |
| 4 | planning | Approbation utilisateur | plan.md |
| 5 | implementation | Toutes sous-tâches terminées | Code + tests |
| 6 | finishing | Choix utilisateur | Merge / PR / garder / abandonner |

Implementation includes: TDD per subtask + code review per parent task.

## Phase Behavior

### Requirements (interactive)
Refine rough ideas through questions (in French). Save requirement.md with REQ-xxx IDs. Await approval.

### Design (interactive)
Explore alternatives, present options (in French). Validate against `rules-references` skill if available. Save design.md with DES-xxx IDs. Await approval.

### Worktree (automatic)
After design approval: create branch `spec/<spec-id>`, create worktree at `.worktrees/<spec-id>`, run project setup, verify test baseline, auto-transition to planning.

### Planning (interactive)
Break design into parent tasks + subtasks (2-5 min each). Status icons on all items. Analyze dependencies for parallelism. Save plan.md. Await approval.

### Implementation (agent-driven)
1. Find independent subtasks (no unresolved dependencies)
2. Dispatch task-implementer agents in parallel (respect parallelTaskLimit)
3. Update plan.md status icons: `[ ]` → `[~]` → `[x]` or `[!]`
4. After parent task's subtasks complete → dispatch code-reviewer
5. If pipelineReviews: overlap next parent's subtasks with review
6. Critical issues block — report to user (in French)
7. All done → full test suite → transition to finishing

### Finishing (interactive)
Present summary (in French). Options: merge, PR, keep, discard.

## State Management

Track in `.specs/<spec-id>/state.json`. Update after every transition.

See `references/state-machine.md` for full schema and valid transitions.

## Suspend and Resume

**Suspend:** Record `suspendedFrom`, set currentPhase to "suspended".
**Resume:** Restore phase, detect half-done work if in implementation, report to user.

See `references/resume-protocol.md` for detection and recovery.

## Multiple Concurrent Specs

Fully isolated: separate directories, worktrees, branches. `/spec status` lists all.

## Clarification Handling

Clarification is dispatched by the `/spec clarify` command. State changes follow the inline amendment workflow defined in the `spec-format` skill (edit in-place, log in changelog, propagate downstream, mark affected subtasks `[!]`).

## Multi-Session Mode

For large features with many parent tasks, implementation can be split across sessions:

1. Each parent task group = one session
2. After completing a parent task group: user runs `/clear` for fresh context
3. `/continue` detects progress and suggests resuming the next group
4. State persisted in state.json `progress` field across sessions
5. The orchestrator handles in-session work; cross-session continuity uses plan.md checkboxes + state.json

This prevents context window exhaustion on large features while maintaining full traceability.

## Additional Resources

- **`references/state-machine.md`** — Full schema, transitions, error handling
- **`references/resume-protocol.md`** — Half-done detection, recovery
