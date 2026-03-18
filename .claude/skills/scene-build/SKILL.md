---
name: scene-build
description: Implement an approved Manim scene plan.
user-invocable: true
argument-hint: "<scene plan or description to implement>"
context: fork
agent: scene-builder
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---
Implement this scene plan:

$ARGUMENTS

Requirements:
- Follow repository conventions (see CLAUDE.md and AGENTS.md)
- Prefer helper reuse from lib/ over duplication
- Type-annotate all lib/ functions
- Run ruff check + format after implementation
- Include a smoke-render command and run it
- Report the render result
