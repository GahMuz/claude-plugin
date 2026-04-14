# Phase : Finishing

All output in French.

## Process

### Step 1: Final Verification
In the worktree:
1. Run full test suite — all must pass
2. Check for uncommitted changes — commit if needed
3. Verify all subtasks in plan.md are `[x]`

If any check fails, report and ask how to proceed.

### Step 2: Present Summary

```
Résumé du spec : <titre>
Branche : spec/<username>/<spec-id>
Tâches : X/X terminées
Sous-tâches : Y/Y terminées
Tests : Z passent
Fichiers modifiés : N
Changements cassants : K (voir baseline-tests.json)
```

If breaking changes exist, list them with test name and reason.

### Step 3: Present Options

1. **Valider** — tout est commité, pousser la branche et lancer la rétrospective. La PR sera créée manuellement via Bitbucket.
2. **Fermer** — sauvegarder le contexte et fermer le spec pour reprendre plus tard.
3. **Abandonner** — supprimer la branche et le worktree, annuler tous les changements.

"Quelle option choisissez-vous ?"

### Step 4: Execute Choice

#### Valider
1. Vérifier qu'il ne reste aucune modification non commitée dans le worktree.
   Si oui : commiter avant de continuer.
2. Pousser la branche :
```bash
git push -u origin spec/<username>/<spec-id>
```
3. "Branche `spec/<username>/<spec-id>` poussée. Créez votre PR via Bitbucket quand vous êtes prêt."
4. Mettre à jour state.json : currentPhase → `"retrospective"`.
5. Mettre à jour registry.md : statut → `retrospective`.
6. Suivre `references/phase-retro.md`.

#### Fermer
- Sauvegarder le contexte : suivre `references/protocol-context.md` section **CLOSE**.
- "Spec fermé. Relancez avec `/spec open <titre>` quand vous êtes prêt."

#### Abandonner
**Double confirmation** : "Êtes-vous sûr ? Cette action supprimera tous les changements non mergés."
Si des modifications non commitées existent : "Des modifications non commitées existent. Les abandonner aussi ?"
```bash
git worktree remove --force .worktrees/<spec-id>
git branch -D spec/<username>/<spec-id>
```
- Mettre à jour registry.md : statut → `abandoned`.
- Supprimer `.sdd/local/active.json`.
- "Spec abandonné."
