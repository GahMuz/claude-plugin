---
name: sdd-status
description: "This skill should be used when the user invokes '/sdd-status', asks 'liste des specs', 'état des specs', 'quels specs sont en cours', 'voir tous les specs', or wants an overview of all specs and ADRs. Shows the active item (spec or ADR), in-progress specs and ADRs, and completed items."
argument-hint: ""
allowed-tools: ["Read", "Glob", "Bash"]
---

# Vue d'ensemble des specs et ADRs

All output in French.

## Process

### Step 1: Identify Active Item
Read `.sdd/local/active.json`.
- If present with `type == "spec"`: note the active spec id and path.
- If present with `type == "adr"`: note the active ADR id and path.
- If absent: no active item.

### Step 2: Read Registries
- Read `.sdd/specs/registry.md`. For each row, read its `state.json` to get `currentPhase` and `updatedAt`.
- Read `.sdd/decisions/registry.md` if it exists. For each row, read its `state.json` similarly.

### Step 3: Display Active Item

If active item is a **spec**:
```
★ Spec active : <titre>
  Phase : <phase>
  Progression : <X/Y sous-tâches> (si implémentation)
  Dernière mise à jour : <date>
```

If active item is an **ADR**:
```
★ ADR actif : <titre> (<adr-number>)
  Phase : <phase>
  Dernière mise à jour : <date>
```

If no active item: "Aucun item actif — lancez `/spec open <titre>` ou `/adr open <titre>`."

### Step 4: Display In-Progress Specs

List all non-completed, non-active specs, sorted by `updatedAt` descending:

```
Specs en cours :
  <titre> — <phase> — <dernière MAJ>
  <titre> — <phase> — <X/Y sous-tâches> — <dernière MAJ>
  ...
```

If none: omit this section.

### Step 5: Display In-Progress ADRs

List all non-completed, non-active ADRs, sorted by `updatedAt` descending:

```
ADRs en cours :
  <adr-number> <titre> — <phase> — <dernière MAJ>
  ...
```

If none: omit this section.

### Step 6: Display Completed Items

List completed specs then completed ADRs, sorted by completion date descending, max 20 each:

```
Specs terminés (N) :
  <titre> — terminé le <date>
  ...

ADRs terminés (N) :
  <adr-number> <titre> — terminé le <date>
  ...
```

If more than 20 exist in a category, note: "(+ X autres non affichés)"
Omit empty categories.
