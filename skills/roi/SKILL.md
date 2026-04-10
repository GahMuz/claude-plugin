---
name: roi
description: "This skill should be used when the user invokes '/roi' to measure time saved with Claude Code, generate a report of completed specs, count tests added, documentation generated, and estimate cost efficiency of the spec-driven workflow over a period."
argument-hint: "[--from YYYY-MM-DD] [--to YYYY-MM-DD]"
context: fork
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# Rapport ROI — Retour sur investissement du workflow spec-driven

Read-only reporting. All output in French. Focus on workflow efficiency, not people.

## Arguments

- No args → 30 derniers jours
- `--from YYYY-MM-DD` → depuis cette date
- `--to YYYY-MM-DD` → jusqu'à cette date

## Process

### Step 1: Scan Completed Specs
Scan `.specs/*/state.json`. Filter specs where:
- `currentPhase` = `"completed"`
- `phases.finishing.completedAt` falls within the requested period

### Step 2: Extract Metrics Per Spec
For each completed spec:

**From state.json:**
- `title`, `specId`
- `createdAt` → start date
- `phases.finishing.completedAt` → end date
- Duration = end - start
- `progress.totalSubtasks`, `progress.completedSubtasks`, `progress.failedSubtasks`

**From plan.md:**
- Count parent tasks and subtasks
- Read each subtask definition (description, files, complexity)

**From baseline-tests.json:**
- Tests before (baseline)
- Tests added = final count - baseline count

**From reviews/:**
- Count review reports

**From git:**
```bash
git diff --stat <baseBranch>...spec/<spec-id> | tail -1
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

### Step 4: Calculate Efficiency
Per spec:
- `tempsEstiméSansClaude` = sum of per-subtask estimates
- `tempsRéel` = elapsed duration from state.json
- `gainTemps` = tempsEstiméSansClaude - tempsRéel
- `gainPourcentage` = gainTemps / tempsEstiméSansClaude × 100

### Step 5: Generate Report

```
# Rapport ROI — Workflow spec-driven
> Période : <from> au <to>
> Généré le : <date>

## Résumé

| Métrique | Valeur |
|----------|--------|
| Specs complétés | X |
| Sous-tâches réalisées | Y |
| Tests ajoutés | +Z |
| Revues de code effectuées | W |
| Fichiers modifiés | N |
| Lignes ajoutées | L |

## Efficacité du workflow

| Métrique | Valeur |
|----------|--------|
| Temps estimé sans Claude | Xh XXmin |
| Temps réel avec Claude | Yh YYmin |
| Gain estimé | ~ZZ% |

## Détail par spec

### <titre du spec>
- **Durée** : <durée>
- **Sous-tâches** : X terminées, Y échouées
- **Tests ajoutés** : +Z
- **Fichiers modifiés** : N (L lignes)
- **Revues** : W rapports

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
| Revues de code | W (X critiques corrigées) |
| Règles projet ajoutées (rétrospectives) | R |
| Complétions fantômes détectées et corrigées | P |

## Observations
- <types de tâches les plus accélérées par le workflow>
- <phases du workflow les plus efficaces>
- <suggestions d'optimisation>
```

### Step 6: Save Report (optional)
"Sauvegarder le rapport dans `.specs/reports/roi-<date>.md` ?"
If yes, create `.specs/reports/` and save.
