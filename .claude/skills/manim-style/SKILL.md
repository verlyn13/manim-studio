---
name: manim-style
description: Coding conventions for Manim scene files and helper modules.
user-invocable: false
allowed-tools: Read, Grep
---
## Manim Coding Conventions

### Scene Files (`scenes/`)
- One conceptual scene per class unless short tightly-coupled variants justify grouping
- `construct()` should read like a storyboard — break mechanics into helper methods
- Use `from manim import *` (idiomatic for manim scenes)
- Prefer named helper methods over long inline lambdas
- Keep mathematical intent obvious from code structure
- Low-quality smoke render first (`-ql`), final render last (`-qh`)

### Helper Modules (`lib/`)
- Full type annotations using `manim.typing` and `ParsableManimColor`
- Explicit imports (no star imports)
- Document non-obvious mathematical choices
- Return concrete types (`VGroup`, `VMobject`) not abstract `Mobject` unless needed

### Text and Math
- Pango `Text()` for labels, titles, annotations
- `MathTex()` for mathematical notation
- Prefer stable MathTex fragments over monolithic expressions
- Isolate alignment-sensitive expressions

### Quality
- Line length: 100 chars
- Format: `ruff format`
- Lint: `ruff check`
- Type check: `mypy` (strict for lib/, relaxed for scenes/)
