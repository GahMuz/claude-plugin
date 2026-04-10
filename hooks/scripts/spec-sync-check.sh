#!/bin/bash
set -euo pipefail

# Lightweight hook: check for active specs and inject sync reminder.
# Runs on every UserPromptSubmit. Designed for minimal overhead.

SPECS_DIR="${CLAUDE_PROJECT_DIR:-.}/.specs"

# Quick exit if no specs directory
[ -d "$SPECS_DIR" ] || exit 0

# Find first active spec (not completed, not unknown)
ACTIVE_SPEC=""
ACTIVE_PHASE=""
for state_file in "$SPECS_DIR"/*/state.json; do
  [ -f "$state_file" ] || continue
  phase=$(grep -o '"currentPhase"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | head -1 | sed 's/.*"currentPhase"[[:space:]]*:[[:space:]]*"//;s/"//')
  if [ -n "$phase" ] && [ "$phase" != "completed" ] && [ "$phase" != "unknown" ]; then
    spec_dir=$(dirname "$state_file")
    ACTIVE_SPEC=$(basename "$spec_dir")
    ACTIVE_PHASE="$phase"
    break
  fi
done

# No active spec — silent exit
[ -z "$ACTIVE_SPEC" ] && exit 0

# Active spec found — output system message (minimal tokens)
cat <<EOF
{"systemMessage": "Spec actif : ${ACTIVE_SPEC} (phase : ${ACTIVE_PHASE}). Si le message utilisateur contient un retour affectant les exigences, la conception ou le plan de ce spec, mettre à jour les documents concernés en place et loguer dans state.json changelog. Si le message est une demande sans rapport avec le spec actif, suggérer /spec new."}
EOF
