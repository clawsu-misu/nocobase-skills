# 决策规则速查 — NocoBase 官方文档（中文版）

| 能力 | 一句话规则 |
|---|---|
| 数据模型驱动（Data-Model-First） | 先把数据结构定死，界面只是数据的不同投影——任何界面需求先翻译成数据问题。 |
| 表类型与关系选型判据（Collection & Association Selection） | 按结构选表类型、按语义选关系基数，多对多一律用中间表。 |
| 主库与外部库选型（Main vs External Data Source） | 新建系统用主库，接管他系统库用外部库——一句话决策。 |
| 区块·字段·操作三层模型（Block / Field / Action） | 界面不是自由画布：字段必须挂在区块下，操作由表格权限统一决定。 |
| 配置优先、代码兜底（Config First, JS as Fallback） | 原生区块负责可配置的标准能力，JS 区块只补业务化的个性体验。 |
| 复用语义：引用 vs 复制（Reference vs Duplicate） | 复用之前先回答一句话：要不要「一改全改」。 |
| 触发器选型矩阵（事件时序模型） | 先定位事件在时序的哪个点，再选触发器——拦截用前、用户操作用后、数据变动用表事件。 |
| 权限四层收口（Four-Layer Permission Funnel） | 角色 → 菜单 → 数据 → 字段；数据范围必须配在服务端。 |
| 版本节点（Revision Checkpoint） | 只在「已完成并验证的清晰节点」存版本——这是 AI 协作开发的节拍器。 |
| 迁移 / 版本 / 备份 三机制不可替代（Migration vs Version vs Backup） | 跨环境发布用迁移、开发回退用版本、容灾还原用备份——三者不能互相顶替。 |
| AI 搭建 Skill 编排链（Skill Orchestration Chain） | 把「搭系统」拆成 9 个职责单一、边界互斥的领域知识包交给 Agent。 |
| AI 员工双层设计（Role Definition + Task Customization） | 稳定层写「是谁」，灵活层写「现在做什么」——一个 AI 只干一类活。 |
| 提示词九要素（Nine-Element Prompt Formula） | 先说清「是谁、做什么、怎么做、做到什么标准」，再谈限制。 |
| AI 权限四层防护（AI Four-Layer Guardrails） | AI 没有额外权限——先建专用角色，再逐层收口，高风险操作保持人工。 |
| T 型数据架构（T-Shaped Data Architecture） | 主表横向装通用能力，扩展表纵向装专业字段——新增业务类型只加表，不改主流程。 |
| 三空间模型（Portal vs App vs Space） | 多工作区解决入口、多应用解决拆分、多空间解决隔离——别混用。 |
| RAG 知识库调优四步（RAG Tuning Loop） | AI 答非所问时，第一反应是去看命中测试，而不是改提示词。 |

> 速查只给结论；需要原文依据、案例或反例时读对应能力卡。
