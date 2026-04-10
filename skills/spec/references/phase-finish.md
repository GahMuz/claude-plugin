# Phase : Finishing

All output in French.

## Process

### Step 1: Final Verification
In the worktree:
1. Run full test suite — all must pass
2. Check for uncommitted changes — commit or stash
3. Verify all subtasks in plan.md are `[x]`

If any check fails, report and ask how to proceed.

### Step 2: Present Summary

```
Résumé du spec : <titre>
Branche : spec/<spec-id>
Tâches : X/X terminées
Sous-tâches : Y/Y terminées
Tests : Z passent
Fichiers modifiés : N
```

### Step 3: Present Options

1. **Fusionner** — Fusionner dans la branche de base, supprimer worktree et branche
2. **Pull Request** — Pousser la branche, créer une PR, garder le worktree
3. **Garder** — Garder branche et worktree pour travail manuel
4. **Abandonner** — Supprimer branche et worktree, annuler les changements

"Quelle option choisissez-vous ?"

### Step 4: Execute Choice

#### Fusionner
```bash
cd <project-root>
git merge spec/<spec-id>
git worktree remove .worktrees/<spec-id>
git branch -d spec/<spec-id>
```

#### Pull Request
```bash
git push -u origin spec/<spec-id>
gh pr create --title "<titre>" --body "<résumé depuis requirement.md + design.md>"
```

#### Garder
"Branche et worktree conservés pour travail manuel."

#### Abandonner
**Double confirmation** : "Êtes-vous sûr ? Cette action supprimera tous les changements."
```bash
git worktree remove .worktrees/<spec-id>
git branch -D spec/<spec-id>
```

### Step 5: Update State
Set currentPhase to `"completed"`.

### Step 6: Cleanup (optional)
"Conserver les fichiers spec dans `.specs/<spec-id>/` pour référence, ou les supprimer ?"
