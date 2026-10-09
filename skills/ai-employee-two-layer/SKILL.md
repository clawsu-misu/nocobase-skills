---
name: ai-employee-two-layer
description: |
  用户要把 AI 接进业务流程，需要先明确「它是什么岗位、管哪类活、技能挂几个、任务挂几个」时；或发现某个 AI 员工响应变慢 / 行为发散需要按岗位收口时；或设计「AI 自动写回业务数据」的表结构时。
  不适用于：AI 回答不准 / 答非所问 / 检索不到（那是检索问题，走 `nocobase-playbook` 的 RAG 调优）；给外部 Agent 设计技能包与边界（那是 `skill-orchestration-chain`）；AI 的权限安全（那是 `ai-guardrails-four-layer`）。
  触发词：AI 员工、AI 助手、岗位、人设、角色定义、技能挂几个、写回数据。
metadata:
  cangjie.generated-by: cangjie-tools v2.5.0
  cangjie.capability-id: cap.ai-employee-two-layer
  cangjie.capability-revision: 1
  cangjie.bundle-id: bundle.nocobase
  cangjie.source-title: NocoBase 官方文档（中文版）
  cangjie.tags: decision, methodology
---
<!-- capability_id: cap.ai-employee-two-layer | revision: 1 | status: active -->
<!-- 来源: 《NocoBase 官方文档（中文版）》（2026（v3 文档线，含 v1/v2 教程）） | 蒸馏: 2026-10-09 -->

# AI 员工双层设计（Role Definition + Task Customization）

> 一句话：稳定层写「是谁」，灵活层写「现在做什么」——一个 AI 只干一类活。

---

## R — 原文（Reading）

> 让 AI 员工理解你的业务逻辑，而不是只执行提示词。
>
> — 《NocoBase 官方文档（中文版）》, `ai-employees/scenarios/viz-crm.md`

---

## I — 方法论骨架（Interpretation）

把 AI 员工拆成两层：角色定义（是谁、风格、能力边界，长期稳定）+ 任务定制（当前做什么、指标、范围，按需切换）。配套两条量化纪律：一个 AI 只干一类活；每个员工的技能 3–5 个、任务 5–7 个以内。NocoBase 预置 9 名员工（Atlas 路由、Viz 分析、Dex 整理、Ellis 邮件、Lexi 翻译、Vera 调研、Nathan 前端、Lina 本地化、Dara 可视化）正是按岗位切的，而不是按功能切的。

---

## A1 — 素材中的应用（Past Application）

Viz 的 CRM 分析落地方案：建 `data_analysis` 模板表存预审核 SQL，用工作流按模板匹配、只读执行、返回 rows+fields，AI 只调用模板不直接写 SQL；背景调研范式把复杂自动化拆成四层工作流：创建任务层 / 执行任务层 / 受控写回层 / 异常清理层。

---

## A2 — 触发场景（Future Trigger）★

### 用户会在什么情境下需要这个能力？

1. 业务方说「给我配个 AI 助手帮忙处理订单」→ 先问岗位职责边界，再写角色设定
2. 发现一个 AI 员工效果越来越差 → 检查是不是技能太多、任务太杂
3. 要落地「AI 自动写回业务数据」时，用「业务表存当前版本 + 过程表存每次调研状态」的双表拆分，避免 AI 覆盖人工数据。

### 语言信号（用户话里出现这些就应激活）

- 「给我配个 AI 助手帮忙处理订单」
- 「这个 AI 员工加了十几个技能，反而不好用」
- 「想让 AI 自动填业务表，又怕覆盖人工数据」
- 「角色定义该怎么写」

### 与相邻能力的区分

- 与 `skill-orchestration-chain` 的区别：本能力设计「岗位」，编排链设计「工具箱」；先有岗位再挂技能。
- 与 `nine-element-prompt` 的区别：本能力决定角色定义的结构（双层），提示词九要素决定每一层里具体写什么。

### 同一来源内的相关能力

- depends-on：`skill-orchestration-chain`
- contrasts-with：—
- composes-with：`nine-element-prompt`、`ai-guardrails-four-layer`、`rag-tuning-loop`

---

## E — 可执行步骤（Execution）

1. **按岗位（不是按功能）切角色**
   - 完成标准：角色是按岗位切的，不是按功能切的。

2. **写角色定义：身份 / 目标 / 能力边界 / 输出风格（长期稳定，不要频繁改）**
   - 完成标准：角色定义四段（身份 / 目标 / 能力边界 / 输出风格）已写完，可长期不改。

3. **按任务挂技能，每个员工 3–5 个技能、5–7 个任务以内**
   - 完成标准：技能数在 3–5 个、任务数在 5–7 个，未超标。

4. **工具授权分级：查询类设 Allow，改数据类设 Ask**
   - 完成标准：工具授权已分级：查询类 Allow、改数据类 Ask。

5. **高风险能力（如 SQL Execution）只授权给少数管理员，并强制 SELECT + 范围限定 + 审计**
   - 完成标准：高风险能力（如 SQL Execution）仅授权给指定管理员，并带 SELECT + 范围限定 + 审计约束。

6. **先跑通一个员工再扩展；用「快捷任务」把常用操作固化成一键触发**
   - 完成标准：至少一个员工已端到端跑通，常用操作已固化为快捷任务。

---

## B — 边界（Boundary）★

### 不要在以下情况使用此能力

- 技能全选会混乱、响应慢、准确率下降。
- 提示词过长（>2000 字符）拖慢且冗余——建议基础 500–800、复杂 800–1500 字符。
- Lina（本地化员工）不支持通用 Skills/Tools；一个 AI 兼多类活会明显不稳。

### 素材中警告的失败模式

- **AI 员工技能全选** → 后果：混乱、响应慢、准确率下降；正确做法：每员工 3–5 个技能、5–7 个任务

### 容易混淆的邻近方法论

- `skill-orchestration-chain`：本能力设计「岗位」，编排链设计「工具箱」；先有岗位再挂技能。
- `nine-element-prompt`：本能力决定角色定义的结构（双层），提示词九要素决定每一层里具体写什么。

---

## 审计信息

- **三重验证**：V1 ✓ / V2 ✓ / V3 ✓
- **置信度**：高（≥3 个独立场景：ai-employees/configuration、built-in/9 名员工、scenarios/viz-crm、scenarios/company-background-research）
- **V1** 跨域验证：配置文档、9 名预置员工、4 个业务场景文档独立复现「角色稳定 + 任务灵活」双层结构。通过。
- **V2** 预测力：可推导出「为什么预置员工按岗位而非功能切」「为什么 AI 写回要用双表拆分」。通过。
- **V3** 独特性：「AI 员工」而非「AI 功能」的隐喻本身就带来了组织化设计——角色、技能、任务、审批层级齐全。通过。
- **出处**：`ai-employees/scenarios/viz-crm.md`
- **蒸馏时间**：2026-10-09
- **来源**：《NocoBase 官方文档（中文版）》（1080 篇 Markdown / 约 130 万中文字）
