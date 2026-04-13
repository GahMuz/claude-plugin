# Defense in Depth

After finding a root cause, fixing it in one place feels sufficient. But that single check can be bypassed by different code paths, mocks, or refactoring.

**Core principle:** Add validation at every layer the bad value passes through. Make the bug structurally impossible.

## The Four Layers

### Layer 1 — Entry Point Validation
Reject invalid input at the public API boundary before it enters the system.

```
function createX(param):
  if param is empty → throw "param cannot be empty"
  if param does not exist → throw "param not found: {param}"
  proceed
```

### Layer 2 — Business Logic Validation
Ensure the value makes sense for the specific operation being performed.

```
function processX(value, context):
  if value is null → throw "value required for {context}"
  proceed
```

### Layer 3 — Environment Guards
Prevent dangerous operations in specific contexts (tests, staging, etc.).

```
function dangerousOp(target):
  if test environment AND target outside safe directory:
    throw "Refusing {op} outside safe directory during tests: {target}"
  proceed
```

### Layer 4 — Debug Instrumentation
Log context before the operation for forensics when other layers fail.

```
log("About to perform {op}", {
  target,
  caller_stack,
  environment
})
```

## Applying the Pattern

1. Trace the data flow (see `root-cause-tracing.md`)
2. List every point the bad value passes through
3. Add a validation layer at each point
4. Test that bypassing layer 1 is caught by layer 2, etc.

## Why All Four Layers

Each layer catches cases the others miss:
- Different code paths bypass entry validation
- Mocks bypass business logic checks
- Edge cases in specific environments need environment guards
- Debug logging identifies structural misuse when all else fails

One validation point is not enough. Make the bug impossible, not just unlikely.
