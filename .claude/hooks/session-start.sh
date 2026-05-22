#!/bin/bash
set -euo pipefail

# Touch skill files to trigger live change detection and ensure skills are loaded
if [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]; then
  find "${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/skills" -name "SKILL.md" -exec touch {} \;
  find "${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/commands" -name "*.md" -exec touch {} \;
fi
