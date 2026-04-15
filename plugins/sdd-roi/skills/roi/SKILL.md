---
name: roi
description: "This skill should be used when the user invokes '/roi' to measure time saved with Claude Code, generate a report of completed specs, count tests added, documentation generated, and estimate cost efficiency of the spec-driven workflow over a period."
argument-hint: "[--from YYYY-MM-DD] [--to YYYY-MM-DD]"
context: fork
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# Rapport ROI — Retour sur investissement du workflow spec-driven

Read-only reporting. All output in French. Focus on workflow efficiency, not people.

## Arguments

- No args → 30 derniers jours
- `--from YYYY-MM-DD` → depuis cette date
- `--to YYYY-MM-DD` → jusqu'à cette date

## Process

### Step 1: Scan Completed Specs

Lire `.sdd/specs/registry.md` — récupérer toutes les lignes avec statut `completed`.

Pour chaque spec trouvée, charger `.sdd/specs/<YYYY>/<MM>/<spec-id>/state.json`.

Filtrer : conserver uniquement les specs où `phases.finishing.completedAt` tombe dans la période demandée.

### Step 2: Extract Metrics Per Spec

For each completed spec:

**From state.json:**
- `title`, `specId`
- `createdAt` → start date
- `phases.finishing.completedAt` → end date
- Duration = end - start
- `progress.totalTasks`, `progress.totalSubtasks`, `progress.completedSubtasks`
- `progress.failedSubtasks` → array, count = `failedSubtasks.length`
- `branch` → branch name for git diff

**From plan.md:**
- Count parent tasks and subtasks
- Read each subtask definition (description, files, complexity)

**From baseline-tests.json:**
- `total` → baseline test count (before implementation)
- `breakingChanges` array → count of documented breaking changes

**Tests ajoutés** (via git, sur la plage de commits du spec) :
```bash
git log --oneline <baseBranch>..<branch> --name-only -- "*test*" "*spec*" "*Test*" "*__tests__*" | grep -c "^\."
```
Utiliser cette estimation pour les nouveaux fichiers de test dans la plage de commits du spec. Si la branche n'existe plus (déjà supprimée), indiquer "N/D".

**From reviews/:**
- Count review report files (`reviews/*.md`)

**Règles projet ajoutées** (depuis log.md) :
- Lire `.sdd/specs/<YYYY>/<MM>/<spec-id>/log.md`
- Chercher dans l'entrée de phase retrospective la mention "X règles ajoutées"
- Si absent : indiquer "N/D"

**From git** (using `branch` field from state.json):
```bash
git diff --stat <baseBranch>...<branch> | tail -1
```
→ Files changed, insertions, deletions

### Step 3: Estimate Time Without Claude Per Subtask

For each completed subtask, read its definition from plan.md and estimate how long the same work would take manually without Claude Code. Consider:

- **Scope**: number of files to create/modify
- **Complexity**: business logic, API integration, simple CRUD
- **Tests**: writing tests from scratch adds significant time
- **Domain knowledge**: codebase exploration time
- **Review**: self-review, manual testing

Provide estimate in minutes per subtask. Be realistic — include thinking, not just typing.

Example calibration:
- Simple entity/model: ~10 min
- Service with business logic + tests: ~30-45 min
- Controller/route with validation: ~20 min
- Config change or rename: ~5 min
- Complex integration with multiple deps: ~45-60 min
- Comprehensive test suite: ~25-40 min

### Step 4: Calculate Efficiency and Profitability

Per spec:
- `tempsEstiméSansClaude` = sum of per-subtask estimates
- `tempsRéel` = elapsed duration from state.json
- `gainTemps` = tempsEstiméSansClaude - tempsRéel
- `gainPourcentage` = gainTemps / tempsEstiméSansClaude × 100

Global profitability (prorated to the analyzed period):
- Coût Claude Code = 125€/mois, proraté sur la période (ex: 15 jours = 125 × 15/30 = 62.50€)
- Coût développeur = 45 000€/an minimum (charges comprises), soit ~21.63€/h (basé sur 1607h/an)
- Temps économisé total = somme des gainTemps de tous les specs
- Valeur du temps économisé = tempsÉconomiséHeures × 21.63€
- ROI = (valeur temps économisé - coût Claude proraté) / coût Claude proraté × 100

### Step 5: Generate Report

```
# Rapport ROI — Workflow spec-driven
> Période : <from> au <to>
> Généré le : <date>

## Résumé

| Métrique | Valeur |
|----------|--------|
| Specs complétés | X |
| Tâches réalisées | T |
| Sous-tâches réalisées | Y |
| Tests ajoutés | +Z |
| Revues de code effectuées | W |
| Fichiers modifiés | F |
| Lignes ajoutées | L |
| Changements cassants documentés | K |

## Efficacité du workflow

| Métrique | Valeur |
|----------|--------|
| Temps estimé sans Claude | Xh XXmin |
| Temps réel avec Claude | Yh YYmin |
| Gain de temps estimé | ~ZZ% |

## Rentabilité

| Métrique | Valeur |
|----------|--------|
| Coût Claude Code (proraté période) | XX.XX€ |
| Coût horaire développeur (base 45k€/an) | 21.63€/h |
| Temps économisé | Xh XXmin |
| Valeur du temps économisé | XXX.XX€ |
| **ROI** | **+XXX%** |

## Détail par spec

### <titre du spec>
- **Durée** : <durée>
- **Tâches** : X terminées
- **Sous-tâches** : X terminées, Y échouées
- **Tests ajoutés** : +Z
- **Fichiers modifiés** : N (L lignes)
- **Revues** : W rapports
- **Changements cassants** : K documentés

**Estimation par sous-tâche :**

| Sous-tâche | Estimation sans Claude | Complexité |
|------------|----------------------|------------|
| TASK-001.1 : Créer l'entité | ~10 min | Simple |
| TASK-001.2 : Service + tests | ~35 min | Moyen |
| **Total estimé sans Claude** | **~65 min** | |
| **Temps réel** | **~25 min** | |
| **Gain** | **~62%** | |

## Qualité produite

| Métrique | Total période |
|----------|---------------|
| Tests ajoutés | +Z |
| Revues de code | W |
| Changements cassants documentés | K |
| Règles projet ajoutées (rétrospectives) | R |

## Observations
- <types de tâches les plus accélérées par le workflow>
- <phases du workflow les plus efficaces>
- <suggestions d'optimisation>
```

### Step 6: Save Report (optional)
"Sauvegarder le rapport dans `.sdd/reports/roi-<date>.md` ?"
If yes, create `.sdd/reports/` if needed and save.
