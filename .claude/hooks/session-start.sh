#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SKILL_SRC="${CLAUDE_PROJECT_DIR}/.claude/skills/managing-transfer-pricing-compliance.md"
SKILL_DEST="${HOME}/.claude/skills/managing-transfer-pricing-compliance.md"

mkdir -p "${HOME}/.claude/skills"

if [ -f "$SKILL_SRC" ]; then
  cp "$SKILL_SRC" "$SKILL_DEST"
  echo "Transfer Pricing Skill wird geladen..." >&2
fi
