# Hooks 配置说明（Cursor 新版格式）

Hooks 是 Cursor 的自动化触发器，在特定事件发生时执行脚本。

> 本仓库已升级到 Cursor 新版 hooks schema：顶层必须包含 `version`（数字）和 `hooks`（对象）。

## 配置文件位置

### 1) 项目级（推荐）

放在项目根目录：

- `.cursor/hooks.json`

### 2) 用户级

放在用户目录：

- `~/.cursor/hooks.json`
- 或 `~/.cursor/settings.json` 中的 `hooks` 字段

## 新版最小格式

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "node .cursor/hooks/stop.js"
      }
    ]
  }
}
```

## 事件名映射（旧版 -> 新版）

| 旧版名称 | 新版名称 |
|------|------|
| `PreToolUse` | `preToolUse` |
| `PostToolUse` | `postToolUse` |
| `UserPromptSubmit` | `beforeSubmitPrompt` |
| `Stop` | `stop` |

## ecc-workflow 当前 hooks 分层

- `hooks.core.json`：核心质量与安全规则（默认必选）
- `hooks.compat.json`：历史行为兼容层（默认合并）
- `hooks.learning.json`：continuous-learning 增强层（仅 `--enable-learning` 时合并）
- `hooks.json`：核心基线配置（可直接使用）

安装脚本会在安装时合成项目级 `.cursor/hooks.json`。

## ecc-workflow 当前 hooks 覆盖

| 事件 | 行为 |
|------|------|
| `preToolUse` | 写代码提醒、长命令 tmux 提示、`git push` 风险提醒 |
| `postToolUse` | TS 检查、Prettier、`console.log` 检测、文档同步与安全提醒 |
| `beforeSubmitPrompt` | Bug 关键词检测，建议使用 `@bug-hunter` |
| `stop` | 会话结束变更统计与文档同步提醒 |

## 安装方式

最小手工安装（核心基线）：

```bash
mkdir -p .cursor
cp hooks/hooks.json .cursor/hooks.json
```

分层模式推荐通过安装脚本：

```bash
echo "Y" | bash scripts/install.sh --verify-after
echo "Y" | bash scripts/install.sh --enable-learning --verify-after
```

## 常用环境变量（在 command 中可用）

| 变量 | 说明 |
|------|------|
| `${TOOL_INPUT_PATH}` | 文件路径（`Write` 相关） |
| `${TOOL_INPUT_COMMAND}` | Shell 命令内容（`Shell` 相关） |
| `${USER_PROMPT}` | 用户输入（`beforeSubmitPrompt`） |

## observe.sh 输入兼容策略

`skills/continuous-learning/hooks/observe.sh` 采用以下优先级读取上下文：

1. **stdin JSON**（优先，面向新版 hooks 事件输入）
2. **环境变量**（兜底，兼容旧配置）

说明：

- 如果存在可解析的 stdin JSON，会优先读取 `tool_name/tool_input/tool_output/user_prompt/session_id`（含常见别名）。
- 若 stdin 不可用或不可解析，则回退到 `TOOL_NAME`、`TOOL_INPUT`、`TOOL_OUTPUT`、`USER_PROMPT`、`SESSION_ID`。
- 脚本在 TTY 下不会主动读取 stdin，避免手工执行时阻塞。
- 记录结构中：
  - `input` 始终是合法 JSON（非法输入时降级为 `{}`）
  - `input_raw` 在输入非法时保留原始字符串，否则为 `null`

## TypeScript Stop Hook 示例

文档中的 TypeScript stop hook 形态可写成：

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "bun run hooks/stop.ts"
      }
    ]
  }
}
```

## 常见报错与修复

### 报错：`Config version must be a number`

原因：`version` 写成了字符串（如 `"1.0.0"`）。  
修复：改成数字 `1`。

### 报错：`Config hooks must be an object`

原因：缺少 `hooks` 顶层对象，或仍使用旧版 `PreToolUse` 顶层结构。  
修复：改为 `{ "version": 1, "hooks": { ... } }`。

## 最佳实践

1. Hook 尽量轻量，避免阻塞主流程
2. 非关键命令加 `|| true`，降低失败影响
3. 输出到 `stderr`（`>&2`）便于在面板中观察
4. 阻止危险操作时使用 `exit 2`

## 相关资源

- [Cursor Hooks（中文）](https://cursor.com/cn/docs/agent/hooks)
- [Third Party Hooks](https://cursor.com/docs/agent/third-party-hooks)
