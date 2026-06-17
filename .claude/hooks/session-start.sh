#!/bin/bash
# SessionStart hook: copies global CLAUDE.md and settings.json to ~/.claude/
# so they persist across ephemeral remote sessions.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# Copy global CLAUDE.md
cp "$PROJECT_DIR/.claude/global-claude.md" "$CLAUDE_DIR/CLAUDE.md"

# Merge settings: keep existing ~/.claude/settings.json if present,
# but ensure our skills entry is registered.
SETTINGS_SRC="$PROJECT_DIR/.claude/settings.json"
SETTINGS_DST="$CLAUDE_DIR/settings.json"

if [ ! -f "$SETTINGS_DST" ]; then
  cp "$SETTINGS_SRC" "$SETTINGS_DST"
fi
