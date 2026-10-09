---
name: revision-checkpoint
description: |
  用户在跟 AI 连着改了一堆东西之后需要确定「上一个可回退的清晰节点在哪」时；或在定「什么时候存版本、版本描述怎么写」的纪律时；或做 AI 交付验收时。
  也可直接用于非 NocoBase 的 AI 协作开发（前端项目、Agent 编排、数据 pipeline）。
  不适用于：跨环境发布与配置同步（走 `nocobase-playbook` 的迁移 / 版本 / 备份三机制）、容灾还原与数据找回（同上，那是备份管理）、服务器迁移或部署（属运维）。
  触发词：存版本、回退、撤销、改坏了、恢复、节点、验收、AI 改太多。
metadata:
  cangjie.generated-by: cangjie-tools v2.5.0
  cangjie.capability-id: cap.revision-checkpoint
  cangjie.capability-revision: 1
  cangjie.bundle-id: bundle.nocobase
  cangjie.source-title: NocoBase 官方文档（中文版）
  cangjie.tags: decision, methodology
---
<!-- capability_id: cap.revision-checkpoint | revision: 1 | status: active -->
<!-- 来源: 《NocoBase 官方文档（中文版）》（2026（v3 文档线，含 v1/v2 教程）） | 蒸馏: 2026-10-09 -->

# 版本节点（Revision Checkpoint）

> 一句话：只在「已完成并验证的清晰节点」存版本——这是 AI 协作开发的节拍器。

---

## R — 原文（Reading）

> 它不是每改一个字段就创建一次版本。默认只在完成并验证一个清晰节点后保存，这样版本列表更容易读，恢复时也更容易判断该回到哪里。
>
> — 《NocoBase 官方文档（中文版）》, `ai-builder/version-control.md`

---

## I — 方法论骨架（Interpretation）

把「存版本」当作开发节奏的节拍器，而不是自动快照。一个版本 = 一个「已完成、已验证、可作为回退基点」的清晰节点；描述写「已经完成了什么」（业务语义），不写 snapshot / backup / test / version2，更不写 token、地址、密码。这条纪律在 AI 连续搭建的场景下价值最高，因为 AI 的改动速度远超人工审查速度，没有节拍器就没法回退。

---

## A1 — 素材中的应用（Past Application）

ai-builder 的标准动作：完成「客户管理页面 + 筛选区 + 编辑表单」后执行 `nb revision create "…"`；ops-management 的发布链路把版本控制列为开发阶段的必备动作；发布前还要额外做发布前备份。

---

## A2 — 触发场景（Future Trigger）★

### 用户会在什么情境下需要这个能力？

1. 让 AI 连着改了 5 个页面后，你应该问「我上一个可回退的清晰节点在哪」
2. 评审 AI 交付时必须检查版本列表，而不只看最终效果
3. 这个模式可直接搬到任何 AI 辅助开发流程（前端项目、Agent 编排、数据 pipeline）。

### 语言信号（用户话里出现这些就应激活）

- 「AI 连续改了五个页面，怎么回去」
- 「什么时候该存一次版本」
- 「版本描述写成 snapshot / v2 行不行」
- 「评审 AI 交付要看什么」

### 与相邻能力的区分

- 与 `migration-version-backup` 的区别：本能力是「开发期回退」，另两条是「跨环境发布」与「容灾还原」——三机制不可互相顶替。
- 与 `ai-guardrails-four-layer` 的区别：版本节点管「改坏了能回去」，AI 权限护栏管「改之前就没权限乱改」。

### 同一来源内的相关能力

- depends-on：—
- contrasts-with：—
- composes-with：`migration-version-backup`、`skill-orchestration-chain`

---

## E — 可执行步骤（Execution）

1. **每完成一个可独立验证的里程碑，存一次版本（一套数据表 / 一个页面 / 一条工作流）**
   - 完成标准：每个里程碑收尾都有一个版本，且版本数量等于里程碑数量（没有噪声版本）。

2. **描述写业务语义：「完成客户管理页面、筛选区和编辑表单配置」**
   - 完成标准：每条版本描述都是业务语义的「已完成什么」。

3. **描述里绝不出现 token、密码、内部地址**
   - 完成标准：全部描述中不含 token、密码、内部地址。

4. **恢复某个版本之前，先给当前状态也存一份，保证可反悔**
   - 完成标准：恢复操作前已先给当前状态存了一份版本。

5. **把「存版本」写进与 AI 协作的固定话术，让它成为交付验收的一部分**
   - 完成标准：「存版本」已写进与 AI 协作的固定话术，并出现在交付验收清单里。

---

## B — 边界（Boundary）★

### 不要在以下情况使用此能力

- 版本控制不能代替备份管理（底层能力是备份）；恢复操作在版本控制插件里做，AI 的 skill 不能自动恢复。
- 插件未启用时无法创建版本。
- 「复制到新版本」仍属同一组工作流，「复制工作流」才算全新工作流（执行次数归零）——统计口径不同。

### 素材中警告的失败模式

- **每改一个字段就存一次版本** → 后果：版本列表被噪声淹没，恢复时无从判断；正确做法：只在完成并验证的清晰节点存版本

### 容易混淆的邻近方法论

- `migration-version-backup`：本能力是「开发期回退」，另两条是「跨环境发布」与「容灾还原」——三机制不可互相顶替。
- `ai-guardrails-four-layer`：版本节点管「改坏了能回去」，AI 权限护栏管「改之前就没权限乱改」。

---

## 审计信息

- **三重验证**：V1 ✓ / V2 ✓ / V3 ✓
- **置信度**：高（≥3 个独立场景：ai-builder/version-control、ops-management/version-control、ops-management/release-management）
- **V1** 跨域验证：AI 搭建侧与运维侧两套文档独立给出同一纪律，且都在发布链路中出现。通过。
- **V2** 预测力：可推导出「版本描述该怎么写」「恢复前必须先备份」「版本计数与备份计数的差异」等结论。通过。
- **V3** 独特性：这条是整份文档中迁移性最强的纪律——它不依赖 NocoBase，可直接用于任何 AI 协作开发。通过。
- **出处**：`ai-builder/version-control.md`
- **蒸馏时间**：2026-10-09
- **来源**：《NocoBase 官方文档（中文版）》（1080 篇 Markdown / 约 130 万中文字）
