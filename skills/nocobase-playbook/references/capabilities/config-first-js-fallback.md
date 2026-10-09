<!-- capability_id: cap.config-first-js-fallback | revision: 1 | status: active -->
<!-- 来源: 《NocoBase 官方文档（中文版）》（2026（v3 文档线，含 v1/v2 教程）） | 蒸馏: 2026-10-09 -->

# 配置优先、代码兜底（Config First, JS as Fallback）

> 一句话：原生区块负责可配置的标准能力，JS 区块只补业务化的个性体验。

---

## R — 原文（Reading）

> 原生区块负责「可配置的标准能力」，JS 区块负责「业务化的个性体验」。
>
> — 《NocoBase 官方文档（中文版）》, `building-tips/operations-dashboard.md`

---

## I — 方法论骨架（Interpretation）

界面搭建有三层台阶，逐级下探：①联动规则（左变量 + 操作符 + 右值）②事件流（触发事件 + 执行时机 + 步骤）——不写完整 JS 也能把自定义逻辑插到系统内置流程的指定位置③RunJS / JS 区块字段列操作。多数人跳过前两层直接写 JS，导致系统失去可配置性与权限联动；正确做法是逐层尝试，只在原生表达不了时才下探。

---

## A1 — 素材中的应用（Past Application）

运营仪表盘：筛选与趋势用原生图表区块，KPI 卡片与点击下钻用 JS 区块（building-tips/operations-dashboard.md）；双表联动筛选用事件流（行点击 → 设置数据范围 → 刷新目标区块）；表单调第三方 API 回填用事件流「渲染前 + 所有流之后 + 执行 JavaScript」。

---

## A2 — 触发场景（Future Trigger）★

### 用户会在什么情境下需要这个能力？

1. 遇到复杂交互需求时，先问「联动规则能不能表达」，再问「事件流能不能表达」，最后才考虑 JS
2. 团队里有人提议「整个仪表盘写成一个 JS 大屏」时，用 M5 直接否决。

### 语言信号（用户话里出现这些就应激活）

- 「这个复杂交互实现不了，是不是要靠写代码」
- 「整个仪表盘能不能写成一个 JS 大屏」
- 「联动规则做到一半发现条件太多」
- 「事件流和 JS 区块该选哪个」

### 与相邻能力的区分

- 与 `block-field-action-model` 的区别：先问「有没有现成区块/字段/操作」，本级只处理原生能力表达不了的部分。
- 与 `reference-vs-duplicate` 的区别：本能力管「怎么实现」，引用/复制管「实现好的怎么复用」。

### 同一来源内的相关能力

- depends-on：`block-field-action-model`
- contrasts-with：—
- composes-with：`block-field-action-model`

---

## E — 可执行步骤（Execution）

1. **第 1 步：尝试联动规则（区块显隐 / 字段显示·必填·赋值 / 操作禁用）**
   - 完成标准：已尝试联动规则，并记录「能表达 / 不能表达」的具体结论。

2. **第 2 步：尝试事件流（选触发事件 + 执行时机，再 Add step）**
   - 完成标准：已尝试事件流（触发事件 + 执行时机），并记录结论。

3. **第 3 步：仍不满足才写 JS；按场景选载体——整块结构用 JS Block、单元数据用 JS Field、衍生列用 JS Column、界面结构用 JS Item、点击逻辑用 JS Action**
   - 完成标准：只有在上述两步都失败时才写 JS，且载体选择（Block/Field/Column/Item/Action）有理由。

4. **写 JS 的六条硬规矩：选 class 或 [name=...] 不用固定 id；注册事件前先解绑；保证幂等防连点；try/catch 并给用户提示；大库缓存到上层复用；重型计算下推到查询阶段**
   - 完成标准：六条硬规矩逐条自查通过：选择器、事件解绑、幂等、异常处理、缓存复用、计算下推。

---

## B — 边界（Boundary）★

### 不要在以下情况使用此能力

- 联动规则不能绕过 ACL——先有查看权限，规则才生效；多条规则是覆盖而非叠加，以最后一条为准。
- RunJS 定位是轻量扩展，适合快速实验与临时逻辑；长期稳定能力应做成插件。
- JS 沙箱内 window/document 是安全代理；区块隐藏后再显示会重渲染，需自行做事件清理。

### 素材中警告的失败模式

- **把整个仪表盘写成一个 JS 大屏** → 后果：失去筛选、权限联动与可配置能力；正确做法：原生区块负责标准能力，JS 只补个性化

### 容易混淆的邻近方法论

- `block-field-action-model`：先问「有没有现成区块/字段/操作」，本级只处理原生能力表达不了的部分。
- `reference-vs-duplicate`：本能力管「怎么实现」，引用/复制管「实现好的怎么复用」。

---

## 审计信息

- **三重验证**：V1 ✓ / V2 ✓ / V3 ✓
- **置信度**：高（≥3 个独立场景：interface-builder/runjs、building-tips/operations-dashboard、building-tips/ai-fill-js-block-form、v1 教程）
- **V1** 跨域验证：界面搭建文档、两篇 building-tips、v1 教程仪表盘章节、AI 前端员工 Nathan 的定位陈述相互印证。通过。
- **V2** 预测力：可推导出「什么时候该叫 Nathan（AI 前端工程师）而不是自己配置」「为什么大屏方案会失去筛选与权限能力」。通过。
- **V3** 独特性：「原生 / JS 分工」这条线在多数低代码平台里并不显式，NocoBase 把它写成了明确的工程纪律。通过。
- **出处**：`building-tips/operations-dashboard.md`
- **蒸馏时间**：2026-10-09
- **来源**：《NocoBase 官方文档（中文版）》（1080 篇 Markdown / 约 130 万中文字）
