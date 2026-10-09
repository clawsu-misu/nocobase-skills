# nocobase-skills

从 **NocoBase 官方文档**（中文版 1080 篇 / 约 130 万字）蒸馏出的 **8 个可调用 Skill**。

解决的问题：用 NocoBase 从零搭一套业务系统时，该按什么顺序做、每个岔路口怎么判断。其中 **4 条方法论不依赖 NocoBase**，可直接迁移到别的平台或自研系统。

| 项 | 值 |
|---|---|
| 版本 | v1.0.2（构建于 2026-10-09） |
| 事实源 | `bundle.nocobase` · cangjie-tools v2.5.0 · 17 条方法论 |
| 质量证据 | 三轮盲测 **67/67 通过**，跨 Skill 混淆 **0/18**，8 个套件 F1 = **1.000** |
| 体量 | 8 个 Skill / 29 个文件 / 240 KB |

## 快速开始

```bash
git clone https://github.com/clawsu-misu/nocobase-skills.git
cd nocobase-skills

./install.sh --dry-run        # 先看会做什么，不落盘
./install.sh                  # 安装本包 8 个到 ~/.workbuddy/skills/
./verify.sh                   # 校验 skills/ 是否被手改过

./link-official.sh --list     # 查官方 20 个技能装在哪、内容对不对（不落盘）
./link-official.sh            # 查找 → 校验 → 接到 WorkBuddy（执行层）
```

其它常用参数：`./install.sh --list`（列出 8 个入口）、`-t <目录>`（改安装目标）、`--force`（覆盖前自动备份为 `*.bak-<时间戳>`）、`--uninstall`（只删本包这 8 个，不碰其它 Skill）。

装完直接在对话里说需求即可，Skill 会按各自的 `description` 自动触发；不确定该找谁时，先落到 `nocobase-playbook` 由它路由。

## 8 个入口

| Skill | 什么时候会用到 | 类型 |
|---|---|---|
| `nocobase-playbook` | 搭建主线的**来源路由入口**。<br>表类型与关系选型（树表 / 视图表 / SQL 表 / 多对多要不要中间表）· 主库与外部库选型 · 区块·字段·操作三层模型 · 配置优先与 JS 兜底 · 引用 vs 复制 · 迁移/版本/备份三机制 · 提示词九要素 · T 型数据架构 · 三空间模型 · RAG 调优 | 路由入口<br>+ 17 张能力卡 |
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

## 与官方 Skills 的关系

官方仓库 [nocobase/skills](https://github.com/nocobase/skills)（npm 包 `@nocobase/skills`，**ISC** 许可）提供 **20 个 Skill**，它们依赖 `nb` CLI **真正操作一个运行中的 NocoBase 实例**。

本包与它是 **「脑」与「手」的关系，单向接线**：

| | 官方 20 个 | 本包 8 个 |
|---|---|---|
| 回答什么 | 怎么把这件事**做掉** | **该不该做**、什么顺序、边界在哪 |
| 依赖 | `nb` CLI + 运行中的实例 + 已认证 | 无（纯 Markdown） |
| 版本 | 20/20 声明 `NocoBase 2 only; never use in a NocoBase 3 project` | 跨版本；4 条 ★ 完全不依赖 NocoBase |
| 门禁 | 有强制 gate（如 revision 先查插件是否启用） | 无 |

**为什么是接线而不是合并/fork**：官方技能是 npm 包，`nb skills update` 会整体覆盖任何本地改动。只写「移交给谁」，可以做到**零维护负担**。所以每张能力卡末节都有一节「移交执行（官方 Skill）」，写明判断完成后该调用官方哪个 Skill。

同主题的 5 组**不重复**，是分层：

| 主题 | 本包（判断） | 官方（执行） |
|---|---|---|
| 版本 | `revision-checkpoint` 判断**何时**存、描述怎么写 | `nocobase-revision` 执行 `nb revision create` |
| 数据建模 | `data-model-first` 判断先建什么、什么顺序 | `nocobase-data-modeling` 执行建表建字段 |
| 权限 | `four-layer-permission-funnel` 判断四层怎么收口 | `nocobase-acl-manage` 执行角色与策略配置 |
| 工作流 | `trigger-selection-timeline` 判断按事件时序该选哪个触发器 | `nocobase-workflow-manage` 执行工作流创建与排障 |
| AI 员工 | `ai-employee-two-layer` 判断岗位怎么定、技能挂几个 | `nocobase-ai-employee` 执行员工创建与绑定 |

### 官方 20 个 Skill 一览

| Skill | 职责 |
|---|---|
| `nocobase-portal-manage` | UI 编写总调度器（页面 / 区块 / 字段 / 操作 / 图表） |
| `nocobase-ui-builder` | No-code Portal 的 UI 实现（仅由上游接续调用） |
| `nocobase-data-modeling` | collection / field / relation / 视图表 |
| `nocobase-acl-manage` | 角色、权限策略、Portal 入口访问、用户-角色绑定 |
| `nocobase-workflow-manage` | 工作流检视 / 创建 / 更新 / 启停 / 排障 |
| `nocobase-revision` | 里程碑版本存档 |
| `nocobase-publish-manage` | 备份还原 / 迁移发布 |
| `nocobase-ai-employee` | AI 员工生命周期 |
| `nocobase-ai-knowledge-base-manager` | 知识库、向量库、文档、检索测试 |
| `nocobase-ai-manager` | LLM provider、模型、embedding、凭证 |
| `nocobase-ai-builder` | AI Portal 源码应用搭建 |
| `nocobase-dsl-reconciler` | YAML / DSL 路径（opt-in） |
| `nocobase-env-manage` | bootstrap、运行时、CLI 与技能维护 |
| `nocobase-plugin-manage` | 插件启停 |
| `nocobase-plugin-development` | 插件源码开发 playbook |
| `nocobase-notification-manage` | 通知通道与发送日志 |
| `nocobase-file-manager` | 文件存储引擎与文件记录 |
| `nocobase-data-analysis` | 通过 MCP 查询与汇总业务数据 |
| `nocobase-prototype-repro` | 按原型复刻页面 |
| `nocobase-utils` | 过滤条件、操作符、表达式、UID 等参考 |

> 完整的双向对接表（哪个能力移交给哪个 Skill）见 `skills/nocobase-playbook/references/overview.md` 第 5 节。

### 环境提示：官方技能装在哪，以及为什么要先查找

各宿主扫描的技能目录不同（Claude Code 看 `~/.claude/skills/`，WorkBuddy 看 `~/.workbuddy/skills/`）。实测 `nb skills install` 落在通用 agent 目录 **`~/.agents/skills/`**，**WorkBuddy 不扫描它** —— 会出现「装好了但不生效」。

不要凭印象写死路径再 `ln -s`。本机实测有 **3 个**候选落点，且其中一个只是指向另一个的软链、还有一个是内容不同的旧副本：

| 候选 | 实际身份 |
|---|---|
| `~/.agents/skills/` | **真身**（`nb skills install` 的安装目标，`nb skills update` 维护它） |
| `~/.claude/skills/` | 相对软链 → `../../.agents/skills/`（目录本身是真目录，只有子项是链） |
| `~/.nocobase/cache/skills/node_modules/@nocobase/skills/skills/` | npm 解包缓存，**`nb` 清理缓存时会消失** → 链它迟早变坏链 |

所以用 `link-official.sh`，它先查再装：

```bash
./link-official.sh --list      # 只查找 + 校验，看命中哪个真身
./link-official.sh             # 执行：查找 → 校验 → 软链（绝对路径）
./link-official.sh --unlink    # 撤销（只删软链，不碰真身）
```

四道闸：

1. **查找** — 按优先级探测全部候选，用「子项物理路径」识别同一真身，命中多个时才比数量定真身；全都找不到就明确报错，**不会链出一个坏链**。
2. **校验** — 逐个检查目录名 / frontmatter `name` / `description` 是否齐备一致，并自检坏链。
3. **版本核对** — 交叉比对技能包版本、技能自述的 NocoBase 代次、`nb env` 当前环境，不一致只提示不阻断。
4. **落盘后复验** — 建链后立刻回读 `SKILL.md` 并核对 `name`，失败自动回滚。

> **已实测**：WorkBuddy **支持软链**。用同一个技能做 A/B（真目录 vs 软链），两种形态都能被技能列表正常识别并读出 description。软链一律用**绝对路径**，真身被移动或删除会立刻暴露成坏链，而不是静默失效。

#### 内容真伪：真身不一定等于官方原味

`--check-upstream` 会从 npm 拉同版本官方包做逐文件指纹比对。本机实测结果：

```bash
./link-official.sh --list --check-upstream
```

`@nocobase/skills` 与本机均为 2.0.58（上游最新即 2.0.58，**不存在 v3 版技能**），但 **20 个里有 10 个已被本地改动**（多为 `nb` 的技能自学习或本地修订，如 `nocobase-revision` 的措辞已比官方更严谨）。脚本会如实报出偏离清单 —— **路径对不等于内容对**，这一步就是用来抓「装上了但装错了东西」的。

若要官方原味，用 `--src` 指向官方解包目录，或先跑 `nb skills update`。

## 目录结构

```
skills/                       8 个可安装 Skill（编译产物，勿手改）
  nocobase-playbook/          路由入口 + 17 张能力卡 + 4 份 references
    SKILL.md
    references/capabilities/  17 张 RIA++ 能力卡
    references/               overview / glossary / cheatsheet / capability-index
  其余 7 个/                   各一份 SKILL.md（RIA++ 六段结构）
BUILD_MANIFEST.json           产物哈希清单 + 构建决策记录
capability-destinations.json  17 条能力卡的去向审计
install.sh                    安装 / 卸载 / dry-run
link-official.sh              官方 20 个技能：查找 → 校验 → 软链（可选 --check-upstream）
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

## 更新记录

| 版本 | 变更 |
|---|---|
| v1.0.2 | 新增 `link-official.sh`：把官方 20 个技能接到 WorkBuddy 执行层，分四道闸 —— 查找（多候选探测 + 同真身识别）→ 校验（目录名 / name / description / 坏链）→ 版本核对（技能包 vs 技能自述代次 vs `nb env` 当前环境）→ 落盘后复验（失败回滚）。支持 `--list` / `--dry-run` / `--mode copy` / `--check-upstream`（从 npm 拉官方包做内容指纹比对）/ `--unlink`（只删软链与逐字节一致的副本，改动过的一律保留）。README 增补候选落点对照与实测结论。 || v1.0.1 | 新增「与官方 Skills 的关系」：17 张能力卡各加一节「移交执行（官方 Skill）」，入口加第 9 条核心原则（脑 ↔ 手分工），`overview.md` 加对接总表；`verified.yaml` 每个能力新增 `handoff` 字段。**未改动任何 `description`**，因此三轮盲测 67/67 的结论继续有效（已记录于 `test-results.md`）。 |
| v1.0.0 | 首次发布：17 条方法论 → 8 个可发现入口，含 RIA++ 能力卡、三轮盲测记录与构建清单。 |

## 许可与来源

素材为 NocoBase 官方文档，方法论为二次创作，少量原文引用已标注出处。详见 [NOTICE.md](NOTICE.md)。
