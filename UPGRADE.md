# 从 v2.0 升级到 v3.0

## 主要变化

| 变化 | 说明 |
|------|------|
| Skills模块化 | spec-driven-dev (441行→60行) 拆分为6个独立skills |
| 持续学习拆分 | continuous-learning (617行→73行) 拆分为4个独立skills |
| Agent精简 | requirement-analyst、spec-writer 从300+行精简到~60行 |
| 新增评估集成 | eval-integration skill，门禁量化评估 |
| 文档精简 | 删除冗余文档，README从461行精简到150行 |

## 升级步骤

### 方式一：全新安装（推荐，无自定义修改时）

```bash
# 1. 备份当前配置（如有自定义）
cp -r .cursor .cursor.backup

# 2. 删除旧配置
rm -rf .cursor/skills .cursor/agents .cursor/templates

# 3. 重新安装
/path/to/ecc-workflow/scripts/install.sh --enable-hooks

# 4. 验证
/path/to/ecc-workflow/scripts/install.sh --verify
```

### 方式二：手动合并（有自定义修改时）

```bash
# 1. 备份
cp -r .cursor .cursor.backup

# 2. 复制新的skills（会新增9个子skills）
cp -r /path/to/ecc-workflow/.cursor/skills/* .cursor/skills/

# 3. 更新agents（如无自定义可直接覆盖）
cp /path/to/ecc-workflow/.cursor/agents/requirement-analyst.md .cursor/agents/
cp /path/to/ecc-workflow/.cursor/agents/spec-writer.md .cursor/agents/

# 4. 更新templates（删除了重复模板）
rm -f .cursor/templates/requirement-output.md
rm -f .cursor/templates/spec-output.md
rm -f .cursor/templates/handoff-template.md

# 5. 验证
/path/to/ecc-workflow/scripts/install.sh --verify
```

## 新增的Skills目录

```
.cursor/skills/
├── requirement-analysis/   # NEW: Phase 1
├── task-planning/          # NEW: Phase 2
├── architecture-design/    # NEW: Phase 3
├── spec-writing/           # NEW: Phase 4
├── code-implementation/    # NEW: Phase 5
├── active-learning/        # NEW: 主动学习
├── passive-learning/       # NEW: 被动学习
├── instinct-evolution/     # NEW: Instinct演化
├── eval-integration/       # NEW: 评估集成
├── spec-driven-dev/        # 精简为概览
├── continuous-learning/    # 精简为概览
├── doc-sync/               # 不变
└── strategic-context/      # 不变
```

## 删除的文件

如果存在以下文件，可以安全删除：

```bash
# 冗余文档
rm -f docs/v2.2-changes-summary.md
rm -f docs/continuous-learning-setup.md
rm -f docs/learn-project-feature.md
rm -f docs/memory-architecture.md
rm -f docs/team-adoption-guide.md

# 重复的commands（已统一到.cursor/commands/）
rm -rf .cursor/skills/continuous-learning/commands/

# 冗余的skill文档
rm -f .cursor/skills/continuous-learning/EXAMPLES.md
rm -f .cursor/skills/continuous-learning/QUICKSTART.md
```

## 使用方式不变

升级后命令使用方式完全兼容：

```bash
/analyze "功能描述"    # 不变
/spec @docs/...        # 不变
/implement @docs/...   # 不变
/learn-project         # 不变
```

## 验证升级成功

```bash
./scripts/install.sh --verify
```

应该看到所有13个核心skills都显示 ✓。
