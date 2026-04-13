# Phase : Planning

All output in French.

## Process

### Step 1: Analyze Design
Read `.sdd/specs/<spec-path>/design.md`. For each DES item, identify:
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

**Structure RED/GREEN/REFACTOR :**
Pour toute tâche impliquant du nouveau code ou de la logique métier, décomposer en :
- `TASK-xxx.1 [RED]` : Écrire les tests en échec — dérivés du "Contrat de test" du DES correspondant
- `TASK-xxx.2 [GREEN]` : Implémenter le code minimal pour faire passer les tests
- `TASK-xxx.3 [REFACTOR]` : Nettoyer le code (optionnel si l'implémentation est déjà propre)
Exceptions : tâches de configuration, documentation, dépendances — pas de `[RED]` requis.

**Splitting guidelines:**
- One concern per subtask
- If > 3 files, consider splitting
- Never group `[RED]` and `[GREEN]` in the same subtask

### Step 4: Analyze Dependencies
Build dependency graph:
- Identify which subtasks can run in parallel
- Minimize dependency chains for maximum parallelism
- Circular dependencies = error, restructure
- Draw ASCII dependency graph

### Step 5: Embed Project Rules
Read `.claude/skills/rules-references/references/rules.md` if it exists.
Include a "Règles projet" checklist section at the top of plan.md with all verifiable rules from rules.md. These checkboxes are verified post-implementation.

Verify plan doesn't violate any rules (e.g., a task modifying a generated file when rules say "pas de modification de fichiers générés"). Report conflicts in French.

### Step 6: Verify Coverage
- Every DES → >= 1 TASK
- Every REQ → >= 1 TASK (via DES)
- Every TASK → >= 1 subtask
- No orphan references
- Report gaps (in French)

### Step 6b: Vérifier le plan (spec-planner)

Dispatcher spec-planner pour vérification automatique de couverture et structure TDD :
```
Agent({
  description: "Vérifier le plan <spec-id>",
  subagent_type: "sdd-spec:spec-planner",
  prompt: "Spec path: <spec-path>"
})
```
- Si **APPROUVÉ** : passer à Step 7
- Si **back-pressure vers design** : retourner en phase design (contrats de test manquants)
- Si **back-pressure vers requirements** : retourner en phase requirements (REQ non couverts)
- Si corrections mineures appliquées automatiquement : re-lire plan.md avant Step 7

### Step 7: Present Plan (in French)
Present plan.md:
- Task list with subtasks, dependencies, status icons
- Dependency graph
- Totals: "X tâches, Y sous-tâches, Z parallélisables dans le premier lot"
- "Relisez le plan. Des tâches à ajuster ?"

### Step 8: Save
Write plan.md using template. Update state.json.
Append log.md entry: date, "Phase planification", X tâches et Y sous-tâches créées, dépendances identifiées.

### Step 9: Await Approval
"Le plan est prêt. X tâches, Y sous-tâches. Lancez `/spec approve` pour démarrer l'implémentation."
