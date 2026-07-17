#!/usr/bin/env bash
# Install the teamlead skill + worker agents into the Claude Code config dir.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"
cp -R "$SRC/agents/." "$CLAUDE_DIR/agents/"
cp -R "$SRC/skills/teamlead" "$CLAUDE_DIR/skills/"

echo "✅ Installed teamlead skill + 3 worker agents into $CLAUDE_DIR"
echo "   Restart Claude Code, then run /teamlead"
