---
name: analyze
description: "This skill should be used when the user invokes '/analyze' to check spec-vs-code consistency, detect phantom completions, verify requirements coverage, or check project rule violations. Read-only consistency audit."
argument-hint: "[spec-id]"
context: fork
allowed-tools: ["Read", "Grep", "Glob"]
---

# Analyse de cohérence

Read-only audit. All output in French. Do NOT modify any files.

## Process

### Step 0: Identify Spec
If argument provided, use it. Otherwise scan `.specs/*/state.json`, list specs with non-completed phases, ask user which to analyze.

### Step 1: Parse Spec Documents
- Read `.specs/<spec-id>/requirement.md` — extract all REQ-xxx items with acceptance criteria
- Read `.specs/<spec-id>/design.md` — extract all DES-xxx items with references
- Read `.specs/<spec-id>/plan.md` — extract all TASK-xxx and subtask items with statuses and file paths

### Step 2: Cross-Check (6 categories)

**2a — Terminé ✅**
For each subtask marked `[x]`: verify file paths exist (Glob) AND acceptance criteria are implemented (Grep for expected patterns). If both pass → terminé.

**2b — Complétions fantômes ❌**
For each subtask marked `[x]`: if any specified file path does NOT exist or is empty → phantom completion. Report: "TASK-xxx.y marquée `[x]` mais `<path>` absent."

**2c — Complétions non marquées ⚠️**
For each subtask marked `[ ]`: if all specified file paths exist → likely done but not marked. Report: "TASK-xxx.y marquée `[ ]` mais fichiers présents."

**2d — Implémentations manquantes ❌**
For each REQ-xxx: trace REQ → DES → TASK chain. If any REQ has no TASK implementing it → missing. Report: "REQ-xxx n'a aucune tâche d'implémentation."

**2e — Implémentations incomplètes ⚠️**
For each subtask marked `[x]`: check acceptance criteria from the corresponding REQ. If code exists but doesn't match all criteria → incomplete. Report: "TASK-xxx.y terminée mais critère non satisfait : <critère>."

**2f — Violations des règles projet ❌**
Read `.claude/skills/rules-references/references/rules.md` if it exists. For each verifiable rule, grep the codebase for violations:
- "Pas de secrets en dur" → grep for hardcoded passwords, API keys
- "Pas de console.log" → grep for console.log / var_dump / System.out.println
- Other rules as defined
Report each violation with file path and line.

### Step 3: Generate Report

```
# Analyse : <spec-title>

## Score : X/Y exigences remplies (Z%)

## Terminé ✅
- REQ-001 : ✅ via TASK-001.1, TASK-001.2

## Complétions fantômes ❌
- TASK-002.3 : marquée [x] mais `src/services/Auth.ts` absent

## Complétions non marquées ⚠️
- TASK-003.1 : marquée [ ] mais fichiers présents

## Implémentations manquantes ❌
- REQ-005 : aucune tâche d'implémentation trouvée

## Implémentations incomplètes ⚠️
- TASK-001.3 : critère "validation email" non trouvé

## Violations des règles projet ❌
- src/utils/api.ts:15 — console.log trouvé
- src/config.ts:3 — clé API en dur

## Recommandation
<prêt pour livraison | corrections nécessaires | ré-orchestration requise>
```

### Step 4: Summary
Present totals and recommendation in French. If score < 100%, list actionable next steps.
