# Spec Document Templates

All document content is in French. JSON keys remain in English.

## requirement.md

```markdown
# Exigences : <Titre du Spec>

> Spec ID : <spec-id>
> Créé le : <ISO-8601>
> Statut : brouillon | approuvé | modifié

## Contexte

<Contexte du problème ou de l'opportunité à traiter>

## Exigences

### REQ-001 : <Titre court>

**Récit utilisateur :** En tant que <rôle>, je veux <capacité> afin de <bénéfice>.

**Critères d'acceptation :**
- [ ] <Condition testable 1>
- [ ] <Condition testable 2>

**Priorité :** obligatoire | souhaitable | optionnel

**Statut :** brouillon | approuvé | modifié

---

### REQ-002 : <Titre court>

...
```

## design.md

```markdown
# Conception : <Titre du Spec>

> Spec ID : <spec-id>
> Créé le : <ISO-8601>
> Statut : brouillon | approuvé | modifié

## Vue d'ensemble

<Approche globale et résumé des décisions clés>

## Sections de conception

### DES-001 : <Titre du composant/décision>

**Implémente :** [REQ-001], [REQ-002]

**Problème :** <Ce qui doit être résolu>

**Approche :** <Solution retenue avec détails>

**Justification :** <Pourquoi cette approche>

**Alternatives considérées :**
1. <Alternative A> — rejetée car <raison>
2. <Alternative B> — rejetée car <raison>

**Compromis :** <Compromis connus de l'approche choisie>

**Statut :** brouillon | approuvé | modifié

---

### DES-002 : <Titre>

**Implémente :** [REQ-003]

...

## Couverture des exigences

| REQ | DES | Couvert |
|-----|-----|---------|
| REQ-001 | DES-001 | ✅ |
| REQ-002 | DES-001 | ✅ |
| REQ-003 | DES-002 | ✅ |
| REQ-004 | — | ❌ À traiter |

Cette matrice permet de repérer les exigences non couvertes d'un coup d'œil.
```

## plan.md

```markdown
# Plan : <Titre du Spec>

> Spec ID : <spec-id>
> Créé le : <ISO-8601>
> Statut : brouillon | approuvé | modifié

## Vue d'ensemble

<Résumé de l'approche d'implémentation et organisation des tâches>

## Graphe de dépendances

  TASK-001 ──┐
  TASK-002 ──┼── TASK-004 ── TASK-006
  TASK-003 ──┘       │
                 TASK-005

## Tâches

### [ ] TASK-001 : Créer le CRUD pour l'entité Utilisateur

**Implémente :** [DES-001]
**Satisfait :** [REQ-001]
**Dépendances :** aucune

#### Sous-tâches

- [ ] **TASK-001.1 : Créer l'entité Utilisateur**
  **Effort estimé :** ~2 min
  **Description :** Créer le modèle Utilisateur avec les champs : id, email, nom, timestamps.
  **Fichiers :**
  - `src/entities/User.ts` (créer)
  **Vérification :**
  ```bash
  npx jest src/entities/User.test.ts
  ```

- [ ] **TASK-001.2 : Créer le repository Utilisateur**
  **Effort estimé :** ~3 min
  **Dépendances :** [TASK-001.1]
  **Description :** Créer le repository avec findById, findByEmail, save, delete.
  **Fichiers :**
  - `src/repositories/UserRepository.ts` (créer)
  - `src/repositories/UserRepository.test.ts` (créer)
  **Vérification :**
  ```bash
  npx jest src/repositories/UserRepository.test.ts
  ```

- [ ] **TASK-001.3 : Créer le service Utilisateur**
  **Effort estimé :** ~4 min
  **Dépendances :** [TASK-001.2]
  **Description :** Couche service avec opérations créer, lire, modifier, supprimer.
  **Fichiers :**
  - `src/services/UserService.ts` (créer)
  - `src/services/UserService.test.ts` (créer)
  **Vérification :**
  ```bash
  npx jest src/services/UserService.test.ts
  ```

---

### [ ] TASK-002 : Ajouter le middleware d'authentification

**Implémente :** [DES-002]
**Satisfait :** [REQ-002]
**Dépendances :** [TASK-001]

#### Sous-tâches

- [ ] **TASK-002.1 : Créer le middleware auth**
  ...
```

## state.json Schema

```json
{
  "specId": "feature-name",
  "title": "Titre lisible",
  "currentPhase": "requirements",
  "createdAt": "2026-04-10T12:00:00Z",
  "updatedAt": "2026-04-10T12:00:00Z",
  "baseBranch": "main",
  "branch": null,
  "worktreePath": null,
  "phases": {
    "requirements": { "status": "pending", "startedAt": null, "approvedAt": null },
    "design":       { "status": "pending", "startedAt": null, "approvedAt": null },
    "worktree":     { "status": "pending", "startedAt": null, "completedAt": null },
    "planning":     { "status": "pending", "startedAt": null, "approvedAt": null },
    "implementation": { "status": "pending", "startedAt": null, "completedAt": null },
    "finishing":    { "status": "pending", "startedAt": null, "completedAt": null }
  },
  "progress": {
    "totalTasks": 0,
    "totalSubtasks": 0,
    "completedSubtasks": 0,
    "failedSubtasks": [],
    "currentBatch": [],
    "completedBatches": []
  },
  "changelog": []
}
```

### config.json schema (project-level)

```json
{
  "languages": ["php", "node-typescript", "java"],
  "pipelineReviews": true,
  "parallelTaskLimit": 0,
  "models": {
    "orchestrator": "opus",
    "task-implementer": "sonnet",
    "code-reviewer": "sonnet",
    "deep-dive": "opus"
  },
  "createdAt": "2026-04-10T12:00:00Z"
}
```

- `parallelTaskLimit`: 0 = unlimited, >0 = max concurrent agents per wave
- `pipelineReviews`: true = review batch N while implementing N+1
- `models`: model per agent (opus, sonnet, haiku). Orchestrator dispatches with configured model.

## log.md

```markdown
# Journal : <Titre du Spec>

> Spec ID : <spec-id>

## Entrées

### <ISO-8601> — <Phase>

**Actions :**
- <action effectuée>

**Décisions :**
- <décision prise et justification>

**Mises à jour spec :**
- <documents modifiés et IDs affectés>

**Bloquants :**
- <bloquant ou "Aucun">

**Prochaines étapes :**
- <ce qui vient ensuite>

---

### <ISO-8601> — <Phase>

...
```

## baseline-tests.json

Captured before implementation begins. Used to detect breaking changes.

```json
{
  "capturedAt": "2026-04-10T13:00:00Z",
  "command": "npm test",
  "total": 142,
  "passed": 142,
  "failed": 0,
  "skipped": 0,
  "breakingChanges": []
}
```

After implementation, `breakingChanges` is populated with tests that newly fail:
```json
{
  "breakingChanges": [
    {
      "test": "UserService.should return user by id",
      "file": "tests/UserService.test.ts",
      "reason": "API response shape changed — documented breaking change",
      "taskId": "TASK-001.3"
    }
  ]
}
```

### changelog entry

```json
{ "date": "2026-04-10T14:30:00Z", "ids": ["REQ-003", "DES-001"], "reason": "Auth doit utiliser OAuth2" }
```

### completedBatches entry

```json
{
  "tasks": ["TASK-001"],
  "subtasks": ["TASK-001.1", "TASK-001.2", "TASK-001.3"],
  "reviewStatus": "passed",
  "reviewedAt": "2026-04-10T15:00:00Z"
}
```

## Review Document Template

### reviews/TASK-xxx-review.md

```markdown
# Revue : TASK-xxx — <Titre de la tâche>

> Révisé le : <ISO-8601>
> Réviseur : agent code-reviewer
> Sous-tâches révisées : TASK-xxx.1, TASK-xxx.2, ...

## Étape 1 : Conformité au spec

**Résultat :** conforme | non conforme

**Constats :**
- <constat ou "Aucun problème">

## Étape 2 : Qualité du code

**Résultat :** conforme | non conforme

**Constats :**
- <constat ou "Aucun problème">

## Étape 3 : Règles projet

**Résultat :** conforme | non conforme | ignoré (pas de skill rules-references)

**Constats :**
- <constat ou "Aucun problème">

## Résumé

| Métrique | Nombre |
|----------|--------|
| Critique | 0 |
| Avertissement | 0 |
| Info | 0 |

**Recommandation :** continuer | correction requise
```
