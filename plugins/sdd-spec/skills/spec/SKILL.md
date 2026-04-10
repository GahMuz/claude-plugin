---
name: spec
description: "This skill should be used when the user invokes '/spec' to manage spec-driven development workflow. Handles 'new spec', 'resume spec', 'approve phase', 'clarify requirements', 'suspend spec', 'discard spec', or 'spec status'. Orchestrates the full lifecycle from requirements through tested, reviewed code."
argument-hint: "new <titre> | resume [titre] | status | clarify | approve | suspend | discard"
context: fork
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Agent"]
---

# Spec Workflow Orchestrator

All communication with the user MUST be in French.

## Parse Arguments

Extract subcommand from user input:
- `new <titre>` → START_NEW
- `resume [titre]` → RESUME
- `status` → STATUS
- `clarify` → CLARIFY
- `approve` → APPROVE
- `suspend` → SUSPEND
- `discard` → DISCARD
- no args → CHECK_STATE

## CHECK_STATE

1. Check `.specs/config.json` exists. If not: "Lancez `/spec-init` d'abord pour configurer le projet."
2. Scan `.specs/*/state.json` for active specs.
3. Active specs exist → show status table. None → suggest `/spec new <titre>`.

## START_NEW

1. Verify `.specs/config.json` exists.
2. Convert title to kebab-case for directory name.
3. Create `.specs/<kebab-titre>/` and `reviews/` subdirectory.
4. Write initial state.json (currentPhase: "requirements", all phases pending).
5. Write initial log.md with creation entry: date, title, "Spec créé".
6. Enter requirements phase — read and follow `references/phase-requirements.md`.

## APPROVE

1. Identify active spec. If multiple, ask user which one (in French).
2. Read state.json → currentPhase.
3. Validate current phase output:
   - requirements: requirement.md has >= 1 REQ
   - design: design.md has >= 1 DES
   - planning: plan.md has >= 1 TASK with subtasks
4. Advance per state machine:
   - requirements → design: follow `references/phase-design.md`
   - design → worktree + planning: follow `references/phase-worktree.md` then `references/phase-planning.md`
   - planning → implementation: follow `references/phase-execution.md`
5. Update state.json after each transition.

## RESUME

1. Title given → find matching spec. No title → list non-completed, let user choose.
2. Read state.json. If suspended → restore phase. If in implementation → follow resume protocol.
3. Report state (in French) and resume.

## CLARIFY

1. Identify active spec.
2. Determine affected documents from user's clarification.
3. Edit items in-place, update status icons.
4. Log in state.json changelog.
5. Propagate downstream (REQ → DES → TASK → subtasks).
6. Mark affected incomplete subtasks `[!]`.

## STATUS

1. Scan `.specs/*/state.json`.
2. Display table: nom du spec, phase, progression (X/Y sous-tâches si en implémentation), dernière mise à jour.

## SUSPEND

1. Identify active spec.
2. Record `suspendedFrom`, set currentPhase to "suspended".
3. Confirm: "Spec '<titre>' suspendu en phase <phase>. Reprenez avec `/spec resume`."

## DISCARD

1. Identify spec. **Ask explicit confirmation** (destructive).
2. If confirmed: remove worktree, delete branch, remove `.specs/<id>/`.
3. Confirm completion.

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

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/spec-sync <spec-id>` | Synchroniser les artefacts spec (corrige le drift, complétions fantômes, couverture) |
| `/continue [spec-id]` | Détecter l'état courant et suggérer la prochaine action |
| `/document-codebase [module]` | Générer des docs module pour réduire la consommation de tokens (80-90%) |
| `/evolve <action>` | Faire évoluer la configuration .claude/ (ajouter, optimiser, auditer) |
| `/roi [--from] [--to]` | Rapport ROI : temps gagné, tests ajoutés, efficacité du workflow |
