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

## License

MIT
