<!-- capability_id: cap.rag-tuning-loop | revision: 1 | status: active -->
<!-- 来源: 《NocoBase 官方文档（中文版）》（2026（v3 文档线，含 v1/v2 教程）） | 蒸馏: 2026-10-09 -->

# RAG 知识库调优四步（RAG Tuning Loop）

> 一句话：AI 答非所问时，第一反应是去看命中测试，而不是改提示词。

---

## R — 原文（Reading）

> 命中是分段而非整篇文档；命中测试默认 Top K = 4、Score = 0.6。
>
> — 《NocoBase 官方文档（中文版）》, `ai-employees/knowledge-base/knowledge-base/hit-tests.md`

---

## I — 方法论骨架（Interpretation）

知识库不是「传了就准」。它是一条需要调参的检索链：分段（Chunk size / Chunk overlap）→ 向量化 → 检索（Top K / Score）→ 注入生成。调优的正确入口是「命中测试」——先用一段真实问题看它命中了哪些分段，再倒推去调分段参数或检索参数；而不是反复改提示词。

---

## A1 — 素材中的应用（Past Application）

知识库同步三链路（Create / Update / Delete，其中 Update 与 Delete 必须按 Key 定位）；Local / Readonly / External 三类知识库的边界；检索策略（按需检索推荐 vs 每次自动检索）；知识库范围 =「Knowledge Base」配置 ∩ 用户角色权限，无交集时回答末尾会提示无权限；内置向量库只支持 PGVector；Resegment 会丢弃手工编辑过的分段与关联问题。

---

## A2 — 触发场景（Future Trigger）★

### 用户会在什么情境下需要这个能力？

1. AI 员工回答不准时，第一步是命中测试，第二步才是调分段，最后才动提示词
2. 知识库内容有更新但答案没变时，检查是否忘了重新向量化
3. 上传 PDF 前先确认是不是纯文本（扫描件需 OCR，否则检索不到）。

### 语言信号（用户话里出现这些就应激活）

- 「AI 员工回答得不准」
- 「分段该怎么切」
- 「知识库更新了答案还是旧的」
- 「扫描版 PDF 传上去检索不到」

### 与相邻能力的区分

- 与 `ai-employee-two-layer` 的区别：先确认岗位与技能挂对了，再排查检索——本能力只在「角色对了但答案不对」时介入。
- 与 `nine-element-prompt` 的区别：排查顺序里提示词是最后一步；若检索命中正常再回来调提示词。

### 同一来源内的相关能力

- depends-on：`ai-employee-two-layer`
- contrasts-with：—
- composes-with：`nine-element-prompt`

---

## E — 可执行步骤（Execution）

1. **上传文档后确认 Status = Success**
   - 完成标准：所有上传文档 Status = Success。

2. **做一次命中测试：用真实业务问题，看命中的是哪几个分段**
   - 完成标准：已用真实业务问题跑过命中测试，能说出命中的是哪几个分段。

3. **命中过长/过短 → 调 Chunk size 与 Chunk overlap（overlap 不能 ≥ chunk size）**
   - 完成标准：分段长度问题已通过 Chunk size / overlap 调整，且 overlap 小于 chunk size。

4. **命中不到 → 检查分段质量、补 Related questions、调 Score 与 Top K**
   - 完成标准：命中不到的问题已按 分段质量 → Related questions → Score/Top K 的顺序处理过。

5. **改过向量配置后必须重新向量化（选 Save and vectorize 或手动 Vectorization）**
   - 完成标准：改过向量配置后已重新向量化。

6. **给角色勾选知识库 Available 权限，否则回答里不会带知识库内容**
   - 完成标准：角色已勾选知识库 Available 权限。

7. **把这套测试参数手动同步到 AI 员工（测试参数不会自动写入）**
   - 完成标准：测试参数已手动同步到 AI 员工（测试参数不会自动写入）。

---

## B — 边界（Boundary）★

### 不要在以下情况使用此能力

- 内置向量库只支持 PGVector（PostgreSQL 插件）。
- 文档类型支持 txt/md/json/csv/xls/xlsx/pdf/doc/docx/pptx，但 PDF 仅解析纯文本，扫描件需先 OCR。
- Resegment 会丢弃手工编辑过的分段与关联问题，执行前需确认。

### 素材中警告的失败模式

- **知识库没配好就上线 Q&A** → 后果：答非所问、命中不到目标文档；正确做法：先做命中测试调 Top K 与 Score 再上线

### 容易混淆的邻近方法论

- `ai-employee-two-layer`：先确认岗位与技能挂对了，再排查检索——本能力只在「角色对了但答案不对」时介入。
- `nine-element-prompt`：排查顺序里提示词是最后一步；若检索命中正常再回来调提示词。

---

## 移交执行（官方 Skill）

**本包是「脑」，官方 `nocobase/*` Skills 是「手」。** 本卡只回答「该不该做、按什么顺序做、边界在哪」；
判定完成后，**具体操作交给官方 Skill** —— 它们依赖 `nb` CLI 与一个运行中的 NocoBase 实例。

**注意**：官方 20 个 Skill 目前全部声明 `NocoBase 2 only; never use in a NocoBase 3 project`。
若你的实例是 3.x，先确认该 Skill 是否已适配，否则本卡仅作判断依据，执行另寻路径。

**官方 20 个 Skill 的完整清单与全部对接关系**：见仓库 README 的《与官方 Skills 的关系》一节。

| 移交时机（判断已完成） | 交给 | 移交内容 |
|---|---|---|
| 已决定调分段或做命中测试，要真改知识库 | `nocobase-ai-knowledge-base-manager` · `nocobase-ai-manager` | 知识库、文档、分段与检索测试；模型服务与 embedding 前置 |

> 官方技能由 npm 包 `@nocobase/skills`（ISC 许可）提供，`nb skills update` 会整体覆盖 —— 因此本包只写「移交给谁」，绝不复制官方内容。

---

## 审计信息

- **三重验证**：V1 ✓ / V2 ✓ / V3 ✓
- **置信度**：高（≥3 个独立场景：knowledge-base 全套文档、rag.md、vector-database.md、scenarios）
- **V1** 跨域验证：分段文档、命中测试文档、RAG 文档、向量库文档、业务场景五处互相印证。通过。
- **V2** 预测力：可推导出「改配置忘了重新向量化会怎样」「知识库权限没给角色会怎样」等结论。通过。
- **V3** 独特性：RAG 调优本身是行业通用能力，独特性中等；但「先做命中测试再动提示词」这条排查顺序具备实操价值。部分通过。
- **出处**：`ai-employees/knowledge-base/knowledge-base/hit-tests.md`
- **蒸馏时间**：2026-10-09
- **来源**：《NocoBase 官方文档（中文版）》（1080 篇 Markdown / 约 130 万中文字）
