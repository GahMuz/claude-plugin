# Phase : Planning

All output in French.

## Process

### Step 1: Analyze Design
Read `.specs/<spec-id>/design.md`. For each DES item, identify:
- Code changes needed
- Files to create/modify
- Tests to write
- Logical implementation order

### Step 2: Create Parent Tasks
Group related work into parent tasks (TASK-xxx):
- Each parent = one logical feature unit (e.g., "Créer le CRUD Utilisateur")
- Assign sequential IDs
- Reference DES and REQ: `Implémente : [DES-001]`, `Satisfait : [REQ-001]`

### Step 3: Break Into Subtasks
For each parent, create subtasks (TASK-xxx.y):
- Each subtask = 2-5 min atomic unit
- Include: description, exact file paths, steps, verification command
- Identify dependencies within and across parents
- Prefix with `[ ]` status icon

**Splitting guidelines:**
- One concern per subtask
- If > 3 files, consider splitting
- Group related model + test when model is small
- Separate test creation from implementation only if test is complex

### Step 4: Analyze Dependencies
Build dependency graph:
- Identify which subtasks can run in parallel
- Minimize dependency chains for maximum parallelism
- Circular dependencies = error, restructure
- Draw ASCII dependency graph

### Step 5: Verify Coverage
- Every DES → >= 1 TASK
- Every REQ → >= 1 TASK (via DES)
- Every TASK → >= 1 subtask
- No orphan references
- Report gaps (in French)

### Step 6: Present Plan (in French)
Present plan.md:
- Task list with subtasks, dependencies, status icons
- Dependency graph
- Totals: "X tâches, Y sous-tâches, Z parallélisables dans le premier lot"
- "Relisez le plan. Des tâches à ajuster ?"

### Step 7: Save
Write plan.md using template. Update state.json.

### Step 8: Await Approval
"Le plan est prêt. X tâches, Y sous-tâches. Lancez `/spec approve` pour démarrer l'implémentation."
