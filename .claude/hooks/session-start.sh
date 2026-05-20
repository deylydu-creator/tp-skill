#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_SKILLS="$SCRIPT_DIR/../skills"

if [ -d "$PROJECT_SKILLS" ]; then
  cp "$PROJECT_SKILLS"/*.md "$SKILLS_DIR/" 2>/dev/null || true
  echo "Transfer Pricing Skill geladen."
fi
