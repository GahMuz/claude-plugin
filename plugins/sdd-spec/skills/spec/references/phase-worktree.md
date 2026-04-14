# Phase : Worktree Setup

Automatic phase — no user interaction needed. Report progress in French.

## Process

### Step 1: Create Branch
Derive a sanitized username from git config:
```bash
GIT_USER=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
```
Create the branch:
```bash
git branch spec/${GIT_USER}/<spec-id>
```
If branch exists from a previous attempt, report and ask user (in French).

### Step 2: Create Worktree
Verify `.worktrees/` is ignored before creating:
```bash
git check-ignore -q .worktrees
```
If NOT ignored: add `.worktrees/` to `.gitignore` and commit the change before proceeding.

```bash
mkdir -p .worktrees
git worktree add .worktrees/<spec-id> spec/${GIT_USER}/<spec-id>
```

### Step 3: Project Setup
In the worktree directory, run setup based on detected project files:
- `package.json` → `npm install` or `yarn install`
- `composer.json` → `composer install`
- `pom.xml` → `mvn install -DskipTests`
- `build.gradle` → `./gradlew build -x test`

### Step 4: Capture Test Baseline
Run project test suite and save results:
- Execute the project's test command (detect from package.json/pom.xml/composer.json)
- All tests must pass for baseline to be valid
- Save to `.sdd/specs/<spec-path>/baseline-tests.json`: total, passed, failed, skipped
- If tests fail: report in French, do NOT proceed to planning
- Append log.md entry: "Worktree créé. Baseline capturée : X tests passent."

### Step 5: Update State
```json
{
  "branch": "spec/<username>/<spec-id>",
  "worktreePath": ".worktrees/<spec-id>",
  "phases.worktree.status": "completed"
}
```

### Step 6: Report and Transition
"Worktree créé dans `.worktrees/<spec-id>` sur la branche `spec/<username>/<spec-id>`. Baseline : X tests passent. Passage à la phase de planification."

Auto-transition to planning phase.

## Error Handling

| Erreur | Action |
|--------|--------|
| Working tree non propre | "Attention : des modifications non commitées existent sur la branche de base." |
| Branche existante | "La branche existe déjà. L'utiliser ou en créer une nouvelle ?" |
| Worktree existant | "Le worktree existe déjà. Le réutiliser ou le recréer ?" |
| Tests échouent | Afficher les échecs, rester en phase worktree |
