---
title: Type Schema Design Considerations
category: architecture
component: type-system
status: draft
version: 1.0.0
last_updated: 2026-03-18
tags: [typing, python, manim, architecture]
priority: high
---

# Type Schema Design Considerations

This document maps every opportunity for a typed foundation across the Manim Studio
project: Python source, configuration files, agent definitions, and tooling contracts.

## 1. Python Type System Strategy

### 1.1 Current State

Manim CE 0.20 ships with rich type annotations. Key types from `manim.typing`:

| Type | Use |
|------|-----|
| `Point3D`, `Point3DLike` | Position vectors and compatible inputs |
| `Vector3D`, `Vector3DLike` | Direction/offset vectors |
| `ParsableManimColor` | Union of ManimColor, hex str, int, RGB/RGBA tuples, numpy arrays |
| `BezierPoints`, `BezierPath` | Curve geometry |
| `PathFuncType` | Animation path callables |
| `MappingFunction` | Point-to-point transforms |

Manim's own classes are well-annotated:
- `Scene.__init__` — fully typed (renderer, camera_class, random_seed, etc.)
- `VMobject.__init__` — fully typed (fill_color, stroke_color as `ParsableManimColor | None`, etc.)
- `Text.__init__` — fully typed (font, slant, weight, t2c, t2f, etc.)
- `MathTex.__init__` — fully typed (tex_strings, arg_separator, tex_to_color_map, etc.)

### 1.2 Typing Strategy for Our Code

#### `lib/` — Strict typing required

All reusable helpers must be fully annotated. mypy strict mode enforces this.

```python
from manim import VGroup, Mobject, RoundedRectangle, Text
from manim.typing import Point3D, Vector3DLike
from manim.utils.color.core import ParsableManimColor


def make_card(
    label: str,
    fill_color: ParsableManimColor | None = None,
    width: float = 0.9,
    height: float = 1.15,
    font_size: float = 30,
    stroke_color: ParsableManimColor = WHITE,
    stroke_width: float = 2,
    text_color: ParsableManimColor = WHITE,
) -> VGroup:
    """Create a labeled card mobject."""
    ...
```

Key decisions:
- **Import types explicitly** from `manim.typing` and `manim.utils.color.core`
- **Use `ParsableManimColor`** not `str` or `ManimColor` — it accepts all valid color inputs
- **Use `Point3DLike`** for position params that accept lists/tuples/arrays
- **Return concrete types** (`VGroup`, `RoundedRectangle`) not `Mobject` unless polymorphism is needed
- **Use `Sequence[str]`** not `list[str]` for input params (accept tuples too)

#### `scenes/` — Pragmatic typing

Scene files use `from manim import *` (star import is idiomatic for manim). This means:
- **ruff F403/F405 suppressed** via per-file-ignores (already configured)
- **mypy cannot resolve star imports** in strict mode
- **Solution**: Type-annotate helper methods on scene classes, accept that `construct()` is largely untyped

```python
# scenes/mathematics/example.py
from manim import *

class MyScene(Scene):
    def make_labeled_group(self, labels: Sequence[str]) -> VGroup:
        """Typed helper — mypy can check callers in lib/."""
        ...

    def construct(self) -> None:
        # Animation choreography — not type-checked beyond basic inference
        ...
```

#### `tests/` — Standard typing

Test files follow normal pytest conventions. Type hints on fixtures and helper functions.

### 1.3 mypy Configuration

Current `pyproject.toml` already sets `strict = true`. Additional refinements needed:

```toml
[tool.mypy]
python_version = "3.13"
strict = true
warn_return_any = true
warn_unused_configs = true
show_error_codes = true

[[tool.mypy.overrides]]
module = "scenes.*"
disallow_untyped_defs = false
disallow_incomplete_defs = false

[[tool.mypy.overrides]]
module = "manim.*"
ignore_missing_imports = true
```

**Rationale**: Strict mode for `lib/` and `tests/`, relaxed for `scenes/` where star imports
and animation choreography make full typing impractical. `ignore_missing_imports` for manim
because manim doesn't ship a `py.typed` marker (mypy can't find type info without it).

### 1.4 Type Aliases for Project Conventions

Define project-level type aliases in `lib/types.py` using the Python 3.12+ `type` statement:

```python
"""Project-wide type aliases for manim scene development."""

from collections.abc import Sequence

from manim import VGroup
from manim.typing import Point3D
from manim.utils.color.core import ParsableManimColor

# A card is a VGroup with a .label attribute — structural convention
type CardMobject = VGroup

# Color maps: label -> color
type ColorMap = dict[str, ParsableManimColor]

# Grid layout specification
type GridSpec = tuple[int, int]  # (rows, cols)

# Sequence of labels used across card/hand factories
type LabelSequence = Sequence[str]

# Position list from grid layout
type PositionList = list[Point3D]
```

The `type` statement (PEP 695) is preferred over `TypeAlias` on Python 3.12+. It's lazily
evaluated, supports forward references natively, and ruff UP040 enforces it.

### 1.5 Runtime Validation Boundaries

Type hints are compile-time only. For system boundaries, add runtime checks:

| Boundary | Validation |
|----------|------------|
| CLI args to scene | manim handles this (click-based) |
| Config file loading | `manim.cfg` parsed by manim's configparser |
| Asset file paths | Validate existence at scene setup time |
| External data (JSON/CSV) | Validate with `TypeAdapter` from pydantic if added |

For now, **no pydantic dependency needed** — the project is self-contained.

## 2. Configuration Schema Validation

### 2.1 JSON Schema for Settings Files

`.claude/settings.json` already declares `"$schema": "https://json.schemastore.org/claude-code-settings.json"`.

`.vscode/settings.json` — add schema reference:
```json
{
  "$schema": "https://json.schemastore.org/vs-code-settings.json",
  ...
}
```

### 2.2 TOML Configuration Typing

`.mise.toml` and `pyproject.toml` are validated by their respective tools (mise, pip/setuptools, ruff, mypy, pytest). No additional schema needed.

`.codex/config.toml` — no official schema exists yet. Document expected keys in AGENTS.md.

### 2.3 Agent Definition Frontmatter

`.claude/agents/*.md` files use YAML frontmatter. No JSON schema validation available,
but the structure is well-defined:

```yaml
---
name: string          # required
description: string   # required
tools: string         # comma-separated tool list
disallowedTools: string
model: string         # sonnet | opus | haiku | inherit | model-id
permissionMode: string # default | acceptEdits | dontAsk | bypassPermissions | plan
maxTurns: number
skills: list[string]
memory: string        # user | project | local
---
```

### 2.4 Skill Definition Frontmatter

`.claude/skills/*/SKILL.md` files:

```yaml
---
name: string           # optional, defaults to directory name
description: string    # recommended
context: string        # fork | (omit for inline)
agent: string          # subagent name when context: fork
allowed-tools: string  # comma-separated
model: string          # optional override
user-invocable: bool   # true for slash commands
argument-hint: string  # help text for arguments
---
```

## 3. Manim-Specific Type Patterns

### 3.1 The Card Pattern

Our existing scene uses a recurring "card" pattern: `VGroup(RoundedRectangle, Text)` with
a `.label` attribute. This is a structural convention, not a formal type.

**Options considered:**

| Approach | Pros | Cons |
|----------|------|------|
| TypeAlias (`CardMobject = VGroup`) | Zero overhead, documents intent | No structural enforcement |
| Protocol class | Structural typing, mypy-checkable | Manim VGroup doesn't implement protocols cleanly |
| Subclass (`class Card(VGroup)`) | Full type safety, custom methods | Must handle manim's metaclass (ConvertToOpenGL) |

**Recommendation**: Start with **TypeAlias** in `lib/types.py`. Move to a **Card subclass**
only when we have 3+ scenes reusing the pattern and need custom methods.

### 3.2 Color Map Pattern

Scenes frequently define `dict[str, color]` mappings. Type this explicitly:

```python
from lib.types import ColorMap

COMBINATORICS_COLORS: ColorMap = {
    "A": BLUE_D,
    "B": TEAL_D,
    "C": GREEN_D,
    "D": PURPLE_D,
    "E": GOLD_D,
}
```

### 3.3 Scene Configuration Pattern

For scenes with many parameters, use a dataclass or TypedDict:

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class CardStyle:
    width: float = 0.9
    height: float = 1.15
    font_size: float = 30
    corner_radius: float = 0.12
    stroke_width: float = 2
```

**When to use**: Only when a scene has 3+ configurable dimensions that get passed around.
Don't over-engineer for a single scene.

## 4. Ruff Type-Checking Rules

Current ruff lint selects: `["E", "F", "W", "I", "N", "UP"]`

**Additions to consider:**

| Rule | What it checks | Add? |
|------|---------------|------|
| `ANN` | Missing type annotations | Yes, for `lib/` only |
| `TCH` | Type-checking imports optimization | Yes |
| `RUF` | Ruff-specific rules | Yes |
| `B` | Bugbear (common pitfalls) | Yes |
| `SIM` | Simplification suggestions | Optional |
| `PTH` | pathlib over os.path | Yes |

**Recommended update:**

```toml
[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "RUF", "TCH", "PTH"]

[tool.ruff.lint.per-file-ignores]
"scenes/**/*.py" = ["F403", "F405", "ANN"]
"tests/**/*.py" = ["ANN"]
```

## 5. Implementation Phases

### Phase A: Foundation (do now)
- [x] mypy strict mode in pyproject.toml
- [ ] Add mypy overrides for scenes/ and manim module
- [ ] Create `lib/types.py` with project type aliases
- [ ] Expand ruff lint rules (B, RUF, TCH, PTH)

### Phase B: Library typing (when extracting helpers)
- [ ] Type-annotate all `lib/` functions with explicit manim types
- [ ] Add `py.typed` marker to `lib/` if it becomes a package
- [ ] Create `CardStyle` dataclass if card pattern recurs

### Phase C: Validation (when adding external data)
- [ ] Add pydantic for data-driven scenes (CSV/JSON input)
- [ ] Schema validation for any custom config formats
- [ ] Runtime path validation for asset loading

## 6. Non-Goals

- **Don't** add type stubs for manim — upstream already has annotations
- **Don't** force full typing on `construct()` methods — animation choreography is inherently imperative
- **Don't** add pydantic/attrs unless data validation is actually needed
- **Don't** create abstract base classes for scene patterns until 3+ concrete implementations exist
- **Don't** use `typing.Protocol` for mobject shapes — manim's metaclass system makes this fragile
