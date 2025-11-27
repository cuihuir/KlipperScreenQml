# Tasks: 基于设计图的UI界面实现

**Input**: Design documents from `/specs/001-metro-ui/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/qml-python-api.md, quickstart.md

**Tests**: 不包含测试任务（规格中未要求TDD）

**Organization**: 任务按用户故事分组，支持独立实现和测试

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可并行执行（不同文件，无依赖）
- **[Story]**: 所属用户故事 (US1-US6)

## Path Conventions

- **Backend**: `backend/` (Python)
- **Frontend**: `qml/` (QML)
- **Components**: `qml/components/`
- **Pages**: `qml/pages/`
- **Assets**: `assets/icons/`

---

## Phase 1: Setup (项目基础设施)

**Purpose**: 创建项目结构、Style系统和基础组件

- [X] T001 从ui_design设计图提取颜色和间距，更新 qml/Style.qml
- [X] T002 [P] 创建底部导航栏组件 qml/components/BottomNavBar.qml
- [X] T003 [P] 创建占位符Toast组件 qml/components/PlaceholderToast.qml
- [X] T004 [P] 创建确认对话框组件 qml/components/ConfirmDialog.qml
- [X] T005 [P] 创建UI状态管理模块 backend/ui_state.py
- [X] T006 [P] 整理图标资源: 从 ui_design/3dUI/ 复制可用素材到 assets/icons/，缺少的再补充
- [X] T007 更新 qml/components/qmldir 注册新组件
- [X] T008 扩展 backend/application.py 暴露UIState到QML

**Checkpoint**: 基础组件和状态管理框架就绪

---

## Phase 2: Foundational (核心框架)

**Purpose**: 实现页面路由、导航系统和共享组件

**⚠️ CRITICAL**: 必须完成此阶段后才能开始用户故事实现

- [X] T009 重构 qml/MainWindow.qml 实现StackLayout页面路由
- [X] T010 集成BottomNavBar到MainWindow，实现4按钮导航 (首页/控制/文件/设置)
- [X] T011 [P] 创建温度卡片组件 qml/components/TempCard.qml (80px最小触摸目标)
- [X] T012 [P] 创建文件卡片组件 qml/components/FileCard.qml (80px最小触摸目标)
- [X] T013 [P] 创建打印模式选择对话框 qml/components/PrintModeDialog.qml (80px最小触摸目标)
- [X] T014 扩展 backend/moonraker_client.py 添加文件元数据获取和缩略图处理
- [ ] T015 扩展 backend/config_manager.py 添加UI设置项 (亮度/音量/语言/时区)
- [X] T016 [P] 添加触摸目标验证任务 (11.3寸80px×80px最小尺寸)
- [X] T017 验证组件qmldir注册完整性 (确保所有QML组件正确注册)
- [X] T018 验证11.3寸屏幕字体大小适配 (最小20px字体)

**Checkpoint**: 页面路由、导航和核心组件就绪，可开始用户故事实现

---

## Phase 3: User Story 1 - 快速开始打印工作流 (Priority: P1) 🎯 MVP

**Goal**: 用户可在30秒内从首页选择文件并开始打印

**Independent Test**: 点击开始打印→选择快速打印→选择文件→确认打印开始

### Implementation for User Story 1

- [ ] T019 [US1] 实现PrintModeDialog三个选项 (快速打印/AI打印/上次打印) - 80px触摸目标
- [ ] T020 [US1] AI打印选项点击显示PlaceholderToast ("AI功能开发中")
- [ ] T021 [US1] 创建文件选择页面 qml/pages/FilesPage.qml (从PrintModeDialog进入)
- [ ] T022 [P] [US1] 实现文件列表左侧区域 (FileCard列表，支持缩略图，80px触摸目标)
- [ ] T023 [P] [US1] 实现文件详情右侧面板 (层高/层数/预估时间/温度，20px字体)
- [ ] T024 [US1] 实现快速打印模式的"开始打印"按钮逻辑 (80px触摸目标)
- [ ] T025 [US1] 创建确认对话框 qml/components/ConfirmDialog.qml (已在Phase1完成)
- [ ] T026 [US1] 实现上次打印确认对话框 LastPrintDialog.qml (80px触摸目标)
- [ ] T027 [US1] 创建打印状态页面 qml/pages/PrintingPage.qml
- [ ] T028 [P] [US1] 实现打印进度显示 (百分比/进度条/剩余时间，20px字体)
- [ ] T029 [P] [US1] 实现打印状态温度显示 (喷头/热床/仓温)
- [ ] T030 [P] [US1] 实现打印状态位置显示 (Z高度/当前层，20px字体)
- [ ] T031 [US1] 实现打印控制按钮 (暂停/恢复/取消，80px触摸目标)
- [ ] T032 [US1] 实现取消打印确认对话框 (80px触摸目标)
- [ ] T033 [US1] 打印开始后自动切换到PrintingPage

**Checkpoint**: 快速打印工作流完整

---

## Phase 4: User Story 2 - 控制页面操作 (Priority: P2)

**Goal**: 用户可手动控制打印机运动、温度和挤出功能

**Independent Test**: 点击控制导航→移动轴→设置温度→挤出操作

### Implementation for User Story 2

- [ ] T034 [US2] 创建控制页面布局 qml/pages/ControlPage.qml (1920x440宽屏)
- [ ] T035 [P] [US2] 创建轴控制组件 (内嵌于ControlPage，X/Y/Z +/- 按钮，80px触摸目标)
- [ ] T036 [P] [US2] 创建步长选择组件 (0.1mm/1mm/10mm/50mm切换，80px触摸目标)
- [ ] T037 [P] [US2] 实现温度设置区域 (使用TempCard组件显示温度，20px字体)
- [ ] T038 [P] [US2] 创建挤出控制按钮 (挤出/回抽，80px触摸目标)
- [ ] T039 [US2] 实现归零按钮逻辑 (通过sendGcode发送G28命令，80px触摸目标)
- [ ] T040 [US2] 实现热床调平按钮 (占位符，待实现G29，80px触摸目标)
- [ ] T041 [US2] 轴移动通过sendGcode实现（G91相对移动）
- [ ] T042 [US2] 温度设置通过MoonrakerClient API实现
- [ ] T043 [US2] 挤出控制通过MoonrakerClient API实现 (占位符)
- [ ] T044 [US2] 实现当前位置坐标实时显示 (positionX/Y/Z，20px字体)
- [ ] T045 [US2] 温度范围验证 (0-300°C，输入截断)
- [ ] T046 [US2] 轴移动安全检查 (归零状态验证)

**Checkpoint**: 控制页面功能完整，支持所有手动操作

---

## Phase 5: User Story 3 - 文件管理和组织 (Priority: P2)

**Goal**: 用户可浏览和管理来自多个来源的打印文件

**Independent Test**: 点击文件导航→切换文件源→查看文件详情→选择打印

### Implementation for User Story 3

- [ ] T047 [US3] 创建文件页面布局 qml/pages/FilesPage.qml
- [ ] T048 [P] [US3] 实现四个筛选选项卡 (本地文件/U盘文件/打印记录/网络文件，80px触摸目标)
- [ ] T049 [P] [US3] 文件夹/文件分层显示（简化版，仅显示文件）
- [ ] T050 [US3] 实现文件列表切换筛选逻辑
- [ ] T051 [P] [US3] USB/历史/网络为占位符功能
- [ ] T052 [P] [US3] 实现文件缩略图异步加载 (Image.asynchronous: true)
- [ ] T053 [US3] 实现文件元数据获取 (通过getFileMetadata Slot)
- [ ] T054 [US3] 实现文件删除功能 (确认对话框 + deleteFile API)
- [ ] T055 [US3] 实现文件下载占位符 (网络文件功能)
- [ ] T056 [US3] 文件列表虚拟化优化 (ListView.cacheBuffer)
- [ ] T057 [US3] 文件搜索功能 (占位符)

**Checkpoint**: 文件管理功能完整，支持本地文件操作

---

## Phase 6: User Story 4 - 系统配置和设置 (Priority: P3)

**Goal**: 用户可配置系统设置，设置在会话之间持久保存

**Independent Test**: 点击设置导航→调整设置→退出设置→验证持久化

### Implementation for User Story 4

- [ ] T058 [US4] 创建设置页面布局 qml/pages/SettingsPage.qml
- [ ] T059 [P] [US4] 实现基础设置选项卡 (亮度/音量滑块，80px触摸目标)
- [ ] T060 [P] [US4] 实现通用设置选项卡 (语言/时区下拉菜单，80px触摸目标)
- [ ] T061 [P] [US4] 实现网络设置选项卡 (WiFi扫描/连接，占位符，80px触摸目标)
- [ ] T062 [US4] 实现设置持久化 (ConfigManager save/load)
- [ ] T063 [US4] 实现亮度音量立即应用效果
- [ ] T064 [US4] 实现语言切换重启界面占位符
- [ ] T065 [US4] 实现设备管理页面 (设备信息/摄像头开关，80px触摸目标)
- [ ] T066 [US4] 实现摄像头开关占位符功能
- [ ] T067 [US4] 实现恢复出厂设置占位符 (确认对话框，80px触摸目标)
- [ ] T068 [US4] 实现网络WiFi扫描占位符
- [ ] T069 [US4] 验证设置持久化完整性

**Checkpoint**: 设置功能完整，支持基本配置

---

## Phase 7: User Story 5 - 首页仪表板状态监控 (Priority: P1) 🎯 MVP

**Goal**: 用户启动应用立即看到打印机状态和快速操作入口

**Independent Test**: 启动应用验证所有状态小部件显示当前打印机数据

### Implementation for User Story 5

- [ ] T070 [US5] 创建首页布局 qml/pages/HomePage.qml (1920x440宽屏Row布局)
- [ ] T071 [P] [US5] 实现温度显示区域 (喷头/热床/仓温三个TempCard，20px字体)
- [ ] T072 [P] [US5] 实现耗材水平显示组件 qml/components/FilamentCard.qml
- [ ] T073 [P] [US5] 实现最近打印卡片组件 qml/components/RecentPrintCard.qml
- [ ] T074 [US5] 实现"开始打印"主按钮，点击打开PrintModeDialog (80px触摸目标)
- [ ] T075 [P] [US5] 实现用户头像占位符 (静态图片 + "Hi, 用户!" 问候)
- [ ] T076 [P] [US5] 实现通知图标占位符 (显示"0条未读"，点击显示PlaceholderToast，80px触摸目标)
- [ ] T077 [P] [US5] 实现打印统计占位符卡片 (静态"0 打印耗地")
- [ ] T078 [US5] 连接MoonrakerClient实时温度数据到首页组件
- [ ] T079 [US5] 实现连接状态指示器 (在线/离线状态，20px字体)
- [ ] T080 [US5] 实现打印机状态指示器 (ready/printing/error，20px字体)

**Checkpoint**: 首页仪表板功能完整，显示实时打印机状态

---

## Phase 8: User Story 6 - 屏保和待机状态 (Priority: P3)

**Goal**: 设备空闲时显示屏保，点击唤醒并返回活动屏幕

**Independent Test**: 设备空闲超时→屏保激活→点击唤醒

### Implementation for User Story 6

- [ ] T081 [US6] 创建屏保页面 qml/pages/ScreenSaverPage.qml
- [ ] T082 [US6] 实现空闲状态屏保布局 (Logo + 时间 + 基本状态，20px字体)
- [ ] T083 [US6] 实现打印中屏保布局 (进度 + 温度 + 剩余时间，20px字体)
- [ ] T084 [US6] 实现空闲检测定时器 backend/ui_state.py:_idle_timer
- [ ] T085 [US6] 实现全局事件过滤器 backend/ui_state.py:eventFilter
- [ ] T086 [US6] 实现屏保激活逻辑 (超时后自动激活)
- [ ] T087 [US6] 实现点击唤醒逻辑 (任意点击退出屏保，全屏触摸区域)
- [ ] T088 [US6] 集成屏保超时设置 (从config.json读取，默认5分钟)
- [ ] T089 [US6] 实现屏保激活时隐藏底部导航栏
- [ ] T090 [US6] 屏保时钟更新机制 (Timer每秒更新)

**Checkpoint**: 屏保功能完整，支持空闲检测和点击唤醒

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: 优化和完善所有用户故事

- [ ] T091 [P] 实现所有占位符功能的日志记录 (logPlaceholderClick)
- [ ] T092 [P] 实现教育入口占位符 (如设计图中有)
- [ ] T093 添加连接状态指示器到顶部栏 (WiFi/蓝牙图标，20px字体)
- [ ] T094 实现打印机忙时阻止新打印 (显示"打印机忙"提示)
- [ ] T095 实现网络断开警告和按钮禁用逻辑
- [ ] T096 [P] 优化文件列表加载性能 (ListView虚拟化)
- [ ] T097 [P] 优化图片异步加载 (Image.asynchronous: true)
- [ ] T098 设计图视觉一致性验证 (颜色/间距/字体对照检查)
- [ ] T099 页面切换动画优化 (< 300ms)
- [ ] T100 触摸响应优化 (< 100ms延迟，80px触摸目标验证)
- [ ] T101 实现错误处理和用户友好提示
- [ ] T102 [P] 实现性能监控 (内存/CPU使用率)
- [ ] T103 验证11.3寸屏幕显示效果 (视觉可读性检查)
- [ ] T104 实现应用启动优化 (< 2秒启动)
- [ ] T105 完整的用户工作流程测试

**Checkpoint**: 系统优化完成，满足性能和用户体验要求

---

## Implementation Strategy

### MVP Scope (Phase 3 Only)
- 快速打印工作流：首页→文件选择→打印确认→打印状态
- 核心功能：温度监控、文件浏览、打印控制

### Incremental Delivery
- 每个用户故事可以独立交付和使用
- 立即可用价值优先 (P1 → P2 → P3)

### Parallel Execution Opportunities
- **Phase 1**: 所有组件可以并行开发 (不同文件)
- **Phase 3-8**: 在每个故事内部，UI组件可以并行开发
- **Phase 9**: 优化任务可以并行执行

### Dependencies
- **Phase 2** 必须在所有用户故事之前完成
- **User Stories 1 & 5** (P1) 可以并行开始 → MVP
- **User Stories 2 & 3** (P2) 可以并行开始
- **User Stories 4 & 6** (P3) 可以并行开始

## Quality Gates

### 11.3寸屏幕适配验证
- [ ] 所有触摸目标 ≥80px×80px (物理尺寸约10mm)
- [ ] 字体大小 ≥20px (确保207 PPI可读性)
- [ ] 元素间距 ≥12px (防止误触)

### Metro UI设计一致性
- [ ] 95%视觉匹配度 (与ui_design设计图)
- [ ] 纯黑背景(#000000) + 亮黄强调色(#FFEB3B)
- [ ] 1920×440超宽屏布局符合性

### 触摸优先设计
- [ ] 禁用复杂手势 (双击/长按/右键)
- [ ] 单次点击完成所有操作
- [ ] 触摸响应时间 <100ms

### 实时数据完整性
- [ ] 温度更新频率 ~1秒/次
- [ ] 页面切换时间 <300ms
- [ ] 数据刷新延迟 <2秒