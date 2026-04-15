---
name: spec
description: "This skill should be used when the user invokes '/spec' to manage spec-driven development workflow. Handles 'new spec', 'open spec' (loads context + resumes workflow), 'recap' (briefing complet avec contexte), 'approve phase', 'clarify spec documents (requirements, design, or plan)', 'discard spec', 'split spec', 'close spec', 'switch spec'. Orchestrates the full lifecycle from requirements through tested, reviewed code."
argument-hint: "new <titre> | open [titre] | recap | clarify | approve | discard | split [<new-titre>] | close | switch <titre>"
context: fork
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Agent"]
---

# Spec Workflow Orchestrator

All communication with the user MUST be in French.

## Local Active Item

The currently active item (spec or ADR) is tracked in `.sdd/local/active.json` — gitignored, machine-local, never committed.

```json
{ "type": "spec", "id": "mon-spec", "path": ".sdd/specs/2026/04/mon-spec", "activatedAt": "ISO-8601" }
```

**Rules:**
- Only one item (spec or ADR) can be active at a time on this machine. This single file enforces the constraint.
- `new`, `open`, `switch` are the only commands that write this file.
- All other commands fail immediately if this file is absent or has `type != "spec"`: "Aucun spec actif. Lancez `/spec open <titre>` pour en ouvrir un."
- `new` and `open` check `active.json`: if present with any type, execute the appropriate CLOSE (spec or ADR) before continuing.

## Parse Arguments

Extract subcommand from user input:
- `new <titre>` → START_NEW
- `open [titre]` → OPEN
- `recap` → RECAP
- `clarify` → CLARIFY
- `approve` → APPROVE
- `discard` → DISCARD
- `split [<new-titre>]` → SPLIT
- `close` → CLOSE
- `switch <titre>` → SWITCH
- no args → CHECK_STATE

## CHECK_STATE

1. Check `.sdd/config.json` exists. If not: "Lancez `/sdd-init` d'abord pour configurer le projet."
2. Read `.sdd/local/active.json`. If present: show that spec prominently with its current phase. If absent: "Aucun spec actif — lancez `/spec new <titre>` ou `/spec open <titre>`."

## START_NEW

0. Read `.sdd/local/active.json`. If present: execute CLOSE (full context save), then continue.
1. Verify `.sdd/config.json` exists.
2. Convert title to kebab-case for directory name. Note current `YYYY/MM` from today's date.
3. Create `.sdd/specs/YYYY/MM/<kebab-titre>/` and `reviews/` subdirectory.
4. Create empty `rule-candidates.md` in the spec directory (header only: `# Règles candidates`).
5. Write initial state.json (currentPhase: "requirements", all phases pending).
6. Write initial log.md with creation entry: date, title, "Spec créé".
7. Add a row to `.sdd/specs/registry.md` with statut `requirements` and links to the three doc files.
8. Write `.sdd/local/active.json` with new spec ID, path, and activatedAt.
9. Enter requirements phase — read and follow `references/phase-requirements.md`.

## OPEN

1. Read `.sdd/specs/registry.md`. Title given → find matching row. No title → list non-completed rows, ask user (in French).
2. Read `.sdd/local/active.json`. If present with `type="adr"`: execute ADR CLOSE. If `type="spec"` with different id: execute spec CLOSE. If same id: skip to step 4.
3. Write `.sdd/local/active.json` with this spec's ID, path, and activatedAt.
4. Load context following priority order from `references/protocol-context.md` section **Chargement du contexte** — present the briefing before resuming.
5. Read state.json → currentPhase. If in implementation → follow `references/protocol-resume.md`.
6. Report state (in French) and resume.

## RECAP

0. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail.
Read and follow `references/phase-recap.md`.

## APPROVE

0. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail.
1. Read state.json → currentPhase.
2. Validate current phase output:
   - requirements: requirement.md has >= 1 REQ
   - design: design.md has >= 1 DES
   - planning: plan.md has >= 1 TASK with subtasks
   - finishing: all tests pass, all subtasks [x], no uncommitted changes in worktree
3. Advance per state machine (`references/state-machine.md`):
   - requirements → design: follow `references/phase-design.md`
   - design → worktree + planning: follow `references/phase-worktree.md` then `references/phase-planning.md`
   - planning → implementation: follow `references/phase-execution.md`
   - finishing → retrospective: follow `references/phase-retro.md`
   - retrospective → completed: follow `references/phase-retro.md`
4. Update state.json after each transition.
5. Update `Statut` column in `.sdd/specs/registry.md`.

## CLARIFY

0. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail.
Read and follow `references/protocol-clarify.md`.

## DISCARD

0. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail.
1. **Ask explicit confirmation** (destructive).
2. If confirmed: remove worktree, delete branch, remove `.sdd/specs/YYYY/MM/<id>/`.
3. Remove row from `.sdd/specs/registry.md`.
4. Delete `.sdd/local/active.json`.
5. Confirm completion.

## SPLIT

0. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail.
Read and follow `references/protocol-split.md`.

## CLOSE

0. Read `.sdd/local/active.json`. If absent or `type != "spec"`: fail — "Aucun spec actif. Utilisez `/adr close` si un ADR est actif."
Read and follow `references/protocol-context.md` section **CLOSE**.

## SWITCH

Execute OPEN on the requested spec. OPEN handles closing the current active automatically.

## Key Principles

**Feedback:** Always tell the user (in French) what phase they're in, what happened, what comes next. During implementation: show subtask progress X/Y.

**Parallelization:** During implementation, dispatch all independent subtasks simultaneously via Agent tool. Respect `parallelTaskLimit` from config.

**Security:** No secrets in spec docs. Validate file paths. Double-confirm destructive actions.

**Token efficiency:** Load phase references only when entering that phase. Agent prompts contain only relevant task context, not full specs.

## Phase References

| Phase | Reference |
|-------|-----------|
| Requirements | `references/phase-requirements.md` |
| Design | `references/phase-design.md` |
| Worktree | `references/phase-worktree.md` |
| Planning | `references/phase-planning.md` |
| Implementation | `references/phase-execution.md` (delegates to orchestrator agent) |
| Finishing | `references/phase-finish.md` |
| Retrospective | `references/phase-retro.md` |
| Clarify | `references/protocol-clarify.md` |
| Recap | `references/phase-recap.md` |
| Split | `references/protocol-split.md` |
| Close / Switch | `references/protocol-context.md` |
| State machine | `references/state-machine.md` |
| Resume protocol | `references/protocol-resume.md` |

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/sdd-status` | Vue d'ensemble : spec active, specs en cours, specs terminées |
| `/spec-review [--no-fix]` | Revue manuelle spec/code : détecte et corrige les incohérences |
| `/doc <module \| --all \| update \| analyse \| status>` | Documenter, analyser et maintenir la doc codebase (économie 80-90% tokens) |
| `/sdd-evolve <action>` | Faire évoluer la configuration .claude/ (ajouter, optimiser, auditer) |
