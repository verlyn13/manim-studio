# Python and Manim Coding Rules

## Imports
- Scene files: `from manim import *` is acceptable and idiomatic
- Library files (`lib/`): explicit imports only, no star imports
- Standard library imports first, then third-party, then local (ruff I001 enforces this)

## Type Annotations
- Required for all functions in `lib/`
- Use `ParsableManimColor` from `manim.utils.color.core` for color parameters
- Use types from `manim.typing` for geometric parameters (Point3D, Vector3DLike, etc.)
- Scene construct() methods: `-> None` return type, params optional
- Use `Sequence[str]` not `list[str]` for input params that accept tuples

## Scene Structure
- One scene class per logical animation
- Helper methods for repeated visual patterns
- `setup()` for initialization, `construct()` for choreography
- Keep construct() readable — if a section exceeds 30 lines, extract a method

## Naming
- Scene classes: PascalCase, descriptive of content (`ChooseFiveThreeTwoProofs`)
- Helper functions: snake_case, verb-first (`make_card`, `build_grid`)
- Constants: UPPER_SNAKE_CASE (`COMBINATORICS_COLORS`)
- Files: snake_case matching the primary scene topic

## Quality Gates
- `ruff check .` must pass clean
- `ruff format .` must produce no changes
- `manim render -ql` must succeed for every scene class
