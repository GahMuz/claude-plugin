# Phase : Split

Split an active spec into two specs when distinct concerns are mixed. All output in French.

## When to Use

Triggered by `/spec split [<new-title>]` or recommended proactively when concern mixing is detected during requirements or design.

Applicable phases: `requirements`, `design`, `planning`.
Not recommended during `implementation` — finish the current wave first, then split.

## Process

### Step 1: Identify Active Spec
Read `.sdd/specs/registry.md`. If argument provided, match by title. Otherwise show active non-completed specs and ask which to split.

### Step 2: Load All Artifacts
Read the spec's documents based on current phase:
- Always: `requirement.md`
- If design or later: `design.md`
- If planning or later: `plan.md`
- Always: `log.md`, `state.json`

### Step 3: Analyse Concerns
Group items by distinct concern. Look for:
- **Different domains** — e.g., refactoring existing code vs. building a new generic system
- **Different stakeholders** — items serving different users or teams
- **Independent deliverability** — items that could ship at different times without dependency
- **Different risk profiles** — a safe refactor bundled with an exploratory new system
- **"While we're at it"** patterns — items added during elicitation that belong to a different scope

Present the proposed grouping in French:

```
## Analyse de la spec : <titre>

### Préoccupation A — <label> (conservée dans cette spec)
- REQ-001 : <résumé>
- REQ-002 : <résumé>
- DES-001 : <résumé> (si applicable)

### Préoccupation B — <label> (nouvelle spec)
- REQ-003 : <résumé>
- REQ-004 : <résumé>
- DES-002 : <résumé> (si applicable)

Cette séparation vous convient-elle ? Souhaitez-vous ajuster la répartition ?
```

Allow the user to move items between groups before proceeding.

### Step 4: Name the New Spec
If `<new-title>` was provided as argument, use it. Otherwise ask:
"Quel titre pour la nouvelle spec ? (kebab-case généré automatiquement)"

### Step 5: Create New Spec Directory
Note current `YYYY/MM`. Create:
```bash
mkdir -p .sdd/specs/YYYY/MM/<new-kebab-title>/reviews
```

### Step 6: Write New Spec Artifacts

#### requirement.md
Copy selected REQ items verbatim (preserve IDs — do NOT renumber).
If a copied REQ depends on a REQ staying in the original spec, add:
```
> ⚠ Dépend de [REQ-xxx] dans la spec `<original-spec-id>` — coordonner la livraison.
```

#### design.md (if design phase or later)
Copy selected DES items verbatim (preserve IDs).
For each DES that references a REQ now in the original spec, add the same cross-spec dependency note.

#### plan.md (if planning phase or later)
Copy selected TASK items verbatim (preserve IDs).
Cross-spec TASK dependencies: add a note under the affected TASK.

#### log.md
```markdown
# Journal — <new-title>

## <ISO-8601> — Création par division

Spec créée par division de `<original-spec-id>` (<original-title>).

**Raison du split :** <concern detected / user-stated reason>

**Éléments transférés :**
- <REQ-xxx>, <REQ-yyy> depuis requirement.md
- <DES-xxx> depuis design.md (si applicable)
- <TASK-xxx> depuis plan.md (si applicable)
```

#### state.json
Set `currentPhase` to match the earliest applicable phase for the new spec's content:
- Only REQs transferred → `requirements`
- REQs + DESs transferred → `design`
- REQs + DESs + TASKs transferred → `planning`

### Step 7: Update Original Spec

#### requirement.md
For each transferred REQ, replace the item body with:
```
> Transféré vers la spec `<new-spec-id>` (<new-title>). [Voir REQ-xxx](.sdd/specs/YYYY/MM/<new-spec-id>/requirement.md)
```
Keep the REQ-xxx ID in place — never reuse it.

#### design.md / plan.md
Same treatment for transferred DES and TASK items.

#### log.md
Append entry:
```markdown
## <ISO-8601> — Division de spec

Préoccupation `<concern B label>` extraite vers la spec `<new-spec-id>`.

**Éléments transférés :** REQ-xxx, REQ-yyy, DES-xxx (si applicable), TASK-xxx (si applicable)
**Raison :** <user-stated reason>
```

### Step 8: Update Registry
Add a new row to `.sdd/specs/registry.md` for the new spec with its phase and doc links.
Update the original spec row's `Statut` if it changed.

### Step 9: Confirm
```
Division effectuée :

Spec originale : <original-title> — conserve REQ-001, REQ-002, DES-001
Nouvelle spec  : <new-title>      — contient REQ-003, REQ-004, DES-002

Phase de la nouvelle spec : <phase>
Références croisées documentées dans les deux specs.

Lancez `/spec resume <new-title>` pour continuer la nouvelle spec,
ou `/spec` pour continuer la spec originale.
```

## Cross-Reference Integrity Rules

- **Never renumber IDs** — IDs are stable across the split
- **Never delete items** — replaced with a transfer stub
- **Cross-spec references** — always noted with both spec path and ID
- **Orphan check** — after split, verify no DES in either spec references a REQ that was moved without a cross-reference note
