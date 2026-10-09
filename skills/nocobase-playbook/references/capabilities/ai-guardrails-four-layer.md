<!-- capability_id: cap.ai-guardrails-four-layer | revision: 1 | status: active -->
<!-- 来源: 《NocoBase 官方文档（中文版）》（2026（v3 文档线，含 v1/v2 教程）） | 蒸馏: 2026-10-09 -->

# AI 权限四层防护（AI Four-Layer Guardrails）

> 一句话：AI 没有额外权限——先建专用角色，再逐层收口，高风险操作保持人工。

---

## R — 原文（Reading）

> AI Agent 本身没有「额外权限」，它能做什么，完全取决于当前使用的身份和角色。……AI 不会绕过 NocoBase 的 ACL 体系。
>
> — 《NocoBase 官方文档（中文版）》, `ai-builder/security.md`

---

## I — 方法论骨架（Interpretation）

给 AI 的权限收口分四层：①员工访问层（AI 用什么角色）②任务可见性层（哪些区块与任务对它可见）③工具授权层（工具调用前是否需人工确认 / 工作流是否再做验证）④数据访问层（最终仍受用户权限与业务逻辑约束）。三条配套纪律：不为 AI 绑 root / admin；默认用 OAuth，只有自动化、无人值守、批量执行才用 API key；删除数据、改权限、启停插件保持人工控制。

---

## A1 — 素材中的应用（Past Application）

NocoBase 的两种数据分析引擎对照：Overall Analytics（模板化，AI 只调用预审核模板）推荐给普通用户；SQL Execution（AI 直接生成并执行 SQL）仅授权管理员并强制 SELECT + 范围限定 + 审计日志。操作可追溯通过 `x-request-source: cli` 请求头落地，审计日志记录 resource / action / userId / roleName / status / 该请求头。

---

## A2 — 触发场景（Future Trigger）★

### 用户会在什么情境下需要这个能力？

1. 任何「让 Agent 直接操作生产系统」的场景，先过这四层
2. 团队里有人为了方便给 AI 配了 admin 角色时，用 M14 否决
3. 审计要求出现时，知道要去 request 日志与审计日志里找 `x-request-source`。

### 语言信号（用户话里出现这些就应激活）

- 「能不能让 AI 直接改生产数据」
- 「为了方便给它配个管理员吧」
- 「AI 改的数据怎么追溯是谁让改的」
- 「删除/改权限这类操作要不要人工确认」

### 与相邻能力的区分

- 与 `four-layer-permission-funnel` 的区别：本能力面向 AI 身份（含专用角色、Ask/Allow 工具分级、请求来源标记）；权限四层收口面向人。
- 与 `ai-employee-two-layer` 的区别：双层设计决定 AI 干什么，四层防护决定它最多能干到哪。

### 同一来源内的相关能力

- depends-on：`four-layer-permission-funnel`、`skill-orchestration-chain`
- contrasts-with：`four-layer-permission-funnel`
- composes-with：`ai-employee-two-layer`

---

## E — 可执行步骤（Execution）

1. **为 AI Agent 建专用角色，按任务拆分权限边界（绝不绑 root / admin / 全局系统配置角色）**
   - 完成标准：AI 专用角色已建，且未绑定 root / admin / 全局系统配置角色。

2. **最小权限起步：先只开查看，按任务逐步补权限**
   - 完成标准：权限从只读起步、逐项补齐，没有一次性放开。

3. **鉴权方式默认 OAuth（审计更易对应到实际操作者）；API key 仅用于自动化场景，且只绑专用角色、定期轮换、不设「永不过期」**
   - 完成标准：鉴权默认走 OAuth；API key 仅用于自动化场景，已绑专用角色且有轮换计划。

4. **改数据的工具设 Ask，查询类设 Allow**
   - 完成标准：工具分级完成：改数据的工具 Ask、查询类 Allow。

5. **删除数据 / 改权限 / 启停插件 / 改系统配置 → 人工确认后再执行**
   - 完成标准：高风险操作（删除数据 / 改权限 / 启停插件 / 改系统配置）保持人工确认。

6. **数据建模与页面变更先在测试环境验证，再同步到生产**
   - 完成标准：变更已在测试环境验证，再同步到生产。

7. **检查可追溯性：确认请求带 `x-request-source: cli`，审计日志能落到人**
   - 完成标准：已确认请求带 `x-request-source: cli`，审计日志能落到人。

---

## B — 边界（Boundary）★

### 不要在以下情况使用此能力

- API key 依赖 APP_KEY：改动 APP_KEY 会让所有 API 密钥失效。
- 不要把长期运行的任务集中使用同一个高权限环境。
- 「非安全模式」的 JavaScript 节点等同授予服务端权限，不是安全边界——不要把脚本编辑权交给低信任用户。

### 素材中警告的失败模式

- **给 AI 绑 admin / root 角色** → 后果：权限暴露面剧增，审计无法归因；正确做法：建专用角色，最小权限起步

### 容易混淆的邻近方法论

- `four-layer-permission-funnel`：本能力面向 AI 身份（含专用角色、Ask/Allow 工具分级、请求来源标记）；权限四层收口面向人。
- `ai-employee-two-layer`：双层设计决定 AI 干什么，四层防护决定它最多能干到哪。

---

## 移交执行（官方 Skill）

**本包是「脑」，官方 `nocobase/*` Skills 是「手」。** 本卡只回答「该不该做、按什么顺序做、边界在哪」；
判定完成后，**具体操作交给官方 Skill** —— 它们依赖 `nb` CLI 与一个运行中的 NocoBase 实例。

**注意**：官方 20 个 Skill 目前全部声明 `NocoBase 2 only; never use in a NocoBase 3 project`。
若你的实例是 3.x，先确认该 Skill 是否已适配，否则本卡仅作判断依据，执行另寻路径。

**官方 20 个 Skill 的完整清单与全部对接关系**：见仓库 README 的《与官方 Skills 的关系》一节。

| 移交时机（判断已完成） | 交给 | 移交内容 |
|---|---|---|
| 已定好 AI 的权限边界，要真配角色与门禁 | `nocobase-acl-manage` · `nocobase-ai-employee` | 为 AI 建专用角色与权限策略；员工绑定与风险面收口 |

> 官方技能由 npm 包 `@nocobase/skills`（ISC 许可）提供，`nb skills update` 会整体覆盖 —— 因此本包只写「移交给谁」，绝不复制官方内容。

---

## 审计信息

- **三重验证**：V1 ✓ / V2 ✓ / V3 ✓
- **置信度**：高（≥3 个独立场景：ai-builder/security、ai-employees/permission、users-permissions/acl、integration/api-keys）
- **V1** 跨域验证：AI 安全文档、AI 员工权限文档、ACL 文档、API 密钥文档四处互相印证。通过。
- **V2** 预测力：可推导出「为什么 SQL Execution 要收归管理员」「为什么要用请求头区分 AI 与人工操作」等做法。通过。
- **V3** 独特性：最小权限是行业共识，但「四层防护 + 引擎分级的推荐/慎用对照」是 NocoBase 具体的落地形态，具备可执行性。通过。
- **出处**：`ai-builder/security.md`
- **蒸馏时间**：2026-10-09
- **来源**：《NocoBase 官方文档（中文版）》（1080 篇 Markdown / 约 130 万中文字）
