#!/usr/bin/env bash
# Pre-tool hook: block obviously destructive shell commands
# Called by Claude Code before Bash tool execution

set -euo pipefail

COMMAND="${CLAUDE_TOOL_INPUT_command:-}"

# Block patterns that could cause data loss
BLOCKED_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \."
    "git clean -fd"
    "git checkout -- \."
    "git reset --hard"
    "git push.*--force.*main"
    "git push.*--force.*master"
    "> /dev/"
    "dd if="
    "mkfs\."
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo "BLOCKED: Potentially destructive command detected: $COMMAND"
        echo "Pattern matched: $pattern"
        exit 2
    fi
done

# Block writes to media/ (generated output, should not be modified by tools)
if echo "$COMMAND" | grep -qE "(>|>>|tee|cp|mv|rm).*media/"; then
    echo "BLOCKED: Do not modify media/ directory — it contains generated output"
    exit 2
fi

exit 0
