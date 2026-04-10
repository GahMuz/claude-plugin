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
Changements cassants : K (voir baseline-tests.json)
```

If breaking changes exist, list them with test name and reason. Include in PR body and commit message.

### Step 3: Present Options

1. **Fusionner** — Fusionner dans la branche de base, supprimer worktree et branche
2. **Pull Request** — Pousser la branche, créer une PR, garder le worktree
3. **Garder** — Garder branche et worktree pour travail manuel
4. **Abandonner** — Supprimer branche et worktree, annuler les changements

"Quelle option choisissez-vous ?"

### Step 4: Generate Commit Message
Before any action, generate a rich commit message including all context:

```
feat(<spec-id>): <titre du spec>

<résumé des exigences principales>

Conception :
- <approche choisie et justification>

Changements :
- <fichiers créés/modifiés principaux>

Changements cassants :
- <liste depuis baseline-tests.json, ou "Aucun">

Refs : <REQ-xxx, DES-xxx>
```

Present the commit message for approval before executing.

### Step 5: Execute Choice

#### Fusionner
```bash
cd <project-root>
git merge spec/<spec-id>
git worktree remove .worktrees/<spec-id>
git branch -d spec/<spec-id>
```

#### Pousser (pour PR)
```bash
git push -u origin spec/<spec-id>
```
"Branche poussée. Créez la PR via votre outil habituel."

#### Garder
"Branche et worktree conservés pour travail manuel."

#### Abandonner
**Double confirmation** : "Êtes-vous sûr ? Cette action supprimera tous les changements."
Check for uncommitted changes first. If found: "Des modifications non commitées existent. Les abandonner aussi ?"
```bash
git worktree remove --force .worktrees/<spec-id>
git branch -D spec/<spec-id>
```

### Step 6: Update State
Set currentPhase to `"completed"`.

### Step 7: Retrospective — Learning from this Spec

Extract learnings and propose .claude/ improvements.
**Separate branch and PR** — never mix config evolution with spec code.

**7a — Extract Learnings**
Analyze: log.md (decisions, workarounds), reviews/ (recurring issues), state.json changelog (conventions emerged), baseline-tests.json (breaking change patterns).

**7b — Categorize Proposals by Domain**
Each proposed rule goes to a domain-scoped file (not a single rules.md):
- Controller rules → `rules-controller.md`
- Service rules → `rules-service.md`
- Entity/model rules → `rules-entity.md`
- Test rules → `rules-test.md`
- API rules → `rules-api.md`
- Security rules → `rules-security.md`
- Cross-cutting rules only → `rules.md`

Create the `rules-*.md` file if it doesn't exist yet. This enables lazy loading — orchestrator loads only the rules file relevant to each subtask's domain.

Also categorize documentation updates: coding-standards.md, architecture.md, testing.md, module docs.

**7c — Present Proposals (in French)**

```
## Rétrospective : <titre du spec>

### Nouvelles règles proposées
- [ ] rules-controller.md : "<règle>" — découverte lors de <contexte>
- [ ] rules-service.md : "<règle>" — flaggée X fois dans les revues
- [ ] rules-test.md (nouveau) : "<règle>" — pattern de test récurrent

### Documentation à mettre à jour
- [ ] coding-standards.md : ajouter <pattern>
- [ ] architecture.md : documenter <décision>
```

"Voulez-vous appliquer ces améliorations ? (oui/non/sélectionner)"

**7d — Apply on Separate Branch**
If user approves:
1. Create branch `claude/learn-<spec-id>` from base branch
2. **Deduplicate**: before adding a rule, check if it already exists in the target `rules-*.md` or in `rules.md`. Skip duplicates.
3. Create/update `rules-*.md` files in `.claude/skills/rules-references/references/`
4. Update the index table in `.claude/skills/rules-references/SKILL.md` for any new `rules-*.md` file (add row with file, domain, "Charger quand")
5. Update documentation files if needed
6. Commit: `chore(claude): apprentissages du spec <titre>`
7. Push branch: `git push -u origin claude/learn-<spec-id>`
8. "Branche poussée. Créez la PR via votre outil habituel."
9. Log: "Rétrospective : X règles ajoutées dans Y fichiers. Branche poussée."

If declined: skip.

### Step 8: Cleanup (optional)
"Conserver les fichiers spec dans `.specs/<spec-id>/` pour référence, ou les supprimer ?"
