# Superpowers (中文增强版)

> 为 Claude Code 提供完整软件开发工作流的插件系统 - 支持**中文触发词**

## 项目简介

Superpowers 是一个为 AI 编码代理设计的完整软件开发工作流系统。它通过一组可组合的"技能"(skills)和智能触发机制，让 AI 在写代码之前先理解需求、设计方案、制定计划，然后执行。

### 核心能力

- 🧠 **先设计后编码** - 不会直接跳进写代码，而是先问清楚你要做什么
- 📋 **分块呈现方案** - 把设计分成小块展示，每块确认后再继续
- 📝 **详细实施计划** - 生成初级工程师也能执行的详细任务清单
- 🤖 **自主执行** - 启动子代理按计划执行，可自主工作数小时
- 🔄 **自动触发** - 技能会根据上下文自动激活，无需手动调用

---

## 与原版的差异

这是基于 [obra/superpowers](https://github.com/obra/superpowers) 的中文增强分支：

| 特性 | 原版 | 中文增强版 |
|------|------|-----------|
| 英文触发词 | ✅ | ✅ |
| **中文触发词** | ❌ | ✅ |
| 上游同步 | 自动更新 | 需运行脚本 |
| 功能完整性 | 100% | 100% |

### 新增中文触发词示例

原来只支持：
```
"Create a feature" → 触发 brainstorming
```

现在也支持：
```
"帮我设计个功能" → 触发 brainstorming
"头脑风暴一下" → 触发 brainstorming
"写个组件" → 触发 brainstorming
```

---

## 安装方法

### 方式一：本地安装（推荐）

直接使用本地目录，可获得完整中文支持：

```bash
# 在 Claude Code 中
/plugin install file:///Users/apple/claudecode/superpowers

# 或使用 --plugin-dir 参数启动
claude -p "帮我设计个功能" --plugin-dir /Users/apple/claudecode/superpowers
```

### 方式二：官方 Marketplace

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**注意**：Marketplace 版本暂无中文触发词支持。

---

## 使用方法

### 1. 直接用中文对话

安装后，直接用中文提出需求即可：

```
# 这些都会自动触发 brainstorming 技能
帮我设计个登录功能
头脑风暴一下数据库结构
讨论一下如何处理并发
写个用户管理组件
加个新功能：导出报表
```

### 2. 使用快捷命令

```bash
/brainstorm        # 进入设计讨论模式
/write-plan        # 创建实施计划
/execute-plan      # 执行计划
```

### 3. 工作流程

```
┌─────────────────────────────────────────────────────────────────┐
│                        提出需求（中文）                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  brainstorming - 提问澄清需求，探索方案，分块呈现设计             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  writing-plans - 制定详细任务清单（2-5分钟/任务）                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  subagent-driven-development - 子代理逐任务执行 + 双阶段评审      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  test-driven-development - RED-GREEN-REFACTOR 测试驱动           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 同步上游更新

当原版有更新时，运行同步脚本即可同时获得：
1. 上游最新功能和修复
2. 中文触发词支持

```bash
cd /Users/apple/claudecode/superpowers
./scripts/sync-and-patch.sh
```

脚本会自动：
1. 从 obra/superpowers 获取最新代码
2. 合并到本地分支
3. 应用中文触发词补丁

---

## 技能库

### 测试
- **test-driven-development** - RED-GREEN-REFACTOR 测试驱动开发

### 调试
- **systematic-debugging** - 四阶段根因分析流程
- **verification-before-completion** - 确保问题真正解决

### 协作
- **brainstorming** - 苏格拉底式设计细化（支持中文）
- **writing-plans** - 详细实施计划
- **executing-plans** - 批量执行与检查点
- **dispatching-parallel-agents** - 并发子代理工作流
- **requesting-code-review** - 代码审查清单
- **receiving-code-review** - 回应审查反馈
- **using-git-worktrees** - 并行开发分支
- **finishing-a-development-branch** - 合并/PR 决策
- **subagent-driven-development** - 双阶段评审快速迭代

### 元技能
- **writing-skills** - 创建新技能的最佳实践
- **using-superpowers** - 技能系统介绍

---

## 设计理念

- **测试驱动** - 永远先写测试
- **系统化而非临时** - 流程优于猜测
- **降低复杂度** - 简单是首要目标
- **证据优于宣称** - 验证后再宣布成功

---

## 项目结构

```
superpowers/
├── skills/              # 所有技能定义
│   ├── brainstorming/   # 已添加中文触发词 ✨
│   ├── test-driven-development/
│   └── ...
├── scripts/             # 实用脚本
│   ├── sync-and-patch.sh         # 同步上游并应用中文补丁
│   └── apply-chinese-patches.sh  # 单独应用中文补丁
├── patches/             # 中文补丁说明
│   └── chinese-triggers.patch
└── CLAUDE.md            # 项目开发指南
```

---

## 链接

- **原项目**: https://github.com/obra/superpowers
- **原作者博客**: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)
- **许可证**: MIT

---

## 中文触发词列表

| 技能 | 英文触发词 | 中文触发词 |
|------|-----------|-----------|
| brainstorming | create a feature, build a component | 做个功能、写个组件、加个功能、头脑风暴、讨论一下、帮我设计、新功能 |

*更多技能的中文触发词正在逐步添加中，欢迎贡献！*
