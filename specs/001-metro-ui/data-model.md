# 数据模型：基于设计图的UI界面实现

**功能**: [spec.md](./spec.md) | **计划**: [plan.md](./plan.md) | **日期**: 2025-11-20

## 概要

本文档定义UI界面需要的核心数据实体、字段结构、验证规则和数据流。所有实体基于Moonraker API规范和QML UI需求设计。

## 核心实体

### 1. PrintFile (打印文件)

**目的**: 表示可打印的G-code文件及其元数据

**字段**:

| 字段名 | 类型 | 必填 | 说明 | 来源 |
|--------|------|------|------|------|
| filename | str | ✅ | 文件名 (含扩展名) | Moonraker API |
| path | str | ✅ | 完整路径 (如 "gcodes/test.gcode") | Moonraker API |
| size | int | ✅ | 文件大小 (字节) | Moonraker API |
| modified | float | ✅ | 修改时间戳 (Unix时间) | Moonraker API |
| thumbnail_url | str | ❌ | 缩略图data URL (Base64) | 元数据提取 |
| slicer | str | ❌ | 切片软件名称 | 元数据 |
| layer_count | int | ❌ | 层数 | 元数据 |
| estimated_time | int | ❌ | 预计打印时间 (秒) | 元数据 |
| first_layer_temp | float | ❌ | 首层喷头温度 | 元数据 |
| first_layer_bed_temp | float | ❌ | 首层热床温度 | 元数据 |
| filament_used | float | ❌ | 耗材用量 (mm) | 元数据 |
| filament_weight | float | ❌ | 耗材重量 (g) | 元数据 |

**验证规则**:
- filename不能为空且必须包含扩展名 (.gcode, .g, .gco)
- size ≥ 0
- modified ≥ 0 (有效的Unix时间戳)
- estimated_time ≥ 0 (如果存在)
- 温度范围: 0-300°C (如果存在)

**数据源**:
```
GET /server/files/list?root=gcodes
GET /server/files/metadata?filename={path}
```

**QML访问**:
```qml
ListView {
    model: printer.fileList  // QVariantList[QVariantMap]

    delegate: FileCard {
        filename: modelData.filename
        thumbnailUrl: modelData.thumbnail_url || ""
        estimatedTime: modelData.estimated_time || 0
    }
}
```

---

### 2. PrintJob (打印任务)

**目的**: 表示当前打印任务的状态和进度

**字段**:

| 字段名 | 类型 | 必填 | 说明 | 来源 |
|--------|------|------|------|------|
| state | str | ✅ | 打印状态 (枚举值见下) | print_stats.state |
| filename | str | ❌ | 当前文件名 | print_stats.filename |
| progress | float | ✅ | 进度 (0.0-1.0) | virtual_sdcard.progress |
| print_duration | float | ✅ | 已打印时长 (秒) | print_stats.print_duration |
| filament_used | float | ✅ | 已用耗材 (mm) | print_stats.filament_used |
| total_duration | float | ❌ | 总打印时长 (秒，完成后) | print_stats.total_duration |
| message | str | ❌ | 状态消息 | print_stats.message |
| current_layer | int | ❌ | 当前层 | print_stats.info.current_layer |
| total_layer | int | ❌ | 总层数 | print_stats.info.total_layer |

**状态枚举**:
- `standby`: 待机（无打印任务）
- `printing`: 打印中
- `paused`: 已暂停
- `complete`: 打印完成
- `cancelled`: 已取消
- `error`: 错误

**计算字段**:
- `remaining_time` = `estimated_time` - `print_duration` (需从文件元数据获取estimated_time)
- `layer_progress` = `current_layer / total_layer` (图形化显示)

**验证规则**:
- state必须是枚举值之一
- progress范围: 0.0-1.0
- print_duration ≥ 0
- current_layer ≤ total_layer (如果都存在)

**数据源**:
```
WebSocket订阅: printer.objects.subscribe
{
    "print_stats": ["state", "filename", "print_duration", "filament_used", "total_duration", "message"],
    "virtual_sdcard": ["progress"],
    "print_stats.info": ["current_layer", "total_layer"]
}
```

**QML访问**:
```qml
Label {
    text: {
        switch(printer.printState) {
            case "printing": return "打印中"
            case "paused": return "已暂停"
            case "complete": return "打印完成"
            default: return "待机"
        }
    }
}

ProgressBar {
    from: 0.0
    to: 1.0
    value: printer.printProgress
}
```

---

### 3. ControlState (控制状态)

**目的**: 表示打印机当前的控制状态（温度、位置、移动参数）

**字段**:

| 字段名 | 类型 | 必填 | 说明 | 来源 |
|--------|------|------|------|------|
| **温度子对象** | | | | |
| extruder_temp | float | ✅ | 喷头当前温度 | extruder.temperature |
| extruder_target | float | ✅ | 喷头目标温度 | extruder.target |
| bed_temp | float | ✅ | 热床当前温度 | heater_bed.temperature |
| bed_target | float | ✅ | 热床目标温度 | heater_bed.target |
| chamber_temp | float | ❌ | 仓温当前温度 | temperature_sensor chamber.temperature |
| **位置子对象** | | | | |
| x_pos | float | ✅ | X轴位置 (mm) | toolhead.position[0] |
| y_pos | float | ✅ | Y轴位置 (mm) | toolhead.position[1] |
| z_pos | float | ✅ | Z轴位置 (mm) | toolhead.position[2] |
| e_pos | float | ✅ | 挤出机位置 (mm) | toolhead.position[3] |
| homed_axes | str | ✅ | 已归零轴 ("xyz") | toolhead.homed_axes |
| **移动参数** | | | | |
| move_step | float | ✅ | 移动步进 (1/10/50mm) | UI状态 |
| feedrate | int | ✅ | 移动速度 (mm/min) | UI状态 |
| extrude_speed | int | ✅ | 挤出速度 (mm/s) | UI状态 |
| extrude_length | float | ✅ | 挤出长度 (mm) | UI状态 |

**验证规则**:
- 温度范围: 0-300°C (target可以为0表示关闭)
- 位置范围:
  - X: 0-打印机max_x (从配置读取，默认0-250)
  - Y: 0-打印机max_y (默认0-250)
  - Z: 0-打印机max_z (默认0-250)
- move_step枚举: [0.1, 1, 10, 50] (mm)
- feedrate范围: 100-12000 (mm/min)
- extrude_speed范围: 1-50 (mm/s)
- extrude_length范围: 1-100 (mm)

**默认值**:
- move_step: 10mm
- feedrate: 3000mm/min
- extrude_speed: 5mm/s
- extrude_length: 10mm

**数据源**:
```
WebSocket订阅:
{
    "extruder": ["temperature", "target"],
    "heater_bed": ["temperature", "target"],
    "temperature_sensor chamber": ["temperature"],
    "toolhead": ["position", "homed_axes"]
}
```

**QML访问**:
```qml
// 温度显示
TempCard {
    title: "喷头"
    currentTemp: printer.extruderTemp
    targetTemp: printer.extruderTarget
}

// 轴位置显示
Label {
    text: "X: " + printer.xPos.toFixed(2) + " mm"
}

// 设置温度
Button {
    onClicked: printer.setTemp("extruder", 200)
}

// 移动轴
Button {
    text: "Z+" + printer.moveStep
    onClicked: printer.moveAxis("Z", printer.moveStep)
}
```

---

### 4. UIState (UI状态)

**目的**: 管理UI导航、屏保、用户交互状态

**字段**:

| 字段名 | 类型 | 必填 | 说明 | 来源 |
|--------|------|------|------|------|
| current_page | str | ✅ | 当前页面 (枚举值见下) | Python UIState |
| screensaver_active | bool | ✅ | 屏保是否激活 | Python UIState |
| idle_time | int | ✅ | 空闲时长 (毫秒) | Python UIState |
| screensaver_timeout | int | ✅ | 屏保超时 (毫秒) | 配置文件 |
| bottom_nav_visible | bool | ✅ | 底部导航栏是否可见 | 计算属性 |

**页面枚举**:
- `home`: 首页
- `control`: 控制页面
- `files`: 文件页面
- `settings`: 设置页面
- `printing`: 打印状态页面
- `screensaver`: 屏保页面

**计算规则**:
- `bottom_nav_visible` = `current_page != "printing" && current_page != "screensaver"`

**验证规则**:
- current_page必须是枚举值之一
- screensaver_timeout范围: 60000-3600000 (1分钟-1小时)

**默认值**:
- current_page: "home"
- screensaver_active: false
- screensaver_timeout: 300000 (5分钟)

**QML访问**:
```qml
StackLayout {
    currentIndex: {
        if (uiState.screensaverActive) return 5
        switch(uiState.currentPage) {
            case "home": return 0
            case "control": return 1
            case "files": return 2
            case "settings": return 3
            case "printing": return 4
        }
    }
}

BottomNavBar {
    visible: uiState.bottomNavVisible
}
```

---

### 5. AppSettings (应用设置)

**目的**: 管理用户可配置的应用设置

**字段**:

| 字段名 | 类型 | 必填 | 说明 | 持久化 |
|--------|------|------|------|--------|
| brightness | int | ✅ | 屏幕亮度 (0-100) | config.json |
| volume | int | ✅ | 音量 (0-100) | config.json |
| language | str | ✅ | 语言代码 | config.json |
| timezone | str | ✅ | 时区 | config.json |
| screensaver_timeout | int | ✅ | 屏保超时 (秒) | config.json |
| theme | str | ✅ | 主题 (占位符) | config.json |
| auto_shutdown | bool | ✅ | 打印完成自动关机 (占位符) | config.json |
| notification_enabled | bool | ✅ | 通知开关 (占位符) | config.json |

**验证规则**:
- brightness范围: 0-100
- volume范围: 0-100
- language枚举: ["zh_CN", "en_US"] (当前仅支持中文)
- timezone: 有效的IANA时区字符串
- screensaver_timeout范围: 60-3600 (秒)

**默认值**:
```json
{
  "brightness": 80,
  "volume": 50,
  "language": "zh_CN",
  "timezone": "Asia/Shanghai",
  "screensaver_timeout": 300,
  "theme": "dark",
  "auto_shutdown": false,
  "notification_enabled": false
}
```

**持久化位置**:
```
config.json → "ui" section
{
  "ui": {
    "brightness": 80,
    "volume": 50,
    ...
  }
}
```

**QML访问**:
```qml
// 设置页面
Slider {
    from: 0
    to: 100
    value: settings.brightness
    onValueChanged: settings.setBrightness(value)
}

ComboBox {
    model: ["简体中文", "English"]
    currentIndex: settings.language === "zh_CN" ? 0 : 1
    onActivated: settings.setLanguage(index === 0 ? "zh_CN" : "en_US")
}
```

---

## 数据流

### 1. 实时数据流 (WebSocket)

```
Moonraker WebSocket
  ↓ (notify_status_update)
MoonrakerClient._update_from_status()
  ↓ (更新内部状态)
发射Qt Signal (temperatureUpdated, printProgressChanged等)
  ↓ (信号槽连接)
QML Property自动更新
  ↓
UI重新渲染
```

**更新频率**:
- 温度: ~1秒/次
- 位置: ~0.5秒/次 (打印时)
- 进度: ~1秒/次

### 2. 用户操作流 (REST API)

```
QML Button.onClicked
  ↓
调用Python @Slot方法
  ↓
MoonrakerClient发送REST请求
  ↓
Moonraker执行操作
  ↓ (WebSocket推送状态更新)
回到实时数据流
```

**示例**: 设置温度
```
QML: printer.setTemp("extruder", 200)
  ↓
Python: POST /printer/gcode/script { "script": "SET_HEATER_TEMPERATURE HEATER=extruder TARGET=200" }
  ↓
Moonraker执行G-code
  ↓
WebSocket推送: {"extruder": {"target": 200}}
  ↓
Signal发射: temperatureUpdated
  ↓
QML更新: TempCard显示目标温度200°C
```

### 3. 配置流 (JSON文件)

```
应用启动
  ↓
ConfigManager.load() 读取 config.json
  ↓
初始化AppSettings
  ↓
暴露到QML
  ↓
用户修改设置
  ↓
ConfigManager.save() 写入 config.json
```

---

## 数据关系

```
┌─────────────┐
│ Application │ (单例)
└──────┬──────┘
       │
       ├─── MoonrakerClient ────┬─── PrintJob
       │                        ├─── ControlState
       │                        └─── List<PrintFile>
       │
       ├─── UIState
       │
       └─── ConfigManager ────── AppSettings
```

**关键点**:
- Application是唯一的根对象
- MoonrakerClient管理所有打印机数据
- UIState管理所有UI交互状态
- ConfigManager管理所有持久化设置
- QML通过`app.printer`、`app.uiState`、`app.settings`访问

---

## 实现注意事项

### 1. 线程安全

- WebSocket线程只能发射信号，不能直接修改QML对象
- 所有MoonrakerClient的Property更新必须在主线程完成
- 使用Qt的信号槽机制自动处理线程切换

### 2. 性能优化

- 文件列表使用QML ListModel + 虚拟化 (ListView.cacheBuffer)
- 缩略图异步加载 (Image.asynchronous: true)
- 温度数据去抖动 (仅当变化>0.5°C时更新UI)
- 限制WebSocket更新频率 (最快1秒/次)

### 3. 错误处理

- API调用失败时回退到上次已知状态
- 缺失元数据字段使用默认值/占位符
- 网络断开时显示"离线"状态

### 4. 数据验证

- Python端验证所有用户输入 (温度、移动距离)
- 超出范围的值截断到有效范围
- QML端进行UI层面的输入限制 (Slider范围)

---

## 下一步

数据模型设计完成后，将生成：

1. ⏭️ `contracts/qml-python-api.md` - 详细的Python-QML接口合约
2. ⏭️ `quickstart.md` - 开发者快速上手指南
