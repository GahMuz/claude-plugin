# Root Cause Tracing

Bugs often manifest deep in the call stack. The instinct is to fix where the error appears — that's a symptom fix. Trace backward to find the original trigger.

## Process

### 1. Observe the symptom
Note exactly what fails: error message, file, line, value received vs. expected.

### 2. Find the immediate cause
What code directly produces this error? Read it.

### 3. Ask: what called this with a bad value?
Trace one level up the call chain. What passed the bad argument?

### 4. Keep tracing
Continue upward until you find where the bad value is **created**, not just passed. That's the root cause.

### 5. Fix at the source
Fix where the bad value originates, not where it causes the error.

## Adding Instrumentation

When the trace isn't obvious, add logging before the failing operation:

```
log("DEBUG: entering <operation>", {
  input_value,
  current_state,
  call_context
})
```

Run once to capture evidence, then analyze where the chain breaks.

## Finding Which Test Causes Pollution

If a file or resource appears unexpectedly during tests and you don't know which test creates it:

1. Run tests one by one (bisection)
2. After each test, check if the pollution exists
3. Stop at the first test that creates it

```bash
# Pseudocode — adapt to your test runner
for test in all_tests:
    if pollution_exists: skip (already polluted)
    run test
    if pollution_exists: FOUND POLLUTER → stop
```

## Key Principle

Never fix where the error appears. Fix where the bad value is born.

Tracing 5 levels up takes 10 minutes. Symptom-fixing the same bug 5 times takes hours.

## After Finding Root Cause

Apply `defense-in-depth.md` — add validation at each layer the bad value passes through, so the bug becomes structurally impossible.
