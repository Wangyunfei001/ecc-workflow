# TaskGraph 协议

## 1. 目的

TaskGraph 是 `ecc-workflow` 中用于工作流分解的统一协议。
它标准化了命令定义中的以下内容：

- 任务拆分
- 依赖顺序
- 并行执行分组
- 合并策略
- 检查点与验收标准

本文档是命令级编排语义的唯一事实来源。

## 2. 最小 Schema

```yaml
workflow_id: wf-<date>-<name>
goal: "自然语言目标描述"
tasks:
  - id: T1
    name: "<任务名称>"
    owner: "<agent 名称>"
    depends_on: []
    parallelizable: false
    input: ["artifact-a"]
    output_schema: ["artifact-b", "report"]
    done_criteria:
      - "<检查项>"
checkpoints:
  - id: C1
    after_tasks: ["T2"]
    type: human_review
merge:
  after: ["T3", "T4"]
  strategy: all_must_pass
```

## 3. 字段定义

### 3.1 工作流字段

- `workflow_id`：唯一运行标识符
- `goal`：用户级目标
- `tasks`：可执行单元列表
- `checkpoints`：显式暂停节点，用于人工确认
- `merge`：分支汇聚策略

### 3.2 任务字段

- `id`：工作流内全局唯一（`T1`、`T2`、...）
- `name`：稳定的任务名称
- `owner`：指定的 agent 角色
- `depends_on`：前置任务 id 列表
- `parallelizable`：调度器是否可并行执行该任务
- `input`：所需的制品或上下文键
- `output_schema`：下游任务期望的输出
- `done_criteria`：验收检查清单

## 4. 调度规则

1. 仅当所有 `depends_on` 任务成功后，任务才可运行。
2. 任务可并行执行的条件：
   - `parallelizable=true`
   - 所有依赖已满足
   - 不存在策略冲突（如安全门禁）。
3. 任务失败行为：
   - 阻塞依赖该任务的下游任务
   - 如已定义，允许重试或走回退路径。
4. 检查点行为：
   - 工作流在 `after_tasks` 完成后暂停
   - 恢复执行需要显式批准。

## 5. 合并策略

支持的值：

- `all_must_pass`：所有上游分支必须通过。
- `best_effort`：部分通过即可继续，并发出警告。
- `security_gate`：安全分支必须通过；其他分支可为警告。

审查分支的默认策略为 `all_must_pass`。

## 6. 状态模型

每个任务使用以下状态之一：

- `pending`（待执行）
- `running`（执行中）
- `succeeded`（成功）
- `failed`（失败）
- `blocked`（阻塞）
- `cancelled`（已取消）

## 7. 协议优先级

当协议规则冲突时：

1. 安全策略
2. 依赖约束
3. 用户显式覆盖
4. 优化偏好（并行化）

## 8. 命令映射

- `/orchestrate`：完整的 TaskGraph 生产者和调度器。
- `/learn-project`：基于阶段的 TaskGraph，支持并行提取/文档生成。
- `/analyze`：问题分解 TaskGraph（澄清图）。
- `/implement`：Spec 驱动的 TaskGraph（实现 + 测试 + 报告）。
- `/review`：多维度审查 TaskGraph，支持合并。

## 9. 验证钩子

验证应确认：

- Schema 存在性
- 依赖健全性（无孤立依赖）
- 合并节点引用的任务 id 有效
- 检查点引用的上游任务有效

`scripts/verify-setup.sh --mode learning` 包含协议能力探针。
