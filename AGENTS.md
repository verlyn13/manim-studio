# AGENTS.md

Manim CE animation project. Mathematical visualization scenes.

## Environment
- Python 3.13 (mise global), uv for packages, ruff for quality
- Render: `manim render -pql` (preview), `manim render -pqh` (final)
- LaTeX: BasicTeX + tlmgr packages (standalone, preview, etc.)
- System deps: ffmpeg, cairo, pango (all via Homebrew)

## Project Layout
| Directory | Purpose |
|-----------|---------|
| `scenes/` | Organized scene files by topic |
| `lib/` | Reusable mobject helpers and utilities |
| `assets/` | Fonts, images, SVGs, audio |
| `tests/` | pytest test suite |
| `media/` | Rendered output (gitignored) |
| `notebooks/` | Jupyter experimentation (optional) |

## Conventions
- Scene classes: self-contained, one logical animation per class
- Text: Pango for labels/titles, MathTex for math
- Helpers: reusable code in lib/, imported by scenes
- Quality: ruff check + ruff format, type hints required
- Commits: conventional (feat/fix/docs/test/refactor/perf), SSH-signed

## Common Commands
| Task | Command |
|------|---------|
| Preview | `manim render -pql <file> <Scene>` |
| Final | `manim render -pqh <file> <Scene>` |
| GIF | `manim render -pqh --format gif <file> <Scene>` |
| Test | `pytest -v` |
| Lint | `ruff check .` |
| Format | `ruff format .` |
| Install | `uv pip install -e '.[dev]'` |
