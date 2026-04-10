# ID System and Cross-Referencing

## ID Format

| Type | Format | Example |
|------|--------|---------|
| Requirement | `REQ-` + 3-digit | REQ-001, REQ-042 |
| Design | `DES-` + 3-digit | DES-001, DES-015 |
| Parent task | `TASK-` + 3-digit | TASK-001, TASK-020 |
| Subtask | `TASK-` + 3-digit + `.` + digit | TASK-001.1, TASK-020.3 |

## Rules

1. Parent IDs are sequential within their document, zero-padded to 3 digits
2. Subtask IDs are sequential within their parent, single digit (1-9)
3. Once assigned, an ID is permanent — never reuse it
4. Removed items: retire the ID, skip it in future assignments
5. Cross-references use bracket notation: `[REQ-001]`, `[TASK-001.2]`

## Reference Chains

```
REQ-001
  ├── DES-001 (implements: [REQ-001])
  │     └── TASK-001 (implements: [DES-001], fulfills: [REQ-001])
  │           ├── TASK-001.1 (créer l'entité)
  │           ├── TASK-001.2 (créer le repository)
  │           └── TASK-001.3 (créer le service)
  └── DES-002 (implements: [REQ-001])
        └── TASK-002 (implements: [DES-002], fulfills: [REQ-001])
              ├── TASK-002.1 (créer le middleware)
              └── TASK-002.2 (ajouter les gardes de route)
```

- Parent tasks carry `implements` and `fulfills` references
- Subtasks inherit parent references unless they override
- Dependencies can exist within or across parent tasks

## Task/Subtask Relationship

- **Parent task** = logical grouping (e.g., "Créer le CRUD Utilisateur")
- **Subtask** = atomic 2-5 min unit, dispatched to an agent
- Dependency types:
  - Within parent: TASK-001.2 depends on TASK-001.1
  - Across parents: TASK-002.1 depends on TASK-001.3
  - Parent-level: TASK-002 depends on TASK-001 (all subtasks must complete)

## Status Icons

Prefix every task/subtask line in plan.md:
- `[ ]` pending
- `[~]` in-progress
- `[x]` completed
- `[!]` failed or blocked

Update icons in-place as work progresses.

## Amendment Workflow

1. **Identify affected IDs**
2. **Edit in-place** in the document
3. **Update status** to "modifié"
4. **Log in changelog**: `{"date": "...", "ids": ["REQ-003"], "reason": "..."}`
5. **Propagate**: REQ → DES → TASK → subtasks
6. **Mark incomplete subtasks** referencing changed items as `[!]`

## Orphan Detection

Before finalizing plan.md:

| Check | Catches |
|-------|---------|
| Every REQ → >= 1 DES | Requirements without design |
| Every DES → >= 1 TASK | Design without tasks |
| Every TASK → >= 1 subtask | Parent tasks without steps |
| Every parent TASK → >= 1 DES + >= 1 REQ | Untraced tasks |
| No dangling references | Typos or deleted IDs |

Orphaned REQs block plan approval.
