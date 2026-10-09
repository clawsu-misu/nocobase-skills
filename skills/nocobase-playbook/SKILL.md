---
name: nocobase-playbook
description: |
  用户在做「用 NocoBase 从零搭一套业务系统」相关的事：想清要存什么数据、把界面搭出来、配权限与工作流、交给 AI 搭建或协作、把它产品化并交付上线。
  
  **本入口自身负责的能力域**（这些问题激活本入口，而不是去激活某个独立 Skill）：
  - 表类型与关系选型（树表 / 视图表 / SQL 表 / 多对多要不要中间表 / 记录唯一标识）
  - 主库与外部库选型（已有 ERP 想加管理界面 / 分析库只读）
  - 区块·字段·操作三层模型（字段放哪 / 按钮权限为什么跟表格走）
  - 配置优先与 JS 兜底（该用配置还是写代码 / 仪表盘要不要写大屏）
  - 引用 vs 复制（模板复用 / 一改全改）
  - 迁移 / 版本 / 备份三机制（改了配置怎么同步到生产 / 上线前检查什么）
  - 提示词九要素（提示词怎么写 / 为什么越写越长没效果）
  - T 型数据架构（多客户多产品线共用一套系统 / 要不要改代码）
  - 三空间模型（多租户 / 多条业务线 / 多个入口 / 整体数据隔离）
  - RAG 知识库调优（AI 答非所问怎么排查 / 分段怎么调 / 命中测试）
  
  **不适用于**：读一段具体配置参数或字段类型清单（属参考手册，本包不覆盖）；问 NocoBase 的源码级插件开发 / API 开发；与具体软件无关的服务器运维、Docker 基础教学、通用 SQL 编写。
  
  触发词：NocoBase、无代码、低代码、表类型、外部库、区块、引用复制、迁移发布、提示词、多租户、知识库、命中测试。
metadata:
  cangjie.generated-by: cangjie-tools v2.5.0
  cangjie.variant: router
  cangjie.bundle-id: bundle.nocobase
  cangjie.capability-count: 17
  cangjie.entrypoint-count: 8
---
# NocoBase 官方文档（中文版） — 来源路由入口（compact pack）

## 触发与不触发

**适用**：与本书能力域相关的咨询与任务（见下方路由表的意图列）。
**不适用**：
- 逐步的 UI 点击教程（本包给判据与顺序，不给「点哪里」）
- 具体字段类型的逐项参数说明（约 60 篇，属参考手册，仅把术语收进术语词典）
- 外部数据库的连接操作步骤、图表库自定义 option 细节、文件/邮件服务的配置步骤
- NocoBase 的插件开发 / API 开发 / Flow Engine 源码级定制（属开发者文档，本次未蒸馏）
- 与具体软件无关的通用服务器运维、Docker 基础教学、编程语言教学

## 核心原则（常驻速览，概览类问题读到这里即可回答）

1. 先定数据结构，再谈界面——界面只是数据的不同投影；任何界面需求先翻译成数据问题。
2. 能用配置表达的不要写代码；配置表达不了的，先穷尽联动规则与事件流，最后才考虑 JS。
3. 权限是服务端的事——区块级数据范围只是体验，不是安全边界；行级隔离必须配在服务端。
4. 只在「已完成并验证的清晰节点」存版本；AI 连续改动的速度决定你必须先有可回退点。
5. AI 没有额外权限——先为它建专用角色，再从最小权限起步，改数据的工具设人工确认。
6. 迁移、版本、备份是三件事：跨环境发布用迁移、开发回退用版本、容灾还原用备份，不可互相顶替。
7. AI 答非所问时，第一反应是做命中测试，其次调分段，最后才动提示词。
8. 触发器按事件时序选，不按「我想用什么」选：可拦截的用操作前、面向用户操作的用操作后、面向数据变动的用数据表事件。
9. 本包只做判断（脑），不做操作；判定完成后把执行移交给官方 `nocobase/*` Skills（手）——每张能力卡都有「移交执行」一节写明移交给谁。

## 能力路由（先读本表，按意图加载 1 张能力卡）

| 用户意图 | 先读 | 补读/备注 |
|---|---|---|
| 从零开始搭一套业务系统，不知从哪下手；先建模还是先搭页面；接手别人搭了一半的系统怎么读 | references/capabilities/data-model-first.md | 已晋级为独立 Skill `data-model-first`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 分类要不要拆成新表；该用哪种关系类型；多对多要不要建中间表；视图表/SQL 表怎么配 | references/capabilities/collection-relation-choice.md | references/capabilities/data-model-first.md |
| 已有系统想加管理界面该用哪个数据源；什么情况该接外部数据库；数据源选型 | references/capabilities/main-vs-external-datasource.md | references/capabilities/data-model-first.md |
| 这个组件该放哪；按钮权限怎么控制；页面为什么加不了这个组件；区块怎么设计 | references/capabilities/block-field-action-model.md | references/capabilities/config-first-js-fallback.md、references/capabilities/reference-vs-duplicate.md、references/capabilities/data-model-first.md |
| 这个需求该用配置还是写代码；什么时候必须写 JS；仪表盘要不要整个写成大屏 | references/capabilities/config-first-js-fallback.md | references/capabilities/block-field-action-model.md |
| 模板该引用还是复制；改了一处结果到处都变了；复用别人的表单模板 | references/capabilities/reference-vs-duplicate.md | references/capabilities/block-field-action-model.md |
| 当 X 发生时自动做 Y 该用哪个触发器；工作流为什么不触发；定时任务怎么写；超时自动取消怎么实现 | references/capabilities/trigger-selection-timeline.md | 已晋级为独立 Skill `trigger-selection-timeline`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 销售只能看自己的客户怎么配；权限怎么设计；看不见数据怎么排查；怎么防止越权 | references/capabilities/four-layer-permission-funnel.md | 已晋级为独立 Skill `four-layer-permission-funnel`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 什么时候该存版本；AI 连着改了很多东西怎么回退；版本描述该怎么写；交付验收要检查什么 | references/capabilities/revision-checkpoint.md | 已晋级为独立 Skill `revision-checkpoint`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 改了配置怎么同步到生产；系统改坏了怎么回去；数据丢了怎么办；怎么上线才安全 | references/capabilities/migration-version-backup.md | references/capabilities/portal-app-space-model.md、references/capabilities/revision-checkpoint.md |
| 怎么把搭建能力拆给 AI；Agent 技能怎么切分；为什么 agent 越做越笨；Skill 体系怎么设计 | references/capabilities/skill-orchestration-chain.md | 已晋级为独立 Skill `skill-orchestration-chain`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 怎么给 AI 配岗位；一个 AI 该管多少事；AI 员工效果越来越差；AI 自动写回业务数据怎么设计 | references/capabilities/ai-employee-two-layer.md | 已晋级为独立 Skill `ai-employee-two-layer`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 提示词该怎么写；为什么提示词越写越长没效果；怎么限制 AI 别乱来 | references/capabilities/nine-element-prompt.md | references/capabilities/skill-orchestration-chain.md、references/capabilities/ai-employee-two-layer.md |
| AI 能不能直接操作生产数据；给 AI 配什么权限；AI 操作的审计怎么做；怎么防止 AI 乱改数据 | references/capabilities/ai-guardrails-four-layer.md | 已晋级为独立 Skill `ai-guardrails-four-layer`（已安装时优先直接使用；本卡仅作原文与背景补充） |
| 多个客户/业务线怎么共用一套系统；新品类要管要不要改代码；系统架构怎么设计才可扩展 | references/capabilities/t-shaped-data-architecture.md | references/capabilities/portal-app-space-model.md、references/capabilities/data-model-first.md |
| 分公司数据怎么隔离；要不要拆成多个应用；多租户怎么设计；给经销商一个只看到部分功能的入口 | references/capabilities/portal-app-space-model.md | references/capabilities/migration-version-backup.md、references/capabilities/t-shaped-data-architecture.md |
| AI 回答不准怎么排查；知识库怎么调；分段参数怎么设；上传文档后 AI 检索不到 | references/capabilities/rag-tuning-loop.md | references/capabilities/nine-element-prompt.md、references/capabilities/ai-employee-two-layer.md |

**非能力类查询**：
- 书名/作者/章节/整书概览 → references/overview.md
- 术语解释 → references/glossary.md
- 决策规则速查（不需要原文依据时） → references/cheatsheet.md
- 完整意图与关键词索引（本表未覆盖的意图先查这里） → references/capability-index.md

## 加载规则

- 每次任务先读本文件，再按路由表加载 **1** 张能力卡；任务明确跨域时最多加载 2 张。
- 概览/书名类问题不加载能力卡，用「核心原则」与 overview.md 回答。
- 路由表与 capability-index.md 都无法命中的意图，明确告知超出本书范围，不要硬套。

## 边界与判停

- 能力路由表与能力索引都无法命中的意图 → 明确告知超出本次蒸馏范围，不要硬套最近似的能力。
- 问「当前推荐的版本路径是哪套（v1/v2/v3）」→ 素材三层并存且未集中声明，需以官方站点版本说明为准。
- 涉及到素材中标注「预览版 / 早期预览」的方案（CRM、工单）→ 只作为设计方法样本，不当作可直接交付的产品。
- 能力卡中标注「推演」的反例 → 不是原文内容，是从相邻边界条件推导的，采用前需自行复核。
- 需要给出精确的性能数字或并发上限 → 素材未给出可引用的量化承诺，不要编造。
