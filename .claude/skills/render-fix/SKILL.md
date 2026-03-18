---
name: render-fix
description: Reproduce and fix a Manim render or export failure.
user-invocable: true
argument-hint: "<error message or failing render command>"
context: fork
agent: render-debugger
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---
Fix this failure:

$ARGUMENTS

Process:
1. Reproduce the failure with the exact command
2. Classify the error (LaTeX, runtime, ffmpeg, environment)
3. Isolate the true cause
4. Patch minimally
5. Rerun a smoke render
6. Summarize cause and fix
