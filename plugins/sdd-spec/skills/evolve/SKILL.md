---
name: evolve
description: "This skill should be used when the user invokes '/evolve' to improve the project's .claude/ configuration, add skills, optimize rules, audit configuration quality, or manage the evolution of Claude Code project setup."
argument-hint: "<action: add | optimize | audit | import>"
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep"]
---

# Évolution de la configuration Claude

Manage the project's `.claude/` configuration as a living artifact. All output in French.

## Actions

| Action | Description |
|--------|-------------|
| `add <description>` | Ajouter un nouveau skill, guard, ou règle |
| `optimize` | Optimiser les skills existants (réduire tokens, éliminer doublons) |
| `audit` | Auditer la configuration complète (sécurité, granularité, cohérence) |
| `import <path>` | Importer un skill depuis un autre projet |

## Process

### Step 1: Inventory
Scan the project's `.claude/` directory:
- List all skills with descriptions and line counts
- List all rules files with line counts
- List all hooks
- Estimate total token budget (sum of all SKILL.md files that could load simultaneously)
- Report in French: "Configuration actuelle : X skills, Y règles, Z hooks. Budget tokens estimé : ~N tokens."

### Step 2: Security Scan
For new or modified skills/hooks, verify:
- No shell injection patterns (eval, exec, backtick execution)
- No network calls without explicit user consent
- No secrets or credentials in skill content
- No file access outside project scope
- **Write scope**: all writes must stay within `.claude/` — never modify files outside this directory
- **Protected files**: `settings.json` and `settings.local.json` are off-limits — never propose modifying them
- Report: "Scan sécurité : X problèmes trouvés" or "Aucun problème"

### Step 3: Duplicate Check
For new skills, compare against existing:
- Check description overlap with existing skills
- Check content similarity
- If overlap > 50%: suggest extending existing skill instead of creating new one
- Report: "Chevauchement détecté avec <skill-name>" or "Aucun doublon"

### Step 4: Granularity Check
Verify configuration quality:
- **One skill = one concern**: skills covering multiple unrelated topics should be split
- **Lazy loading respected**: skills should reference large content in `references/`, not inline
- **No bloated rules**: individual rules files should be < 200 lines
- **No duplication across rules**: same rule shouldn't appear in multiple files
- **Rules index in sync**: verify the index table in `.claude/skills/rules-references/SKILL.md` matches the actual `rules-*.md` files on disk. Flag missing entries or stale references.
- **Domain scoping**: detect rules in `rules.md` that are domain-specific and should be split into `rules-*.md` (e.g., controller-only rules sitting in the cross-cutting file)
- Report issues and suggest fixes

### Step 5: Present Plan
Based on the action:

**For `add`:**
- Propose: skill name, directory location, SKILL.md content outline, references needed
- New SKILL.md files must include frontmatter with: `name`, `description`, `argument-hint`, `allowed-tools`
- If adding a rules file (`rules-*.md`): also update the index table in `.claude/skills/rules-references/SKILL.md` with file name, domain, and "Charger quand" condition
- Check for naming conflicts
- Estimate token impact

**For `optimize`:**
- Identify oversized skills (> 3000 words in SKILL.md)
- Identify rules that could be lazily loaded
- Identify unused or redundant skills
- Detect domain-specific rules stuck in `rules.md` → propose extracting to `rules-*.md`
- Verify rules index is in sync with actual files
- Propose specific optimizations with token savings estimate

**For `audit`:**
- Present full report from Steps 1-4
- Recommend priority improvements

**For `import`:**
- Validate `<path>`: must be an existing file or directory — if absent, report "Chemin introuvable : `<path>`" and abort
- Read the source skill
- Run security + duplicate + granularity checks
- Propose adaptation for current project

### Step 6: Await Approval
Present the plan. "Voulez-vous appliquer ces modifications ?"
**NEVER auto-modify** — wait for explicit user approval.

### Step 7: Execute
After approval:
- Create/modify files as planned
- If `rules-*.md` files were created or renamed: update the index table in rules-references SKILL.md
- Update any other cross-references
- Report: "Modifications appliquées : <summary>."

### Step 8: Validate
Re-run granularity check on modified files to confirm quality.
