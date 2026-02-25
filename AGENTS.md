# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This is **ecc-workflow**, a Cursor IDE plugin consisting entirely of Markdown, JSON, and Bash files. There is no package manager, no build system, no runtime server, and no automated test suite.

### Key directories

| Directory | Contents |
|---|---|
| `agents/` | 10 AI agent role definitions (architect, planner, coder, reviewer, etc.) |
| `skills/` | 13 skill definitions, each with a `SKILL.md` entry point |
| `commands/` | 11 slash-command definitions (`/analyze`, `/spec`, `/implement`, etc.) |
| `rules/` | 5 rule sets (quality gates, routing, coding standards, security) |
| `templates/` | 3 document templates (ADR, requirement, spec) |
| `hooks/` | Automation hooks config (`hooks.json`) |
| `scripts/` | `install.sh` (installs plugin into a project) and `verify-setup.sh` (validates continuous-learning config) |
| `.cursor-plugin/` | `plugin.json` manifest for Cursor Marketplace |

### Linting / validation

There is no traditional linter. Validate correctness with:
- `bash -n scripts/install.sh scripts/verify-setup.sh` — shell syntax check
- `jq empty .cursor-plugin/plugin.json hooks/hooks.json` — JSON validation
- Verify all 13 skills have `SKILL.md`: `for d in skills/*/; do test -f "$d/SKILL.md" && echo "OK $d" || echo "MISSING $d"; done`

### Running the install script

`scripts/install.sh` is interactive (prompts for confirmation). Pipe `echo "Y"` for non-interactive use:
```
echo "Y" | bash scripts/install.sh [--enable-hooks] <target-project-path>
```

### Known caveats

- `install.sh` and `verify-setup.sh` reference a `.cursor/` sub-directory layout from pre-marketplace versions. In the current marketplace layout, plugin content lives at root level (`agents/`, `skills/`, etc.), so the copy step in `install.sh` finds 0 files and `verify-setup.sh` reports failures for command/doc checks. This is an existing repo state, not an environment issue.
- `verify-setup.sh` also checks for `~/.cursor/homunculus/config.json` which is not created by `install.sh`; this is another pre-existing gap.
