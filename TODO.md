# QtKs - KlipperScreen 完整复刻待办事项

**最后更新**: 2025-12-09
**当前进度**: 8/35 面板完成 (22.9%)

---

## ✅ 已完成功能

### Phase 1-9: 基础框架 (001-global-nav)
- [x] iOS 风格全局导航系统
- [x] HOME/RETURN 全局按钮
- [x] NavigationManager 导航栈管理
- [x] HomePage 主页布局 (Widget + 功能图标)
- [x] HomeWidget 基类 (状态管理 + 加载动画)
- [x] TempWidget - 温度控制 (弹出键盘)
- [x] FanWidget - 风扇控制 (滑块 + 旋转动画)
- [x] LedWidget - LED 控制 (滑块 + 发光效果)
- [x] PrintControlWidget - 打印控制状态机 (5 个状态)
- [x] 数据节流优化 (温度/进度/风扇/LED)
- [x] 导航错误处理
- [x] Widget 加载状态反馈

### 已有页面/组件
- [x] SettingsPage - 设置页面 (基础)
- [x] FilesPage - 文件浏览页面 (需增强)
- [x] JobStatusPage - 打印状态详情页 ✨ **v0.0.1 新增**
- [x] ControlPage - 控制页面 (基础)
- [x] MoveControl - 移动控制组件 (需独立为页面)
- [x] NumericKeypad - 数字键盘
- [x] ErrorOverlay - 错误全屏显示
- [x] NotificationToast - 通知提示

---

## 🎯 P0 - 核心功能面板 (必须实现)

### 1. job_status - 打印状态详情页 ⭐⭐⭐
**优先级**: 最高
**状态**: ✅ 已完成 (v0.0.1)
**实际工作量**: 3 小时

**功能需求**:
- [x] 大型进度圆环显示 (0-100%) - 200x200 圆形进度条
- [ ] 实时温度曲线图 (热端/热床) - 暂未实现，使用温度数值显示
- [x] 打印信息卡片
  - [x] 当前层 / 总层数
  - [x] 已用时间 / 预计剩余时间
  - [x] 耗材用量 (米)
  - [x] 打印速度倍率
- [x] 缩略图显示 (从 printer.printThumbnail)
- [x] 打印控制按钮
  - [x] 暂停/恢复
  - [x] 取消 (带确认对话框)
  - [x] 微调 (进入 fine_tune 页面)
- [x] 文件名显示

**参考文件**: `KlipperScreen/panels/job_status.py` (42KB)

**实现步骤**:
1. 创建 `qml/pages/JobStatusPage.qml`
2. 实现进度圆环组件 (`CircularProgress.qml`)
3. 实现温度曲线图组件 (`TemperatureChart.qml`)
4. 绑定 MoonrakerClient 数据 (printProgressChanged, temperatureUpdated)
5. 添加到 pageRegistry
6. 从 PrintControlWidget 点击卡片跳转到此页面

---

### 2. gcodes - 文件浏览器完整版 ⭐⭐⭐
**优先级**: 最高
**状态**: ✅ 大部分完成
**实际工作量**: 2 小时

**功能需求**:
- [x] 文件列表显示 (已有)
- [x] 缩略图加载 (已有)
- [x] 文件元数据显示增强 ✨ **已完善**
  - [x] 打印时间预估
  - [x] 耗材用量
  - [x] 层高/层数
  - [x] 切片软件信息
- [x] 排序功能 ✨ **新增**
  - [x] 按名称
  - [x] 按修改时间
  - [x] 按大小
- [x] 搜索/过滤 ✨ **新增**
- [ ] 文件操作
  - [x] 打印 (已有)
  - [x] 删除 (已有带确认)
  - [ ] 重命名
  - [ ] 复制/移动
- [ ] 目录导航 (子文件夹支持)
- [ ] 上传文件按钮

**参考文件**: `KlipperScreen/panels/gcodes.py` (25KB)

**实现步骤**:
1. 增强现有 `qml/pages/FilesPage.qml`
2. 添加排序下拉菜单
3. 添加搜索框
4. 实现文件操作对话框
5. 添加元数据详情展示

---

### 3. move - 完整移动控制页 ⭐⭐⭐
**优先级**: 高
**状态**: ✅ 基本完成
**实际工作量**: 已有 (无需额外开发)

**功能需求**:
- [x] XYZ 轴移动控制 (已有)
- [x] 移动距离选择 (0.1/1/5/10/25/50/100mm) (已有)
- [x] 归零按钮 (X/Y/Z/全部) (已有)
- [ ] 速度调节滑块 (可选)
- [ ] Z 轴探针 (可选)
- [x] 禁用电机 (已有确认对话框)
- [x] 当前位置显示 (X/Y/Z 坐标) (已有)
- [x] 归零状态指示器 (已有，通过颜色)

**参考文件**: `KlipperScreen/panels/move.py` (11KB)

**实现步骤**:
1. 将 `MoveControl` 组件改造为独立页面 `MovePage.qml`
2. 添加速度调节滑块 (F 参数)
3. 添加当前位置显示 (绑定 positionUpdated 信号)
4. 添加到 pageRegistry
5. 从主页功能图标点击进入

---

### 4. extrude - 挤出机控制页 ⭐⭐
**优先级**: 高
**状态**: ✅ 已完成
**实际工作量**: 已有 (修复字体大小 bug)

**功能需求**:
- [x] 进料/退料按钮
- [x] 挤出长度选择 (5/10/25/50/100/200mm)
- [x] 挤出速度选择 (1/3/5/10/15/20 mm/s)
- [x] 温度显示 (当前/目标)
- [x] 温度不足警告 (< 170°C)
- [ ] 多挤出机支持 (extruder/extruder1) - 可选功能
- [ ] 更换耗材向导 - 可选功能

**参考文件**: `KlipperScreen/panels/extrude.py` (16KB)

**实现步骤**:
1. 创建 `qml/pages/ExtrudePage.qml`
2. 后端添加 G-code 命令 (G1 E)
3. 添加温度检查逻辑
4. 实现挤出机选择器 (多挤出机)
5. 添加到 pageRegistry

---

### 5. temperature - 温度图表页 ⭐⭐
**优先级**: 中高
**状态**: ⚠️ 部分完成 (基础版已有,缺图表)
**实际工作量**: 已有基础版 (修复字体 bug)

**功能需求**:
- [ ] 实时温度曲线图 - **缺失** (需 2-3 小时开发)
  - [ ] 热端温度曲线
  - [ ] 热床温度曲线
  - [ ] 目标温度虚线
- [ ] 时间轴 (最近 10/30/60 分钟) - **缺失**
- [ ] 温度范围自动缩放 - **缺失**
- [x] 温度设置面板 ✅
  - [x] 预设温度 (PLA/ABS)
  - [ ] 自定义温度输入 - 建议添加 NumericKeypad
- [x] 加热器开关 ✅

**参考文件**: `KlipperScreen/panels/temperature.py` (27KB)

**实现步骤**:
1. 创建 `qml/pages/TemperaturePage.qml`
2. 实现温度图表组件 `TemperatureChart.qml` (使用 QML Charts)
3. 后端添加温度历史数据缓存
4. 添加预设温度配置
5. 添加到 pageRegistry

---

## 🔧 P1 - 高级功能面板

### 6. fine_tune - 打印中微调 ⭐⭐
**优先级**: 中
**状态**: ✅ 已完成
**实际工作量**: 已有 (修复字体大小 bug)

**功能需求**:
- [x] 速度调节 (10%-200%) ✅
  - [x] 打印速度百分比滑块
  - [x] 实时应用 (M220 S)
  - [x] 快捷按钮 (50/75/100/125/150%)
- [x] 流量调节 (75%-125%) ✅
  - [x] 挤出流量百分比滑块
  - [x] 实时应用 (M221 S)
  - [x] 快捷按钮 (90/95/100/105/110%)
- [x] Z 轴偏移 (-2mm ~ +2mm) ✅
  - [x] 微调按钮 (±0.1/±0.05/±0.01mm)
  - [x] 实时应用 (SET_GCODE_OFFSET Z_ADJUST)
- [x] 风扇速度覆盖 (0-100%) ✅
  - [x] 风扇速度滑块
  - [x] M106 S 控制
  - [x] 快捷按钮 (0/25/50/75/100%)

**参考文件**: `KlipperScreen/panels/fine_tune.py` (9KB)

---

### 7. bed_level - 热床调平 ⭐⭐
**优先级**: 中
**状态**: 未开始
**预计工作量**: 2 小时

**功能需求**:
- [ ] 调平点选择 (4 角 / 5 点 / 9 点)
- [ ] 手动调平引导
  - [ ] 移动到每个调平点
  - [ ] Z 轴下降到纸张厚度
  - [ ] 提示用户调节螺丝
- [ ] 自动调平 (BED_SCREWS_ADJUST)
- [ ] 保存/取消

**参考文件**: `KlipperScreen/panels/bed_level.py` (14KB)

---

### 8. bed_mesh - 网床可视化 ⭐⭐
**优先级**: 中
**状态**: 未开始
**预计工作量**: 3 小时

**功能需求**:
- [ ] 3D 网格图显示
- [ ] 色阶图 (热力图)
- [ ] 网格点高度值显示
- [ ] 配置管理
  - [ ] 保存当前配置
  - [ ] 加载已保存配置
  - [ ] 删除配置
- [ ] 网床校准按钮 (BED_MESH_CALIBRATE)

**参考文件**: `KlipperScreen/panels/bed_mesh.py` (11KB)

**技术难点**:
- QML 3D 渲染或使用 Canvas 绘制
- 网格数据解析

---

### 9. gcode_macros - 宏命令 ⭐
**优先级**: 中
**状态**: 未开始
**预计工作量**: 1-2 小时

**功能需求**:
- [ ] 宏列表显示 (从 Klipper 配置读取)
- [ ] 宏分类/分组
- [ ] 一键执行宏
- [ ] 宏参数输入 (如果宏需要参数)
- [ ] 执行状态反馈

**参考文件**: `KlipperScreen/panels/gcode_macros.py` (8KB)

---

### 10. fan - 风扇控制完整版 ⭐
**优先级**: 低
**状态**: 部分完成 (FanWidget 已有)
**预计工作量**: 1 小时

**功能需求**:
- [x] 单个风扇控制 (已有)
- [ ] 多风扇支持 (打印冷却/电子冷却/仓灯冷却)
- [ ] 独立速度控制
- [ ] 风扇曲线图 (转速 vs 时间)

**参考文件**: `KlipperScreen/panels/fan.py` (5KB)

---

## 🌐 P2 - 系统管理面板

### 11. network - 网络配置 ⭐
**优先级**: 中低
**状态**: 未开始
**预计工作量**: 2-3 小时

**功能需求**:
- [ ] 当前网络状态显示
  - [ ] IP 地址
  - [ ] MAC 地址
  - [ ] 信号强度
- [ ] WiFi 扫描
- [ ] WiFi 连接/断开
- [ ] WiFi 密码输入
- [ ] 网络设置
  - [ ] DHCP/静态 IP
  - [ ] DNS 配置

**参考文件**: `KlipperScreen/panels/network.py` (18KB)

**技术难点**:
- 需要调用系统网络管理工具 (NetworkManager/wpa_supplicant)

---

### 12. system - 系统信息 ⭐
**优先级**: 中低
**状态**: 未开始
**预计工作量**: 1-2 小时

**功能需求**:
- [ ] CPU 使用率
- [ ] 内存使用率
- [ ] 磁盘使用率
- [ ] 系统温度 (CPU/GPU)
- [ ] Klipper/Moonraker 版本
- [ ] 内核版本
- [ ] 运行时间

**参考文件**: `KlipperScreen/panels/system.py` (7KB)

---

### 13. console - 终端控制台 ⭐
**优先级**: 中低
**状态**: 未开始
**预计工作量**: 2 小时

**功能需求**:
- [ ] G-code 命令输入
- [ ] 命令历史记录
- [ ] 输出日志显示 (滚动)
- [ ] 命令自动补全
- [ ] 快捷命令按钮 (M112 急停等)

**参考文件**: `KlipperScreen/panels/console.py` (5KB)

---

### 14. updater - 系统更新 ⭐
**优先级**: 低
**状态**: 未开始
**预计工作量**: 2 小时

**功能需求**:
- [ ] 检查更新
- [ ] 显示可用更新列表
  - [ ] Klipper
  - [ ] Moonraker
  - [ ] KlipperScreen
  - [ ] 系统组件
- [ ] 更新日志显示
- [ ] 执行更新
- [ ] 更新进度显示

**参考文件**: `KlipperScreen/panels/updater.py` (15KB)

---

### 15. power - 电源控制
**优先级**: 低
**状态**: 未开始
**预计工作量**: 1 小时

**功能需求**:
- [ ] 电源设备列表 (从 Moonraker power 插件)
- [ ] 开/关控制
- [ ] 状态显示
- [ ] 分组控制

**参考文件**: `KlipperScreen/panels/power.py` (3KB)

---

## 🎨 P3 - 特殊功能面板

### 16. camera - 摄像头显示
**优先级**: 低
**预计工作量**: 1 小时

**功能需求**:
- [ ] 摄像头流显示 (MJPEG/WebRTC)
- [ ] 多摄像头切换
- [ ] 截图功能

**参考文件**: `KlipperScreen/panels/camera.py` (4KB)

---

### 17. input_shaper - 共振补偿
**优先级**: 低
**预计工作量**: 2 小时

**功能需求**:
- [ ] 共振频率测试
- [ ] 测试结果图表
- [ ] Shaper 配置
- [ ] 保存/应用配置

**参考文件**: `KlipperScreen/panels/input_shaper.py` (8KB)

---

### 18. zcalibrate - Z 轴校准
**优先级**: 中
**预计工作量**: 2 小时

**功能需求**:
- [ ] Z 轴偏移校准向导
- [ ] 纸张法校准
- [ ] 保存偏移值
- [ ] 探针 Z 轴校准

**参考文件**: `KlipperScreen/panels/zcalibrate.py` (16KB)

---

### 19. retraction - 回抽设置
**优先级**: 低
**预计工作量**: 1 小时

**功能需求**:
- [ ] 回抽长度调节
- [ ] 回抽速度调节
- [ ] 固件回抽设置
- [ ] 测试回抽

**参考文件**: `KlipperScreen/panels/retraction.py` (6KB)

---

### 20. pressure_advance - 压力推进
**优先级**: 低
**预计工作量**: 1 小时

**功能需求**:
- [ ] PA 值调节
- [ ] PA 校准向导
- [ ] 保存/应用

**参考文件**: `KlipperScreen/panels/pressure_advance.py` (5KB)

---

### 21. limits - 速度/加速度限制
**优先级**: 低
**预计工作量**: 1 小时

**功能需求**:
- [ ] 最大速度设置
- [ ] 最大加速度设置
- [ ] 保存/应用

**参考文件**: `KlipperScreen/panels/limits.py` (6KB)

---

### 22. spoolman - 耗材管理
**优先级**: 低
**预计工作量**: 2-3 小时

**功能需求**:
- [ ] 耗材库存列表
- [ ] 当前使用耗材
- [ ] 耗材信息显示
- [ ] 更换耗材

**参考文件**: `KlipperScreen/panels/spoolman.py` (17KB)

---

### 23. exclude - 对象排除
**优先级**: 低
**预计工作量**: 2 小时

**功能需求**:
- [ ] 打印对象列表
- [ ] 排除对象选择
- [ ] 对象预览

**参考文件**: `KlipperScreen/panels/exclude.py` (6KB)

---

### 24. notifications - 通知中心
**优先级**: 低
**预计工作量**: 1 小时

**功能需求**:
- [ ] 通知历史记录
- [ ] 通知详情查看
- [ ] 清除通知

**参考文件**: `KlipperScreen/panels/notifications.py` (2KB)

---

### 25. splash_screen - 启动画面
**优先级**: 低
**预计工作量**: 1 小时

**功能需求**:
- [ ] 启动动画
- [ ] 连接状态提示
- [ ] 错误提示

**参考文件**: `KlipperScreen/panels/splash_screen.py` (7KB)

---

## 🔧 后端增强需求

### MoonrakerClient 扩展
- [ ] 添加网床数据 API (bed_mesh)
- [ ] 添加宏列表 API (gcode_macros)
- [ ] 添加系统信息 API (system_info)
- [ ] 添加更新 API (update_manager)
- [ ] 添加电源控制 API (power devices)
- [ ] 添加摄像头流 API
- [ ] 添加历史数据缓存 (温度曲线图)

### 配置管理
- [ ] 用户偏好设置持久化
- [ ] 主题配置管理
- [ ] 快捷按钮自定义

---

## 📊 实施优先级建议

### 第一阶段 (本周完成):
1. job_status - 打印状态详情 ⭐⭐⭐
2. gcodes 增强 - 文件浏览器完善 ⭐⭐⭐
3. move 独立页面 - 移动控制 ⭐⭐⭐

### 第二阶段 (下周):
4. extrude - 挤出机控制 ⭐⭐
5. temperature - 温度图表 ⭐⭐
6. fine_tune - 打印微调 ⭐⭐

### 第三阶段:
7. bed_level - 热床调平
8. gcode_macros - 宏命令
9. console - 终端控制台

### 第四阶段:
10. 系统管理面板 (network, system, updater)
11. 高级功能面板 (bed_mesh, input_shaper, zcalibrate)

---

## 📝 开发规范

### 命名规范
- 页面文件: `qml/pages/XxxPage.qml` (驼峰命名)
- 组件文件: `qml/components/XxxComponent.qml`
- 后端文件: `backend/xxx_module.py` (snake_case)

### 代码结构
- 每个页面必须继承自 `Page` 或自定义基类
- 所有数据绑定通过 `Connections` 连接 MoonrakerClient
- 使用 Style.qml 统一样式
- 使用 KlipperScreen SVG 图标 (ThemedIcon)

### 测试要求
- 每个页面完成后必须测试运行
- 验证数据绑定正确
- 验证导航正常
- 验证错误处理

---

**预计总工作量**: 40-50 小时
**当前完成度**: 8.6% (3/35 面板)
**目标完成时间**: 2-3 周

---

**备注**:
- 优先实现 P0 核心功能，确保基本可用性
- P1/P2/P3 功能可以后续迭代
- 复杂功能 (如 bed_mesh 3D 图) 可以先用简化版实现
