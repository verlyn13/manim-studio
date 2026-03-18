#!/usr/bin/env bash
# Post-edit hook: run ruff on changed Python files
# Called by Claude Code after Write/Edit on .py files

set -euo pipefail

# Get the file path from the tool result (passed via environment)
FILE_PATH="${CLAUDE_TOOL_INPUT_FILE_PATH:-${CLAUDE_TOOL_INPUT_file_path:-}}"

# Only process Python files
if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.py ]]; then
    exit 0
fi

# Only process if file exists
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Activate venv if available
if [[ -f .venv/bin/activate ]]; then
    source .venv/bin/activate
fi

# Run ruff check (auto-fix safe issues) and format
ruff check --fix --quiet "$FILE_PATH" 2>/dev/null || true
ruff format --quiet "$FILE_PATH" 2>/dev/null || true
