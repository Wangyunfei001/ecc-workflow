# ecc-workflow

Spec-driven development workflow + continuous learning for Cursor.

## Install

```bash
/add-plugin ecc-workflow
```

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
