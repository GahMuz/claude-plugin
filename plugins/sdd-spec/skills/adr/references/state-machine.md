# State Machine — ADR

## Valid Phase Values

| Phase | Description |
|-------|-------------|
| `framing` | Définir le problème, les contraintes, les non-objectifs |
| `exploration` | Identifier et analyser les options possibles |
| `discussion` | Comparer les options, converger vers une décision |
| `decision` | Formaliser la décision dans l'ADR |
| `retrospective` | Valider les règles candidates découvertes pendant l'ADR |
| `completed` | ADR finalisé, prêt pour l'implémentation |

## Valid Transitions

```
framing        → exploration    (user approval, framing.md validé)
exploration    → discussion     (user approval, ≥2 options avec trade-offs)
discussion     → decision       (user approval, consensus atteint)
decision       → retrospective  (user approval, adr.md finalisé)
retrospective  → completed      (retro terminée)
```

No other transitions are valid. Phases cannot be skipped.

## Transition Procedure

When advancing from phase X to phase Y:
1. Set `phases.X.status` to `"approved"`
2. Set `phases.X.approvedAt` to ISO-8601
3. Set `phases.Y.status` to `"in-progress"`
4. Set `phases.Y.startedAt` to ISO-8601
5. Set `currentPhase` to Y
6. Set root `updatedAt`

## Initial state.json Template

```json
{
  "id": "<kebab-titre>",
  "adrNumber": "ADR-xxx",
  "title": "<titre>",
  "currentPhase": "framing",
  "createdAt": "<ISO-8601>",
  "updatedAt": "<ISO-8601>",
  "phases": {
    "framing":     { "status": "in-progress", "startedAt": "<ISO-8601>" },
    "exploration":    { "status": "pending" },
    "discussion":     { "status": "pending" },
    "decision":       { "status": "pending" },
    "retrospective":  { "status": "pending" },
    "completed":      { "status": "pending" }
  }
}
```
