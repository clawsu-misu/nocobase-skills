# 《NocoBase 官方文档（中文版）》— 整书理解（阶段 0 产出）

> 本文档是 cangjie-skill 流水线的阶段 0 产出，后续所有 extractor 与能力卡都以此为全局上下文。

## 基本信息

- **标题**：NocoBase 官方文档（中文版）
- **作者**：NocoBase 官方文档团队
- **发布/整理时间**：2026（v3 文档线，含 v1/v2 教程）
- **内容类型**：产品文档站（rspress 构建的官方文档源码仓库）
- **版本来源**：`/Users/su/flowus/nocobase/docs/docs/cn/`
- **处理时间**：2026-10-09
- **处理范围**：中文版 1080 篇 Markdown / 8.3 MB / 约 130 万中文字（其余 9 个语种为翻译副本，不重复蒸馏）

---

## 1. 结构（Structural）

### 类型
方法论 + 实操手册的混合体：既有「怎么想」（设计原则、选型判据），也有「怎么做」（配置步骤、命令）。本次蒸馏只取前者。

### 一句话主旨
**NocoBase 把「搭一套业务系统」这件事拆成了一条可被 AI 执行、可被版本控制、可被权限收口的确定性流水线**——先定数据结构，再让界面成为数据的投影，然后配上权限与自动化，最后交给 AI 并产品化。

### 骨架（45 个一级板块归并为 5 大板块）

1. **搭建主线**：data-sources / interface-builder / workflow / users-permissions（约 1.2 MB，方法论密度 ★★★★★）
2. **AI 原生（v3 核心）**：ai / ai-builder / ai-employees（约 310 KB，★★★★★）
3. **教程与方案**：tutorials（v1 24 篇 + v2 7 篇）/ solution（CRM、工单）（约 490 KB，★★★★★）
4. **工程与架构**：flow-engine / plugin-development / api / cluster-mode / adr（约 1 MB，偏 API 参考）
5. **运维与安全**：ops-management / security / log-and-monitor / multi-app（约 200 KB，★★★）

**论点之间的关系**：**递进**。板块 1 是地基，板块 2 是 v3 新增的「谁来搭」的答案，板块 3 是地基建成的两种实例（最小可行 / 复杂演进），板块 4–5 是支撑性材料。五条主线恰好构成一条从「想清要存什么」到「交付给客户」的时间轴。

### 作者要解决的核心问题
**如何让非专业开发者在没有工程师的情况下，搭出并长期运营一套真实可用的业务系统。** 其答案的技术前提是「界面与数据彻底解耦」，组织前提是「把 Agent 变成搭建主体而不是辅助按钮」。

---

## 2. 解释（Interpretive）

### 关键术语（作者本人的用法）

| 术语 | 作者的定义 | 和常识用法的差异 |
|---|---|---|
| Collection | 一类业务数据的完整描述（存哪里/哪些字段/如何被使用） | 不等于数据库表——它同时携带界面与业务能力语义 |
| Block / Field / Action | 数据在界面上的投影单元 / 单元数据的载体 / 触发指令的按钮 | 「字段」在这里是**组件**，必须挂在区块下，不能独立存在 |
| Data scope | 默认筛选条件，始终生效 | 区块级的只是前端过滤；**只有服务端级才是安全边界** |
| Revision | 完成并验证一个清晰节点后的存档 | 不是自动快照，也不是备份 |
| AI Employee | 由人设 + 技能组成、在业务界面里理解上下文的智能体 | 与「AI 按钮 / AI 助手插件」不同——它有岗位、有边界、有权限身份 |
| Skill | 给 AI 的专业领域知识包 | 与「AI 员工的技能（Tool）」是两个不同层级的东西，素材中混用，需按上下文区分 |

### 核心命题（用自己的话）

1. 界面需求必须先翻译成数据问题；顺序反了必然返工。
2. 平台能力分两层：可配置的标准能力（原生区块）与业务化的个性体验（JS）。判定顺序是「联动规则 → 事件流 → JS」。
3. 权限是服务端的事。前端过滤只影响体验，不影响安全。
4. 版本不是快照，是开发节奏的节拍器——AI 改动越快，节拍器越必要。
5. 迁移、版本、备份是三件不同的事，混用会覆盖生产数据。
6. AI 的价值不在「生成」，而在「被编排」：职责单一且显式声明边界的技能包 + 有岗位的 AI 员工 + 没有额外权限的护栏。
7. 系统的可复用性由数据结构决定（T 型主表/扩展表），而不是由功能数量决定。

### 论证链
作者用三类材料把命题串起来：**原则陈述**（如「彻底解耦」）+ **选型矩阵**（触发器、表类型、数据源）+ **完整实例**（v2 极简工单、v1 任务管理→CRM、两份行业方案）。其中「触发器选型」与「权限四层」被明确写成矩阵形式，说明作者有意把经验固化成判据而非技巧。

---

## 3. 批判（Critical）★

### 作者的时代局限
- **三层版本并存**：v1 教程、v2 教程、v3 概念（Flow Engine / AI 员工）同时在线，但文档未集中声明「当前推荐路径是哪套」。读者容易把三套当成一套。
- **截图全部外链**：1200+ 张截图托管在 `static-docs.nocobase.com`，脱离网络后文档不可读。

### 作者的立场盲点
- **单一厂商视角**：所有选型结论都以「NocoBase 的能力现状」为前提。例如「多对多一律用中间表」在纯 PostgreSQL 场景下并非必需，但在本平台的数组字段能力下成立。
- **只有成功案例**：文档体系内没有「失败复盘」章节。反例只能从各处 warning 段落与质量测试场景反推。
- **预览功能与正式功能混杂**：CRM 与工单方案标注「预览版 / 早期预览」，部分工作流标注「待完善」，但排版上与正式内容无区分。

### 未被证明的假设
- 假设用户已经想得清「核心业务对象」。文档给了「列 3–7 个对象」的动作，但没给对象边界不清时（如「项目」与「任务」该不该拆表）的判据。
- 假设 AI 的能力边界稳定。Skill 编排链的有效性建立在「AI 能可靠遵循领域知识包」之上，文档未讨论 AI 失效时的降级路径。
- 假设「配置优先」总是更优。文档未给出配置复杂度超过代码时的切换阈值。

### 最强反对意见
> 「这套方法论的价值高度依赖 NocoBase 的具体实现。把 v3 的 AI 员工、Flow Engine、多空间等特性拿掉之后，剩下的部分——先建模、配置优先、权限分层——已经是低代码行业二十年的共识，不构成新知识。」

**本报告的回应**：17 条能力中真正迁移性最高的 4 条（M9 版本节点、M11 Skill 编排链、M12 AI 员工双层设计、M14 AI 权限四层防护）**均不依赖 NocoBase**，且在 AI 协作开发这个新场景下被重新论证过（AI 改动速度 → 节拍器必要性；Agent 越权风险 → 护栏四层）。行业共识部分（M1/M2/M4）在本报告中作为「地基」保留，但不作为净收益主张。

> **以上批判已直接成为各能力卡 B 段（边界）的来源。**

---

## 4. 应用潜力（Applicability）

### 可 skill 化的内容
- [x] 搭建链路的顺序与选型判据（M1–M8）
- [x] 版本/迁移/备份的交付纪律（M9–M10）
- [x] Agent 工程方法论：技能切分、岗位设计、提示词结构、权限护栏（M11–M14）
- [x] 产品化与规模化：T 型架构、三空间、RAG 调优（M15–M17）

### 不适合 skill 化的内容
- 逐字段类型说明（约 60 篇，高度同构的参考手册）
- 外部数据库连接步骤、ECharts option 细节、文件/邮件配置步骤
- plugin-development / api / flow-engine 的源码级细节（与「搭建者全链路」主题不符）

### 预估 skill 数量
**17 张能力卡 → 1 个来源路由入口 + 7 个晋级 Skill**（受可发现入口软预算 8 约束；最终由阶段 1.6 晋级门决定）

### 优先级排序（按「最能赋能普通人」）
1. **revision-checkpoint** — 立刻可用、不依赖平台、直接缓解 AI 协作的主要风险
2. **skill-orchestration-chain / ai-employee-two-layer / ai-guardrails-four-layer** — Agent 工程三件套
3. **data-model-first → trigger-selection-timeline → four-layer-permission-funnel** — 搭建链路主干
4. 其余作为能力卡，经来源路由入口访问

---

## ✅ 质量门检查

- [x] 主旨能用一句话说清
- [x] 骨架列出 5 个一级论点（3–7 范围内）
- [x] 关键术语词典 ≥5 条（32 条）
- [x] 批判阶段列出 ≥3 条作者局限（3 类 + 最强反对意见）
- [x] 已向用户展示并得到确认

**用户确认时间**：2026-10-09（骨架与蒸馏重心在阶段 0 后经用户确认：走「搭建者全链路」）

---

---

## 5. 与官方 Skills 的对接（脑 ↔ 手）

本次蒸馏的产物是**判断层**（该不该做 / 顺序 / 边界）。官方仓库 [nocobase/skills](https://github.com/nocobase/skills)（npm `@nocobase/skills`，ISC 许可）提供的是**执行层**：20 个依赖 `nb` CLI 真正操作实例的技能。

**两层是单向接线，不混装、不合并、不 fork**。理由是官方技能为 npm 包，`nb skills update` 会整体覆盖任何本地改动 —— 只写「移交给谁」可以做到零维护负担。

> **版本前提**：官方 20 个技能目前全部声明 `NocoBase 2 only; never use in a NocoBase 3 project`；本包的判断规则跨版本（其中 4 条迁移性最高的完全不依赖 NocoBase）。

### 5.1 官方 20 个 Skill 与对接关系

| 官方 Skill | 职责 | 能力边界 | 本包移交给它的能力 |
|---|---|---|---|
| `nocobase-portal-manage` | UI 编写总调度器 | 页面 / 菜单 / 区块 / 字段 / 操作 / 布局 / 联动 / KPI / 仪表盘 / 图表的默认入口；先从 nb portal list 解析出唯一启用 Portal | `block-field-action-model`、`config-first-js-fallback`、`reference-vs-duplicate`、`nine-element-prompt`、`portal-app-space-model` |
| `nocobase-ui-builder` | No-code Portal UI 实现 | 仅在上游已解析出唯一 Portal 且 portalType=no-code 时接续；不从原始 UI 请求直接选中 | —（本包无对应判断卡，属纯执行/参考技能） |
| `nocobase-data-modeling` | 数据模型管理 | collection / field / relation / 视图表结构的检视与变更 | `data-model-first`、`collection-relation-choice`、`main-vs-external-datasource`、`t-shaped-data-architecture` |
| `nocobase-acl-manage` | ACL 治理 | 角色生命周期、全局角色模式、权限策略、Portal 入口访问、用户-角色绑定与风险评估 | `four-layer-permission-funnel`、`ai-guardrails-four-layer` |
| `nocobase-workflow-manage` | 工作流管理 | 工作流的检视 / 创建 / 更新 / 复制 / 启停 / 版本安全编辑 / 执行排障 | `trigger-selection-timeline` |
| `nocobase-revision` | 版本存档 | 把一个「已完成且有意义的里程碑」存成可恢复的版本 | `revision-checkpoint`、`migration-version-backup` |
| `nocobase-publish-manage` | 备份与迁移发布 | 备份还原（nb api backup）与迁移发布（nb api migration） | `migration-version-backup` |
| `nocobase-ai-employee` | AI 员工生命周期 | 发现已有员工、判断适配、创建 / 维护专用员工、准备绑定到界面 | `ai-employee-two-layer`、`ai-guardrails-four-layer` |
| `nocobase-ai-knowledge-base-manager` | 知识库与向量库 | 知识库能力核对、向量库、Local / Readonly / External 知识库、文档、检索测试 | `rag-tuning-loop` |
| `nocobase-ai-manager` | AI 核心前置 | LLM provider、已保存服务、CLI 与 UI 的配置分工、对话模型、embedding 发现、凭证安全 | `rag-tuning-loop` |
| `nocobase-ai-builder` | AI Portal 源码应用 | 在 AI Portal 里设计 / 搭建 / 验证源码级应用（基于 portal-template-default） | `nine-element-prompt`、`portal-app-space-model` |
| `nocobase-dsl-reconciler` | DSL 路径（opt-in） | 仅在用户明确要 YAML / DSL / 可提交 git / cli push 时使用 | `skill-orchestration-chain` |
| `nocobase-env-manage` | 环境与 CLI 维护 | bootstrap、运行时生命周期、CLI 维护、技能维护 | `main-vs-external-datasource`、`skill-orchestration-chain` |
| `nocobase-plugin-manage` | 插件启停 | 用 nb plugin 检视 / 启用 / 停用插件 | —（本包无对应判断卡，属纯执行/参考技能） |
| `nocobase-plugin-development` | 插件源码开发 | 脚手架、服务端与客户端代码、i18n、验证的完整 playbook | —（本包无对应判断卡，属纯执行/参考技能） |
| `nocobase-notification-manage` | 通知管理 | 站内信通道、邮件 SMTP 通道、工作流通知节点、发送日志 | `trigger-selection-timeline` |
| `nocobase-file-manager` | 文件存储 | 文件存储引擎、文件表、业务关联与文件记录生命周期 | —（本包无对应判断卡，属纯执行/参考技能） |
| `nocobase-data-analysis` | 数据查询分析 | 通过 MCP 查询与汇总业务数据（计数、分组、归属分布） | —（本包无对应判断卡，属纯执行/参考技能） |
| `nocobase-prototype-repro` | 原型复刻 | 给定 HTML / 图片 / 链接原型时按版式与标志性视觉复刻 | —（本包无对应判断卡，属纯执行/参考技能） |
| `nocobase-utils` | 通用参考 | 过滤条件与字段操作符、求值引擎、表达式语法、UID 生成等跨功能参考 | `config-first-js-fallback` |

### 5.2 覆盖统计

- 本包 17 张能力卡中，**17 张**有明确的官方执行手（每张卡末节「移交执行」列出）。
- 官方 20 个 Skill 中，**14 个**被本包的判断卡覆盖；其余为纯执行、参考或开发向技能，不属于「搭建者全链路」的判断范围。
- 两层**同主题但不重复**：例如官方 `nocobase-revision` 执行 `nb revision create`，本包 `revision-checkpoint` 判断**何时**该存、描述怎么写、恢复前先做什么。

