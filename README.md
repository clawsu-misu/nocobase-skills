# nocobase-skills

从 **NocoBase 官方文档**（中文版 1080 篇 / 约 130 万字）蒸馏出的 **8 个可调用 Skill**。

解决的问题：用 NocoBase 从零搭一套业务系统时，该按什么顺序做、每个岔路口怎么判断。其中 **4 条方法论不依赖 NocoBase**，可直接迁移到别的平台或自研系统。

| 项 | 值 |
|---|---|
| 版本 | v1.0.0（构建于 2026-10-09） |
| 事实源 | `bundle.nocobase` · cangjie-tools v2.5.0 · 17 条方法论 |
| 质量证据 | 三轮盲测 **67/67 通过**，跨 Skill 混淆 **0/18**，8 个套件 F1 = **1.000** |
| 体量 | 8 个 Skill / 31 个文件 / 248 KB |

## 快速开始

```bash
./install.sh --dry-run    # 先看会做什么，不落盘
./install.sh              # 安装到 ~/.workbuddy/skills/
./verify.sh               # 校验 skills/ 是否被手改过
```

装完直接在对话里说需求即可，Skill 会按各自的 `description` 自动触发；不确定该找谁时，先落到 `nocobase-playbook` 由它路由。

## 8 个入口

| Skill | 什么时候会用到 | 类型 |
|---|---|---|
| `nocobase-playbook` | 搭建主线的**来源路由入口**。<br>表类型与关系选型（树表 / 视图表 / SQL 表 / 多对多要不要中间表）· 主库与外部库选型 · 区块·字段·操作三层模型 · 配置优先与 JS 兜底 · 引用 vs 复制 · 迁移/版本/备份三机制 · 提示词九要素 · T 型数据架构 · 三空间模型 · RAG 调优 | 路由入口<br>+ 10 张能力卡 |
| `data-model-first` | 「先建模还是先拖页面」；需求含糊（客户只说了一个页面）不知从哪下手；接手别人搭了一半的系统 | 晋级 |
| `trigger-selection-timeline` | 自动化该用哪个触发器；工作流建好了却不触发要排查根因；「超时自动取消」这类相对时间需求 | 晋级 |
| `four-layer-permission-funnel` | 配「谁能看到什么、谁能改什么」；多角色 / 多部门数据隔离；反馈「看不到数据 / 看到了不该看的」 | 晋级 |
| `revision-checkpoint` | AI 连着改了一堆东西后，上一个可回退的清晰节点在哪；定「什么时候存版本、描述怎么写」的纪律 ★ | 晋级 |
| `skill-orchestration-chain` | 自建 Agent / Skill 体系：能力怎么切、切几个、每个边界的 out of scope 怎么写 ★ | 晋级 |
| `ai-employee-two-layer` | 把 AI 接进业务流程前先定岗位：它是谁、管哪类活、技能挂几个、任务挂几个 ★ | 晋级 |
| `ai-guardrails-four-layer` | 让 AI 直接操作真实业务数据前，划定权限边界（前提句：**AI 没有额外权限**）★ | 晋级 |

★ = 不依赖 NocoBase，迁移性最高。

## 只要一个入口也可以

`nocobase-playbook` 内含全部 17 条方法论的完整能力卡（`skills/nocobase-playbook/references/capabilities/`），单独安装即可覆盖所有主题，代价是那 4 条 ★ 无法独立触发，每次都要先读路由表：

```bash
cp -R skills/nocobase-playbook ~/.workbuddy/skills/
```

## 目录结构

```
skills/                       8 个可安装 Skill（编译产物，勿手改）
  nocobase-playbook/          路由入口 + 10 张能力卡 + 4 份 references
    SKILL.md
    references/capabilities/  17 张 RIA++ 能力卡
    references/               overview / glossary / cheatsheet / capability-index
  其余 7 个/                   各一份 SKILL.md（RIA++ 六段结构）
BUILD_MANIFEST.json           产物哈希清单 + 构建决策记录
capability-destinations.json  17 条能力卡的去向审计
install.sh                    安装 / 卸载 / dry-run
verify.sh                     校验 skills/ 是否被手改
NOTICE.md                     素材来源与版权说明
```

## 不要手改 `skills/`

`skills/` 是**编译产物**。要改内容就改事实源（Bundle）再重编译：

```
<蒸馏工作区>/books/nocobase/.cangjie/capabilities/
```

```bash
python3 <...>/cangjie.py compile \
  --bundle <...>/books/nocobase/.cangjie/capabilities \
  --out    <...>/books/nocobase/dist --output pack --yes
```

编译器会比对 `BUILD_MANIFEST.json` 里的 `published_hashes`，检测到本地手改时**拒绝静默覆盖**。任何时候可以自查：

```bash
./verify.sh    # 需要 python3（macOS 自带）
```

## 移植到其它 Agent 平台

Skill 是纯 Markdown + YAML frontmatter（`name` / `description`），与 Claude Code 技能格式同源，拷贝到对应平台的技能目录即可使用。依赖宿主能力的部分（子 Agent、hooks 等）需自行适配。

## 许可与来源

素材为 NocoBase 官方文档，方法论为二次创作，少量原文引用已标注出处。详见 [NOTICE.md](NOTICE.md)。
