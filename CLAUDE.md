---
title: Manim Projects - Claude Code Configuration
category: reference
component: project-context
status: active
version: 1.1.0
last_updated: 2026-03-18
tags: [manim, animation, python, math]
priority: high
---

# Manim Projects

Mathematical animation scenes built with [Manim Community Edition](https://www.manim.community/).

## Quick Context

- **Language**: Python 3.13 (mise global)
- **Framework**: Manim CE >= 0.20
- **Package manager**: uv
- **LaTeX**: BasicTeX + tlmgr packages
- **Render**: `manim render <file.py> <ClassName>`

## Environment Setup

```bash
direnv allow                     # Load .envrc (activates mise)
uv pip install -e '.[dev]'      # Install deps into mise-managed Python
```

## Key Locations

| What | Where |
|------|-------|
| Tool versions | `.mise.toml` |
| Dependencies | `pyproject.toml` |
| Environment | `.envrc` (direnv + mise) |
| Scenes | `scenes/` (organized by topic) |
| Reusable helpers | `lib/` |
| Assets | `assets/` (fonts, images, SVGs, audio) |
| Rendered output | `media/` (gitignored) |
| Tests | `tests/` |
| Manim config | `manim.cfg` |

## Common Commands

```bash
# Preview (low quality, fast)
manim render -pql scenes/mathematics/choose_five_three_manim.py ChooseFiveThreeTwoProofs

# Final render (high quality)
manim render -pqh scenes/mathematics/choose_five_three_manim.py ChooseFiveThreeTwoProofs

# GIF output
manim render -pqh --format gif scenes/mathematics/choose_five_three_manim.py ChooseFiveThreeTwoProofs

# Lint and format
ruff check .
ruff format .

# Tests
pytest -v
```

## Conventions

- Type hints for all functions
- Ruff for linting and formatting (not black, not prettier)
- Conventional commits: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`
- Sign all commits (SSH signing)
- Scene classes go in `scenes/` organized by topic
- Each file should be self-contained (importable scene classes)
- Pango text for labels/titles; MathTex for mathematical notation
- Reusable mobject helpers go in `lib/`

## Agentic Architecture

### Entry Points
- **Default**: `claude --agent manim-orchestrator`
- **Planning only**: `claude --model opus --agent manim-orchestrator`
- **Quick task**: Normal claude session (agents available via delegation)

### Subagents (`.claude/agents/`)
| Agent | Model | Purpose |
|-------|-------|---------|
| `manim-orchestrator` | inherit | Lead agent — decomposes and delegates |
| `scene-planner` | opus | Scene specs, storyboards, implementation plans |
| `scene-builder` | sonnet | Implements scenes and helpers |
| `render-debugger` | sonnet | Fixes render/LaTeX/ffmpeg failures |
| `visual-qa` | sonnet | Reviews pacing, clarity, pedagogy |
| `asset-researcher` | haiku | Finds fonts, SVGs, references (read-only) |

### Skills (slash commands)
| Command | Agent | Purpose |
|---------|-------|---------|
| `/scene-plan` | scene-planner | Plan a new animation |
| `/scene-build` | scene-builder | Implement from a plan |
| `/render-fix` | render-debugger | Fix a render failure |
| `/animation-review` | visual-qa | Review scene quality |

### Hooks
- **PreToolUse → Bash**: Blocks destructive commands (rm -rf, force push, etc.)
- **PostToolUse → Write/Edit**: Auto-runs ruff check + format on Python files

### Rules (`.claude/rules/`)
- `python-manim.md` — Import, typing, naming, and quality conventions
- `rendering.md` — Render quality levels, caching, export workflow
- `pedagogy.md` — Animation design principles for educational content

## Multi-Tool Project

This project is configured for four AI tools:
- **Claude Code**: `CLAUDE.md` + `.claude/` (agents, skills, hooks, rules)
- **Codex CLI**: `.codex/config.toml`
- **Cursor IDE**: `.cursor/rules/manim.mdc`
- **VS Code**: `.vscode/settings.json`
- **Shared contract**: `AGENTS.md` (canonical reference for all tools)

## Type System
- **mypy strict** for `lib/` — full type annotations with manim types
- **mypy relaxed** for `scenes/` — star imports make strict impractical
- **Type aliases** in `lib/types.py` — CardMobject, ColorMap, LabelSequence, etc.
- **Design doc**: `docs/type-schema-design.md`
