---
name: spec-sync
description: "This skill should be used when the user invokes '/spec-sync' to synchronize spec artifacts, detect and repair drift, fix phantom completions, update coverage links, check project rule violations, or audit spec-vs-code consistency. Fixes by default, --no-fix for read-only."
argument-hint: "[spec-id] [--no-fix]"
context: fork
allowed-tools: ["Read", "Grep", "Glob", "Edit"]
---

# Synchronisation des artefacts spec

Detect drift and repair it. All output in French.
Default: **fix mode** — repair detected issues. With `--no-fix`: read-only audit only.

## Process

### Step 0: Identify Spec
If argument provided, look it up in `.sdd/specs/registry.md` to resolve the full path. Otherwise read registry.md, list specs with non-completed phases, ask user which to sync.

### Step 1: Parse Spec Documents
- Read `.sdd/specs/YYYY/MM/<spec-id>/requirement.md` — extract all REQ-xxx items with acceptance criteria
- Read `.sdd/specs/YYYY/MM/<spec-id>/design.md` — extract all DES-xxx items with references
- Read `.sdd/specs/YYYY/MM/<spec-id>/plan.md` — extract all TASK-xxx and subtask items with statuses and file paths

### Step 2: Cross-Check (6 categories)

**2a — Terminé ✅**
For each subtask marked `[x]`: verify file paths exist (Glob) AND acceptance criteria are implemented (Grep for expected patterns). If both pass → terminé.

**2b — Complétions fantômes ❌**
For each subtask marked `[x]`: if any specified file path does NOT exist or is empty → phantom.
- **Fix**: Edit plan.md, revert `[x]` → `[ ]`. Report: "TASK-xxx.y : complétion fantôme corrigée, retour à `[ ]`."

**2c — Complétions non marquées ⚠️**
For each subtask marked `[ ]`: if all specified file paths exist → likely done but not marked.
- **Fix**: Edit plan.md, mark `[ ]` → `[x]`. Report: "TASK-xxx.y : fichiers présents, marquée `[x]`."

**2d — Implémentations manquantes ❌**
For each REQ-xxx: trace REQ → DES → TASK chain. If any REQ has no TASK implementing it → missing.
- **Fix**: Report gap. Cannot auto-fix (needs planning). Suggest: "REQ-xxx n'a aucune tâche — relancer `/spec` en phase planning."

**2e — Implémentations incomplètes ⚠️**
For each subtask marked `[x]`: check acceptance criteria from the corresponding REQ. If code exists but doesn't match all criteria → incomplete.
- **Fix**: Edit plan.md, revert `[x]` → `[!]`. Report: "TASK-xxx.y : critère non satisfait, marquée `[!]`."

**2f — Violations des règles projet ❌**
Read `.claude/skills/rules-references/references/rules.md` if it exists. For each verifiable rule, grep for violations.
- **Fix**: Report violations with file:line. Cannot auto-fix code. List as action items.

### Step 3: Apply Fixes (unless --no-fix)
If fix mode (default):
- Apply all checkbox corrections in plan.md via Edit
- Update state.json progress counts to match corrected plan
- Append log.md entry: "Synchronisation effectuée : X corrections appliquées."

If --no-fix:
- Report all findings without modifying files

### Step 4: Generate Report

```
# Synchronisation : <spec-title>

## Score : X/Y exigences remplies (Z%)

## Corrections appliquées (ou "Mode lecture seule")
- TASK-xxx.y : complétion fantôme → [ ]
- TASK-yyy.z : fichiers présents → [x]

## Terminé ✅
- REQ-001 : ✅ via TASK-001.1, TASK-001.2

## Complétions fantômes corrigées ❌
- TASK-002.3 : `src/services/Auth.ts` absent

## Implémentations manquantes ❌
- REQ-005 : aucune tâche d'implémentation

## Implémentations incomplètes ⚠️
- TASK-001.3 : critère "validation email" non trouvé

## Violations des règles projet ❌
- src/utils/api.ts:15 — console.log trouvé

## Recommandation
<prêt pour livraison | corrections nécessaires | ré-orchestration requise>
```

### Step 5: Summary
Present totals and recommendation in French. If score < 100%, list actionable next steps.
