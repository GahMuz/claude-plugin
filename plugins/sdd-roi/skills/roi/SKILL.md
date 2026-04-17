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

**From requirement.md:**
- Count REQ items (`nbREQ`)

**From design.md:**
- Count DES items (`nbDES`)

**From plan.md:**
- Count parent TASK items (`nbTASK`) and total subtasks (`nbSubtask`)
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

### Step 3: Estimate Time Without Claude Per Phase

Estimate how long each phase would take for an **efficient developer working manually** (optimistic baseline — no onboarding, familiar with the codebase).

**Phase Requirements** : `15 + (nbREQ × 8)` minutes
- Gathering, writing acceptance criteria, stakeholder validation

**Phase Design** : `10 + (nbDES × 10)` minutes
- Architecture decisions, component breakdown, API contracts

**Phase Planning** : `10 + (nbTASK × 5) + (nbSubtask × 2)` minutes
- Task breakdown, sequencing, estimating

**Phase Implementation** — estimate per completed subtask from plan.md:
- **Scope**: number of files to create/modify
- **Complexity**: business logic, API integration, simple CRUD
- **Tests**: writing tests from scratch adds significant time
- **Domain knowledge**: codebase exploration time

  Calibration (optimiste — développeur expérimenté, familier du codebase) :
  - Simple entity/model: ~10 min
  - Service with business logic + tests: ~30-45 min
  - Controller/route with validation: ~20 min
  - Config change or rename: ~5 min
  - Complex integration with multiple deps: ~45-60 min
  - Comprehensive test suite: ~25-40 min

  > **Note :** Ces estimations sont spéculatives — elles représentent un cas favorable et varient fortement selon la complexité du domaine, la dette technique, et la familiarité avec le codebase. Le `tempsEstiméSansClaude` est une borne basse, pas une valeur absolue.

**Phase Finishing/Review** : `20 + (nbSubtask × 3)` minutes
- Manual testing, PR description, code review

**Phase Rétrospective** : 15 minutes (fixed)
- Post-mortem, documenting learnings (often skipped manually — conservative estimate)

### Step 4: Calculate Efficiency and Profitability

Per spec:
- `tempsEstiméSansClaude` = sum of all phase estimates (requirements + design + planning + implementation + finishing + retrospective)
- `tempsRéel` = elapsed duration from state.json (createdAt → finishing.completedAt)
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

## Économies estimées par phase

> Baseline : dev efficace, familier avec le codebase (estimation optimiste)

| Phase | Estimation sans Claude | Durée avec Claude | Gain |
|-------|----------------------|-------------------|------|
| Requirements (X REQ) | ~XX min | inclus durée totale | ~XX min |
| Design (Y DES) | ~XX min | inclus durée totale | ~XX min |
| Planning (Z tâches) | ~XX min | inclus durée totale | ~XX min |
| Implémentation (N sous-tâches) | ~XX min | inclus durée totale | ~XX min |
| Finishing/Review | ~XX min | inclus durée totale | ~XX min |
| Rétrospective | ~15 min | inclus durée totale | ~XX min |
| **Total** | **~Xh XXmin** | **~Yh YYmin** | **~ZZ%** |

## Efficacité globale

| Métrique | Valeur |
|----------|--------|
| Temps estimé sans Claude (toutes phases) | Xh XXmin |
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

**Estimation par phase :**

| Phase | Estimation sans Claude |
|-------|----------------------|
| Requirements (X REQ) | ~XX min |
| Design (Y DES) | ~XX min |
| Planning (Z tâches / N sous-tâches) | ~XX min |
| Implémentation | ~XX min |
| Finishing/Review | ~XX min |
| Rétrospective | ~15 min |
| **Total estimé sans Claude** | **~XXX min** |
| **Temps réel avec Claude** | **~XX min** |
| **Gain** | **~XX%** |

**Détail implémentation :**

| Sous-tâche | Estimation sans Claude | Complexité |
|------------|----------------------|------------|
| TASK-001.1 : Créer l'entité | ~10 min | Simple |
| TASK-001.2 : Service + tests | ~35 min | Moyen |

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
