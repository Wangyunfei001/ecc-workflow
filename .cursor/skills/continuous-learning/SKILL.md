---
name: continuous-learning
description: 持续学习系统概览。双模学习架构的编排skill，协调主动学习、被动学习和Instinct演化。
version: 3.0.0
globs: []
apply_when: |
  - 需要了解持续学习系统
  - 首次使用学习功能
priority: 20
requires: []
outputs: []
---

# 持续学习 (Continuous Learning) v3.0

## 概述

双模学习系统，从开发会话中自动提取编码模式和偏好，形成可复用的"直觉库"。

```
┌────────────────────────────────────────────────────────────┐
│                  Continuous Learning                        │
│                    （双模学习系统）                           │
├────────────────────────────────────────────────────────────┤
│  🔍 主动学习 ──▶ 快速建立项目认知 ──▶ 初始Instincts         │
│  👀 被动学习 ──▶ 日常观察积累 ──▶ 动态调整Instincts         │
│  🧬 演化 ──▶ 聚类Instincts ──▶ Skills/Commands/Agents      │
└────────────────────────────────────────────────────────────┘
```

## 子Skills

| Skill | 说明 | 触发 |
|-------|------|------|
| [active-learning](../active-learning/SKILL.md) | 主动学习，快速分析项目 | `/learn-project` |
| [passive-learning](../passive-learning/SKILL.md) | 被动学习，日常观察 | Hooks自动 |
| [instinct-evolution](../instinct-evolution/SKILL.md) | Instinct演化 | `/evolve` |

## 记忆架构

| 层级 | 位置 | 内容 | 共享 |
|------|------|------|------|
| 项目级 | `docs/` | Spec、计划、ADR | Git自动 |
| 用户级 | `~/.cursor/homunculus/` | Instincts、习惯 | export/import |

## 命令速查

| 命令 | 说明 |
|------|------|
| `/learn-project` | 主动学习项目 |
| `/instinct-status` | 查看Instincts |
| `/evolve` | 演化Instincts |
| `/instinct-export` | 导出Instincts |
| `/instinct-import` | 导入Instincts |

## 典型流程

```bash
# Day 1: 主动学习
/learn-project --depth=medium

# Week 1-4: 被动学习（自动）
# 正常开发，Hooks自动观察

# Month 1: 演化
/evolve
```

## 相关资源

- [Observer Agent](./agents/observer.md)
- [命令文档](../../commands/) — learn-project, instinct-status, evolve 等
