# TaskGraph Protocol

## 1. Purpose

TaskGraph is the unified protocol for workflow decomposition in `ecc-workflow`.
It standardizes how commands define:

- task breakdown
- dependency order
- parallel execution groups
- merge strategy
- checkpoints and acceptance criteria

This document is the single source of truth for command-level orchestration semantics.

## 2. Minimal Schema

```yaml
workflow_id: wf-<date>-<name>
goal: "Natural-language goal"
tasks:
  - id: T1
    name: "<task name>"
    owner: "<agent name>"
    depends_on: []
    parallelizable: false
    input: ["artifact-a"]
    output_schema: ["artifact-b", "report"]
    done_criteria:
      - "<check item>"
checkpoints:
  - id: C1
    after_tasks: ["T2"]
    type: human_review
merge:
  after: ["T3", "T4"]
  strategy: all_must_pass
```

## 3. Field Definitions

### 3.1 Workflow Fields

- `workflow_id`: unique run identifier
- `goal`: user-level objective
- `tasks`: executable unit list
- `checkpoints`: explicit pause nodes for human confirmation
- `merge`: branch convergence policy

### 3.2 Task Fields

- `id`: globally unique in workflow (`T1`, `T2`, ...)
- `name`: stable task name
- `owner`: designated agent role
- `depends_on`: predecessor task ids
- `parallelizable`: whether scheduler can run task concurrently
- `input`: required artifacts or context keys
- `output_schema`: expected outputs for downstream tasks
- `done_criteria`: acceptance checklist

## 4. Scheduling Rules

1. A task is runnable only when all `depends_on` tasks succeed.
2. A task can run in parallel only if:
   - `parallelizable=true`
   - all dependencies are satisfied
   - no policy conflict exists (e.g., safety gate).
3. Failed task behavior:
   - block dependent tasks
   - allow retry or fallback path if defined.
4. Checkpoint behavior:
   - workflow pauses after `after_tasks`
   - resume requires explicit approval.

## 5. Merge Strategy

Supported values:

- `all_must_pass`: all upstream branches must pass.
- `best_effort`: proceed with partial pass and emit warnings.
- `security_gate`: security branch must pass; others may be warnings.

Default strategy for review branches is `all_must_pass`.

## 6. Status Model

Each task uses one status:

- `pending`
- `running`
- `succeeded`
- `failed`
- `blocked`
- `cancelled`

## 7. Protocol Priorities

When protocol rules conflict:

1. security policy
2. dependency constraints
3. explicit user override
4. optimization preference (parallelization)

## 8. Command Mapping

- `/orchestrate`: full TaskGraph producer and scheduler.
- `/learn-project`: phase-based TaskGraph with parallel extraction/doc generation.
- `/analyze`: question decomposition TaskGraph (clarification graph).
- `/implement`: spec-driven TaskGraph (implementation + test + report).
- `/review`: multi-dimension review TaskGraph with merge.

## 9. Validation Hooks

Validation should confirm:

- schema presence
- dependency soundness (no orphan dependency)
- merge node references valid task ids
- checkpoint references valid upstream tasks

`scripts/verify-setup.sh --mode learning` includes protocol capability probes.
