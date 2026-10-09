# 能力索引（完整版）

| capability_id | 标题 | 重要度 | 意图 | 关键词 | 能力卡 |
|---|---|---|---|---|---|
| cap.data-model-first | 数据模型驱动（Data-Model-First） | critical | 从零开始搭一套业务系统，不知从哪下手；先建模还是先搭页面；接手别人搭了一半的系统怎么读 | 数据模型、建模、先建模还是先搭界面、data model、data modeling、先做什么、接手项目、需求翻译成数据 | capabilities/data-model-first.md |
| cap.collection-relation-choice | 表类型与关系选型判据（Collection & Association Selection） | high | 分类要不要拆成新表；该用哪种关系类型；多对多要不要建中间表；视图表/SQL 表怎么配 | 表类型、关系、树表、中间表、记录唯一标识、collection、association、many-to-many、tree table、unique key | capabilities/collection-relation-choice.md |
| cap.main-vs-external-datasource | 主库与外部库选型（Main vs External Data Source） | high | 已有系统想加管理界面该用哪个数据源；什么情况该接外部数据库；数据源选型 | 数据源、主库、外部库、外部数据库、ERP、data source、external database、只读分析 | capabilities/main-vs-external-datasource.md |
| cap.block-field-action-model | 区块·字段·操作三层模型（Block / Field / Action） | high | 这个组件该放哪；按钮权限怎么控制；页面为什么加不了这个组件；区块怎么设计 | 区块、字段、操作、界面搭建、block、field、action、界面设计器 | capabilities/block-field-action-model.md |
| cap.config-first-js-fallback | 配置优先、代码兜底（Config First, JS as Fallback） | high | 这个需求该用配置还是写代码；什么时候必须写 JS；仪表盘要不要整个写成大屏 | 配置优先、低代码边界、JS区块、RunJS、联动规则、事件流、config first、low-code、custom code | capabilities/config-first-js-fallback.md |
| cap.reference-vs-duplicate | 复用语义：引用 vs 复制（Reference vs Duplicate） | high | 模板该引用还是复制；改了一处结果到处都变了；复用别人的表单模板 | 模板、引用、复制、复用、同步、ui template、reference、duplicate、sync | capabilities/reference-vs-duplicate.md |
| cap.trigger-selection-timeline | 触发器选型矩阵（事件时序模型） | high | 当 X 发生时自动做 Y 该用哪个触发器；工作流为什么不触发；定时任务怎么写；超时自动取消怎么实现 | 触发器、工作流、自动化、定时任务、webhook、审批、trigger、workflow、automation、cron | capabilities/trigger-selection-timeline.md |
| cap.four-layer-permission-funnel | 权限四层收口（Four-Layer Permission Funnel） | critical | 销售只能看自己的客户怎么配；权限怎么设计；看不见数据怎么排查；怎么防止越权 | 权限、角色、数据范围、数据隔离、ACL、字段权限、permission、role、data scope、越权 | capabilities/four-layer-permission-funnel.md |
| cap.revision-checkpoint | 版本节点（Revision Checkpoint） | critical | 什么时候该存版本；AI 连着改了很多东西怎么回退；版本描述该怎么写；交付验收要检查什么 | 版本、版本控制、回退、节拍器、revision、checkpoint、rollback、AI协作 | capabilities/revision-checkpoint.md |
| cap.migration-version-backup | 迁移 / 版本 / 备份 三机制不可替代（Migration vs Version vs Backup） | critical | 改了配置怎么同步到生产；系统改坏了怎么回去；数据丢了怎么办；怎么上线才安全 | 迁移、发布、备份、版本、交付、上线、migration、release、backup、环境隔离 | capabilities/migration-version-backup.md |
| cap.skill-orchestration-chain | AI 搭建 Skill 编排链（Skill Orchestration Chain） | critical | 怎么把搭建能力拆给 AI；Agent 技能怎么切分；为什么 agent 越做越笨；Skill 体系怎么设计 | AI搭建、Skill、Agent、编排、技能切分、职责单一、skill orchestration、agent design、out of scope | capabilities/skill-orchestration-chain.md |
| cap.ai-employee-two-layer | AI 员工双层设计（Role Definition + Task Customization） | critical | 怎么给 AI 配岗位；一个 AI 该管多少事；AI 员工效果越来越差；AI 自动写回业务数据怎么设计 | AI员工、角色设计、岗位、人设、任务、ai employee、agent role、role setting、tool | capabilities/ai-employee-two-layer.md |
| cap.nine-element-prompt | 提示词九要素（Nine-Element Prompt Formula） | medium | 提示词该怎么写；为什么提示词越写越长没效果；怎么限制 AI 别乱来 | 提示词、prompt、角色设定、正面引导、80:20、prompt engineering、system prompt | capabilities/nine-element-prompt.md |
| cap.ai-guardrails-four-layer | AI 权限四层防护（AI Four-Layer Guardrails） | critical | AI 能不能直接操作生产数据；给 AI 配什么权限；AI 操作的审计怎么做；怎么防止 AI 乱改数据 | AI安全、权限、审计、护栏、专用角色、最小权限、guardrail、AI permission、audit、x-request-source | capabilities/ai-guardrails-four-layer.md |
| cap.t-shaped-data-architecture | T 型数据架构（T-Shaped Data Architecture） | high | 多个客户/业务线怎么共用一套系统；新品类要管要不要改代码；系统架构怎么设计才可扩展 | 架构、模块化、继承表、扩展表、产品化、复用、architecture、t-shaped、extensible | capabilities/t-shaped-data-architecture.md |
| cap.portal-app-space-model | 三空间模型（Portal vs App vs Space） | high | 分公司数据怎么隔离；要不要拆成多个应用；多租户怎么设计；给经销商一个只看到部分功能的入口 | 多应用、多空间、多工作区、多租户、数据隔离、入口、multi-app、multi-space、multi-portal | capabilities/portal-app-space-model.md |
| cap.rag-tuning-loop | RAG 知识库调优四步（RAG Tuning Loop） | high | AI 回答不准怎么排查；知识库怎么调；分段参数怎么设；上传文档后 AI 检索不到 | RAG、知识库、命中测试、分段、向量库、Top K、知识库调优、retrieval、embedding | capabilities/rag-tuning-loop.md |
