# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Superpowers is a Claude Code plugin that provides composable "skills" for software development workflows. The plugin injects the `using-superpowers` skill at session start, which instructs Claude on when and how to invoke other skills.

**Core philosophy:** Skills enforce discipline (TDD, systematic debugging, brainstorming before coding) through mandatory checklists and red-flag detection.

## Architecture

### Plugin Structure

```
superpowers/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json      # Local marketplace config for testing
├── skills/                   # All skill definitions (SKILL.md files)
├── commands/                 # Slash commands (/brainstorm, /write-plan, /execute-plan)
├── agents/                   # Reusable agent definitions (code-reviewer)
├── hooks/                    # SessionStart hook injection
├── lib/                      # Shared JavaScript modules
└── tests/                    # Integration and unit test suites
```

### Skill File Format

Each skill directory contains a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: Use when [condition] - [what it does]
---

# Skill Content

[Detailed instructions in markdown]
```

**Critical:** The `description` field must be trigger-only ("Use when X"). Including workflow summaries in descriptions causes the "Description Trap" - Claude follows the short description instead of reading detailed content.

### Session Start Bootstrap

The `SessionStart` hook (`hooks/session-start.sh`) injects the full `using-superpowers` skill content into every session's context. This establishes skills protocol before any user interaction.

**Key implementation detail:** The hook uses a polyglot wrapper (`run-hook.cmd`) that works on both Windows (cmd.exe + Git bash) and Unix systems.

### Skill Namespacing

- **Plugin skills:** `superpowers:skill-name` (e.g., `superpowers:test-driven-development`)
- **Personal skills:** `skill-name` (from `~/.claude/skills/`)
- **Personal skills override plugin skills** when names match

## Common Commands

### Testing

```bash
# Run Claude Code skill tests (fast unit tests)
cd tests/claude-code
./run-skill-tests.sh

# Run integration tests (slow, 10-30 min, real subagent execution)
./run-skill-tests.sh --integration

# Run specific test
./run-skill-tests.sh --test test-subagent-driven-development.sh

# Run explicit skill request tests
cd tests/explicit-skill-requests
./run-test.sh subagent-driven-development ./prompts/subagent-driven-development-please.txt
```

### Token Analysis

```bash
# Analyze token usage from a Claude Code session
python3 tests/claude-code/analyze-token-usage.py ~/.claude/projects/<project-dir>/<session-id>.jsonl
```

### Development Workflow

1. **Modify a skill:** Edit `skills/<skill-name>/SKILL.md`
2. **Test locally:** Use `--plugin-dir` flag to load from source
   ```bash
   claude -p "test prompt" --plugin-dir /path/to/superpowers
   ```
3. **Update version:** Edit `.claude-plugin/plugin.json` and `RELEASE-NOTES.md`
4. **Commit:** Use conventional commit format

## Key Skills Overview

### Mandatory Entry Points

- **using-superpowers** - Injected at session start. Establishes the "check for skills first" rule with red-flag tables to prevent rationalization.
- **brainstorming** - MUST use before any creative work. Asks questions one at a time, presents design in sections for validation.
- **systematic-debugging** - MUST use before any bug fix. Four-phase root cause investigation before attempting fixes.

### Execution Flows

- **subagent-driven-development** - Execute implementation plans in current session. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality).
- **executing-plans** - Alternative: batch execution with human checkpoints in parallel session.

### Disciplines

- **test-driven-development** - RED-GREEN-REFACTOR. Iron law: delete code written before tests.
- **systematic-debugging** - Root cause before fixes. Four phases: investigate → pattern → hypothesis → implement.

## Slash Commands

Commands in `commands/` are user-only (`disable-model-invocation: true`):

- `/brainstorm` - Shortcut for `superpowers:brainstorming`
- `/write-plan` - Shortcut for `superpowers:writing-plans`
- `/execute-plan` - Shortcut for `superpowers:executing-plans`

These redirect to skills but prevent Claude from invoking them autonomously (users explicitly trigger them).

## Testing Infrastructure

### Test Types

1. **skill-triggering/** - Validates skills trigger from naive prompts without explicit naming
2. **claude-code/** - Integration tests using `claude -p` with JSONL transcript analysis
3. **explicit-skill-requests/** - Verifies Claude invokes skills when users name them directly
4. **subagent-driven-dev/** - End-to-end workflow validation with real projects

### Test Projects

Subagent-driven-dev tests use complete mini-projects:
- `go-fractals/` - CLI tool (10 tasks)
- `svelte-todo/` - CRUD app (12 tasks)

### Session Transcript Format

Tests parse `.jsonl` session files to verify:
- Skill tool was invoked
- Subagents were dispatched (Task tool)
- TodoWrite was used for tracking
- Tests pass
- Git commits show proper workflow

## Skill Writing Guidelines

See `skills/writing-skills/SKILL.md` for complete guide. Key points:

1. **Description trap:** Descriptions must be trigger-only. No workflow summaries.
2. **DOT flowcharts:** Use for decision processes. Prose supports, flowchart defines.
3. **Token efficiency:** Target <500 lines per skill. Progressive disclosure.
4. **Cross-references:** Use `superpowers:skill-name` format with requirement markers:
   - `**REQUIRED SUB-SKILL:**` - Must use in workflow
   - `**REQUIRED BACKGROUND:**` - Must understand first
   - `**Complementary skills:**` - Optional but helpful

## Platform Support

### Claude Code (Primary)

Native plugin via `.claude-plugin/`. Uses Skill tool and SessionStart hooks.

### Codex (Experimental)

Uses `~/.codex/superpowers/.codex/superpowers-codex` script. Tool mapping:
- `TodoWrite` → `update_plan`
- `Task` tool → Manual fallback (subagents not available)
- `Skill` tool → `superpowers-codex use-skill`

### OpenCode (Experimental)

Native JavaScript plugin with custom tools (`use_skill`, `find_skills`). Uses shared `lib/skills-core.js` module.

## Release Process

1. Update version in `.claude-plugin/plugin.json`
2. Add entry to `RELEASE-NOTES.md` with date, changes, breaking changes
3. Commit with conventional format
4. Tag release (git follows semantic versioning)
5. Update marketplace if needed

## Common Issues

### Skills Not Loading

- Ensure running from plugin directory for local testing
- Check `~/.claude/settings.json` has plugin enabled
- Verify skill frontmatter is valid YAML

### Description Trap

Symptom: Claude follows short description instead of detailed process.
Fix: Remove all workflow details from `description:` field. Keep only "Use when X".

### Skill Not Triggering

- Check trigger strength in description (`description: "You MUST use this..."` vs `description: "Use when..."`)
- For explicit requests, ensure `using-superpowers` emphasizes requested skills
- Test with `tests/explicit-skill-requests/` suite
