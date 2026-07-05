#!/bin/bash
# Hook guard for the dreamer agent.
# Restricts Write/Edit to the project's auto-memory directory only.
# Install as a PreToolUse hook matching "Edit|Write" on the dreamer agent.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MEMORY_DIR=$(jq -r '.autoMemoryDirectory // empty' "$PROJECT_DIR/.claude/settings.json" 2>/dev/null)

if [ -z "$MEMORY_DIR" ]; then
  # No redirect configured — fall back to Claude Code's default memory location:
  # ~/.claude/projects/<slug>/memory/, where <slug> is the project's absolute path
  # (git repo root if inside a repo, else the project directory) with "/" and " "
  # replaced by "-". The leading "/" becomes a leading "-".
  PROJECT_ROOT=$(cd "$PROJECT_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "$PROJECT_DIR")
  PROJECT_SLUG=$(echo "$PROJECT_ROOT" | sed 's|/|-|g; s| |-|g')
  MEMORY_DIR="$HOME/.claude/projects/$PROJECT_SLUG/memory"
fi

# Expand a leading ~/ in a configured autoMemoryDirectory so the prefix check
# compares real absolute paths (the tool's file_path is already absolute).
case "$MEMORY_DIR" in
  "~/"*) MEMORY_DIR="$HOME/${MEMORY_DIR#\~/}" ;;
esac

if [ -z "$MEMORY_DIR" ]; then
  echo "Blocked: could not determine the memory directory; the dreamer may not write here." >&2
  exit 2
fi

# Normalize to exactly one trailing slash so the prefix check matches a
# directory boundary, not a string prefix (/foo/memory vs /foo/memory-backup).
MEMORY_DIR="${MEMORY_DIR%/}/"

if [[ "$FILE_PATH" != "$MEMORY_DIR"* ]]; then
  echo "Blocked: this agent may only modify files in the memory directory ($MEMORY_DIR)." >&2
  exit 2
fi

exit 0

# Version 1.1
