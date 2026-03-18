---
name: scene-plan
description: Create a scene plan and implementation outline for a Manim animation task.
user-invocable: true
argument-hint: "<description of the animation to plan>"
context: fork
agent: scene-planner
allowed-tools: Read, Grep, Glob, Bash
---
Plan this animation task:

$ARGUMENTS

Return:
1. Visual goal — one sentence
2. Sequence of beats — ordered storyboard
3. Required classes/helpers — what to build or reuse from lib/
4. Scene/file targets — where code goes
5. Smoke-render command — exact command to validate
6. Risks and edge cases — LaTeX, layout, timing
