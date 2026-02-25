# Legacy to Marketplace Migration Guide

## 1. 目标

将历史安装方式平滑迁移到 marketplace 原生布局，确保：

- 主工作流不中断
- 学习数据（observations/instincts）保留
- 可回滚

## 2. 适用对象

- 使用过旧安装脚本并依赖 `.cursor/*` 旧路径假设的项目
- 已在用户目录保存 `homunculus` 学习数据的个人环境

## 3. 迁移前检查

### 3.1 项目级

- 备份当前 `.cursor/` 目录
- 记录本地 hooks 配置来源（项目级/用户级）
- 执行一次现有验证，保留输出作为基线

### 3.2 用户级

- 备份 `~/.cursor/homunculus/`
- 备份 `~/.cursor/hooks/`（如存在）

## 4. 迁移步骤

### Step 1: Dry-run

- 运行安装器 dry-run，确认将变更的文件集合
- 识别冲突项（已有 hooks、自定义脚本）

### Step 2: 核心模式迁移

- 按新映射安装核心组件到项目 `.cursor/`
- 生成/合成项目级 `.cursor/hooks.json`
- 执行 core 模式 verify

### Step 3: learning 增强迁移（可选）

- 显式启用 learning 安装
- 迁移观察脚本与 learning 目录
- 执行 learning 模式 verify

### Step 4: 清理与兼容

- 保留 compat hooks 一段过渡期
- 标注可删除的旧配置项与预计淘汰版本

## 5. 数据保留策略

- `~/.cursor/homunculus/observations.jsonl`：只追加，不覆盖
- `~/.cursor/homunculus/instincts/*`：全量保留
- `~/.cursor/homunculus/evolved/*`：按时间戳保留历史产物

## 6. 回滚策略

### 6.1 触发条件

- 核心命令不可用
- hooks 阻断误报导致开发流中断
- learning 启用后出现异常且影响核心流程

### 6.2 回滚动作

- 恢复项目 `.cursor/` 备份
- 恢复 hooks 备份
- learning 目录回滚仅撤销本次新增/覆盖，保留历史数据

## 7. 验收清单

- 核心命令可执行：`/analyze`、`/spec`、`/implement`、`/review`、`/sync`
- verify core 通过
- 若启用 learning：verify learning 通过或仅有非阻断 WARN
- 历史学习数据可见且未丢失

## 8. 常见问题

- 问：检测到旧变量名 hooks 怎么处理？
  - 答：先放入 compat 层，完成迁移后逐步清理。
- 问：learning 失败会不会影响开发？
  - 答：不会，learning 必须可降级，不得阻断核心模式。
