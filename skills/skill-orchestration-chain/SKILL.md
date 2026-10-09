---
name: skill-orchestration-chain
description: |
  用户在设计自建 Agent / Skill 体系，需要决定「能力怎么切、切几个、每个边界的 out of scope 怎么写」时；或一个 Agent 的技能体系越堆越乱、需要重新切分时；或想让 AI 从零搭一套系统、需要知道装什么与按什么顺序驱动时。
  不适用于：某个 Agent 的岗位人设与「技能 3–5 个、任务 5–7 个」的数量上限（那是 `ai-employee-two-layer`）；提示词本身怎么写（走 `nocobase-playbook` 的提示词九要素）；Agent 运行故障排查（如 401 / 超时，属集成排错）。
  触发词：Skill 怎么拆、Agent 技能、职责单一、能力边界、AI 搭建、编排链、out of scope。
metadata:
  cangjie.generated-by: cangjie-tools v2.5.0
  cangjie.capability-id: cap.skill-orchestration-chain
  cangjie.capability-revision: 1
  cangjie.bundle-id: bundle.nocobase
  cangjie.source-title: NocoBase 官方文档（中文版）
  cangjie.tags: decision, methodology
---
<!-- capability_id: cap.skill-orchestration-chain | revision: 1 | status: active -->
<!-- 来源: 《NocoBase 官方文档（中文版）》（2026（v3 文档线，含 v1/v2 教程）） | 蒸馏: 2026-10-09 -->

# AI 搭建 Skill 编排链（Skill Orchestration Chain）

> 一句话：把「搭系统」拆成 9 个职责单一、边界互斥的领域知识包交给 Agent。

---

## R — 原文（Reading）

> NocoBase Skills 是可安装到 AI Agent 中的领域知识包，让 AI 理解 NocoBase 的配置体系。NocoBase 提供 9 个 Skills，覆盖搭建全流程。
>
> — 《NocoBase 官方文档（中文版）》, `ai-builder/index.md`

---

## I — 方法论骨架（Interpretation）

不给 Agent 一个「万能 prompt」，而是给它 9 个职责单一、且明确声明「我不能做什么」的领域知识包：env-manage → data-modeling → ui-builder → workflow-manage → acl-manage → dsl-reconciler → plugin-manage → publish-manage → revision。每个 Skill 的 out-of-scope 声明就是协作边界——AI 界面 Skill 会主动说「配 ACL 请用权限 Skill」，这正是多 Skill 体系相对单 prompt 的核心优势。

---

## A1 — 素材中的应用（Past Application）

一句话建 CRM 数据模型（自动生成客户/联系人/商机/订单及关联）；一句话建客户管理页面（含搜索框与表格）；一句话编「订单创建后扣减商品库存」工作流（还能指出「库存不足仍执行扣减」的逻辑隐患）；一句「用 nocobase-dsl-reconciler skill 搭建工单管理系统，含仪表盘、工单列表、用户管理、SLA 配置」先出设计方案再一次性搭好；一句话存版本。

---

## A2 — 触发场景（Future Trigger）★

### 用户会在什么情境下需要这个能力？

1. 你自己设计 Agent 的 skill 体系时，直接照搬「按阶段切职责 + 明确 out of scope」的切法
2. 当你发现一个 Agent 越做越笨时，先检查是不是技能堆太多、没有边界声明
3. 新系统从 0 搭建时，优先走这条链路而不是手工点。

### 语言信号（用户话里出现这些就应激活）

- 「我要给 Agent 设计一套技能，怎么切」
- 「一个 Agent 装了多少个技能算多」
- 「AI 越用越笨了」
- 「新系统能不能让 AI 从零搭」

### 与相邻能力的区分

- 与 `ai-employee-two-layer` 的区别：本能力切的是「给 Agent 的领域知识包」，双层设计切的是「AI 员工的人设与任务」——一个是工具箱，一个是岗位。
- 与 `nine-element-prompt` 的区别：编排链决定「技能怎么分」，提示词九要素决定「单个技能里的话怎么写」。

### 同一来源内的相关能力

- depends-on：—
- contrasts-with：—
- composes-with：`ai-employee-two-layer`、`nine-element-prompt`、`ai-guardrails-four-layer`

---

## E — 可执行步骤（Execution）

1. **装 CLI：`npm install -g @nocobase/cli`，用 `nb --version` 确认**
   - 完成标准：`nb --version` 正常返回版本号。

2. **初始化：严格只运行 `nb init --ui`——不要改参数、不要尝试「非交互加速」，这条命令会同时自动安装 Skills**
   - 完成标准：`nb init --ui` 已原样执行完成，且 Skills 已随命令自动安装。

3. **校验环境：`nb env list`，确认有 env 且状态正常**
   - 完成标准：`nb env list` 显示存在 env 且状态正常。

4. **重启 AI Agent 会话，让它读取最新的 CLI 配置（配置在 ~/.nocobase/，全局可访问）**
   - 完成标准：AI Agent 会话已重启，能读到最新 CLI 配置。

5. **按顺序驱动：data-modeling → ui-builder → workflow-manage → acl-manage**
   - 完成标准：四个搭建类 Skill 已按顺序驱动，每一步都有可见产物。

6. **每个里程碑用 revision 存版本；跨环境用 publish-manage**
   - 完成标准：里程碑已用 revision 存版本；跨环境发布已走 publish-manage。

---

## B — 边界（Boundary）★

### 不要在以下情况使用此能力

- 界面 Skill 不能配 ACL、不能设计数据表、不能编工作流、不处理 v1 非现代页面导航。
- 工作流 Skill 不能设计数据模型、不能删除整个工作流、不能凭空编造节点或触发器类型。
- dsl-reconciler 不能逐字段微调（改用 data-modeling Skill）、不处理数据迁移与权限工作流，且功能仍在测试中、稳定性有限。
- AI 开发插件产出的 client-v2 代码只能在 /v/ 路径使用，不建议上生产；生成的代码与译文启用前必须人工 review。

### 容易混淆的邻近方法论

- `ai-employee-two-layer`：本能力切的是「给 Agent 的领域知识包」，双层设计切的是「AI 员工的人设与任务」——一个是工具箱，一个是岗位。
- `nine-element-prompt`：编排链决定「技能怎么分」，提示词九要素决定「单个技能里的话怎么写」。

---

## 审计信息

- **三重验证**：V1 ✓ / V2 ✓ / V3 ✓
- **置信度**：高（≥3 个独立场景：ai-builder 9 个 Skill 文档、ai-dev、nocobase-cli、多处一句话案例）
- **V1** 跨域验证：9 个 Skill 各自独立成文且互相声明边界；ai-dev 的插件开发 Skill 另立一条，边界清晰。通过。
- **V2** 预测力：可推导出「为什么 AI 会主动建议换用另一个 Skill」「自建 Agent 体系该怎么切分职责」。通过。
- **V3** 独特性：把搭建能力做成「可安装到 Agent 的领域知识包」而非内嵌 AI 功能，是当前最前沿的产品形态之一，迁移价值极高。通过。
- **出处**：`ai-builder/index.md`
- **蒸馏时间**：2026-10-09
- **来源**：《NocoBase 官方文档（中文版）》（1080 篇 Markdown / 约 130 万中文字）
