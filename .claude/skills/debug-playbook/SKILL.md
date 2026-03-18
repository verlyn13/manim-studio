---
name: debug-playbook
description: Systematic debugging playbook for common Manim failure categories.
user-invocable: false
allowed-tools: Read, Grep, Bash
---
## Manim Debug Playbook

### Triage Flowchart
1. **ImportError** → venv not activated or dependency missing
2. **LaTeX error** → Missing tlmgr package or invalid TeX syntax
3. **ffmpeg error** → ffmpeg not found or codec issue
4. **Cairo/Pango error** → Missing Homebrew dependency
5. **Runtime error in construct()** → Code bug, use traceback
6. **Blank/empty render** → Mobjects off-screen or zero opacity

### Quick Diagnostics
```bash
# Environment
source .venv/bin/activate
python --version          # Should be 3.13.x
manim --version           # Should be 0.20.x

# LaTeX
eval "$(/usr/libexec/path_helper)"
pdflatex --version
kpsewhich standalone.sty  # Should find the file

# System deps
ffmpeg -version
brew list cairo pango freetype harfbuzz

# Quick render test
manim render -ql scenes/mathematics/choose_five_three_manim.py ChooseFiveThreeTwoProofs
```

### Fix Patterns
| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `ModuleNotFoundError: manim` | venv not active | `source .venv/bin/activate` |
| `LaTeX Error: File ... not found` | Missing TeX package | `sudo tlmgr install <pkg>` |
| `pdflatex: command not found` | PATH missing BasicTeX | `eval "$(/usr/libexec/path_helper)"` |
| `colour configuration couldn't be parsed` | Harmless warning | Ignore — manim loads defaults |
| `SyntaxWarning: invalid escape` | pydub bug on 3.13 | Ignore — upstream issue |
| Empty video file | Off-screen mobjects | Check positions, scale, camera frame |
