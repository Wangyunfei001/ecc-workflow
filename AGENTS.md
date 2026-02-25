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
- `jq empty .cursor-plugin/plugin.json hooks/hooks.json hooks/hooks.core.json hooks/hooks.compat.json hooks/hooks.learning.json` — JSON validation
- Verify all 13 skills have `SKILL.md`: `for d in skills/*/; do test -f "$d/SKILL.md" && echo "OK $d" || echo "MISSING $d"; done`

### Running the install script

`scripts/install.sh` is interactive (prompts for confirmation). Pipe `echo "Y"` for non-interactive use:
```
echo "Y" | bash scripts/install.sh [--enable-hooks] <target-project-path>
```

### TaskGraph protocol status

Task decomposition and orchestration now use a unified TaskGraph protocol:

- Spec: `docs/architecture/task-graph-protocol.md`
- Command-level protocol sections: `orchestrate`, `learn-project`, `analyze`, `implement`, `review`
- Routing alignment: `rules/agent-routing.md`
- Capability probe: `scripts/verify-setup.sh --mode learning`

This repo still relies on prompt/rule-driven orchestration. It does not include a standalone runtime DAG scheduler service.

### Redesign specification status

A spec-only redesign package is available and should be treated as the implementation baseline for future script changes:

- `docs/architecture/plugin-contract.md`
- `docs/specs/features/installer-redesign.md`
- `docs/specs/features/hooks-layering.md`
- `docs/specs/features/verify-redesign.md`
- `docs/migration/legacy-to-marketplace.md`

Important: these documents define target behavior but do not mean the current shell scripts are already updated.
