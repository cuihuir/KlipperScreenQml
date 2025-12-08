# 任务清单：iOS 风格全局导航与主页设计

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**状态**: 待实施

## 任务概览

- **总任务数**: 47
- **P1 用户故事任务**: 38
- **P2 用户故事任务**: 3
- **Setup/基础任务**: 6
- **并行机会**: 21 个任务可并行执行

---

## 实现策略

### MVP 范围（最小可行产品）

**推荐 MVP**: 用户故事 1 + 用户故事 7（主页显示 + 全局导航）

这将提供：
- ✅ 可运行的主页界面
- ✅ Widget 基础框架（虽然数据可能是模拟的）
- ✅ 全局导航系统（返回/Home 按钮）
- ✅ 从主页进入现有功能页的能力
- ✅ 完整的导航体验

### 渐进式交付顺序

1. **Phase 1**: Setup（任务 T001-T003） - 项目基础设施
2. **Phase 2**: Foundational（任务 T004-T006） - 导航系统核心
3. **Phase 3**: US1 + US7（任务 T007-T020） - MVP: 主页 + 导航 ✅
4. **Phase 4**: US2（任务 T021-T024） - 温度控制
5. **Phase 5**: US3（任务 T025-T028） - 风扇/LED 控制
6. **Phase 6**: US4 + US5（任务 T029-T036） - 打印控制
7. **Phase 7**: US6（任务 T037-T039） - 功能图标导航
8. **Phase 8**: US8（任务 T040-T042） - 布局优化（P2）
9. **Phase 9**: Polish（任务 T043-T047） - 性能和错误处理

---

## Phase 1: Setup（项目初始化）

**目标**: 搭建项目基础设施

### 任务

- [x] T001 创建功能分支 001-global-nav
- [x] T002 [P] 检查 Python 依赖完整性（PySide6, websockets, aiohttp, requests）
- [x] T003 [P] 创建 assets/icons/ 目录并准备占位图标

---

## Phase 2: Foundational（导航系统核心）

**目标**: 实现导航管理器和全局按钮基础设施

**前置条件**: Phase 1 完成

### 任务

- [x] T004 实现 NavigationManager 类 in `backend/navigation_manager.py`
  - 实现 `pushPage()`, `popPage()`, `popToRoot()` 方法
  - 实现 `currentDepth`, `currentPage`, `canGoBack` 属性
  - 发射 `navigationChanged`, `depthChanged` 信号
- [x] T005 扩展 Application 类注册 NavigationManager in `backend/application.py`
  - 添加 `self.navigation_manager = NavigationManager(parent=self)`
  - 暴露 `@Property(QObject) def navigationManager()` 给 QML
- [x] T006 [P] 在 main.py 中注册 navigationManager 为全局上下文属性
  - `engine.rootContext().setContextProperty("navigationManager", app.navigationManager)`

---

## Phase 3: US1 + US7（MVP: 主页显示 + 全局导航）

**用户故事 1**: 主页显示常用功能和快捷操作
**用户故事 7**: 使用全局按钮导航

**目标**: 实现可运行的主页界面和全局导航系统

**独立测试标准（US1）**:
- ✅ 主页加载时显示 4 个 Widget 占位符（温度、风扇、LED、打印）
- ✅ 主页显示 6 个功能图标（设置、控制、文件、AFC、移动、更多）
- ✅ Widget 区域和图标区域有清晰的视觉分隔

**独立测试标准（US7）**:
- ✅ 左侧显示 HOME 和 RETURN 两个全局按钮
- ✅ 点击功能图标后，全局按钮保持可见
- ✅ 点击 HOME 按钮返回主页
- ✅ 点击 RETURN 按钮返回上一级（或主页）
- ✅ 导航在 300ms 内完成

### 任务

#### US1: 主页基础结构

- [x] T007 [US1] 创建 HomeWidget 基类 in `qml/components/HomeWidget.qml`
  - 定义通用属性：`widgetId`, `title`, `widgetState`, `isInteractive`
  - 实现状态管理：idle/active/updating/error
  - 添加加载指示器和错误指示器
- [x] T008 [P] [US1] 创建 TempWidget 占位符 in `qml/components/TempWidget.qml`
  - 继承 HomeWidget
  - 显示静态"温度"标签和 "0.0°C" 占位符
  - 添加 `heaterName` 属性
- [x] T009 [P] [US1] 创建 FanWidget 占位符 in `qml/components/FanWidget.qml`
  - 继承 HomeWidget
  - 显示静态"风扇"标签和 "关闭" 状态
  - 添加 `fanName` 属性
- [x] T010 [P] [US1] 创建 LedWidget 占位符 in `qml/components/LedWidget.qml`
  - 继承 HomeWidget
  - 显示静态"LED"标签和 "关闭" 状态
  - 添加 `ledName` 属性
- [x] T011 [P] [US1] 创建 PrintControlWidget 占位符 in `qml/components/PrintControlWidget.qml`
  - 继承 HomeWidget
  - 显示超大"开始打印"按钮（idle 状态）
  - 定义 `printState` 属性（暂时固定为 "idle"）
- [x] T012 [P] [US1] 创建 FunctionIcon 组件 in `qml/components/FunctionIcon.qml`
  - 定义属性：`iconId`, `label`, `iconPath`, `targetPage`
  - 实现点击事件（暂时只打印日志）
  - 添加悬停反馈效果
- [x] T013 [US1] 创建 HomePage in `qml/pages/HomePage.qml`
  - 使用 RowLayout 分为左右两区域（60%/40%）
  - 左侧：放置 4 个 Widget（TempWidget, FanWidget, LedWidget, PrintControlWidget）
  - 右侧：使用 GridLayout 放置 6 个 FunctionIcon
  - 绑定 `property StackView stackView: StackView.view`

#### US7: 全局导航系统

- [x] T014 [P] [US7] 创建 GlobalNavButtons 组件 in `qml/components/GlobalNavButtons.qml`
  - 创建 HOME 按钮（始终启用）
  - 创建 RETURN 按钮（绑定 `enabled: navigationManager.canGoBack`）
  - 实现 `onClicked` 处理器调用 `navigationManager` 方法
  - 添加按钮图标和悬停效果
- [x] T015 [US7] 更新 MainWindow.qml 集成 StackView + GlobalNavButtons
  - 使用 RowLayout：左侧 GlobalNavButtons（80px），右侧 StackView
  - 设置 `initialItem: homePageComponent`
  - 配置转场动画：pushEnter/pushExit/popEnter/popExit（250ms, OutCubic）
- [x] T016 [P] [US7] 创建页面注册表 in `qml/MainWindow.qml`
  - 定义 `pageRegistry` QtObject
  - 注册现有页面：settings, control, files, printing
  - 实现 `navigateTo(pageId, properties)` 辅助函数
- [x] T017 [US7] 在 HomePage 中实现 FunctionIcon 点击导航
  - 连接 `onClicked` 到 `pageRegistry.navigateTo()`
  - 同步调用 `navigationManager.pushPage()`
- [x] T018 [US7] 为现有页面（SettingsPage, ControlPage, FilesPage）添加生命周期钩子
  - 添加 `StackView.onActivated` 钩子（打印日志）
  - 添加 `StackView.onDeactivated` 钩子（打印日志）
  - 绑定 `property StackView stackView: StackView.view`
- [x] T019 [US7] 测试导航流程：主页 → 设置页 → 主页
  - 验证 HOME 按钮始终可点击
  - 验证 RETURN 按钮在主页时禁用，在设置页时启用
  - 验证导航栈深度正确更新
- [x] T020 [US7] 测试导航流程：主页 → 控制页 → 子页面 → RETURN → 主页
  - 验证多层导航栈管理
  - 验证 `popPage()` 逐层返回
  - 验证 `popToRoot()` 直接返回主页

---

## Phase 4: US2（温度控制）

**用户故事 2**: 在主页上调节温度

**目标**: 实现温度 Widget 的数据绑定和交互式键盘输入

**独立测试标准**:
- ✅ 温度 Widget 显示实时温度数据（从 Moonraker）
- ✅ 点击温度 Widget 弹出数字键盘
- ✅ 输入温度后点击确定，温度值更新
- ✅ 点击背景或取消按钮，键盘隐藏且温度不变
- ✅ 温度变化平滑动画（SmoothedAnimation）

### 任务

- [x] T021 [US2] 扩展 MoonrakerClient 添加温度设置方法 in `backend/moonraker_client.py`
  - 添加 `@Slot(str, int) def setExtruderTemp(heater_name, target_temp)`
  - 发送 `SET_HEATER_TEMPERATURE` G-code 命令
  - 确保 `temperatureUpdated` 信号已存在（可能已有）
- [x] T022 [US2] 实现完整的 TempWidget in `qml/components/TempWidget.qml`
  - 添加 `Connections { target: printer; onTemperatureUpdated }` 绑定数据
  - 显示当前温度（大号字体）和目标温度（小号字体）
  - 添加 `SmoothedAnimation` 实现温度平滑变化
  - 实现 `MouseArea.onClicked: showKeypad()`
- [x] T023 [US2] 创建温度键盘弹出层 in `qml/components/TempWidget.qml`
  - 使用 `Popup { modal: false; dim: true }` 包装 NumericKeypad
  - 配置 `enter/exit` 转场动画（200ms, OutBack）
  - 实现 `onConfirmed`: 调用 `printer.setExtruderTemp()` 并关闭 Popup
  - 实现 `onCancelled`: 直接关闭 Popup
  - 处理点击背景关闭（`closePolicy: Popup.CloseOnPressOutside`）
- [x] T024 [US2] 测试温度控制流程
  - 验证温度数据从 Moonraker 实时更新
  - 验证点击 Widget 弹出键盘
  - 验证输入 220 并确定后，温度目标值更新
  - 验证点击背景或取消，键盘关闭且温度不变

---

## Phase 5: US3（风扇/LED 控制）

**用户故事 3**: 在主页上控制风扇和 LED

**目标**: 实现风扇和 LED Widget 的数据绑定和滑块控制

**独立测试标准**:
- ✅ 风扇 Widget 显示实时速度状态
- ✅ 拖动风扇滑块，风扇速度实时更新
- ✅ 点击风扇开关按钮，风扇开启/关闭
- ✅ LED Widget 功能同理

### 任务

- [x] T025 [P] [US3] 扩展 MoonrakerClient 添加风扇控制方法 in `backend/moonraker_client.py`
  - 添加 `@Slot(str, bool) def setFanOnOff(fan_name, on)`
  - 添加 `@Slot(str, float) def setFanSpeed(fan_name, speed)`
  - 发送 `SET_FAN_SPEED` G-code 命令
  - 添加 `fanStateChanged = Signal(str, bool, float)` 信号
  - 在 `_update_from_status()` 中解析风扇状态并发射信号
- [x] T026 [P] [US3] 扩展 MoonrakerClient 添加 LED 控制方法 in `backend/moonraker_client.py`
  - 添加 `@Slot(str, bool) def setLedOnOff(led_name, on)`
  - 添加 `@Slot(str, float) def setLedBrightness(led_name, brightness)`
  - 发送 `SET_LED` G-code 命令
  - 添加 `ledStateChanged = Signal(str, bool, float)` 信号
  - 在 `_update_from_status()` 中解析 LED 状态并发射信号
- [x] T027 [US3] 实现完整的 FanWidget in `qml/components/FanWidget.qml`
  - 添加 `Connections { target: printer; onFanStateChanged }` 绑定数据
  - 添加 `Slider` 组件控制速度（0.0-1.0）
  - 添加开关按钮调用 `printer.setFanOnOff()`
  - 在滑块释放时调用 `printer.setFanSpeed()`
  - 显示当前速度百分比（Math.round(speed * 100) + "%"）
- [x] T028 [US3] 实现完整的 LedWidget in `qml/components/LedWidget.qml`
  - 结构与 FanWidget 类似
  - 绑定 `ledStateChanged` 信号
  - 调用 `printer.setLedOnOff()` 和 `printer.setLedBrightness()`

---

## Phase 6: US4 + US5（打印控制）

**用户故事 4**: 主页打印控制：待机时显示超大开始按钮
**用户故事 5**: 主页打印控制：打印中切换为进度卡片

**目标**: 实现打印控制 Widget 的状态机和交互

**独立测试标准（US4）**:
- ✅ 待机时显示超大"开始打印"按钮
- ✅ 按钮尺寸显著（100px 高度）
- ✅ 点击按钮导航到文件选择页

**独立测试标准（US5）**:
- ✅ 打印开始后，Widget 切换为进度卡片
- ✅ 进度卡片显示进度百分比、图层信息、剩余时间
- ✅ 点击暂停按钮，打印暂停且按钮变为"继续"
- ✅ 点击取消按钮，打印取消且卡片切换回开始按钮
- ✅ 点击卡片非按钮区域，导航到打印详情页
- ✅ 打印完成后，显示完成消息 3 秒后自动切换回开始按钮

### 任务

- [x] T029 [US4] [US5] 在 MoonrakerClient 中确认打印控制方法存在
  - 验证 `startPrint()`, `pausePrint()`, `resumePrint()`, `cancelPrint()` 方法
  - 验证 `printStateChanged`, `printProgressChanged` 信号
  - 如缺失，添加相应方法和信号
- [x] T030 [US4] 实现 PrintControlWidget 的 idle 状态组件 in `qml/components/PrintControlWidget.qml`
  - 创建 `Component { id: idleComponent }`
  - 显示超大 MetroButton："开始打印"（100px 高度）
  - `onClicked: pageRegistry.navigateTo("files", { "mode": "select" })`
- [x] T031 [P] [US5] 实现 PrintControlWidget 的 printing 状态组件
  - 创建 `Component { id: printingComponent }`
  - 显示文件名、进度条、进度百分比、图层信息、剩余时间
  - 添加背景 `MouseArea { z: 0; onClicked: pageRegistry.navigateTo("printing") }`
  - 添加暂停/继续按钮（`z: 10`，调用 `printer.pausePrint()/resumePrint()`）
  - 添加取消按钮（`z: 10`，调用 `printer.cancelPrint()`）
  - 确保按钮区域阻止事件传播（`mouse.accepted = true`）
- [x] T032 [P] [US5] 实现 PrintControlWidget 的 complete 状态组件
  - 创建 `Component { id: completeComponent }`
  - 显示 "✓ 打印完成" 消息和文件名
  - 添加 `Timer { interval: 3000; running: true; onTriggered: printState = "idle" }`
- [x] T033 [P] [US5] 实现 PrintControlWidget 的 error 状态组件
  - 创建 `Component { id: errorComponent }`
  - 显示 "⚠ 打印错误" 消息
  - 添加"重试"按钮（调用 `printer.startPrint(fileName)`）
  - 添加"取消"按钮（设置 `printState = "idle"`）
- [x] T034 [US5] 实现 PrintControlWidget 的状态机 in `qml/components/PrintControlWidget.qml`
  - 添加 `Connections { target: printer; onPrintStateChanged; onPrintProgressChanged }`
  - 使用 `Loader` 根据 `printState` 加载对应组件：
    - `idle` → `idleComponent`
    - `printing` / `paused` → `printingComponent`
    - `complete` → `completeComponent`
    - `error` → `errorComponent`
- [x] T035 [US5] 创建取消打印确认对话框 in `qml/components/ConfirmDialog.qml`（如不存在）
  - 显示 "确定要取消当前打印吗？"
  - 提供 "确定" 和 "取消" 按钮
  - 发射 `accepted()` 和 `rejected()` 信号
- [x] T036 [US4] [US5] 测试打印控制流程
  - 验证待机时显示开始按钮
  - 模拟打印开始，验证切换为进度卡片
  - 验证暂停/继续/取消按钮功能
  - 验证点击卡片导航到详情页
  - 模拟打印完成，验证 3 秒后自动回到 idle

---

## Phase 7: US6（功能图标导航）

**用户故事 6**: 从主页进入功能全屏页

**目标**: 完善功能图标的导航逻辑

**独立测试标准**:
- ✅ 点击"设置"图标，进入设置页且全局按钮可见
- ✅ 点击"控制"图标，进入控制页且全局按钮可见
- ✅ 点击"文件"图标，进入文件页且全局按钮可见
- ✅ 所有功能页左侧留出 80px 空间不被遮挡

### 任务

- [x] T037 [P] [US6] 为所有功能图标配置 targetPage 属性 in `qml/pages/HomePage.qml`
  - 设置、控制、文件、AFC、移动、更多 图标的 `targetPage` 属性
  - 确保 `iconPath` 指向正确的图标文件（或占位符）
- [x] T038 [US6] 验证现有功能页面适配全局按钮布局
  - 检查 SettingsPage, ControlPage, FilesPage 的布局
  - 确保内容区域不会延伸到左侧 80px 全局按钮区域
  - 如有必要，调整 `anchors` 或 `margins`
- [x] T039 [US6] 测试功能图标导航流程
  - 从主页点击每个功能图标
  - 验证进入对应功能页
  - 验证全局按钮始终可见且可操作
  - 验证 RETURN 按钮状态正确

---

## Phase 8: US8（主页布局优化 - P2）

**用户故事 8**: 主页布局清晰分区

**目标**: 优化主页视觉层次和布局美观性

**独立测试标准**:
- ✅ Widget 区域和图标区域有明显的视觉分隔
- ✅ Widget 以卡片形式呈现，有圆角和阴影（或边框）
- ✅ 图标稀疏排布，间距均匀，易于点击

### 任务

- [x] T040 [US8] 调整 HomePage 布局的视觉分隔 in `qml/pages/HomePage.qml`
  - 在 Widget 区域添加背景色（`Style.bgSecondary`）
  - 在图标区域添加不同的背景色（`Style.bgPrimary`）
  - 或在两区域间添加分隔线（`Rectangle { width: 2; color: Style.border }`）
- [x] T041 [US8] 优化 Widget 卡片样式 in `qml/components/HomeWidget.qml`
  - 确保 `radius: Style.radiusSmall`（4px）
  - 添加 `border.width: 1; border.color: Style.border`（可选）
  - 调整内边距（`anchors.margins: Style.spacingNormal`）
- [x] T042 [US8] 优化图标网格间距 in `qml/pages/HomePage.qml`
  - 设置 `GridLayout { rowSpacing: Style.spacingLarge; columnSpacing: Style.spacingLarge }`
  - 确保图标大小统一（120x120px）
  - 验证触摸目标符合 44px 最小标准

---

## Phase 9: Polish（性能和错误处理）

**目标**: 优化性能、添加错误处理、完善边缘情况

### 任务

- [ ] T043 [P] 实现 Widget 数据节流 in `backend/moonraker_client.py`
  - 温度更新：变化 >= 0.5°C 才发射信号
  - 进度更新：时间间隔 >= 1 秒才发射信号
  - 风扇/LED 更新：变化 >= 0.05 (5%) 才发射信号
- [ ] T044 [P] 添加导航错误处理 in `qml/MainWindow.qml`
  - 在 `pageRegistry.navigateTo()` 中添加 try-catch
  - 页面加载失败时显示错误提示（Toast）
  - 导航栈损坏时自动重置到主页
- [ ] T045 [P] 处理键盘弹出时的导航冲突
  - 在 TempWidget 的 Popup 中添加 `onVisibleChanged`
  - 如果键盘可见时用户点击 HOME，先关闭键盘再导航
- [ ] T046 [P] 添加 Widget 加载状态反馈
  - 在 HomeWidget 中实现 `widgetState = "updating"` 时的动画
  - 添加 Metro 点阵式加载指示器（3 个圆点交替闪烁）
- [ ] T047 实现性能监控和优化验证
  - 测试导航切换时间 < 300ms
  - 测试 Widget 更新延迟 < 500ms
  - 测试 UI 帧率保持 60 FPS
  - 使用 QML Profiler 识别性能瓶颈

---

## 依赖关系图

### 用户故事完成顺序

```
Phase 1 (Setup) → Phase 2 (Foundational)
                     ↓
                  Phase 3 (US1 + US7) ← MVP
                     ↓
        ┌────────────┼────────────┐
        ↓            ↓            ↓
   Phase 4 (US2) Phase 5 (US3) Phase 6 (US4+US5)
        └────────────┼────────────┘
                     ↓
                Phase 7 (US6)
                     ↓
                Phase 8 (US8 - P2)
                     ↓
                Phase 9 (Polish)
```

### 关键依赖说明

1. **US1 依赖**: 无（可最先实现）
2. **US7 依赖**: NavigationManager（Phase 2）
3. **US2 依赖**: US1（需要 TempWidget 基础）
4. **US3 依赖**: US1（需要 FanWidget/LedWidget 基础）
5. **US4+US5 依赖**: US1（需要 PrintControlWidget 基础）
6. **US6 依赖**: US7（需要导航系统）
7. **US8 依赖**: US1（需要主页布局存在）

---

## 并行执行机会

### Phase 1（3 个并行任务）

- T002（检查依赖）|| T003（创建目录）

### Phase 2（1 个并行任务）

- T006（注册上下文）可在 T005 完成后并行于其他任务

### Phase 3（8 个并行任务）

- T008（TempWidget）|| T009（FanWidget）|| T010（LedWidget）|| T011（PrintControlWidget）|| T012（FunctionIcon）
  这 5 个组件可同时开发
- T014（GlobalNavButtons）可与 Widget 开发并行
- T016（页面注册表）可与导航按钮并行

### Phase 4（无额外并行）

- T021-T024 需顺序执行（数据绑定 → Widget 实现 → 键盘 → 测试）

### Phase 5（2 个并行任务）

- T025（风扇控制方法）|| T026（LED 控制方法）
  两个后端方法可同时开发
- T027（FanWidget）|| T028（LedWidget）
  两个前端组件可同时开发

### Phase 6（4 个并行任务）

- T031（printing 状态）|| T032（complete 状态）|| T033（error 状态）
  三个状态组件可同时开发
- T035（确认对话框）可与状态组件并行开发

### Phase 8（3 个并行任务）

- T040（布局分隔）|| T041（Widget 样式）|| T042（图标间距）
  三个视觉优化任务可同时进行

### Phase 9（4 个并行任务）

- T043（数据节流）|| T044（错误处理）|| T045（键盘冲突）|| T046（加载状态）
  四个优化任务可同时进行

---

## 任务格式验证

✅ **所有 47 个任务**均遵循 checklist 格式：
- 每个任务以 `- [ ]` 开头
- 包含任务 ID（T001-T047）
- P1 用户故事任务包含 `[US#]` 标签
- 并行任务包含 `[P]` 标签
- 包含明确的文件路径或描述
- 按 Phase 和用户故事组织

---

## 测试策略

### 单元测试（可选 - 未明确要求）

如果后续需要添加测试，建议：
- Python: 使用 pytest 测试 NavigationManager 类
- QML: 使用 QML TestCase 测试 Widget 组件

### 集成测试（通过验收场景）

每个用户故事的"独立测试标准"即为集成测试标准：
- US1: 验证主页显示和布局
- US2: 验证温度控制交互
- US3: 验证风扇/LED 控制交互
- US4+US5: 验证打印控制状态机
- US6: 验证功能图标导航
- US7: 验证全局导航系统
- US8: 验证布局视觉效果

### 性能测试

Phase 9（T047）包含性能验证：
- 导航时间 < 300ms
- Widget 更新 < 500ms
- 帧率 60 FPS

---

## 下一步

1. **执行 MVP**（推荐）:
   - 完成 Phase 1-3（任务 T001-T020）
   - 验证主页和导航系统可运行
   - 获取用户反馈

2. **完整实现**:
   - 按 Phase 顺序执行所有任务（T001-T047）
   - 每个 Phase 完成后进行验收测试
   - 最后执行 Polish 阶段

3. **使用 `/speckit.implement`**:
   - 运行 `/speckit.implement` 命令开始逐任务实现
   - AI 将按顺序执行任务并生成代码
   - 每个任务完成后进行验证

---

**任务清单生成完成！** ✅

**总任务数**: 47
**MVP 任务数**: 20（T001-T020）
**并行机会**: 21 个任务可并行执行
**预估 MVP 完成时间**: 4-6 小时（手动实现）/ 2-3 小时（AI 辅助）
