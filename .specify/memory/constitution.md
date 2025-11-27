# QtKs 项目宪章 / QtKs Project Constitution

## 核心原则 / Core Principles

### I. 双语文档规范 / Bilingual Documentation Standard

**中文版（用户视角）：**
- 所有项目文档必须提供中文版本供用户阅读
- 规范文档（spec）、计划文档（plan）、任务列表（tasks）等用户面向文档必须使用中文编写
- 当英文表达更精确时，可创建双语版本：
  - 中文版：供用户阅读和审核
  - 英文版：供AI处理和理解，保持技术精确性
  - 两个版本必须保持内容同步

**English Version (AI Perspective):**
- All project documents must provide Chinese version for user reading
- User-facing documents (spec, plan, tasks) must be written in Chinese
- When English is more precise, create bilingual versions:
  - Chinese version: For user reading and review
  - English version: For AI processing, maintaining technical precision
  - Both versions must stay synchronized

### II. QML/Python 架构 / QML/Python Architecture

**中文版：**
- 使用 QML 构建用户界面
- 使用 Python 处理后端逻辑
- 通过信号槽机制实现前后端通信

**English Version:**
- Build UI with QML
- Handle backend logic with Python
- Use signal-slot mechanism for frontend-backend communication

### III. 渐进式开发 / Progressive Development

**中文版：**
- 优先实现核心功能（P1优先级）
- 每个功能必须独立可测试
- 遵循 MVP（最小可行产品）原则

**English Version:**
- Implement core features first (P1 priority)
- Each feature must be independently testable
- Follow MVP (Minimum Viable Product) principles

## 开发流程 / Development Workflow

### 功能开发流程 / Feature Development Process

**中文版：**
1. 使用 `/speckit.specify` 创建功能规范（中文）
2. 使用 `/speckit.plan` 生成实现计划（中文）
3. 使用 `/speckit.tasks` 创建任务列表（中文）
4. 使用 `/speckit.implement` 执行实现
5. 提交前必须向用户确认（不要直接提交代码）

**English Version:**
1. Create feature spec with `/speckit.specify` (Chinese)
2. Generate implementation plan with `/speckit.plan` (Chinese)
3. Create task list with `/speckit.tasks` (Chinese)
4. Execute implementation with `/speckit.implement`
5. Confirm with user before committing (never commit directly)

## 技术约束 / Technical Constraints

### UI 框架 / UI Framework

**中文版：**
- 前端：PySide6 + QML
- 样式：Metro 设计风格
- 触摸优先的交互设计

**English Version:**
- Frontend: PySide6 + QML
- Styling: Metro design style
- Touch-first interaction design

### 后端架构 / Backend Architecture

**中文版：**
- Python 3.x
- 与 Moonraker API 集成
- 支持 Klipper 3D打印机控制

**English Version:**
- Python 3.x
- Integration with Moonraker API
- Support for Klipper 3D printer control

## 治理 / Governance

**中文版：**
- 本宪章优先于所有其他开发实践
- 修改宪章需要明确记录和用户批准
- 所有 AI 生成的代码和文档必须遵循本宪章

**English Version:**
- This constitution supersedes all other development practices
- Constitution amendments require explicit documentation and user approval
- All AI-generated code and documentation must comply with this constitution

**版本 / Version**: 1.0.0 | **批准日期 / Ratified**: 2025-11-26 | **最后修订 / Last Amended**: 2025-11-26
