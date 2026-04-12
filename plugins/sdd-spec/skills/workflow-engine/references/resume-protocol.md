# Resume Protocol

## Detecting Work to Resume

On `/spec resume`:
1. Read `.sdd/specs/registry.md` to find all specs and their paths
2. Filter: `currentPhase` is `"suspended"` or any non-`"completed"` phase
3. Multiple candidates → list with phase and last updated, ask user (in French)
4. Single candidate → resume directly
5. None → report "Aucun spec à reprendre"

## Resuming by Phase

### Interactive Phases (requirements, design, planning)
1. Read current document
2. Present to user (in French)
3. Ask: "Continuer l'édition ou approuver en l'état ?"

### Worktree Phase
1. Check worktree exists at `worktreePath`
2. Exists → verify branch, continue to test baseline
3. Missing → re-create from branch
4. Branch also missing → report error, suggest re-entering design

### Implementation Phase
Follow half-done detection below.

### Finishing Phase
Re-run verification, re-present options.

## Half-Done Implementation Detection

### Step 1: Read Plan State
- Parse plan.md for all TASK/subtask items and statuses
- Read `progress` from state.json

### Step 2: Inspect Worktree
```bash
git status --short
git log --oneline $(git merge-base HEAD <baseBranch>)..HEAD
```

### Step 3: Classify Each Subtask

| Recorded Status | Commits | Uncommitted | Tests Pass | Classification |
|----------------|---------|-------------|------------|----------------|
| `[x]` completed | Yes | No | Yes | Confirmé terminé |
| `[x]` completed | Yes | Yes | — | Nettoyage requis |
| `[~]` in-progress | Yes | No | Yes | Probablement terminé — vérifier |
| `[~]` in-progress | Yes | No | No | Partiellement fait — tests échouent |
| `[~]` in-progress | No | Yes | — | Commencé mais non commité |
| `[ ]` pending | No | No | — | Non commencé |

### Step 4: Report (in French)

```
Rapport de reprise : <titre>
Phase : implémentation
Progression : 5/12 sous-tâches terminées

Terminées :
  TASK-001.1, TASK-001.2, TASK-001.3, TASK-002.1, TASK-002.2 ✓

Partiellement terminées (attention requise) :
  TASK-002.3 : implémentation présente mais tests échouent
  TASK-003.1 : test écrit, pas d'implémentation

Non commencées :
  TASK-003.2, TASK-003.3, TASK-004.1, TASK-004.2, TASK-004.3

Action recommandée : Corriger TASK-002.3 et terminer TASK-003.1 avant le prochain lot.
```

### Step 5: Resume
- Fix partial subtasks first (re-dispatch task-implementer)
- Then continue normal batch execution

## Worktree Health Check

Before resuming implementation:
1. Worktree exists in `git worktree list`
2. Correct branch checked out
3. No merge conflicts
4. Dependencies installed (node_modules, vendor, etc.)

Report failures and suggest remediation before proceeding.
