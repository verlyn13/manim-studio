---
name: animation-review
description: Review a Manim scene for pacing, readability, pedagogy, and visual quality.
user-invocable: true
argument-hint: "<scene file and class name to review>"
context: fork
agent: visual-qa
allowed-tools: Read, Grep, Glob, Bash
---
Review this scene:

$ARGUMENTS

Score each dimension (1-5):
- Clarity: Can a student track every element?
- Pacing: Are wait times and animation speeds appropriate?
- Composition: Is screen space used effectively?
- Pedagogy: Does the animation build understanding?

Then provide:
- Strengths
- Issues (with specific code locations)
- Prioritized recommendations
