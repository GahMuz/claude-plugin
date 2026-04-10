# Phase : Worktree Setup

Automatic phase — no user interaction needed. Report progress in French.

## Process

### Step 1: Create Branch
```bash
git branch spec/<spec-id>
```
If branch exists from a previous attempt, report and ask user (in French).

### Step 2: Create Worktree
```bash
mkdir -p .worktrees
git worktree add .worktrees/<spec-id> spec/<spec-id>
```
Add `.worktrees/` to `.gitignore` if not already there.

### Step 3: Project Setup
In the worktree directory, run setup based on detected project files:
- `package.json` → `npm install` or `yarn install`
- `composer.json` → `composer install`
- `pom.xml` → `mvn install -DskipTests`
- `build.gradle` → `./gradlew build -x test`

### Step 4: Verify Test Baseline
Run project test suite:
- All tests must pass
- Record baseline count
- If tests fail: report in French, do NOT proceed to planning

### Step 5: Update State
```json
{
  "branch": "spec/<spec-id>",
  "worktreePath": ".worktrees/<spec-id>",
  "phases.worktree.status": "completed"
}
```

### Step 6: Report and Transition
"Worktree créé dans `.worktrees/<spec-id>` sur la branche `spec/<spec-id>`. Baseline : X tests passent. Passage à la phase de planification."

Auto-transition to planning phase.

## Error Handling

| Erreur | Action |
|--------|--------|
| Working tree non propre | "Attention : des modifications non commitées existent sur la branche de base." |
| Branche existante | "La branche existe déjà. L'utiliser ou en créer une nouvelle ?" |
| Worktree existant | "Le worktree existe déjà. Le réutiliser ou le recréer ?" |
| Tests échouent | Afficher les échecs, rester en phase worktree |
