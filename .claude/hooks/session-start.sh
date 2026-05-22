#!/bin/bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Live change detection only fires for newly created files, not pre-existing ones.
# Fix: delete and recreate each SKILL.md to trigger a genuine "file created" event.
for skill_md in "$PROJECT_DIR"/.claude/skills/*/SKILL.md; do
  if [ -f "$skill_md" ]; then
    content=$(cat "$skill_md")
    rm "$skill_md"
    printf '%s' "$content" > "$skill_md"
  fi
done

# Same for commands files
for cmd_md in "$PROJECT_DIR"/.claude/commands/*.md; do
  if [ -f "$cmd_md" ]; then
    content=$(cat "$cmd_md")
    rm "$cmd_md"
    printf '%s' "$content" > "$cmd_md"
  fi
done
