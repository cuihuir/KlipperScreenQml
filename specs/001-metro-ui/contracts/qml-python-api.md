# QML-Python API 合约

**功能**: [spec.md](../spec.md) | **数据模型**: [data-model.md](../data-model.md) | **日期**: 2025-11-20

## 概要

本文档定义QML前端与Python后端之间的完整接口合约，包括Properties、Slots、Signals的详细规范。

## 接口概览

### 暴露对象

QML通过全局`app`对象访问以下Python单例：

```qml
// qml/MainWindow.qml
ApplicationWindow {
    property var app: app  // 由main.py注入的Application对象

    // 访问子对象
    property var printer: app.printer    // MoonrakerClient
    property var uiState: app.uiState    // UIState
    property var settings: app.settings  // ConfigManager
}
```

---

## 1. MoonrakerClient (printer对象)

### Properties (只读，除非标注可写)

#### 打印机连接状态

```python
@Property(bool, notify=connectionStateChanged)
def connected(self) -> bool
```
- **说明**: 是否已连接到Moonraker
- **初始值**: `False`
- **QML用法**: `if (printer.connected) { ... }`

```python
@Property(str, notify=printerStateChanged)
def printerState(self) -> str
```
- **说明**: 打印机状态 ("ready", "printing", "paused", "error", "offline")
- **初始值**: `"offline"`
- **QML用法**: `Label { text: printer.printerState }`

---

#### 温度数据

```python
@Property(float, notify=temperatureUpdated)
def extruderTemp(self) -> float
```
- **说明**: 喷头当前温度 (°C)
- **初始值**: `0.0`
- **更新频率**: ~1秒/次 (WebSocket)
- **QML用法**: `Label { text: printer.extruderTemp.toFixed(1) + "°C" }`

```python
@Property(float, notify=temperatureUpdated)
def extruderTarget(self) -> float
```
- **说明**: 喷头目标温度 (°C)
- **初始值**: `0.0`
- **QML用法**: `Label { text: printer.extruderTarget.toFixed(0) + "°C" }`

```python
@Property(float, notify=temperatureUpdated)
def bedTemp(self) -> float
```
- **说明**: 热床当前温度 (°C)
- **初始值**: `0.0`

```python
@Property(float, notify=temperatureUpdated)
def bedTarget(self) -> float
```
- **说明**: 热床目标温度 (°C)
- **初始值**: `0.0`

```python
@Property(float, notify=temperatureUpdated)
def chamberTemp(self) -> float
```
- **说明**: 仓温当前温度 (°C)，如果打印机没有仓温传感器则返回0
- **初始值**: `0.0`

**信号定义**:
```python
temperatureUpdated = Signal(dict)  # {"extruder": {...}, "bed": {...}, "chamber": {...}}
```

---

#### 位置数据

```python
@Property(float, notify=positionUpdated)
def xPos(self) -> float
```
- **说明**: X轴当前位置 (mm)
- **初始值**: `0.0`
- **QML用法**: `Label { text: "X: " + printer.xPos.toFixed(2) }`

```python
@Property(float, notify=positionUpdated)
def yPos(self) -> float
```
- **说明**: Y轴当前位置 (mm)

```python
@Property(float, notify=positionUpdated)
def zPos(self) -> float
```
- **说明**: Z轴当前位置 (mm)

```python
@Property(str, notify=positionUpdated)
def homedAxes(self) -> str
```
- **说明**: 已归零的轴，如 "xyz" (全部归零) 或 "xy" (仅XY归零)
- **初始值**: `""`
- **QML用法**:
```qml
Button {
    enabled: printer.homedAxes.includes("z")  // Z轴已归零才允许移动
}
```

**信号定义**:
```python
positionUpdated = Signal(dict)  # {"x": 0.0, "y": 0.0, "z": 0.0, "homed_axes": "xyz"}
```

---

#### 打印任务数据

```python
@Property(str, notify=printStateChanged)
def printState(self) -> str
```
- **说明**: 打印状态 ("standby", "printing", "paused", "complete", "cancelled", "error")
- **初始值**: `"standby"`
- **QML用法**:
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
```

```python
@Property(float, notify=printProgressChanged)
def printProgress(self) -> float
```
- **说明**: 打印进度 (0.0-1.0)
- **初始值**: `0.0`
- **QML用法**: `ProgressBar { value: printer.printProgress }`

```python
@Property(str, notify=printStateChanged)
def currentFilename(self) -> str
```
- **说明**: 当前打印文件名
- **初始值**: `""`

```python
@Property(int, notify=printProgressChanged)
def printDuration(self) -> int
```
- **说明**: 已打印时长 (秒)
- **初始值**: `0`
- **QML用法**:
```qml
Label {
    text: {
        var hours = Math.floor(printer.printDuration / 3600)
        var minutes = Math.floor((printer.printDuration % 3600) / 60)
        return hours + "h " + minutes + "m"
    }
}
```

```python
@Property(int, notify=printProgressChanged)
def estimatedTimeRemaining(self) -> int
```
- **说明**: 预计剩余时间 (秒)，基于Moonraker计算
- **初始值**: `0`

**信号定义**:
```python
printStateChanged = Signal(str)  # state
printProgressChanged = Signal(dict)  # {"progress": 0.5, "duration": 1800, "remaining": 1800}
```

---

#### 文件列表数据

```python
@Property(QVariant, notify=fileListChanged)
def fileList(self) -> list
```
- **说明**: 可打印文件列表，每个元素是QVariantMap（字典）
- **初始值**: `[]`
- **QML用法**:
```qml
ListView {
    model: printer.fileList

    delegate: FileCard {
        filename: modelData.filename
        size: modelData.size
        thumbnailUrl: modelData.thumbnail_url || ""
        estimatedTime: modelData.estimated_time || 0
    }
}
```

**元素结构** (参考data-model.md的PrintFile实体):
```python
{
    "filename": "test.gcode",
    "path": "gcodes/test.gcode",
    "size": 1024000,
    "modified": 1732012800.0,
    "thumbnail_url": "data:image/png;base64,...",  # 可选
    "estimated_time": 3600,  # 可选
    "layer_count": 120,  # 可选
    ...
}
```

**信号定义**:
```python
fileListChanged = Signal(list)
```

---

#### 控制参数 (UI状态)

```python
@Property(float, notify=moveStepChanged)
def moveStep(self) -> float
```
- **说明**: 当前移动步进 (mm)，可选值 [0.1, 1, 10, 50]
- **初始值**: `10.0`
- **可写**: ✅
- **QML用法**:
```qml
Button {
    text: "Z+" + printer.moveStep
    onClicked: printer.moveAxis("Z", printer.moveStep)
}

ComboBox {
    model: [0.1, 1, 10, 50]
    currentIndex: 2  // 默认10mm
    onActivated: printer.setMoveStep(model[index])
}
```

**信号定义**:
```python
moveStepChanged = Signal(float)
```

---

### Slots (方法)

#### 温度控制

```python
@Slot(str, float)
def setTemp(self, heater: str, temp: float)
```
- **说明**: 设置加热器目标温度
- **参数**:
  - `heater`: 加热器名称 ("extruder", "heater_bed")
  - `temp`: 目标温度 (°C)，范围 0-300，0表示关闭
- **验证**: 自动截断到0-300范围
- **G-code**: `SET_HEATER_TEMPERATURE HEATER={heater} TARGET={temp}`
- **QML用法**:
```qml
Button {
    text: "200°C"
    onClicked: printer.setTemp("extruder", 200)
}

Slider {
    from: 0
    to: 260
    onValueChanged: printer.setTemp("extruder", value)
}
```

```python
@Slot(str)
def preheat(self, preset: str)
```
- **说明**: 预热到预设温度
- **参数**: `preset` - 预设名称 ("PLA", "ABS", "PETG")
- **行为**: 同时设置喷头和热床温度
  - PLA: 喷头200°C, 热床60°C
  - ABS: 喷头240°C, 热床100°C
  - PETG: 喷头230°C, 热床80°C
- **QML用法**:
```qml
Button {
    text: "PLA预热"
    onClicked: printer.preheat("PLA")
}
```

---

#### 轴控制

```python
@Slot(str)
def homeAxis(self, axes: str)
```
- **说明**: 归零指定轴
- **参数**: `axes` - 轴名称，如 "X", "Y", "Z", "XY", "XYZ"
- **G-code**: `G28 {axes}`
- **QML用法**:
```qml
Button {
    text: "全部归零"
    onClicked: printer.homeAxis("XYZ")
}

Button {
    text: "归零Z"
    onClicked: printer.homeAxis("Z")
}
```

```python
@Slot(str, float)
def moveAxis(self, axis: str, distance: float)
```
- **说明**: 相对移动指定轴
- **参数**:
  - `axis`: 轴名称 ("X", "Y", "Z")
  - `distance`: 移动距离 (mm)，正数向正方向，负数向负方向
- **验证**: 检查轴是否已归零 (homed_axes)，未归零则拒绝
- **G-code**: `G91\nG1 {axis}{distance} F3000\nG90`
- **QML用法**:
```qml
Button {
    text: "X+"
    enabled: printer.homedAxes.includes("x")
    onClicked: printer.moveAxis("X", printer.moveStep)
}

Button {
    text: "Z-"
    enabled: printer.homedAxes.includes("z")
    onClicked: printer.moveAxis("Z", -printer.moveStep)
}
```

```python
@Slot(str, float)
def moveAxisAbsolute(self, axis: str, position: float)
```
- **说明**: 绝对移动到指定位置
- **参数**:
  - `axis`: 轴名称
  - `position`: 目标位置 (mm)
- **G-code**: `G90\nG1 {axis}{position} F3000`

---

#### 挤出控制

```python
@Slot(float, float)
def extrude(self, length: float, speed: float = 5.0)
```
- **说明**: 挤出/回抽耗材
- **参数**:
  - `length`: 挤出长度 (mm)，正数挤出，负数回抽，范围 -100 到 100
  - `speed`: 挤出速度 (mm/s)，范围 1-50，默认5
- **验证**: 喷头温度必须≥170°C，否则拒绝（冷挤出保护）
- **G-code**: `M83\nG1 E{length} F{speed*60}`
- **QML用法**:
```qml
Button {
    text: "挤出10mm"
    enabled: printer.extruderTemp >= 170
    onClicked: printer.extrude(10, 5)
}

Button {
    text: "回抽5mm"
    enabled: printer.extruderTemp >= 170
    onClicked: printer.extrude(-5, 5)
}
```

---

#### 打印控制

```python
@Slot(str)
def startPrint(self, filepath: str)
```
- **说明**: 开始打印指定文件
- **参数**: `filepath` - 文件路径，如 "gcodes/test.gcode"
- **验证**: 文件必须存在于fileList中
- **API**: `POST /printer/print/start { "filename": filepath }`
- **行为**: 自动切换到PrintingPage
- **QML用法**:
```qml
Button {
    text: "开始打印"
    onClicked: printer.startPrint(modelData.path)
}
```

```python
@Slot()
def pausePrint(self)
```
- **说明**: 暂停当前打印
- **验证**: 仅当printState == "printing"时有效
- **API**: `POST /printer/print/pause`
- **QML用法**:
```qml
Button {
    text: "暂停"
    enabled: printer.printState === "printing"
    onClicked: printer.pausePrint()
}
```

```python
@Slot()
def resumePrint(self)
```
- **说明**: 恢复打印
- **验证**: 仅当printState == "paused"时有效
- **API**: `POST /printer/print/resume`

```python
@Slot()
def cancelPrint(self)
```
- **说明**: 取消打印
- **验证**: 仅当printState == "printing" 或 "paused"时有效
- **API**: `POST /printer/print/cancel`
- **行为**: 弹出确认对话框（QML实现）

---

#### 文件管理

```python
@Slot()
def refreshFileList(self)
```
- **说明**: 刷新文件列表
- **API**: `GET /server/files/list?root=gcodes`
- **行为**: 异步获取，完成后发射fileListChanged信号
- **QML用法**:
```qml
Button {
    text: "刷新"
    onClicked: printer.refreshFileList()
}

Component.onCompleted: printer.refreshFileList()  // 页面加载时刷新
```

```python
@Slot(str, result=QVariant)
def getFileMetadata(self, filepath: str) -> dict
```
- **说明**: 获取文件详细元数据
- **参数**: `filepath` - 文件路径
- **返回**: 元数据字典（参考data-model.md）
- **API**: `GET /server/files/metadata?filename={filepath}`
- **QML用法**:
```qml
Dialog {
    property var metadata: printer.getFileMetadata(currentFile)

    Label { text: "层数: " + metadata.layer_count }
    Label { text: "预计时间: " + formatTime(metadata.estimated_time) }
    Image { source: metadata.thumbnail_url }
}
```

```python
@Slot(str)
def deleteFile(self, filepath: str)
```
- **说明**: 删除文件
- **参数**: `filepath` - 文件路径
- **API**: `DELETE /server/files/gcodes/{filepath}`
- **行为**: 删除后自动刷新文件列表
- **QML用法**:
```qml
Button {
    text: "删除"
    onClicked: {
        confirmDialog.action = () => printer.deleteFile(modelData.path)
        confirmDialog.open()
    }
}
```

---

#### 系统控制

```python
@Slot()
def emergencyStop(self)
```
- **说明**: 紧急停止
- **G-code**: `M112` (立即停止)
- **行为**: 停止所有运动，关闭加热器，需要重启固件
- **QML用法**:
```qml
Button {
    text: "紧急停止"
    highlighted: true
    Material.background: Material.Red
    onClicked: printer.emergencyStop()
}
```

```python
@Slot()
def motorsOff(self)
```
- **说明**: 关闭步进电机
- **G-code**: `M84`
- **QML用法**:
```qml
Button {
    text: "电机关闭"
    onClicked: printer.motorsOff()
}
```

---

#### 占位符功能

```python
@Slot(str)
def logPlaceholderClick(self, featureName: str)
```
- **说明**: 记录占位符功能点击
- **参数**: `featureName` - 功能名称（如 "AI打印", "通知中心"）
- **行为**: 记录到日志文件，发射placeholderClicked信号
- **QML用法**:
```qml
Button {
    text: "AI打印"
    onClicked: {
        printer.logPlaceholderClick("AI打印")
        placeholderToast.show("AI打印")
    }
}
```

**信号定义**:
```python
placeholderClicked = Signal(str)  # featureName
```

---

#### 控制参数设置

```python
@Slot(float)
def setMoveStep(self, step: float)
```
- **说明**: 设置移动步进
- **参数**: `step` - 步进值，必须是 [0.1, 1, 10, 50] 之一
- **验证**: 自动取最接近的有效值
- **QML用法**:
```qml
ComboBox {
    model: ["0.1mm", "1mm", "10mm", "50mm"]
    onActivated: printer.setMoveStep([0.1, 1, 10, 50][index])
}
```

---

### Signals (事件)

所有信号已在上文Properties和Slots部分定义，汇总如下：

```python
# 连接状态
connectionStateChanged = Signal(bool)
printerStateChanged = Signal(str)

# 温度
temperatureUpdated = Signal(dict)  # {"extruder": {...}, "bed": {...}}

# 位置
positionUpdated = Signal(dict)  # {"x": 0, "y": 0, "z": 0, "homed_axes": "xyz"}

# 打印任务
printStateChanged = Signal(str)
printProgressChanged = Signal(dict)  # {"progress": 0.5, "duration": 1800}

# 文件
fileListChanged = Signal(list)
downloadProgressChanged = Signal(str, float)  # (filename, progress)

# 控制参数
moveStepChanged = Signal(float)

# 占位符
placeholderClicked = Signal(str)
```

**QML监听示例**:
```qml
Connections {
    target: printer

    function onTemperatureUpdated(data) {
        console.log("温度更新:", JSON.stringify(data))
    }

    function onPrintStateChanged(state) {
        if (state === "complete") {
            completionDialog.open()
        }
    }
}
```

---

## 2. UIState (uiState对象)

### Properties

```python
@Property(str, notify=pageChanged)
def currentPage(self) -> str
```
- **说明**: 当前页面名称
- **枚举**: "home", "control", "files", "settings", "printing", "screensaver"
- **初始值**: `"home"`
- **可写**: ✅ (通过changePage Slot)

```python
@Property(bool, notify=screensaverActiveChanged)
def screensaverActive(self) -> bool
```
- **说明**: 屏保是否激活
- **初始值**: `False`

```python
@Property(bool, notify=pageChanged)
def bottomNavVisible(self) -> bool
```
- **说明**: 底部导航栏是否可见（计算属性）
- **计算**: `currentPage not in ["printing", "screensaver"]`
- **QML用法**:
```qml
BottomNavBar {
    visible: uiState.bottomNavVisible
}
```

### Slots

```python
@Slot(str)
def changePage(self, pageName: str)
```
- **说明**: 切换页面
- **参数**: `pageName` - 页面名称（枚举值）
- **验证**: 必须是有效页面名称
- **QML用法**:
```qml
Button {
    text: "首页"
    onClicked: uiState.changePage("home")
}
```

```python
@Slot()
def deactivateScreensaver(self)
```
- **说明**: 退出屏保
- **行为**: 返回到首页，重置空闲定时器

```python
@Slot(int)
def setScreensaverTimeout(self, timeoutMs: int)
```
- **说明**: 设置屏保超时时间
- **参数**: `timeoutMs` - 超时时间（毫秒），范围 60000-3600000

### Signals

```python
pageChanged = Signal(str)  # pageName
screensaverActiveChanged = Signal(bool)
```

---

## 3. ConfigManager (settings对象)

### Properties

```python
@Property(int, notify=brightnessChanged)
def brightness(self) -> int
```
- **说明**: 屏幕亮度 (0-100)
- **初始值**: `80`
- **可写**: ✅

```python
@Property(int, notify=volumeChanged)
def volume(self) -> int
```
- **说明**: 音量 (0-100)
- **初始值**: `50`

```python
@Property(str, notify=languageChanged)
def language(self) -> str
```
- **说明**: 语言代码
- **枚举**: "zh_CN", "en_US"
- **初始值**: `"zh_CN"`

```python
@Property(str, notify=timezoneChanged)
def timezone(self) -> str
```
- **说明**: 时区字符串
- **初始值**: `"Asia/Shanghai"`

### Slots

```python
@Slot(int)
def setBrightness(self, value: int)
```
- **说明**: 设置亮度
- **参数**: `value` - 亮度值 (0-100)
- **行为**: 立即保存到config.json
- **QML用法**:
```qml
Slider {
    from: 0
    to: 100
    value: settings.brightness
    onValueChanged: settings.setBrightness(value)
}
```

```python
@Slot(int)
def setVolume(self, value: int)
```
- **说明**: 设置音量

```python
@Slot(str)
def setLanguage(self, lang: str)
```
- **说明**: 设置语言
- **参数**: `lang` - 语言代码

```python
@Slot(str)
def setTimezone(self, tz: str)
```
- **说明**: 设置时区

### Signals

```python
brightnessChanged = Signal(int)
volumeChanged = Signal(int)
languageChanged = Signal(str)
timezoneChanged = Signal(str)
```

---

## 使用示例

### 完整页面示例 - ControlPage.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Page {
    id: root

    // 从MainWindow传入
    property var printer: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // 温度控制区域
        RowLayout {
            spacing: 24

            TempCard {
                title: "喷头"
                currentTemp: printer.extruderTemp
                targetTemp: printer.extruderTarget
                onSetTemp: (temp) => printer.setTemp("extruder", temp)
            }

            TempCard {
                title: "热床"
                currentTemp: printer.bedTemp
                targetTemp: printer.bedTarget
                onSetTemp: (temp) => printer.setTemp("heater_bed", temp)
            }
        }

        // 轴控制区域
        AxisControl {
            printer: root.printer

            onHomeClicked: (axes) => printer.homeAxis(axes)
            onMoveClicked: (axis, dist) => printer.moveAxis(axis, dist)
        }

        // 挤出控制
        ExtrudeControl {
            enabled: printer.extruderTemp >= 170

            onExtrudeClicked: (length, speed) => printer.extrude(length, speed)
        }
    }

    // 监听温度更新
    Connections {
        target: printer
        function onTemperatureUpdated(data) {
            // 温度变化时自动刷新（属性绑定已自动处理）
        }
    }
}
```

---

## 错误处理

### Python端

```python
@Slot(str, float)
def setTemp(self, heater: str, temp: float):
    try:
        # 验证参数
        temp = max(0, min(300, temp))  # 截断到有效范围

        # 发送请求
        response = requests.post(...)

        if response.status_code != 200:
            self.logger.error(f"设置温度失败: {response.text}")
            # 不抛出异常，静默失败
    except Exception as e:
        self.logger.error(f"setTemp异常: {e}")
```

### QML端

```qml
Button {
    text: "设置温度"
    onClicked: {
        try {
            printer.setTemp("extruder", 200)
        } catch (e) {
            console.error("调用失败:", e)
            errorToast.show("操作失败，请重试")
        }
    }
}
```

---

## 性能考虑

### 1. 减少信号发射频率

```python
def _update_from_status(self, status):
    """仅当值变化超过阈值时发射信号"""
    if 'extruder' in status:
        new_temp = status['extruder']['temperature']
        if abs(new_temp - self._extruder_temp) > 0.5:  # 0.5°C阈值
            self._extruder_temp = new_temp
            self.temperatureUpdated.emit(status)
```

### 2. QML属性绑定优化

```qml
// ✅ 高效：直接绑定
Label {
    text: printer.extruderTemp.toFixed(1) + "°C"
}

// ❌ 低效：手动监听
Label {
    id: tempLabel
    Connections {
        target: printer
        function onTemperatureUpdated() {
            tempLabel.text = printer.extruderTemp.toFixed(1) + "°C"
        }
    }
}
```

### 3. 异步操作

```python
@Slot(str)
def refreshFileList(self, root="gcodes"):
    """异步刷新文件列表，不阻塞UI"""
    def async_refresh():
        try:
            files = self._fetch_files(root)  # 可能耗时
            # 在主线程更新（通过信号）
            self.fileListChanged.emit(files)
        except Exception as e:
            self.logger.error(f"刷新文件失败: {e}")

    # 在后台线程执行
    threading.Thread(target=async_refresh, daemon=True).start()
```

---

## 测试

### Python端单元测试

```python
# tests/test_moonraker_client.py
def test_set_temp():
    client = MoonrakerClient()

    # 监听信号
    signal_data = {}
    client.temperatureUpdated.connect(lambda data: signal_data.update(data))

    # 调用方法
    client.setTemp("extruder", 200)

    # 验证（需mock requests）
    assert signal_data['extruder']['target'] == 200
```

### QML组件测试

```qml
// tests/qml/tst_TempCard.qml
import QtTest

TestCase {
    name: "TempCard"

    function test_setTemp() {
        var card = createTemporaryObject(tempCardComponent, testCase)
        var spy = createTemporaryObject(signalSpyComponent, testCase, {
            target: card,
            signalName: "setTemp"
        })

        card.targetTemp = 200
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 200)
    }
}
```

---

## 版本兼容性

**当前API版本**: 1.0

**Breaking Changes策略**:
- Property/Slot签名变更：主版本号+1
- 新增Property/Slot：次版本号+1
- Bug修复：补丁版本号+1

**未来扩展预留**:
- Multi-extruder支持 (extruder1, extruder2...)
- 网络管理API (WiFi连接)
- 用户系统API (登录/退出)

---

## 下一步

API合约完成后，将生成：

⏭️ `quickstart.md` - 开发者快速上手指南
