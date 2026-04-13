#!/bin/bash
set -euo pipefail

# Lightweight hook: inject active spec reminder on every user prompt.
# Reads .sdd/local/active.json — the single source of truth for the active spec.

LOCAL_ACTIVE="${CLAUDE_PROJECT_DIR:-.}/.sdd/local/active.json"

# Quick exit if no active spec
[ -f "$LOCAL_ACTIVE" ] || exit 0

# Read specId and specPath
SPEC_ID=$(grep -o '"specId"[[:space:]]*:[[:space:]]*"[^"]*"' "$LOCAL_ACTIVE" | sed 's/.*"specId"[[:space:]]*:[[:space:]]*"//;s/"//')
SPEC_PATH=$(grep -o '"specPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$LOCAL_ACTIVE" | sed 's/.*"specPath"[[:space:]]*:[[:space:]]*"//;s/"//')

[ -z "$SPEC_ID" ] && exit 0

# Read current phase from state.json
STATE_FILE="${CLAUDE_PROJECT_DIR:-.}/$SPEC_PATH/state.json"
if [ -f "$STATE_FILE" ]; then
  PHASE=$(grep -o '"currentPhase"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | head -1 | sed 's/.*"currentPhase"[[:space:]]*:[[:space:]]*"//;s/"//')
else
  PHASE="inconnu"
fi

cat <<EOF
{"systemMessage": "Spec actif : ${SPEC_ID} (phase : ${PHASE}). Si le message utilisateur contient un retour affectant les exigences, la conception ou le plan, mettre à jour les documents concernés en place et loguer dans state.json changelog."}
EOF
