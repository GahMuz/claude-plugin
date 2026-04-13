---
name: Spec Format
description: This skill should be used when working with ".sdd/" directory, "spec documents", "requirement.md", "design.md", "plan.md", "state.json", "spec IDs" (REQ-xxx, DES-xxx, TASK-xxx), "registry.md", or when creating, reading, or amending spec files. Provides canonical structure and conventions for spec-driven development documents.
---

# Spec Format

Define the structure, file formats, ID system, and conventions for `.sdd/` documents.

**Language rule:** All user-facing spec documents and output must be written in French. Internal fields (state.json keys, config keys) remain in English.

## Directory Layout

```
.sdd/
├── config.json                  # Project config (from /spec-init)
├── docs/                        # Generated documentation (from /doc)
│   ├── manifest.json
│   ├── index.md
│   └── modules/
│       └── <module>/
│           ├── module-<module>.md
│           ├── feature-<feature>.md
│           ├── analyse-<module>.md
│           ├── improvement-<module>.md
│           └── missing-rules-<module>.md
└── specs/
    ├── registry.md              # Flat index of all specs (past and active)
    └── YYYY/MM/feature-name/   # One directory per spec (kebab-case, dated)
        ├── state.json               # Workflow state and progress
        ├── requirement.md           # User stories and acceptance criteria
        ├── design.md                # Technical design decisions
        ├── plan.md                  # Implementation tasks and subtasks
        ├── log.md                   # Audit trail (decisions, actions, blockers)
        ├── context.md               # Working context snapshot (shared via git, updated on /spec close)
        ├── baseline-tests.json      # Test baseline captured before implementation
        └── reviews/                 # Code review reports
            └── TASK-001-review.md
```

Each spec directory is named in kebab-case derived from the spec title. The path prefix `YYYY/MM/` uses the creation date.

## Registry File (`.sdd/specs/registry.md`)

Flat index of all specs — lets the agent discover and load any spec without scanning the full date tree.

```markdown
# Registre des specs

| Identifiant | Titre | Période | Statut | Requirement | Design | Plan |
|-------------|-------|---------|--------|-------------|--------|------|
| feature-name | Titre de la spec | 2026/04 | completed | [REQ](2026/04/feature-name/requirement.md) | [DES](2026/04/feature-name/design.md) | [PLAN](2026/04/feature-name/plan.md) |
```

**Statut values:** `requirements` · `design` · `planning` · `implementation` · `finishing` · `completed` · `discarded`

**Maintenance rules:**
- Add a row on `START_NEW`
- Update `Statut` column on every phase transition (APPROVE, CLOSE, FINISH)
- Remove row on `DISCARD`

## ID System

Every item has a stable, permanent ID for cross-referencing and targeted amendments.

| Prefix | Document | Example |
|--------|----------|---------|
| `REQ-` | requirement.md | REQ-001, REQ-002 |
| `DES-` | design.md | DES-001, DES-002 |
| `TASK-` | plan.md (parent) | TASK-001, TASK-002 |
| `TASK-.` | plan.md (subtask) | TASK-001.1, TASK-001.2 |

Rules:
- Sequential within document, zero-padded to 3 digits (parent) or single digit (subtask)
- Permanent — never reuse a deleted ID, skip it in sequence
- Cross-reference format: `[REQ-001]`, `[DES-003]`, `[TASK-001.2]`
- Every parent TASK references at least one REQ and one DES
- Subtasks inherit parent references unless they specify their own

For detailed conventions, see `references/id-system.md`.

## Documents

### requirement.md
User stories (in French) with acceptance criteria. Each requirement is a `REQ-xxx` section with: user story, acceptance criteria, priority (must/should/could), status.

### design.md
Technical design decisions (in French). Each `DES-xxx` section: problem, approach, rationale, alternatives, tradeoffs, references to REQs.

### plan.md
Hierarchical implementation plan. **Parent tasks** (`TASK-xxx`) group related work. **Subtasks** (`TASK-xxx.y`) are atomic 2-5 min units.

Status icons prefix each line:
- `[ ]` pending — `[~]` in-progress — `[x]` completed — `[!]` failed/blocked

Subtasks = unit of agent dispatch. Parent tasks = unit of review.

### log.md
Audit trail per spec (in French). Dated entries tracking: actions taken, decisions made, spec updates, task completions, blockers encountered. Updated by orchestrator after every wave, during clarifications, and on resume. Essential for multi-session work and team handoffs.

### baseline-tests.json
Test baseline captured before implementation begins. Records: total tests, passed, failed, test names. Used to detect breaking changes — if previously passing tests fail after implementation, it's either a bug or a documented breaking change.

### state.json
Workflow state. Keys in English. See `references/templates.md` for schema.

### config.json (project-level)
At `.sdd/config.json`. Champs : `schemaVersion` (version du schéma de données, utilisée pour les migrations et la fraîcheur de la doc), `parallelTaskLimit` (0=unlimited), `pipelineReviews` (bool).

## Inline Amendments

1. Edit items in-place within the document
2. Append to `changelog` in state.json
3. Update `updatedAt`
4. Mark affected incomplete TASKs `[!]` for re-review

Never create separate amendment files.

## Cross-Reference Integrity

- Every DES → lists which REQs it addresses
- Every parent TASK → lists which DES and REQ it implements
- Amending a REQ → check referencing DES → check referencing TASK
- Before finalizing: verify no orphans

## Additional Resources

- **`references/templates.md`** — Full document templates with schemas
- **`references/id-system.md`** — Detailed ID conventions, amendment workflow
