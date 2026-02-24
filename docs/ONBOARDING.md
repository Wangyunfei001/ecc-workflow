# Cursor ECC工作流系统 - 新人上手指南

欢迎加入Cursor ECC工作流系统!本指南将帮助你快速上手并开始使用。

## 前置准备

### 必需工具

- [Cursor IDE](https://cursor.sh/) - AI增强的代码编辑器
- Git - 版本控制

### 推荐工具

- [Obsidian](https://obsidian.md/) - 用于管理docs/目录下的文档(可选但强烈推荐)

### 技能要求

- 基本的Git操作
- 熟悉Markdown语法
- 了解AI辅助编程的基本概念

## 快速开始(15分钟)

### Step 1: 安装配置(5分钟)

```bash
# 1. 克隆或复制工作流到你的项目
cd your-project
cp -r path/to/ecc-workflow/.cursor/* .cursor/

# 2. 创建文档目录结构
mkdir -p docs/{requirements,plans,architecture,adrs,specs/features,specs/apis,specs/components,CODEMAPS}

# 3. 如果使用Obsidian,将docs/目录添加为vault
# 打开Obsidian → "打开文件夹作为保管库" → 选择docs/目录
```

### Step 2: 主动学习项目(10分钟)

在Cursor中打开项目,执行:

```bash
/learn-project --depth=quick
```

这会自动:
- 分析项目结构和技术栈
- 理解编码规范和设计模式
- 生成项目文档和Onboarding指南
- 生成初始Instincts(3-5个)

**等待学习完成**,你将获得:
- ✅ `docs/PROJECT_OVERVIEW.md` - 项目概览
- ✅ `docs/CODEMAPS/overview.md` - 代码地图
- ✅ `.cursor/rules/project-standards.md` - 项目编码规范

## 第一个完整流程(30分钟)

让我们通过一个实际例子来体验完整工作流。

### 场景: 添加用户注册功能

#### Phase 1: 需求分析(5分钟)

在Cursor中输入:

```bash
/analyze 用户注册功能,支持邮箱注册
```

AI会开始追问:
- 目标用户是谁?
- 核心功能是什么?
- 验收标准是什么?
- ...

**你需要做**: 逐一回答问题,或者说"你来决定"

**输出**: `docs/requirements/2026-02-03-user-registration.md`

**Gate 1检查**: 
1. 打开需求文档
2. 确认追问清单完成
3. 将`status: clarified`改为`status: approved`

#### Phase 2: 任务规划(5分钟)

```bash
@planner @docs/requirements/2026-02-03-user-registration.md
```

AI会:
- 验证需求文档
- 拆解任务
- 识别依赖
- 评估风险

**输出**: `docs/plans/2026-02-03-user-registration.md`

**Gate 2检查**: 确认任务合理后,改为`status: approved`

#### Phase 3: 架构设计(5分钟)

对于简单功能,可以跳过此步。对于复杂功能:

```bash
@architect @docs/plans/2026-02-03-user-registration.md
```

AI会:
- 进行技术追问
- 设计架构方案
- 对比多个方案
- 记录架构决策(ADR)

**输出**: 
- `docs/architecture/user-registration.md`
- `docs/adrs/ADR-001-auth-strategy.md`

**Gate 3检查**: 确认架构合理后,改为`status: approved`

#### Phase 4: 规格撰写(10分钟)

```bash
/spec @docs/architecture/user-registration.md
# 或如果跳过Phase 3:
/spec @docs/plans/2026-02-03-user-registration.md
```

AI会生成详细的技术规格,包括:
- 数据模型定义
- API请求/响应格式
- 错误码定义
- 边界情况处理
- 测试策略

**输出**: `docs/specs/features/user-registration.md`

**Gate 4检查**: 
1. 确认数据模型精确(字段类型、约束)
2. 确认API完整(路径、参数、响应)
3. 确认错误处理覆盖
4. 改为`status: approved`

#### Phase 5: 代码实现(5分钟)

```bash
/implement @docs/specs/features/user-registration.md
```

AI会**严格按照Spec**生成代码:
- 100%按Spec定义
- 不添加任何额外功能
- 不修改Spec未提及的代码

**输出**: 符合Spec的代码实现

#### 收尾: 审查和同步

```bash
# 代码审查
/review

# 文档同步
/sync
```

## 常用操作速查

### 开发新功能

```bash
# 完整流程
/analyze "需求描述"
# [审查需求,改为approved]
@planner @docs/requirements/xxx.md
# [审查计划,改为approved]
@architect @docs/plans/xxx.md  # 可选
# [审查架构,改为approved]
/spec @docs/architecture/xxx.md
# [审查Spec,改为approved]
/implement @docs/specs/features/xxx.md
/review
/sync
```

### 简化流程(小功能)

```bash
/analyze "需求描述"
# [审查需求]
@planner @docs/requirements/xxx.md
# [审查计划]
/spec @docs/plans/xxx.md  # 跳过架构设计
# [审查Spec]
/implement @docs/specs/features/xxx.md
```

### 查看学习成果

```bash
# 查看已学习的Instinct
/instinct-status

# 演化Instinct为Skill/Command
/evolve

# 导出给团队
/instinct-export
```

## 理解核心概念

### Gate(门禁)

每个Gate是**强制停止点**,必须人工审查:

| Gate | 检查内容 | 通过标志 |
|------|---------|---------|
| Gate 1 | 需求完整、边界清晰 | `status: approved` |
| Gate 2 | 任务合理、风险可控 | `status: approved` |
| Gate 3 | 架构合理、技术可行 | `status: approved` |
| Gate 4 | 规格精确、可实现 | `status: approved` |

**为什么需要Gate?** 防止在模糊需求上浪费时间,确保每个阶段都清晰明确。

### Spec(技术规格)

Spec是**唯一真理来源**(Source of Truth):
- 数据模型的精确定义
- API的完整契约
- 错误处理的详细说明
- 边界情况的明确处理

**strict-coder只实现Spec中定义的内容**,不会自由发挥。

### Instinct(直觉)

Instinct是系统从你的编码习惯中学到的**原子化模式**:
- 主动学习(`/learn-project`)生成初始Instincts(置信度0.5-0.7)
- 被动学习(Hooks观察)持续强化或调整置信度
- 演化(`/evolve`)将相关Instincts聚类为Skill/Command

## 工具使用技巧

### Obsidian集成

如果使用Obsidian管理docs/:

1. **Wikilinks**: 使用`[[]]`链接文档
   ```markdown
   需求文档: [[requirements/2026-02-03-user-registration]]
   ```

2. **标签**: 使用`#`标记文档类型
   ```markdown
   #requirement #p0 #auth
   ```

3. **图谱视图**: 查看文档关联关系
   - View → Graph View

4. **模板**: 使用`.cursor/templates/`下的模板
   - 设置 → 模板文件夹 → 选择`.cursor/templates`

### Git工作流

```bash
# 提交Spec和需求文档
git add docs/
git commit -m "docs: 添加用户注册需求和规格"

# 提交代码实现
git add src/
git commit -m "feat: 实现用户注册功能 (refs: docs/specs/features/user-registration.md)"

# 项目级记忆(docs/)会跟随Git提交
# 用户级记忆(~/.cursor/homunculus/)不会
```

## 常见问题

### Q: 必须严格遵守5阶段流程吗?

A: 不必须。根据任务复杂度可以简化:
- **简单功能**: 可跳过Phase 3(架构设计)
- **紧急修复**: 可简化Phase 1追问
- **绝不跳过**: Gate 4(Spec审查)和Phase 5(代码实现)

### Q: Spec写得太细了,很费时间?

A: Spec的粒度是"足够实现"而非"事无巨细"。关键字段必须精确,非关键可以留白。对于简单功能,只写核心部分即可。

### Q: 主动学习(/learn-project)必须执行吗?

A: 不必须,但强烈推荐:
- **首次接触项目**: 必须执行,快速建立认知
- **熟悉的项目**: 可跳过
- **紧急任务**: 可跳过,依赖被动学习

### Q: 如何处理实现中发现Spec有问题?

A: 立即停止实现,更新Spec,重新审查后继续。**不要在代码里"偷偷修改"**。

### Q: 团队新成员如何快速上手?

A: 
1. 让已有成员先使用,积累Instinct
2. 执行`/learn-project --depth=medium`学习项目
3. 导入团队Instinct: `/instinct-import`
4. 跟随一个完整流程实践

## 下一步

- 阅读 [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) 了解系统架构
- 阅读 [记忆架构说明](./memory-architecture.md) 了解双层记忆
- 查看 [团队推广指南](./team-adoption-guide.md) 了解团队协作
- 实践完整流程,体验工作流价值

## 获得帮助

- 查看`.cursor/agents/`下的Agent定义了解角色职责
- 查看`.cursor/commands/`下的命令文档了解命令用法
- 查看`.cursor/skills/`下的Skill文档了解工作流详情
- 查看`docs/`目录下的其他文档

祝你使用愉快!
