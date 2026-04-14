---
name: adr
description: "This skill should be used when the user invokes '/adr' to manage Architecture Decision Records. Handles architectural exploration and decision-making before implementation: 'new adr', 'open adr' (loads context + resumes workflow), 'recap', 'approve phase', 'close adr', 'switch adr'. Orchestrates the full lifecycle from problem framing through decision to spec handoff."
argument-hint: "new <titre> | open [titre] | recap | approve | close | switch <titre>"
context: fork
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Agent"]
---

# ADR Workflow Orchestrator

All communication with the user MUST be in French.

## Local Active Item

The currently active item (spec or ADR) is tracked in `.sdd/local/active.json` — gitignored, machine-local, never committed.

```json
{ "type": "adr", "id": "gestion-secrets-spring", "path": ".sdd/decisions/2026/04/gestion-secrets-spring", "activatedAt": "ISO-8601" }
```

**Rules:**
- Only one item (spec or ADR) can be active at a time. The single `active.json` file enforces the constraint.
- `new`, `open`, `switch` are the only commands that write this file.
- All other commands fail immediately if this file is absent or has `type != "adr"`: "Aucun ADR actif. Lancez `/adr open <titre>` pour en ouvrir un."
- `new` and `open` check `active.json`: if present with any type, execute the appropriate CLOSE (spec or ADR) before continuing.

## Parse Arguments

Extract subcommand from user input:
- `new <titre>` → START_NEW
- `open [titre]` → OPEN
- `recap` → RECAP
- `approve` → APPROVE
- `close` → CLOSE
- `switch <titre>` → SWITCH
- no args → CHECK_STATE

## CHECK_STATE

1. Check `.sdd/config.json` exists. If not: "Lancez `/sdd-init` d'abord pour configurer le projet."
2. Read `.sdd/local/active.json`. If present with `type="adr"`: show that ADR prominently with its current phase. If absent or `type="spec"`: "Aucun ADR actif — lancez `/adr new <titre>` ou `/adr open <titre>`."

## START_NEW

0. Read `.sdd/local/active.json`. If present: execute the appropriate CLOSE (`type="spec"` → spec CLOSE, `type="adr"` → ADR CLOSE), then continue.
1. Verify `.sdd/config.json` exists.
2. Convert title to kebab-case for directory name. Note current `YYYY/MM` from today's date.
3. Determine next ADR number: count data rows in `.sdd/decisions/registry.md` (create file with header if absent), increment.
4. Create `.sdd/decisions/YYYY/MM/<kebab-titre>/`.
5. Write initial `state.json` (currentPhase: "framing", all phases pending).
6. Write initial `log.md` with creation entry: date, title, ADR number, "ADR créé".
7. Write empty `framing.md`, `options.md`, and `rule-candidates.md` (headers only: `# Règles candidates`).
8. Add a row to `.sdd/decisions/registry.md`: ADR number, title, period, status "framing".
9. Write `.sdd/local/active.json`: `{ "type": "adr", "id": "<kebab-titre>", "path": ".sdd/decisions/YYYY/MM/<kebab-titre>", "activatedAt": "<ISO-8601>" }`.
10. Enter framing phase — read and follow `references/phase-framing.md`.

## OPEN

1. Read `.sdd/decisions/registry.md`. Title given → find matching row. No title → list non-completed rows, ask user (in French).
2. Read `.sdd/local/active.json`. If present: execute the appropriate CLOSE unless it's the same ADR id, then skip to step 4.
3. Write `.sdd/local/active.json`: `{ "type": "adr", "id": "...", "path": "...", "activatedAt": "..." }`.
4. Load context following priority order from `references/protocol-context.md` section **Chargement du contexte** — present the briefing before resuming.
5. Read `state.json` → currentPhase. Resume the active phase.
6. Report state (in French) and resume.

## RECAP

0. Read `.sdd/local/active.json`. If absent or `type != "adr"`: fail.

Present a structured summary:

```
## Récap ADR — <titre> (ADR-xxx)

**Phase :** <phase courante>

### Problème
<1-2 phrases depuis framing.md>

### Options identifiées
- <option A> — <statut : en analyse | discutée | rejetée | finaliste>
- ...

### Arguments clés
- <argument ou contrainte important validé>

### Questions ouvertes
- [ ] <question non résolue>

### Commandes disponibles
<liste selon la phase — voir ci-dessous>
```

**Commandes par phase :**

**framing :**
- `/adr approve` — valider le cadrage et passer à l'exploration des options
- `/adr close` — sauvegarder et fermer

**exploration :**
- `/adr approve` — valider les options et passer à la discussion
- `/adr close` — sauvegarder et fermer

**discussion :**
- `/adr approve` — consensus atteint, formaliser la décision
- `/adr close` — sauvegarder et fermer

**decision :**
- `/adr approve` — ADR finalisé, lancer la rétrospective
- `/adr close` — sauvegarder et fermer

**retrospective :**
- en cours — répondre aux propositions de règles une par une
- `/adr approve` — finaliser la rétrospective et marquer l'ADR comme complété

**completed :**
- `/adr open <titre>` — consulter un ADR existant
- `/spec new <titre>` — démarrer l'implémentation de la décision

## APPROVE

0. Read `.sdd/local/active.json`. If absent or `type != "adr"`: fail.
1. Read `state.json` → currentPhase.
2. Validate current phase output:
   - framing: `framing.md` has problem statement + at least 1 constraint
   - exploration: `options.md` has at least 2 options with pros/cons
   - discussion: `log.md` has at least 1 discussion entry, consensus mentioned
   - decision: `adr.md` exists with decision and justification
3. Advance per state machine (`references/state-machine.md`):
   - framing → exploration: follow `references/phase-exploration.md`
   - exploration → discussion: follow `references/phase-discussion.md`
   - discussion → decision: follow `references/phase-decision.md`
   - decision → retrospective: follow `references/phase-retro.md`
   - retrospective → completed: follow `references/phase-transition.md`
4. Update `state.json` after each transition.
5. Update `Statut` column in `.sdd/decisions/registry.md`.

## CLOSE

0. Read `.sdd/local/active.json`. If absent or `type != "adr"`: fail.
Read and follow `references/protocol-context.md` section **CLOSE**.

## SWITCH

Execute OPEN on the requested ADR. OPEN handles closing the current active item automatically.

## Key Principles

**Feedback:** Always tell the user (in French) what phase they're in, what happened, what comes next.

**No implementation:** ADR produces only documents (framing.md, options.md, adr.md). No code, no branches, no worktrees.

**Security:** No secrets or credentials in ADR documents.

**Token efficiency:** Load phase references only when entering that phase.

## Phase References

| Phase | Reference |
|-------|-----------|
| Framing | `references/phase-framing.md` |
| Exploration | `references/phase-exploration.md` |
| Discussion | `references/phase-discussion.md` |
| Decision | `references/phase-decision.md` |
| Retrospective | `references/phase-retro.md` |
| Transition | `references/phase-transition.md` |
| Context | `references/protocol-context.md` |
| State machine | `references/state-machine.md` |

## Related Skills

| Skill | Purpose |
|-------|---------|
| `/spec new <titre>` | Démarrer l'implémentation d'une décision ADR |
| `/sdd-status` | Vue d'ensemble des specs et ADRs |
