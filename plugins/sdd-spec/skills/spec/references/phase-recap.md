# Récapitulatif de la spec active

Présente un briefing complet de la spec active en français.

## Step 1: Lire l'état

- Lire `state.json` → currentPhase, updatedAt
- Si implémentation : lire `plan.md`, compter `[x]`, `[~]`, `[ ]`, `[!]` sous-tâches
- Sinon : lire le document de la phase courante (requirement.md / design.md / plan.md), compter les items

## Step 2: Charger le contexte

Lire `context.md` dans le répertoire de la spec (si présent).
Si absent : noter "Aucun contexte sauvegardé — `/spec close` créera un context.md."

## Step 3: Présenter le briefing

```
## Récap — <titre>

**Phase :** <phase>  **Progression :** <X/Y sous-tâches> (si implémentation)

### Objectif
<1-2 phrases depuis context.md ou requirement.md>

### Où on en est
<résumé de la phase — ce qui a été fait, ce qui reste>

### Décisions clés
- <DES-xxx> : <décision et justification courte>
- ...

### Questions ouvertes
- [ ] <question bloquante ou importante>
- ...

### Prochaine action
<commande concrète à lancer + pourquoi>
```

## Step 4: Vérifier le worktree

Exécuter `git status --short` dans le worktree (si `worktreePath` est défini dans state.json).
Si des modifications non commitées : "Attention : modifications non commitées dans le worktree."

## Step 5: Suggérer une vérification qualité

Si la phase est implémentation ou ultérieure :
"Lancez `/spec-review` pour vérifier la cohérence spec/code."
