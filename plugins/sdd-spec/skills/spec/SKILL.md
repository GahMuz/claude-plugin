---
name: spec
description: "This skill should be used when the user invokes '/spec' to manage spec-driven development workflow. Handles 'new spec', 'resume spec' (loads context + resumes workflow), 'recap', 'approve phase', 'clarify requirements', 'suspend spec', 'discard spec', 'split spec', 'close spec', 'switch spec', or 'spec status'. Orchestrates the full lifecycle from requirements through tested, reviewed code."
argument-hint: "new <titre> | resume [titre] | recap | status | clarify | approve | suspend | discard | split [<new-titre>] | close | switch <titre>"
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
- `split [<new-titre>]` → SPLIT
- `close` → CLOSE
- `switch <titre>` → SWITCH
- `recap` → RECAP
- no args → CHECK_STATE

## CHECK_STATE

1. Check `.sdd/config.json` exists. If not: "Lancez `/spec-init` d'abord pour configurer le projet."
2. If a spec was opened earlier in this session, show it prominently as active.
3. Read `.sdd/specs/registry.md` for all specs.
4. Active specs exist → show status table. None → suggest `/spec new <titre>`.

## START_NEW

1. Verify `.sdd/config.json` exists.
2. Convert title to kebab-case for directory name. Note current `YYYY/MM` from today's date.
3. Create `.sdd/specs/YYYY/MM/<kebab-titre>/` and `reviews/` subdirectory.
4. Write initial state.json (currentPhase: "requirements", all phases pending).
5. Write initial log.md with creation entry: date, title, "Spec créé".
6. Add a row to `.sdd/specs/registry.md` with statut `requirements` and links to the three doc files.
7. Enter requirements phase — read and follow `references/phase-requirements.md`.

## APPROVE

1. Read `.sdd/specs/registry.md` to identify active spec. If multiple, ask user which one (in French).
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
6. Update `Statut` column in `.sdd/specs/registry.md`.

## RESUME

1. Read `.sdd/specs/registry.md`. Title given → find matching row. No title → list non-completed rows, let user choose.
2. Establish the spec as active in this session (conversation-level tracking).
3. Load context following priority order from `references/phase-context.md` section **Chargement du contexte**, Step 3 — present the briefing before resuming.
4. Read state.json. If suspended → restore phase. If in implementation → follow resume protocol.
5. Report state (in French) and resume.

## CLARIFY

1. Read `.sdd/specs/registry.md` to identify active spec.
2. Determine affected documents from user's clarification.
3. Edit items in-place, update status icons.
4. Log in state.json changelog.
5. Propagate downstream (REQ → DES → TASK → subtasks).
6. Mark affected incomplete subtasks `[!]`.

## STATUS

1. Read `.sdd/specs/registry.md`. For each row, read its state.json via the stored path.
2. Display table: nom du spec, phase, progression (X/Y sous-tâches si en implémentation), dernière mise à jour.

## SUSPEND

1. Read `.sdd/specs/registry.md` to identify active spec.
2. Record `suspendedFrom`, set currentPhase to "suspended".
3. Update `Statut` to `suspended` in registry.md.
4. Confirm: "Spec '<titre>' suspendu en phase <phase>. Reprenez avec `/spec resume`."

## DISCARD

1. Read `.sdd/specs/registry.md` to identify spec. **Ask explicit confirmation** (destructive).
2. If confirmed: remove worktree, delete branch, remove `.sdd/specs/YYYY/MM/<id>/`.
3. Remove row from `.sdd/specs/registry.md`.
4. Confirm completion.

## SPLIT

Read and follow `references/phase-split.md`.

## RECAP

1. Identifier la spec active : session courante → sinon `.sdd/specs/registry.md` (spec non terminée la plus récente) → sinon demander.
2. Lire dans cet ordre : `context.md` (si présent), puis `state.json`, puis `plan.md` (si implementation).
3. Présenter un briefing complet en français :

```
## Récap — <titre du spec>

**Phase :** <phase>  **Progression :** <X/Y sous-tâches> (si implementation)

### Objectif
<1-2 phrases>

### Où on en est
<résumé de la phase courante — ce qui a été fait, ce qui reste>

### Décisions clés
- <DES-xxx> : <décision et justification courte>
- ...

### Questions ouvertes
- [ ] <question bloquante ou importante>
- ...

### Prochaine action
<commande concrète à lancer + pourquoi>
```

Différence avec `/continue` : recap charge le contexte (`context.md`) pour un briefing complet incluant les décisions et questions ouvertes — pas seulement la prochaine commande.

## CLOSE

Read and follow `references/phase-context.md` section **CLOSE**.

## SWITCH

1. If a spec is active in this session: execute CLOSE (save context).
2. Execute RESUME on the requested spec (loads context + resumes workflow).

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
| Split | `references/phase-split.md` |
| Close / Switch | `references/phase-context.md` |

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/spec-sync <spec-id>` | Synchroniser les artefacts spec (corrige le drift, complétions fantômes, couverture) |
| `/continue [spec-id]` | Détecter l'état courant et suggérer la prochaine action |
| `/doc <module \| --all \| update \| analyse \| status>` | Documenter, analyser et maintenir la doc codebase (économie 80-90% tokens) |
| `/evolve <action>` | Faire évoluer la configuration .claude/ (ajouter, optimiser, auditer) |
| `/roi [--from] [--to]` | Rapport ROI : temps gagné, tests ajoutés, efficacité du workflow |
