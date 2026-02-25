# Changelog

## 1.1.0 - 2026-02-25

- Add TaskGraph protocol for multi-agent orchestration:
  - `docs/architecture/task-graph-protocol.md`
  - TaskGraph sections in `orchestrate`, `learn-project`, `analyze`, `implement`, `review` commands
  - TaskGraph scheduling rules in `rules/agent-routing.md`
  - Verify-setup probes for protocol docs and observe.sh capabilities
- Add redesign documents:
  - `docs/architecture/plugin-contract.md`
  - `docs/specs/features/installer-redesign.md`
  - `docs/specs/features/hooks-layering.md`
  - `docs/specs/features/verify-redesign.md`
  - `docs/migration/legacy-to-marketplace.md`
- Rewrite `scripts/install.sh` to v4.0 with:
  - root-level component mapping (`agents/`, `skills/`, `commands/`, `rules/`, `hooks/`, `templates/`)
  - mode-aware install (`core` by default, `--enable-learning` optional)
  - `--dry-run`, `--verify-after`, and verify forwarding
  - layered hooks composition for `.cursor/hooks.json`
- Rewrite `scripts/verify-setup.sh` to v4.0 with:
  - `--mode core|learning`
  - grouped checks (Contract / Install / Hooks / Learning)
  - ERROR/WARN/INFO level output and strict mode support
  - observe capability probe (`stdin` + `input_raw`)
- Introduce layered hooks files:
  - `hooks/hooks.core.json`
  - `hooks/hooks.compat.json`
  - `hooks/hooks.learning.json`
- Upgrade `skills/continuous-learning/hooks/observe.sh`:
  - stdin JSON first, environment fallback second
  - safe JSON recording via `jq`
  - `input_raw` fallback field when raw input is non-JSON
- Update docs in `README.md`, `AGENTS.md`, and `hooks/README.md` to reflect new behavior.

## 1.0.2 - 2026-02-24

- Migrate `hooks/hooks.json` to the new Cursor Hooks schema (`version` + `hooks`).
- Update hook event names to `preToolUse`, `postToolUse`, `beforeSubmitPrompt`, and `stop`.
- Rewrite `hooks/README.md` to match the latest Cursor hooks docs and troubleshooting flow.
- Update plugin metadata version to `1.0.2`.

## 1.0.1 - 2026-02-24

- Improve README with marketplace-friendly install and quick-start sections.
- Add `docs/marketplace-submission.md` with bilingual submission copy.
- Update plugin metadata version to `1.0.1`.

## 1.0.0 - 2026-02-24

- Convert repository to single-plugin marketplace-ready layout.
- Add `.cursor-plugin/plugin.json` for `ecc-workflow`.
- Add marketplace logo at `assets/logo.png` and wire `plugin.json` `logo` field.
- Migrate `.cursor` components to `rules/`, `skills/`, `agents/`, `commands/`, `hooks/`.
- Add missing command/rule frontmatter for submission compatibility.
- Refresh root README and include plugin distribution metadata.
