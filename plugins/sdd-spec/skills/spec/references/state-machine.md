# State Machine

## Valid Phase Values

| Phase | Description |
|-------|-------------|
| `requirements` | Gathering and refining requirements |
| `design` | Creating technical design |
| `worktree` | Setting up isolated workspace |
| `planning` | Breaking design into tasks |
| `implementation` | Executing tasks with TDD |
| `finishing` | Completing the branch |
| `retrospective` | Extracting learnings and updating rules |
| `completed` | Spec fully done |

## Valid Transitions

```
requirements → design              (user approval)
design → worktree                  (user approval, auto-chain)
worktree → planning                (automatic after setup)
planning → implementation          (user approval)
implementation → finishing          (all subtasks completed)
finishing → retrospective          (user chooses "Valider")
retrospective → completed          (retro complete)
```

No other transitions are valid. Phases cannot be skipped.

## Transition Procedure

When advancing from phase X to phase Y:
1. Set `phases.X.status` to `"approved"` or `"completed"`
2. Set `phases.X.approvedAt` or `completedAt` to ISO-8601
3. Set `phases.Y.status` to `"in-progress"`
4. Set `phases.Y.startedAt` to ISO-8601
5. Set `currentPhase` to Y
6. Set root `updatedAt`

## Implementation Progress Tracking

```json
{
  "totalTasks": 4,
  "totalSubtasks": 12,
  "completedSubtasks": 7,
  "failedSubtasks": ["TASK-002.3"],
  "currentBatch": ["TASK-003.1", "TASK-003.2"],
  "completedBatches": [
    {
      "tasks": ["TASK-001"],
      "subtasks": ["TASK-001.1", "TASK-001.2", "TASK-001.3"],
      "reviewStatus": "passed",
      "reviewedAt": "2026-04-10T14:00:00Z"
    }
  ]
}
```

## Error States

| Error | Action |
|-------|--------|
| Worktree creation fails | Stay in design, report git error |
| Test baseline fails | Stay in worktree, report failing tests |
| Subtask fails | Mark `[!]`, continue others, report after batch |
| Critical review issue | Block next batch, report to user |
| All subtasks in batch fail | Pause implementation, wait for user |
