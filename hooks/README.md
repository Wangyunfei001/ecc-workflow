# Hooks 配置说明

Hooks 是 Cursor 的自动化触发器，在特定事件发生时自动执行操作。

## 两种 Hooks 配置

本工作流包含**两种 Hooks 配置**，服务于不同目的：

### 1. 项目级 Hooks（`.cursor/hooks/hooks.json`）

**用途：** 代码质量检查、格式化、安全提醒

**配置格式：**
```json
{
  "PreToolUse": [
    {
      "name": "Hook 名称",
      "matcher": "tool == 'Write' && tool_input.path matches '.*\\.ts$'",
      "hooks": [{ "type": "command", "command": "..." }]
    }
  ]
}
```

### 2. 用户级 Hooks（`~/.cursor/settings.json`）

**用途：** 持续学习系统的观察收集

**配置格式（需手动添加到 settings.json）：**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/hooks/observe.sh pre"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/hooks/observe.sh post"
      }]
    }]
  }
}
```

### 配置优先级

```
用户级配置 (~/.cursor/settings.json)
         │
         ▼ 合并
项目级配置 (.cursor/hooks/hooks.json)
         │
         ▼
     最终生效
```

---

## Hook 类型

| 类型 | 触发时机 | 用途 |
|------|----------|------|
| PreToolUse | 工具调用前 | 验证、提醒、阻止 |
| PostToolUse | 工具调用后 | 格式化、检查、通知 |
| UserPromptSubmit | 用户发送消息时 | 检测关键词、建议 |
| Stop | Claude 响应结束时 | 统计、清理、提醒 |
| PreCompact | 上下文压缩前 | 保存重要信息 |
| Notification | 权限请求时 | 自定义通知 |

## 当前配置的 Hooks

### PreToolUse

| Hook | 触发条件 | 行为 |
|------|----------|------|
| 代码写入提醒 | 写入 .ts/.vue 文件 | 提醒检查 Spec |
| 长时间命令提醒 | 运行 npm/yarn 等 | 建议使用 tmux |
| Git Push 确认 | git push 命令 | 提醒审查 |
| 禁止直接 Push | push 到 main/master | 阻止并提醒 |

### PostToolUse

| Hook | 触发条件 | 行为 |
|------|----------|------|
| TypeScript 检查 | 编辑 .ts/.vue | 运行 vue-tsc --noEmit |
| Prettier 格式化 | 编辑代码文件 | 自动格式化 |
| console.log 检查 | 编辑代码文件 | 警告移除 |
| 文档同步提醒 | 编辑 API/类型 | 提醒运行 /sync |
| 安全文件警告 | 编辑安全相关文件 | 建议安全审查 |

### UserPromptSubmit

| Hook | 触发条件 | 行为 |
|------|----------|------|
| Bug 关键词检测 | 包含错误关键词 | 建议使用 bug-hunter |

### Stop

| Hook | 触发条件 | 行为 |
|------|----------|------|
| 变更统计 | 每次会话结束 | 显示变更文件 |
| 文档同步提醒 | 代码有变更 | 提醒同步 |

## 安装方式

### 方式 1: 项目级配置

将 `hooks.json` 复制到项目根目录：

```bash
cp .cursor/hooks/hooks.json .cursor/hooks.json
```

### 方式 2: 用户级配置

合并到用户配置：

```bash
# 查看用户配置
cat ~/.cursor/settings.json

# 将 hooks 配置合并到 settings.json 的 hooks 字段
```

## 自定义 Hook

### 添加新 Hook

编辑 `hooks.json`：

```json
{
  "PostToolUse": [
    {
      "name": "自定义 Hook 名称",
      "description": "描述",
      "matcher": "tool == 'Write' && tool_input.path matches '*.py$'",
      "hooks": [
        {
          "type": "command",
          "command": "your-command-here"
        }
      ]
    }
  ]
}
```

### Matcher 语法

```javascript
// 工具匹配
tool == 'Write'
tool == 'Bash'
tool == 'Read'

// 输入参数匹配
tool_input.path matches '.*\\.ts$'
tool_input.command matches 'git push.*'

// 组合条件
tool == 'Write' && tool_input.path matches '.*\\.ts$'

// 用户输入匹配
user_prompt matches '.*bug.*'
```

### Hook 类型

```json
// 消息提示
{
  "type": "message",
  "message": "提示内容"
}

// 执行命令
{
  "type": "command",
  "command": "shell-command-here"
}
```

## 常用变量

| 变量 | 说明 |
|------|------|
| `${TOOL_INPUT_PATH}` | 文件路径（Write 操作） |
| `${TOOL_INPUT_COMMAND}` | 命令内容（Bash 操作） |
| `${USER_PROMPT}` | 用户输入内容 |

## 调试

### 查看 Hook 执行日志

```bash
# 查看最近的 Hook 执行
tail -f ~/.cursor/logs/hooks.log
```

### 禁用 Hook

临时禁用所有 Hooks：

```bash
# 在 settings.json 中设置
{
  "hooks": {
    "enabled": false
  }
}
```

禁用特定 Hook：

```json
{
  "PreToolUse": [
    {
      "name": "要禁用的 Hook",
      "enabled": false,
      "matcher": "...",
      "hooks": [...]
    }
  ]
}
```

## 最佳实践

1. **Hook 应该轻量** — 避免耗时操作阻塞主流程
2. **使用 || true 兜底** — 防止命令失败中断流程
3. **限制输出** — 使用 `head -N` 限制输出行数
4. **错误输出到 stderr** — 使用 `>&2` 确保消息可见

## 相关资源

- [Cursor Hooks 文档](https://docs.cursor.com/hooks)
- [ECC Hooks 参考](https://github.com/affaan-m/everything-claude-code)
