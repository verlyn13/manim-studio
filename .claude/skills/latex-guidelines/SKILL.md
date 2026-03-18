---
name: latex-guidelines
description: Conventions for MathTex/Tex usage, escaping, alignment, and common failure patterns.
user-invocable: false
allowed-tools: Read, Grep
---
## LaTeX Guidelines for Manim

### Environment
- BasicTeX installed via Homebrew (`brew install --cask basictex`)
- Additional packages via tlmgr: standalone, preview, doublestroke, relsize, fundus-calligra, wasysym, physics, dvisvgm, rsfs, wasy, cm-super

### MathTex Best Practices
- Use raw strings: `MathTex(r"\binom{n}{k}")`
- Split complex expressions into substrings for TransformMatchingTex:
  ```python
  MathTex(r"\binom{5}{3}", "=", r"\frac{5!}{3!2!}")
  ```
- Each substring becomes a separate submobject for targeted animations

### Common Failures
- **Missing package**: Run `sudo tlmgr install <package-name>`
- **Encoding errors**: Ensure raw strings (`r"..."`) for all backslash sequences
- **Invisible output**: Check if expression compiles but produces empty bounding box
- **Alignment breaks**: Isolate `&` and `\\` alignment markers

### Debugging
1. Reduce to the smallest failing MathTex expression
2. Test with: `python -c "from manim import MathTex; m = MathTex(r'...')"`
3. Check LaTeX log in `media/Tex/` for detailed error messages
4. If tlmgr path not found: `eval "$(/usr/libexec/path_helper)"`
