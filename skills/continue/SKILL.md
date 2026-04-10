---
name: continue
description: "This skill should be used when the user invokes '/continue', asks 'où en est-on', 'what's next', 'prochaine étape', 'reprendre', or wants to know what to do next on a spec. Detects current state and suggests next action."
argument-hint: "[spec-id]"
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# Détection intelligente de la prochaine étape

All output in French. Read current state and suggest the exact next command.

## Process

### Step 0: Identify Specs
Scan `.specs/*/state.json`. Build a summary of all specs:

| Spec | Phase | Progression | Dernière MAJ |
|------|-------|-------------|--------------|

If argument provided, focus on that spec. Otherwise show all and focus on the most recently updated non-completed spec.

### Step 1: Detect State and Suggest

Based on `currentPhase` in state.json:

**`requirements`** (interactive):
- Read requirement.md, count REQ items
- "Spec '<titre>' en phase d'exigences. X exigences rédigées."
- Suggest: "Continuez à affiner ou lancez `/spec approve` pour passer à la conception."

**`design`** (interactive):
- Read design.md, count DES items
- "Spec '<titre>' en phase de conception. X sections de design."
- Suggest: "Continuez à affiner ou lancez `/spec approve` pour passer à la planification."

**`worktree`** (automatic):
- "Spec '<titre>' en phase de worktree (automatique)."
- Suggest: "Lancez `/spec approve` pour relancer la création du worktree."

**`planning`** (interactive):
- Read plan.md, count tasks/subtasks
- "Spec '<titre>' en phase de planification. X tâches, Y sous-tâches."
- Suggest: "Relisez le plan, puis `/spec approve` pour démarrer l'implémentation."

**`implementation`** (agent-driven):
- Read plan.md, count `[x]`, `[~]`, `[ ]`, `[!]` subtasks
- "Spec '<titre>' en implémentation. X/Y sous-tâches terminées, Z échouées."
- If suspended: "Spec suspendu. Lancez `/spec resume` pour reprendre."
- If in progress: "Lancez `/spec resume` pour continuer l'implémentation."
- If all done: "Toutes les sous-tâches terminées. Lancez `/spec approve` pour finaliser."

**`finishing`** (interactive):
- "Spec '<titre>' prêt à finaliser."
- Suggest: "Lancez `/spec approve` pour choisir : fusionner, PR, garder ou abandonner."

**`suspended`**:
- Read `suspendedFrom` to show original phase
- "Spec '<titre>' suspendu en phase <phase>."
- Suggest: "Lancez `/spec resume` pour reprendre."

**`completed`**:
- "Spec '<titre>' terminé."
- Suggest: "Lancez `/spec new <titre>` pour démarrer un nouveau spec."

### Step 2: Check Uncommitted Work
Run `git status --short` in worktree (if exists).
If uncommitted changes: "Attention : des modifications non commitées détectées dans le worktree."

### Step 3: Suggest Quality Checks
If in implementation or later:
- "Lancez `/sync <spec-id>` pour synchroniser et vérifier la cohérence spec/code."
