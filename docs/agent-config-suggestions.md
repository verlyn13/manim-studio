Yes. For **Claude Code CLI in March 2026**, the strongest setup for this kind of Manim/animation repo is:

* **one top-level orchestrator**
* **a small set of focused subagents**
* **skills for repeatable workflows**
* **hooks for deterministic quality gates**
* **`CLAUDE.md` + rules for project memory**
* **`opusplan` for most daily work, with pinned `claude-opus-4-6[1m]` for architecture-heavy sessions**

That matches Claude Code’s current feature set: custom subagents with tool/model/permission controls, skills with `context: fork`, hooks, `CLAUDE.md` plus auto memory, and the `opusplan` alias that uses **Opus in plan mode** and **Sonnet in execution mode**. Anthropic’s current aliases point `opus` to **Opus 4.6** and `sonnet` to **Sonnet 4.6**; both support **1M context** where available. ([Claude API Docs][1])

I would **not** make **agent teams** your default architecture here. Anthropic currently marks agent teams as **experimental** and disabled by default, with known limitations. For a Manim codebase, a single lead agent plus subagents is cleaner and easier to reason about. Use agent teams only for exceptional parallel investigations or parallel review passes. ([Claude][2])

## Recommended operating model

Use **`opusplan`** as your normal entry point:

```bash
claude --model opusplan --effort high --agent manim-orchestrator
```

Then switch to pinned **Opus 4.6** only when you want the most careful architectural reasoning:

```bash
claude --model claude-opus-4-6[1m] --effort high --agent manim-orchestrator
```

That aligns with Claude Code’s current model behavior: `opusplan` gives Opus for plan mode and Sonnet for execution, while Opus 4.6 supports `max` effort and 1M context. ([Claude API Docs][3])

## Repo layout

```text
.claude/
├── CLAUDE.md
├── settings.json
├── rules/
│   ├── python-manim.md
│   ├── rendering.md
│   └── pedagogy.md
├── agents/
│   ├── manim-orchestrator.md
│   ├── scene-planner.md
│   ├── scene-builder.md
│   ├── render-debugger.md
│   ├── visual-qa.md
│   └── asset-researcher.md
├── skills/
│   ├── scene-plan/SKILL.md
│   ├── scene-build/SKILL.md
│   ├── render-fix/SKILL.md
│   ├── animation-review/SKILL.md
│   ├── latex-guidelines/SKILL.md
│   ├── manim-style/SKILL.md
│   └── debug-playbook/SKILL.md
└── hooks/
    ├── check-style.sh
    ├── run-scene-smoke.sh
    └── block-dangerous-bash.sh
```

Claude Code officially supports project-scoped settings in `.claude/settings.json`, project `CLAUDE.md`, project subagents in `.claude/agents/`, and project skills in `.claude/skills/`. Start as standalone project config; if this becomes reusable across repos, Anthropic’s current guidance is to convert it into a plugin later. ([Claude][4])

## The agent framework

The key design constraint is important: **subagents cannot spawn other subagents**. So the architecture should be **flat**, with all delegation happening from the main orchestrator only. Claude Code’s built-in Explore/Plan/general-purpose agents are still useful, but your custom top-level conductor should own all explicit delegation. ([Claude API Docs][5])

### 1. `manim-orchestrator`

Run this as the main session agent.

Purpose:

* decompose requests
* decide whether to use built-in **Explore** first
* delegate planning, implementation, debugging, and review
* integrate final changes

Suggested file:

```md
---
name: manim-orchestrator
description: Lead agent for Manim work. Breaks tasks into planning, implementation, debugging, and review, then delegates to the appropriate subagent and integrates results.
tools: Agent(scene-planner, scene-builder, render-debugger, visual-qa, asset-researcher), Read, Grep, Glob, Bash, Edit, Write, Skill
model: inherit
memory: project
---
You are the lead agent for this Manim repository.

Rules:
- Keep delegation flat. Subagents do not spawn other subagents.
- Use scene-planner before scene-builder for any nontrivial animation task.
- Use render-debugger for runtime, ffmpeg, LaTeX, or environment failures.
- Use visual-qa before declaring a scene complete.
- Prefer low-quality smoke renders during iteration; reserve final renders for the end.
- Update project memory with reusable architectural decisions.
```

### 2. `scene-planner`

Purpose:

* translate lesson goals into a scene spec
* produce shot order, animation intent, timing, math objects, helper abstractions
* identify what should become reusable library code

Suggested configuration:

```md
---
name: scene-planner
description: Plans Manim scenes, storyboard flow, object choreography, helper abstractions, and implementation boundaries before coding begins.
tools: Read, Grep, Glob, Bash
model: claude-opus-4-6
permissionMode: plan
memory: project
skills:
  - pedagogy-guidelines
  - rendering
---
Plan the scene before implementation.

Output:
1. scene goal
2. visual sequence
3. math objects and transforms
4. helper abstractions to create/reuse
5. likely failure points
6. smoke-test command
```

### 3. `scene-builder`

Purpose:

* implement or refactor scene code
* create reusable helpers
* keep scene files small and maintainable

```md
---
name: scene-builder
description: Implements or refactors Manim scenes and supporting helpers while following repository conventions.
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
memory: project
skills:
  - manim-style
  - latex-guidelines
  - render-contracts
---
Implement approved scene plans cleanly.

Priorities:
- readable scene structure
- reusable helpers over duplication
- stable smoke-render path
- minimal side effects outside the target scope
```

### 4. `render-debugger`

Purpose:

* handle Manim tracebacks
* fix LaTeX issues
* fix ffmpeg/export failures
* fix environment/config regressions

```md
---
name: render-debugger
description: Diagnoses and fixes Manim runtime, LaTeX, ffmpeg, and environment failures with minimal code changes.
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
memory: project
skills:
  - debug-playbook
  - latex-guidelines
  - render-contracts
---
Debug by reproducing, narrowing the failure, applying the smallest robust fix, and rerunning a smoke render.
```

### 5. `visual-qa`

Purpose:

* evaluate pacing
* readability at normal playback
* cognitive load for students
* clutter, camera flow, transition quality

```md
---
name: visual-qa
description: Reviews Manim animations for clarity, pacing, composition, pedagogy, and viewer comprehension.
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
skills:
  - pedagogy-guidelines
  - animation-review-rubric
---
Review scenes as a viewer and instructor, not as an implementer.

Focus on:
- what a student can actually track on screen
- excessive simultaneous motion
- text size and dwell time
- whether transitions explain, not merely decorate
```

### 6. `asset-researcher`

Purpose:

* find or validate fonts, SVGs, palette choices, licensing notes, and external references
* never edit code

```md
---
name: asset-researcher
description: Finds and validates assets, references, fonts, and source material without modifying project files.
tools: Read, Grep, Glob, WebFetch, WebSearch, Bash
disallowedTools: Edit, Write
model: haiku
permissionMode: dontAsk
---
Research only. Return concise recommendations with source notes and file placement suggestions.
```

Claude Code officially supports per-agent `tools`, `disallowedTools`, `model`, `permissionMode`, `skills`, `hooks`, and `memory`. Preloaded skills are injected into the subagent’s context at startup, and subagents do **not** inherit the parent’s skills automatically. ([Claude API Docs][5])

## The skill framework

Use **skills** for workflows you want both humans and Claude to invoke repeatedly. Anthropic’s current docs say custom commands have effectively merged into skills, so a skill directory creates a slash command like `/scene-plan`. Skills can run inline or in an isolated forked subagent with `context: fork`. ([Claude][6])

### Skill 1: `/scene-plan`

This should run in isolation through the planner.

```md
---
name: scene-plan
description: Create a scene plan and implementation outline for a Manim animation task.
context: fork
agent: scene-planner
allowed-tools: Read, Grep, Glob, Bash
---
Plan this animation task:

$ARGUMENTS

Return:
1. visual goal
2. sequence of beats
3. required classes/helpers
4. scene/file targets
5. smoke-render command
6. risks and edge cases
```

### Skill 2: `/scene-build`

Route to the builder.

```md
---
name: scene-build
description: Implement an approved Manim scene plan.
context: fork
agent: scene-builder
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---
Implement this approved scene plan:

$ARGUMENTS

Requirements:
- preserve repository conventions
- prefer helper reuse
- include a concrete smoke-render command
```

### Skill 3: `/render-fix`

Route logs and failures to the debugger.

```md
---
name: render-fix
description: Reproduce and fix a Manim render or export failure.
context: fork
agent: render-debugger
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---
Fix this failure:

$ARGUMENTS

Process:
1. reproduce
2. isolate the true cause
3. patch minimally
4. rerun a smoke render
5. summarize cause and fix
```

### Skill 4: `/animation-review`

For human-experience review.

```md
---
name: animation-review
description: Review a Manim scene for pacing, readability, pedagogy, and visual quality.
context: fork
agent: visual-qa
allowed-tools: Read, Grep, Glob, Bash
---
Review this scene or render target:

$ARGUMENTS

Score:
- clarity
- pacing
- composition
- pedagogical usefulness
- final recommendations
```

### Skill 5: `manim-style`

This one should be **inline reference content**, not forked.

```md
---
name: manim-style
description: Coding conventions for Manim scene files and helper modules.
disable-model-invocation: false
allowed-tools: Read, Grep
---
Conventions:
- one conceptual scene per class unless short tightly-coupled variants justify grouping
- keep construct() readable; move mechanics into helpers
- prefer named helper methods over long inline lambdas
- keep mathematical intent obvious from code structure
- low-quality smoke render first, final render last
```

### Skill 6: `latex-guidelines`

Also inline reference content.

```md
---
name: latex-guidelines
description: Local conventions for MathTex/Tex usage, escaping, alignment, and common failure patterns.
allowed-tools: Read, Grep
---
Guidelines:
- prefer stable MathTex fragments over giant monolithic expressions
- isolate alignment-sensitive expressions
- avoid hidden whitespace changes in multiline expressions
- when debugging TeX, reduce to the smallest failing expression
```

The useful official nuance here is that `context: fork` makes the skill execute in a fresh isolated context, and the `agent` field selects which subagent configuration provides the model/tools/permissions for that skill. ([Claude][6])

## Hooks and quality gates

For this repo, put enforcement in **hooks**, not in prose instructions. Anthropic’s docs are explicit that hooks are the right mechanism for actions that must happen every time, and that they are deterministic rather than advisory. They also note hooks add **zero context cost** unless their output is injected back into the conversation. ([Claude][7])

I would add three hooks:

1. **Post-edit style gate**

   * run `ruff check --fix` or your preferred formatter/linter on touched Python files

2. **Post-edit scene smoke gate**

   * if a `scenes/*.py` file changed, run a fast low-quality render for the touched scene

3. **Pre-Bash safety gate**

   * block obviously destructive shell commands and accidental writes to generated/output areas

Example `.claude/settings.json` skeleton:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "opusplan",
  "permissions": {
    "defaultMode": "acceptEdits",
    "disableBypassPermissionsMode": "disable",
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(uv run manim *)",
      "Bash(uv run ruff *)",
      "Bash(uv run pytest *)",
      "Bash(ffmpeg *)",
      "WebFetch(domain:docs.manim.community)",
      "WebFetch(domain:pypi.org)",
      "WebFetch(domain:github.com)"
    ],
    "ask": [
      "Bash(git commit *)",
      "Bash(git push *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Edit(./media/**)",
      "Write(./media/**)",
      "Bash(rm -rf *)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-bash.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-style.sh",
            "timeout": 60
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/run-scene-smoke.sh",
            "async": true,
            "timeout": 300
          }
        ]
      }
    ]
  }
}
```

That structure is consistent with Anthropic’s current settings and hooks docs, including the official schema, permission rules, `disableBypassPermissionsMode`, and hook matcher format. The `/hooks` menu can inspect the effective hook set. ([Claude][4])

## `CLAUDE.md` strategy

Use `CLAUDE.md` for:

* repository architecture
* render commands
* naming conventions
* what “done” means
* where scenes, helpers, assets, and exports live

Use **rules files** for narrower scopes:

* Python/Manim coding conventions
* rendering workflow
* pedagogical standards

Anthropic’s docs distinguish `CLAUDE.md` from auto memory: `CLAUDE.md` is for instructions and rules you author, while auto memory accumulates learned patterns. More specific scopes override broader ones, and subdirectory rules can load on demand. ([Claude API Docs][1])

A good project `CLAUDE.md` for this repo would include:

* canonical smoke-render commands
* “never commit `media/`”
* when to use low vs final quality
* asset naming and licensing notes
* approved fonts and visual style
* review checklist before final export

## Worktree and batch strategy

Claude Code has first-class **git worktree** support via `--worktree`, and its built-in `/batch` skill can decompose large repo-wide changes into **5 to 30 independent units**, then run one background agent per unit in isolated worktrees. For a Manim repo, that is ideal for things like:

* migrating helper APIs across many scenes
* normalizing imports
* standardizing style or caption handling
* splitting monolithic scene files into reusable helpers ([Claude][6])

For normal focused work:

```bash
claude --model opusplan --effort high --agent manim-orchestrator --worktree pascal-identity
```

For a repo-wide mechanical upgrade, prefer the built-in:

```text
/batch migrate all scene files to the new helper API and update smoke-render commands
```

If your worktrees would otherwise duplicate heavy shared directories, Claude Code also supports `worktree.symlinkDirectories` and `worktree.sparsePaths` in settings. That is useful for large Manim asset directories. ([Claude][8])

## Practical defaults I would choose

* **Main session:** `opusplan`
* **Architecture-only session:** `claude-opus-4-6[1m] --effort high`
* **Planner agent:** pinned `claude-opus-4-6`
* **Builder/debugger agents:** `sonnet`
* **Asset researcher:** `haiku`
* **Explore:** leave Claude’s built-in Explore alone; it already uses a fast read-only Haiku setup for codebase discovery. ([Claude API Docs][5])

## One extra detail that matters on the CLI

Claude Code’s Bash tool keeps the **working directory** across commands, but **environment variables do not persist** between Bash invocations. Anthropic’s docs recommend activating your environment before launching Claude Code, or using `CLAUDE_ENV_FILE` / a `SessionStart` hook if you need persistent env setup. For a Manim repo, that means you should launch Claude Code from the already-activated `uv` environment or set a session-start environment bootstrap. ([Claude][9])

## Bottom line

For your Manim work, the cleanest pro framework is:

* **`opusplan` main session**
* **one flat lead agent**
* **5 focused subagents**
* **skills as slash-command workflows**
* **hooks as the real quality gate**
* **`CLAUDE.md` for architecture and conventions**
* **`/batch` + worktrees only for broad mechanical changes**
* **agent teams only as an occasional experimental tool**

That is the most aligned with Anthropic’s current docs and avoids overbuilding around features that are either advisory-only or still experimental. ([Claude][7])

I can turn this into a **complete starter `.claude/` directory** with all agent and skill files filled out for a Manim repo.

[1]: https://docs.anthropic.com/en/docs/claude-code/memory "How Claude remembers your project - Claude Code Docs"
[2]: https://code.claude.com/docs/en/agent-teams?utm_source=chatgpt.com "Orchestrate teams of Claude Code sessions"
[3]: https://docs.anthropic.com/en/docs/claude-code/model-config "Model configuration - Claude Code Docs"
[4]: https://code.claude.com/docs/en/settings "Claude Code settings - Claude Code Docs"
[5]: https://docs.anthropic.com/en/docs/claude-code/sub-agents "Create custom subagents - Claude Code Docs"
[6]: https://code.claude.com/docs/en/skills "Extend Claude with skills - Claude Code Docs"
[7]: https://code.claude.com/docs/en/features-overview "Extend Claude Code - Claude Code Docs"
[8]: https://code.claude.com/docs/en/cli-reference "CLI reference - Claude Code Docs"
[9]: https://code.claude.com/docs/en/tools-reference "Tools reference - Claude Code Docs"

