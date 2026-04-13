---
name: Debugging Process
description: This skill should be used when tests fail after implementation, a bug appears during spec execution, or unexpected behavior is encountered. Covers systematic root cause investigation, hypothesis testing, and escalation threshold. Invoked by spec-task-implementer on failure; injectable by spec-orchestrator when retrying failed subtasks.
---

# Debugging Process

Systematic approach to finding and fixing bugs during spec implementation. Random fixes waste time and mask root causes.

**Core principle:** Find the root cause before attempting any fix. Symptom fixes are failure.

## The Iron Rule

Never propose a fix without completing Phase 1. If you haven't identified the root cause, you're guessing.

## Phase 1 — Root Cause Investigation

Before any fix:

1. **Read the full error output** — stack trace, line numbers, error codes. Do not skip past warnings.
2. **Reproduce consistently** — can you trigger it reliably? If not, gather more data before guessing.
3. **Check recent changes** — what changed that could cause this? Review git diff and recent modifications.
4. **Trace data flow** — for errors deep in a call chain, trace backward: where does the bad value originate? Keep tracing up the chain until you find the source.

## Phase 2 — Pattern Analysis

1. Find working examples in the same codebase that are similar to what's broken.
2. Compare working vs. broken — list every difference, however small.
3. Understand dependencies — what config, environment, or state does the code assume?

## Phase 3 — Hypothesis and Testing

1. **Form a single hypothesis** — state clearly: "I think X is the root cause because Y."
2. **Make the smallest possible change** to test it — one variable at a time.
3. If it works → Phase 4. If not → form a **new** hypothesis. Never stack fixes.

## Phase 4 — Fix and Verify

1. Fix the root cause, not the symptom.
2. Run the targeted test — confirm it passes.
3. Run the full related test suite — confirm nothing regressed.
4. If the fix doesn't work: return to Phase 1 with the new information.

## Escalation Threshold

**After 3 failed fix attempts: stop.**

Do not attempt a 4th fix. Mark the subtask `[!]` and report to the orchestrator with:
- What was tried (each hypothesis and result)
- What is now understood about the root cause
- What would need to change to resolve it

Three failures usually indicate an architectural assumption is wrong, not a simple bug. The orchestrator should dispatch `spec-deep-dive` for thorough root cause investigation before retrying.

## Reference Docs

- **`references/root-cause-tracing.md`** — technique de trace arrière dans la call chain pour trouver l'origine d'une mauvaise valeur ; inclut la recherche de test polluter par bisection
- **`references/defense-in-depth.md`** — après avoir trouvé la cause racine, ajouter de la validation aux 4 couches (entry, business logic, environment guard, debug logging) pour rendre le bug structurellement impossible

## Anti-patterns

| Pattern | Why it fails |
|---------|-------------|
| "Let me try X and see" | Guessing without a hypothesis — can't learn from the result |
| Multiple changes at once | Can't isolate what worked or what caused new failures |
| Fix the symptom | Root cause resurfaces elsewhere or in production |
| Skip Phase 1 under time pressure | Systematic is faster than thrashing — always |
| 4th fix attempt | At this point it's architectural — escalate, don't persist |
