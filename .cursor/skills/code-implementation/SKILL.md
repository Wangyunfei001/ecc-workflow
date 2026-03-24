---
name: code-implementation
description: 代码实现工作流（Phase 5）。严格按Spec实现代码，包含审查和文档同步。
version: 1.0.0
globs: ["src/**/*"]
apply_when: |
  - Spec已approved
  - /implement 命令触发
  - @strict-coder 调用
priority: 60
requires: ["spec-writing"]
outputs: ["src/**/*"]
---

# 代码实现 (Phase 5)

## 目标

严格按 Spec 实现代码，不添加任何额外功能。

## 输入

状态为 `approved` 的 Spec 文档

## 触发方式

```bash
"/implement @docs/specs/features/[feature-name].md"
```

## 约束（红线）

- 只实现 Spec 中定义的内容
- 不添加任何额外功能
- 不修改任何 Spec 未提及的代码

## 后续步骤

### 代码审查

```bash
"/review"
```

审查维度：
1. **Spec 合规性** — 代码是否与 Spec 一致？
2. **代码质量** — 是否符合编码规范？
3. **安全性** — 是否存在安全漏洞？
4. **测试覆盖** — 测试是否充分？

### 文档同步

```bash
"/sync"
```

同步内容：
- 更新 Spec 变更日志
- 更新 Codemap
- 标记 Spec 为 `implemented`

## 输出

符合 Spec 的代码实现，通过审查和文档同步后闭环完成。

## 相关资源

- [strict-coder Agent](../../agents/strict-coder.md)
- [code-reviewer Agent](../../agents/code-reviewer.md)
- [librarian Agent](../../agents/librarian.md)
