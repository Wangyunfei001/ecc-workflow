---
name: compact
description: 执行上下文压缩，生成结构化的阶段快照并保存，以便在长会话或会话重启后恢复上下文。
---

# /compact 命令

执行上下文压缩并生成阶段快照。

## 场景与用途

长会话中上下文逐渐变大，或者跨阶段（Phase）时，执行此命令。命令会总结当前的进展并生成结构化快照文件到 `docs/.context-snapshots/` 目录下。当切换 Cursor 会话时，可以用 `@docs/.context-snapshots/phase-X.md` 快速恢复当前开发状态。

## 用法

```bash
/compact
/compact --phase planner
/compact "刚刚完成了数据库设计，准备进入编码"
```

## 执行流程

1. AI 根据近期对话与相关文档（需求/Spec）总结当前状态。
2. 提取并生成以下结构化字段：
   - **current_phase**: 当前所处阶段（如 requirement, plan, spec, implement）
   - **decisions_made**: 已确认的核心决策（非探索性讨论）
   - **artifacts_produced**: 已生成或修改的关键文件路径
   - **open_questions**: 尚待解决的问题或下一步阻碍
   - **next_action**: 明确的下一步行动指令
3. 调用 `node .cursor/scripts/snapshot-context.mjs`（可选）或者直接按上述结构输出并写入 `docs/.context-snapshots/phase-<当前阶段>-<时间>.md`。

## 快照模板示例

```markdown
# Context Snapshot

- **Phase**: planner
- **Date**: 2026-03-23

## Decisions Made
- 数据库选用 PostgreSQL
- 接口协议使用 REST

## Artifacts Produced
- `docs/plans/2026-03-23-login.md`

## Open Questions
- 缓存层是否需要 Redis（留给 architect 决定）

## Next Action
- 交接给 architect 进行架构设计
```