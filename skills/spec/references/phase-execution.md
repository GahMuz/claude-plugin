# Phase : Implementation

Report all progress in French.

## Process

### Step 1: Read Configuration
From `.specs/config.json`:
- `parallelTaskLimit`: max concurrent agents (0 = unlimited)
- `pipelineReviews`: overlap reviews with next batch

### Step 2: Build Execution Plan
From plan.md:
1. List all subtasks with status `[ ]` (pending)
2. Find subtasks with no unresolved dependencies → first batch
3. Respect `parallelTaskLimit` (0 = dispatch all independent subtasks)

### Step 3: Execute Batch
For each subtask in batch, dispatch a task-implementer agent in parallel:

```
Agent({
  description: "Implémenter TASK-xxx.y",
  subagent_type: "spec-driven-dev:task-implementer",
  prompt: "<subtask definition + relevant DES + relevant REQ + worktree path + test commands>"
})
```

**Include in agent prompt:**
- Subtask definition from plan.md
- Relevant DES section from design.md
- Relevant REQ from requirement.md
- Working directory (worktree path)
- Test commands from verification section

**Exclude (token efficiency):**
- Full spec documents
- Unrelated tasks
- Plugin internals

Update plan.md: `[ ]` → `[~]` for dispatched subtasks.

### Step 4: Report Progress (in French)
After each agent completes:
- Update plan.md: `[~]` → `[x]` or `[!]`
- Update state.json progress
- Report: "TASK-xxx.y terminée (X/Y sous-tâches au total)"
- If failed: report error details

### Step 5: Parent Task Review
When ALL subtasks of a parent task complete → dispatch code-reviewer:

```
Agent({
  description: "Revue TASK-xxx",
  subagent_type: "spec-driven-dev:code-reviewer",
  prompt: "<completed subtasks + file changes + spec references + worktree path>"
})
```

Save review to `.specs/<spec-id>/reviews/TASK-xxx-review.md`.

If `pipelineReviews` true: start next parent's subtasks while review runs. If review finds critical issues → pause.

### Step 6: Handle Review Results
- No critical → continue
- Critical found → block, report in French:
  "Problèmes critiques détectés lors de la revue de TASK-xxx. Correction requise avant de continuer."

### Step 7: Next Batch
Update statuses, recalculate available subtasks, repeat from Step 3.

### Step 8: All Complete
All subtasks `[x]` → run full test suite → report → transition to finishing.
"Toutes les sous-tâches terminées. Suite de tests : X tests passent."
