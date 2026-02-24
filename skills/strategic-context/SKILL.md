---
name: strategic-context
description: 上下文管理高级技能。包含战略性压缩、迭代检索、评估框架等高级功能，用于长会话和复杂任务的上下文优化。
version: 2.0.0
globs: []
apply_when: |
  - 长时间开发会话（>1小时）
  - 上下文窗口接近满载（>70%）
  - 复杂多步骤任务
  - /compact 命令触发
  - 需要评估驱动开发
priority: 10
requires: []
outputs: []
---

# 战略性上下文管理 (Strategic Context)

## 概述

本 Skill 集成了 ECC 的高级上下文管理功能，帮助在长会话和复杂任务中保持高效的上下文利用。

## 包含功能

### 1. Strategic Compact（战略性压缩）

在任务的逻辑边界手动进行上下文压缩，而非依赖自动压缩。

#### 何时使用

- 上下文窗口接近满载（通常 > 70%）
- 完成一个重要阶段，即将开始下一阶段
- 长时间开发会话（> 1 小时）
- 需要保留关键信息的复杂任务

#### 使用方式

```bash
# 在逻辑节点手动触发
/compact

# 或者明确告知 AI
"请在开始下一阶段前，总结当前进度并压缩上下文"
```

#### 最佳实践

```
Phase 1: 需求分析
    │
    ▼ ← /compact (保留: 需求要点、关键决策)
Phase 2: Spec 撰写
    │
    ▼ ← /compact (保留: Spec 核心内容、API 定义)
Phase 3: 代码实现
    │
    ▼ ← /compact (保留: 实现进度、遇到的问题)
Phase 4: 审查修复
```

#### 压缩时保留的信息

| 信息类型 | 是否保留 | 说明 |
|---------|---------|------|
| 核心需求 | ✅ | 用户的原始意图 |
| 关键决策 | ✅ | 架构选择、技术决策 |
| 当前进度 | ✅ | 已完成/待完成的任务 |
| 错误解决 | ✅ | 重要的 bug 修复经验 |
| 中间对话 | ❌ | 探索性讨论、已解决的问题 |
| 代码细节 | ❌ | 可以重新读取的代码内容 |

---

### 2. Iterative Retrieval（迭代检索）

渐进式细化上下文检索，解决子代理上下文问题。

#### 何时使用

- 复杂多步骤任务
- 需要跨多个文件/模块的信息
- 子代理需要额外上下文
- 初次检索结果不足以解决问题

#### 工作流程

```
Step 1: 广泛检索
    │
    ▼ 评估结果
Step 2: 定向检索（基于 Step 1 的线索）
    │
    ▼ 评估结果
Step 3: 精准检索（聚焦具体位置）
    │
    ▼
获得完整上下文
```

#### 示例

```bash
# Step 1: 广泛搜索
"搜索所有与用户认证相关的代码"

# 结果: 发现 auth/, middleware/, utils/jwt.ts

# Step 2: 定向检索
"读取 auth/service.ts 和 middleware/auth.ts"

# 结果: 发现关键逻辑在 validateToken 函数

# Step 3: 精准检索
"读取 validateToken 函数及其相关的类型定义"

# 获得完整上下文，可以开始修改
```

#### 最佳实践

1. **先广后窄** — 从目录级开始，逐步缩小范围
2. **记录线索** — 每次检索记录发现的关键路径
3. **验证相关性** — 确认检索的内容与任务相关
4. **避免过度检索** — 只检索必要的内容

---

### 3. Eval Harness（评估框架）

正式的评估驱动开发 (EDD) 原则的评估框架。

#### 核心概念

```
传统开发:  实现 → 测试 → 修复 → 完成
EDD 开发:  定义评估标准 → 实现 → 评估 → 迭代 → 达标
```

#### 评估维度

| 维度 | 评估内容 | 工具 |
|------|---------|------|
| 代码质量 | 复杂度、可读性、规范 | ESLint, Prettier |
| 类型安全 | 类型覆盖、严格性 | TypeScript |
| 测试覆盖 | 行/分支/函数覆盖率 | Jest, Coverage |
| 性能 | 响应时间、内存使用 | Benchmark |
| 安全 | 漏洞、最佳实践 | npm audit, OWASP |

#### 使用方式

```bash
# 定义评估标准
"这个功能的评估标准是:
1. 测试覆盖率 > 80%
2. 类型覆盖率 100%
3. 无 ESLint 错误
4. API 响应时间 < 200ms"

# 实现后评估
"运行评估检查这些标准"

# 迭代改进
"根据评估结果，优化响应时间"
```

#### 评估报告模板

```markdown
# 评估报告

## 📊 评估标准

| 标准 | 目标 | 实际 | 状态 |
|------|------|------|------|
| 测试覆盖率 | > 80% | 85% | ✅ |
| 类型覆盖率 | 100% | 100% | ✅ |
| ESLint 错误 | 0 | 0 | ✅ |
| API 响应时间 | < 200ms | 150ms | ✅ |

## 📝 改进建议

1. 建议添加边界测试用例
2. 可以考虑添加缓存优化响应时间

## ✅ 结论

**PASSED** - 所有评估标准已达成
```

---

## 组合使用

### 长会话最佳实践

```
会话开始
    │
    ▼
Phase 1: 需求分析
    │ 使用 Iterative Retrieval 理解现有代码
    │
    ▼ /compact
Phase 2: 设计
    │ 记录关键决策
    │
    ▼ /compact
Phase 3: 实现
    │ 使用 Eval Harness 定义标准
    │ 迭代直到达标
    │
    ▼ /compact
Phase 4: 审查
    │ 生成评估报告
    │
    ▼
会话结束
```

### 复杂任务处理

```bash
# 1. 定义评估标准
"定义这个重构任务的成功标准:
- 所有测试通过
- 无类型错误
- 代码复杂度降低"

# 2. 迭代检索理解现状
"搜索相关模块"
"读取核心文件"
"理解依赖关系"

# 3. 阶段性压缩
"总结当前理解，准备开始重构"

# 4. 实现并评估
"实现重构"
"运行评估检查"

# 5. 迭代改进
"根据评估结果改进"
```

---

## 配置选项

```json
{
  "strategic_context": {
    "compact": {
      "auto_suggest_threshold": 0.7,  // 上下文使用 70% 时建议压缩
      "preserve_categories": [
        "requirements",
        "decisions",
        "progress",
        "errors"
      ]
    },
    "iterative_retrieval": {
      "max_depth": 3,          // 最大迭代深度
      "breadth_first": true    // 先广后窄
    },
    "eval_harness": {
      "default_coverage_threshold": 80,
      "strict_type_checking": true,
      "lint_on_save": true
    }
  }
}
```

---

## 相关资源

- [ECC Strategic Compact](https://github.com/affaan-m/everything-claude-code)
- [ECC Iterative Retrieval](https://github.com/affaan-m/everything-claude-code)
- [ECC Eval Harness](https://github.com/affaan-m/everything-claude-code)
- [Continuous Learning Skill](../continuous-learning/SKILL.md)
