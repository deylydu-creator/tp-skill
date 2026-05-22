#!/bin/bash

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG="$PROJECT_DIR/.claude/hook-debug.log"

{
  echo "=== SessionStart: $(date) ==="
  echo "PROJECT_DIR: $PROJECT_DIR"
  echo "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-not set}"
  echo "Git log:"
  git -C "$PROJECT_DIR" log --oneline -3 2>&1 || echo "(git log failed)"
  echo "Files:"
  find "$PROJECT_DIR/.claude" -type f 2>&1 || echo "(find failed)"
} >> "$LOG"

# Give the file watcher time to initialize
sleep 8

recreate_file() {
  local file="$1"
  local pass="$2"
  [ -f "$file" ] || return
  local tmp
  tmp=$(mktemp)
  cp "$file" "$tmp"
  rm -f "$file"
  cat "$tmp" > "$file"
  rm -f "$tmp"
  echo "Recreated (pass $pass): $file at $(date)" >> "$LOG"
}

# Pass 1: rm + cat > triggers IN_CREATE + IN_CLOSE_WRITE events
for skill_md in "$PROJECT_DIR"/.claude/skills/*/SKILL.md; do
  recreate_file "$skill_md" 1
done
for cmd_md in "$PROJECT_DIR"/.claude/commands/*.md; do
  recreate_file "$cmd_md" 1
done

# Pass 2: repeat after a short delay in case the watcher hadn't registered the first pass yet
sleep 4

for skill_md in "$PROJECT_DIR"/.claude/skills/*/SKILL.md; do
  recreate_file "$skill_md" 2
done
for cmd_md in "$PROJECT_DIR"/.claude/commands/*.md; do
  recreate_file "$cmd_md" 2
done

echo "Hook complete: $(date)" >> "$LOG"
