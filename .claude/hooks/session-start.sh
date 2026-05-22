#!/bin/bash
# SessionStart hook: exits immediately, spawns a detached background worker.
# The worker recreates skill/command files AFTER the file watcher has started,
# so the watcher sees genuine file-created events and registers the commands.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG="$PROJECT_DIR/.claude/hook-debug.log"

{
  echo "=== SessionStart: $(date) ==="
  echo "CLAUDE_CODE_REMOTE: ${CLAUDE_CODE_REMOTE:-not set}"
  git -C "$PROJECT_DIR" log --oneline -2 2>&1 || true
} >> "$LOG"

# Write the worker to a temp file so it can be run in a new process session.
TMPSCRIPT=$(mktemp /tmp/tp-skill-worker.XXXXXX.sh)
chmod +x "$TMPSCRIPT"

# Variables are expanded NOW (outer shell) so the worker needs no env inheritance.
cat > "$TMPSCRIPT" << WORKERSCRIPT
#!/bin/bash
LOG="$LOG"
PROJ="$PROJECT_DIR"
SELF="$TMPSCRIPT"

recreate() {
  local pass=\$1 n=0 f tmp
  for f in "\$PROJ"/.claude/skills/*/SKILL.md "\$PROJ"/.claude/commands/*.md; do
    [ -f "\$f" ] || continue
    tmp=\$(mktemp)
    cp "\$f" "\$tmp" && rm -f "\$f" && cat "\$tmp" > "\$f" && rm -f "\$tmp"
    echo "  Recreated: \$f" >> "\$LOG"
    n=\$((n+1))
  done
  echo "Pass \$pass done (\$n files) at \$(date)" >> "\$LOG"
}

# Three passes at increasing delays to survive any watcher startup timing.
sleep 5  && echo "--- pass 1 ---" >> "\$LOG" && recreate 1
sleep 10 && echo "--- pass 2 ---" >> "\$LOG" && recreate 2
sleep 15 && echo "--- pass 3 ---" >> "\$LOG" && recreate 3

echo "Worker done: \$(date)" >> "\$LOG"
rm -f "\$SELF"
WORKERSCRIPT

# setsid puts the worker in a new session/process-group so it survives
# after this hook exits (even if Claude Code kills the hook's process group).
if command -v setsid > /dev/null 2>&1; then
  setsid bash "$TMPSCRIPT" >> "$LOG" 2>&1 &
else
  nohup bash "$TMPSCRIPT" >> "$LOG" 2>&1 &
  disown $!
fi

echo "Hook complete, worker spawned (PID $!): $(date)" >> "$LOG"
