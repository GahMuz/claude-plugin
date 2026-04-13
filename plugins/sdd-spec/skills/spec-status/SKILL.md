---
name: spec-status
description: "This skill should be used when the user invokes '/spec-status', asks 'liste des specs', 'état des specs', 'quels specs sont en cours', 'voir tous les specs', or wants an overview of all specs. Shows the active spec, in-progress specs, and completed specs."
argument-hint: ""
allowed-tools: ["Read", "Glob", "Bash"]
---

# Vue d'ensemble des specs

All output in French.

## Process

### Step 1: Identify Active Spec
Read `.sdd/local/active.json`. Note the active specId if present.

### Step 2: Read Registry
Read `.sdd/specs/registry.md`. For each row, read its `state.json` to get `currentPhase` and `updatedAt`.

### Step 3: Display Active Spec

If `.sdd/local/active.json` is present, show the active spec first with full detail:

```
★ Spec active : <titre>
  Phase : <phase>
  Progression : <X/Y sous-tâches> (si implémentation)
  Dernière mise à jour : <date>
```

If no active spec: "Aucun spec actif — lancez `/spec open <titre>` pour en ouvrir un."

### Step 4: Display In-Progress Specs

List all non-completed, non-active specs, sorted by `updatedAt` descending:

```
En cours :
  <titre> — <phase> — <dernière MAJ>
  <titre> — <phase> — <X/Y sous-tâches> — <dernière MAJ>
  ...
```

If none: omit this section.

### Step 5: Display Completed Specs

List completed specs (currentPhase = "completed"), sorted by `completedAt` descending, max 20:

```
Terminés (N) :
  <titre> — terminé le <date>
  <titre> — terminé le <date>
  ...
```

If more than 20 exist, note: "(+ X autres non affichés)"
If none: omit this section.
