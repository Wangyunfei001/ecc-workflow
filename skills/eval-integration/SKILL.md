---
name: eval-integration
description: 评估集成工作流。将Eval Harness强制绑定到门禁检查点，确保每个Gate都有量化评估标准。
version: 1.0.0
globs: ["docs/requirements/**/*.md", "docs/plans/**/*.md", "docs/architecture/**/*.md", "docs/specs/**/*.md"]
apply_when: |
  - 门禁检查时自动触发
  - 需要量化评估文档质量
  - 评估驱动开发（EDD）场景
priority: 15
requires: []
outputs: []
---

# 评估集成 (Eval Integration)

## 目标

将Eval Harness强制绑定到Spec-Driven-Dev的门禁检查点，确保每个Gate都有**量化评估标准**。

## 核心原则

```
传统门禁:  人工审查 → status: approved
EDD门禁:   自动评估 + 人工审查 → 达标后 status: approved
```

## 门禁评估标准

### Gate 1: 需求分析

| 检查项 | 自动检查 | 阈值 |
|--------|----------|------|
| 追问清单完成率 | ✅ | >= 80% |
| 用户场景数量 | ✅ | >= 1 |
| 验收标准定义 | ✅ | >= 3条 |
| 范围边界定义 | ✅ | 必须有"不做"列表 |

**自动检查脚本**:
```bash
# 检查追问清单完成率
grep -c "✅\|☑️\|✓" docs/requirements/*.md
```

### Gate 2: 任务规划

| 检查项 | 自动检查 | 阈值 |
|--------|----------|------|
| 任务粒度 | ✅ | 每个2-5分钟 |
| 依赖关系定义 | ✅ | 必须有依赖图 |
| 风险识别 | ✅ | >= 1条 |

### Gate 3: 架构设计

| 检查项 | 自动检查 | 阈值 |
|--------|----------|------|
| ADR完整性 | ✅ | 必须有Context/Decision/Consequences |
| 技术选型记录 | ✅ | >= 1个决策 |
| 影响分析 | ✅ | 必须列出 |

### Gate 4: 规格撰写

| 检查项 | 自动检查 | 阈值 |
|--------|----------|------|
| Spec字段覆盖率 | ✅ | >= 90% |
| 数据模型定义 | ✅ | 必须有类型+约束 |
| API端点定义 | ✅ | 必须有请求/响应 |
| 错误码覆盖 | ✅ | >= 3个 |
| 验收清单 | ✅ | >= 5条 |

**Spec字段检查脚本**:
```bash
# 检查必需章节
required_sections=("概述" "数据模型" "API设计" "边界情况" "验收清单")
for section in "${required_sections[@]}"; do
  grep -q "## .*$section" spec.md || echo "Missing: $section"
done
```

## 评估报告模板

```markdown
# Gate X 评估报告

## 📊 自动检查结果

| 检查项 | 目标 | 实际 | 状态 |
|--------|------|------|------|
| 追问清单完成率 | >= 80% | 85% | ✅ |
| 验收标准数量 | >= 3 | 5 | ✅ |
| 范围边界定义 | 必须 | 有 | ✅ |

## 📝 人工检查项

- [ ] 需求描述清晰无歧义
- [ ] 用户场景覆盖核心流程
- [ ] 约束条件合理

## ✅ 评估结论

**PASSED** - 可以进入下一阶段
```

## 使用方式

### 自动触发（推荐）

在门禁检查时，系统会自动运行评估：

```bash
# 当文档status从draft改为review时
# 自动触发评估检查
```

### 手动触发

```bash
# 评估指定文档
"评估 @docs/requirements/xxx.md 是否达到Gate 1标准"

# 生成评估报告
"生成 Gate 4 评估报告"
```

## 与门禁流程的集成

```
文档编写 → 提交审查 → 自动评估 → 评估报告
                            │
                            ▼
                    ┌───────────────┐
                    │ 达标？        │
                    └───────────────┘
                      │         │
                      ▼         ▼
                    是         否
                      │         │
                      ▼         ▼
              人工确认      返回修改
                      │
                      ▼
              status: approved
```

## 配置

```json
{
  "eval_integration": {
    "auto_check_on_review": true,
    "gate_thresholds": {
      "gate1_checklist_completion": 0.8,
      "gate4_spec_coverage": 0.9
    },
    "require_human_confirmation": true
  }
}
```

## 相关资源

- [strategic-context Eval Harness](../strategic-context/SKILL.md)
- [spec-driven-dev门禁](../spec-driven-dev/SKILL.md)
