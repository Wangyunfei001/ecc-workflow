# ecc-workflow

Spec-driven development workflow + continuous learning for Cursor.

## Marketplace install

Install from Cursor Marketplace:

1. Open Cursor Marketplace
2. Search `ecc-workflow`
3. Click **Install**

Or install directly in chat:

```bash
/add-plugin ecc-workflow
```

## Quick start (5 minutes)

Use this minimal flow in a new or existing project:

```bash
# 1) Clarify requirements (Phase 1)
/analyze Build user login with email and phone support

# 2) Plan implementation tasks (Phase 2)
@planner @docs/requirements/<your-requirement-file>.md

# 3) Write implementation-ready spec (Phase 4)
/spec @docs/plans/<your-plan-file>.md

# 4) Implement and validate (Phase 5)
/implement @docs/specs/features/<your-spec-file>.md
/review
/sync
```

For complex features, run `@architect` between `@planner` and `/spec`.

## What this plugin provides

- `rules/`: quality gates, routing, coding and security guardrails
- `skills/`: 5-phase Spec-driven workflow and learning loop
- `agents/`: requirement/planning/architecture/spec/coding/review/doc-sync roles
- `commands/`: `/analyze`, `/spec`, `/implement`, `/review`, `/sync`, and learning commands
- `hooks/`: optional project hooks for reminders, checks, and safety prompts

## Typical flow

1. Run `/analyze` to clarify requirements.
2. Use `@planner` and optionally `@architect` for plan/design.
3. Run `/spec` to produce implementation-grade spec.
4. Run `/implement`, then `/review` and `/sync`.
5. Use `/learn-project` and `/evolve` to improve long-term quality.

## Directory layout

```text
.
├── .cursor-plugin/plugin.json
├── rules/
├── skills/
├── agents/
├── commands/
├── hooks/
├── templates/
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Notes

- `hooks/hooks.json` is optional and intended for project-level automation.
- Existing `templates/` are preserved for skill/command references.

## Redesign status

The plugin redesign docs are available and the first implementation wave is now applied in this repository.

- Contract: `docs/architecture/plugin-contract.md`
- Installer redesign: `docs/specs/features/installer-redesign.md`
- Hooks layering: `docs/specs/features/hooks-layering.md`
- Verify redesign: `docs/specs/features/verify-redesign.md`
- Migration guide: `docs/migration/legacy-to-marketplace.md`

Current direction:

- Core mode first (official Cursor plugin/hook flow)
- Optional learning mode (`homunculus`) as an enhancement layer
- Backward compatibility through an explicit `compat` layer

Implemented highlights:

- `scripts/install.sh` now supports core/learning mode installation and layered hooks composition.
- `scripts/verify-setup.sh` now supports mode-based verification with grouped checks.
- `hooks/` is split into `core`, `compat`, and `learning` layers.
- `observe.sh` now supports stdin-first parsing with environment-variable fallback.

## TaskGraph protocol

Task decomposition now follows a unified protocol:

- Protocol spec: `docs/architecture/task-graph-protocol.md`
- Commands with protocol section:
  - `commands/orchestrate.md`
  - `commands/learn-project.md`
  - `commands/analyze.md`
  - `commands/implement.md`
  - `commands/review.md`
- Routing alignment: `rules/agent-routing.md`

To trigger parallel subagent cards in Cursor UI, ensure the command/prompt instructs the agent to launch multiple subagents in the same turn with concise `description` fields.

## Validation checklist

```bash
bash -n scripts/install.sh scripts/verify-setup.sh
jq empty .cursor-plugin/plugin.json hooks/hooks.json hooks/hooks.core.json hooks/hooks.compat.json hooks/hooks.learning.json
for d in skills/*/; do test -f "$d/SKILL.md" && echo "OK $d" || echo "MISSING $d"; done
bash scripts/verify-setup.sh --mode core --target <target-project>
bash scripts/verify-setup.sh --mode learning --target <target-project>
```

## License

MIT
