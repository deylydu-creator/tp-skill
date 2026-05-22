#!/bin/bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG="$PROJECT_DIR/.claude/hook-debug.log"

# Diagnostic logging
{
  echo "=== SessionStart: $(date) ==="
  echo "PROJECT_DIR: $PROJECT_DIR"
  echo "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-not set}"
  echo "Git log:"
  git -C "$PROJECT_DIR" log --oneline -3 2>&1 || echo "(git log failed)"
  echo ".claude/ contents:"
  ls -la "$PROJECT_DIR/.claude/" 2>&1 || echo "(ls failed)"
  echo ".claude/skills/ contents:"
  find "$PROJECT_DIR/.claude/skills" -type f 2>&1 || echo "(find failed)"
} >> "$LOG"

# Wait for file watcher to initialize before triggering events
sleep 3

# Recreate skill files using cp+mv to trigger a genuine file-created event
for skill_md in "$PROJECT_DIR"/.claude/skills/*/SKILL.md; do
  if [ -f "$skill_md" ]; then
    tmp="${skill_md}.$$.tmp"
    cp "$skill_md" "$tmp"
    rm "$skill_md"
    mv "$tmp" "$skill_md"
    echo "Recreated: $skill_md" >> "$LOG"
  fi
done

# Same for commands
for cmd_md in "$PROJECT_DIR"/.claude/commands/*.md; do
  if [ -f "$cmd_md" ]; then
    tmp="${cmd_md}.$$.tmp"
    cp "$cmd_md" "$tmp"
    rm "$cmd_md"
    mv "$tmp" "$cmd_md"
    echo "Recreated: $cmd_md" >> "$LOG"
  fi
done

echo "Hook complete: $(date)" >> "$LOG"
