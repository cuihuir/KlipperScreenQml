# 快速上手指南：基于设计图的UI界面开发

**功能**: [spec.md](./spec.md) | **API合约**: [contracts/qml-python-api.md](./contracts/qml-python-api.md) | **日期**: 2025-11-20

## 概要

本指南帮助开发者快速上手QtKs的Metro UI界面开发，包括项目结构、开发流程、常见模式和调试技巧。

## 前置要求

- Python 3.10+
- PySide6 >= 6.5.0
- 基本的Qt/QML知识
- 熟悉Moonraker API（可选，有文档即可）

## 项目结构导航

```
QtKs/
├── backend/                    # Python后端模块
│   ├── application.py          # 主应用类（暴露到QML）
│   ├── moonraker_client.py     # Moonraker通信层
│   ├── config_manager.py       # 配置管理
│   └── ui_state.py             # [新增] UI状态管理
│
├── qml/                        # QML前端代码
│   ├── MainWindow.qml          # 根窗口（页面路由）
│   ├── Style.qml               # 样式单例（颜色/字体/间距）
│   ├── qmldir                  # 模块导出定义
│   ├── components/             # 可复用组件
│   │   ├── qmldir              # 组件注册文件
│   │   ├── TempCard.qml        # 温度卡片
│   │   ├── AxisControl.qml     # 轴控制
│   │   ├── FileCard.qml        # 文件卡片
│   │   ├── BottomNavBar.qml    # [新增] 底部导航栏
│   │   └── PlaceholderToast.qml # [新增] 占位符提示
│   └── pages/                  # 主要页面
│       ├── HomePage.qml        # [新增] 首页
│       ├── ControlPage.qml     # [新增] 控制页面
│       ├── FilesPage.qml       # [新增] 文件页面
│       ├── SettingsPage.qml    # [新增] 设置页面
│       ├── PrintingPage.qml    # [新增] 打印状态页面
│       └── ScreenSaverPage.qml # [新增] 屏保页面
│
├── assets/                     # 静态资源
│   └── icons/                  # [新增] 图标文件
│
├── specs/001-metro-ui/         # 功能规格文档
│   ├── spec.md                 # 功能规格
│   ├── plan.md                 # 实施计划
│   ├── research.md             # 技术研究
│   ├── data-model.md           # 数据模型
│   ├── contracts/              # API合约
│   └── quickstart.md           # 本文件
│
├── config.json                 # 配置文件
├── main.py                     # 应用入口
└── requirements.txt            # Python依赖
```

## 5分钟快速开始

### 1. 环境设置

```bash
# 克隆项目（假设已完成）
cd QtKs

# 安装依赖
pip install -r requirements.txt

# 配置打印机连接
vim config.json  # 修改 printer.host 和 printer.port
```

### 2. 运行应用

```bash
# 自动检测显示环境（WSL/X11）
python3 main.py

# 或使用启动脚本
./run_gui.sh
```

### 3. 验证连接

```bash
# 测试Moonraker连接（无GUI）
python3 test_connection.py

# 查看日志
tail -f qtks.log
```

---

## 开发工作流

### 工作流程图

```
1. 设计图分析 → 2. QML组件开发 → 3. Python后端扩展 → 4. 集成测试 → 5. 提交
     ↓               ↓                   ↓                   ↓            ↓
ui_design/*.png   qml/components/    backend/*.py       手动测试       Git commit
                     qml/pages/                         qmlscene
```

### 典型开发任务

#### 任务1: 添加新的QML页面

**场景**: 添加"文件管理"页面

**步骤**:

1. **创建页面文件**

```bash
touch qml/pages/FilesPage.qml
```

```qml
// qml/pages/FilesPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as Components

Page {
    id: root

    // 接收从MainWindow传入的单例
    property var printer: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // 标题栏
        Label {
            text: "我的图纸"
            font.pixelSize: 24
            font.bold: true
        }

        // 文件列表
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: printer.fileList
            spacing: 12

            delegate: Components.FileCard {
                width: ListView.view.width
                filename: modelData.filename
                size: modelData.size
                thumbnailUrl: modelData.thumbnail_url || ""
                estimatedTime: modelData.estimated_time || 0

                onClicked: {
                    // 显示文件详情对话框
                    fileDetailsDialog.file = modelData
                    fileDetailsDialog.open()
                }
            }
        }

        // 刷新按钮
        Button {
            text: "刷新"
            onClicked: printer.refreshFileList()
        }
    }

    // 页面加载时刷新文件列表
    Component.onCompleted: {
        printer.refreshFileList()
    }
}
```

2. **在MainWindow中集成**

```qml
// qml/MainWindow.qml
import "pages" as Pages

ApplicationWindow {
    // ...

    StackLayout {
        id: pageStack
        currentIndex: {
            switch(uiState.currentPage) {
                case "home": return 0
                case "control": return 1
                case "files": return 2  // 新增
                case "settings": return 3
                default: return 0
            }
        }

        Pages.HomePage { printer: root.printer }
        Pages.ControlPage { printer: root.printer }
        Pages.FilesPage { printer: root.printer }  // 新增
        Pages.SettingsPage { printer: root.printer }
    }
}
```

3. **添加导航按钮**

```qml
// qml/components/BottomNavBar.qml
Row {
    // ...

    Button {
        text: "文件"
        icon.source: "qrc:/assets/icons/files.png"
        onClicked: uiState.changePage("files")
        highlighted: uiState.currentPage === "files"
    }
}
```

4. **测试**

```bash
python3 main.py
# 点击"文件"按钮，验证页面切换
```

---

#### 任务2: 创建可复用QML组件

**场景**: 创建温度卡片组件

**步骤**:

1. **创建组件文件**

```bash
touch qml/components/TempCard.qml
```

```qml
// qml/components/TempCard.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: root

    // 对外暴露属性
    property string title: "温度"
    property real currentTemp: 0.0
    property real targetTemp: 0.0

    // 对外暴露信号
    signal setTemp(real temp)

    width: 200
    height: 120
    radius: 8
    color: Material.backgroundColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // 标题
        Label {
            text: root.title
            font.pixelSize: 16
            font.bold: true
        }

        // 当前温度
        Label {
            text: root.currentTemp.toFixed(1) + "°C"
            font.pixelSize: 32
            color: root.currentTemp > 50 ? "#f44336" : "#2196f3"
        }

        // 目标温度
        Label {
            text: "目标: " + root.targetTemp.toFixed(0) + "°C"
            font.pixelSize: 14
            color: "#b0b0b0"
        }

        // 快捷温度按钮
        Row {
            spacing: 8

            Button {
                text: "0"
                onClicked: root.setTemp(0)
            }

            Button {
                text: "200"
                onClicked: root.setTemp(200)
            }

            Button {
                text: "240"
                onClicked: root.setTemp(240)
            }
        }
    }
}
```

2. **在qmldir中注册**

```bash
# qml/components/qmldir
module components
TempCard 1.0 TempCard.qml
AxisControl 1.0 AxisControl.qml
# ... 其他组件
```

3. **在页面中使用**

```qml
// qml/pages/ControlPage.qml
import "../components" as Components

Page {
    property var printer: null

    Components.TempCard {
        title: "喷头"
        currentTemp: printer.extruderTemp
        targetTemp: printer.extruderTarget

        onSetTemp: (temp) => printer.setTemp("extruder", temp)
    }
}
```

**关键点**:
- ✅ 使用`property`暴露可配置属性
- ✅ 使用`signal`暴露事件
- ✅ 必须在`qmldir`中注册
- ❌ 不要使用内联`component`语法（Qt版本不支持）

---

#### 任务3: 添加Python控制命令

**场景**: 添加"电机关闭"功能

**步骤**:

1. **在MoonrakerClient中添加Slot**

```python
# backend/moonraker_client.py

class MoonrakerClient(QObject):
    # ...

    @Slot()
    def motorsOff(self):
        """关闭所有步进电机"""
        try:
            self._send_gcode("M84")  # G-code: 关闭电机
            self.logger.info("电机已关闭")
        except Exception as e:
            self.logger.error(f"关闭电机失败: {e}")

    def _send_gcode(self, gcode: str):
        """发送G-code命令（辅助方法）"""
        try:
            response = requests.post(
                f"{self.base_url}/printer/gcode/script",
                json={"script": gcode},
                timeout=3
            )
            if response.status_code != 200:
                raise Exception(f"HTTP {response.status_code}: {response.text}")
        except Exception as e:
            self.logger.error(f"发送G-code失败: {gcode} - {e}")
            raise
```

2. **在QML中调用**

```qml
// qml/pages/ControlPage.qml
Button {
    text: "电机关闭"
    icon.source: "qrc:/assets/icons/motor-off.png"

    onClicked: printer.motorsOff()
}
```

3. **测试**

```bash
python3 main.py
# 点击"电机关闭"按钮
# 检查日志: tail -f qtks.log
```

**常见G-code命令**:

| 功能 | G-code | 说明 |
|------|--------|------|
| 归零 | `G28 X Y Z` | 归零指定轴 |
| 移动 | `G1 X100 F3000` | 移动到X=100，速度3000mm/min |
| 设置温度 | `M104 S200` | 设置喷头温度200°C |
| 挤出 | `G1 E10 F300` | 挤出10mm |
| 电机关闭 | `M84` | 关闭所有电机 |
| 紧急停止 | `M112` | 立即停止 |

---

#### 任务4: 实现占位符功能

**场景**: 添加"AI打印"占位符按钮

**步骤**:

1. **使用PlaceholderToast组件**

```qml
// qml/pages/HomePage.qml
import "../components" as Components

Page {
    property var printer: null

    // 实例化Toast组件
    Components.PlaceholderToast {
        id: placeholderToast
    }

    // AI打印按钮
    Button {
        text: "AI打印"
        icon.source: "qrc:/assets/icons/ai.png"

        onClicked: {
            // 记录点击
            printer.logPlaceholderClick("AI打印")

            // 显示提示
            placeholderToast.featureName = "AI打印"
            placeholderToast.open()
        }
    }
}
```

2. **验证日志记录**

```bash
tail -f qtks.log
# 点击按钮后应看到:
# INFO - 占位符功能点击: AI打印
```

**占位符规范**:
- ✅ 显示完整UI（按钮/卡片）
- ✅ 点击时显示Toast提示
- ✅ 记录到日志文件
- ✅ 2秒自动关闭
- ❌ 不实现实际功能

---

## 常见开发模式

### 模式1: 实时数据绑定

**问题**: 如何让QML实时显示打印机温度？

**解决方案**: Property绑定 + Signal自动更新

```python
# backend/moonraker_client.py
class MoonrakerClient(QObject):
    temperatureUpdated = Signal(dict)

    @Property(float, notify=temperatureUpdated)
    def extruderTemp(self):
        return self._extruder_temp

    def _update_from_status(self, status):
        """WebSocket数据更新"""
        if 'extruder' in status:
            self._extruder_temp = status['extruder']['temperature']
            self.temperatureUpdated.emit(status)  # 触发QML更新
```

```qml
// QML自动响应
Label {
    text: printer.extruderTemp.toFixed(1) + "°C"
    // 无需手动监听信号，Property绑定自动更新
}
```

**关键**:
- Python: `@Property(type, notify=signal)`
- QML: 直接绑定属性，无需`Connections`

---

### 模式2: 用户操作流

**问题**: 用户点击按钮如何触发打印机操作？

**解决方案**: QML事件 → Python Slot → Moonraker API

```qml
// 1. QML按钮
Button {
    text: "归零"
    onClicked: printer.homeAxis("XYZ")  // 调用Python Slot
}
```

```python
# 2. Python Slot
@Slot(str)
def homeAxis(self, axes: str):
    self._send_gcode(f"G28 {axes}")  # 发送G-code
```

```
3. Moonraker执行 → 4. WebSocket推送状态 → 5. QML更新
```

---

### 模式3: 异步操作 + 进度反馈

**问题**: 下载大文件时如何显示进度？

**解决方案**: aiohttp流式下载 + 进度Signal

```python
# backend/moonraker_client.py
downloadProgressChanged = Signal(str, float)  # (filename, progress)

async def _download_file_async(self, url, dest):
    async with session.get(url) as response:
        total = int(response.headers.get('Content-Length', 0))
        downloaded = 0

        with open(dest, 'wb') as f:
            async for chunk in response.content.iter_chunked(8192):
                f.write(chunk)
                downloaded += len(chunk)
                progress = downloaded / total
                self.downloadProgressChanged.emit(filename, progress)  # 实时更新
```

```qml
// QML进度条
ProgressBar {
    id: progressBar
    from: 0.0
    to: 1.0
}

Connections {
    target: printer
    function onDownloadProgressChanged(file, progress) {
        if (file === currentFile) {
            progressBar.value = progress
        }
    }
}
```

---

### 模式4: 页面间状态共享

**问题**: 多个页面如何访问同一打印机状态？

**解决方案**: Application单例 + 属性传递

```python
# backend/application.py
class Application(QObject):
    def __init__(self):
        self.moonraker = MoonrakerClient()  # 唯一实例

    @Property(QObject, constant=True)
    def printer(self):
        return self.moonraker  # 暴露单例
```

```qml
// qml/MainWindow.qml - 根窗口
ApplicationWindow {
    property var printer: app.printer  // 持有单例引用

    Pages.HomePage { printer: root.printer }    // 传递给所有页面
    Pages.ControlPage { printer: root.printer }
    Pages.FilesPage { printer: root.printer }
}
```

**关键**: 单例在Python端创建，QML通过属性传递共享

---

## 调试技巧

### 1. QML调试输出

```qml
Button {
    onClicked: {
        console.log("按钮点击，温度:", printer.extruderTemp)
        console.log("文件列表:", JSON.stringify(printer.fileList))
    }
}

// 查看输出
// 终端会显示QML控制台输出
```

### 2. Python日志

```python
# backend/moonraker_client.py
self.logger.info(f"设置温度: {heater}={temp}°C")
self.logger.debug(f"WebSocket数据: {data}")
self.logger.error(f"连接失败: {e}")
```

```bash
# 查看日志
tail -f qtks.log

# 调试级别日志
# 修改 main.py
logging.basicConfig(level=logging.DEBUG, ...)
```

### 3. QML性能分析

```bash
# 启用QML Profiler
QSG_VISUALIZE=overdraw python3 main.py  # 可视化重绘区域
QSG_RENDER_TIMING=1 python3 main.py     # 显示渲染时间
```

### 4. 网络请求调试

```python
# 添加requests日志
import http.client as http_client
http_client.HTTPConnection.debuglevel = 1

# 查看所有HTTP请求/响应
```

### 5. 常见错误排查

**错误**: `ReferenceError: printer is not defined`

**原因**: QML组件未接收到`printer`属性

**解决**:
```qml
// 确保页面声明了属性
Page {
    property var printer: null  // 声明

    Component.onCompleted: {
        if (!printer) {
            console.error("printer对象未传入!")
        }
    }
}
```

**错误**: `TypeError: Cannot call method 'setTemp' of null`

**原因**: MoonrakerClient未初始化

**解决**:
```qml
Button {
    enabled: printer !== null  // 检查对象存在
    onClicked: {
        if (printer) printer.setTemp("extruder", 200)
    }
}
```

**错误**: QML组件找不到 (`Component is not installed`)

**原因**: 未在`qmldir`中注册

**解决**:
```bash
# qml/components/qmldir
module components
YourComponent 1.0 YourComponent.qml  # 添加这一行
```

---

## 设计图对照开发

### 工作流

1. **打开设计图**

```bash
# 在图片查看器中打开
eog ui_design/首页@3x.png
```

2. **提取视觉参数**

使用颜色选择器工具（如GIMP、Photoshop）：
- 背景色: `#1a1a1a`
- 卡片背景: `#2d2d2d`
- 强调色: `#ff5722`
- 文字色: `#ffffff`

3. **定义到Style.qml**

```qml
// qml/Style.qml
pragma Singleton
import QtQuick

QtObject {
    readonly property color primaryBg: "#1a1a1a"
    readonly property color cardBg: "#2d2d2d"
    readonly property color accent: "#ff5722"
    readonly property color textPrimary: "#ffffff"
}
```

4. **在组件中使用**

```qml
import "../Style.qml" as Style

Rectangle {
    color: Style.primaryBg  // 使用单例颜色
}
```

### 布局对齐

**设计图尺寸**: 1920x440

**QML实现**:

```qml
ApplicationWindow {
    width: 1920
    height: 440

    // 底部导航栏: 60像素
    BottomNavBar {
        height: 60
        anchors.bottom: parent.bottom
    }

    // 内容区域: 440 - 60 = 380像素
    StackLayout {
        anchors.top: parent.top
        anchors.bottom: navBar.top
        height: 380  // 可用高度
    }
}
```

**间距规范** (从设计图测量):
- 页面边距: 16px
- 卡片间距: 12px
- 组内间距: 8px

---

## 测试策略

### 1. 手动测试清单

```markdown
- [ ] 页面切换流畅（< 300ms）
- [ ] 温度数据实时更新（1秒内）
- [ ] 按钮点击响应（< 100ms）
- [ ] 文件列表加载（< 500ms for 100项）
- [ ] 屏保5分钟后自动激活
- [ ] 触摸操作响应（实际设备）
- [ ] 占位符功能显示Toast
- [ ] 设计图一致性（目视95%）
```

### 2. Python单元测试

```python
# tests/test_moonraker_client.py
import pytest
from backend.moonraker_client import MoonrakerClient

def test_set_temp():
    client = MoonrakerClient()
    client.setTemp("extruder", 200)
    # 验证（需mock requests）
```

### 3. QML组件测试（可选）

```qml
// tests/qml/tst_TempCard.qml
import QtTest

TestCase {
    name: "TempCard"

    function test_tempDisplay() {
        var card = createTemporaryObject(tempCardComponent)
        card.currentTemp = 200.5
        compare(card.text, "200.5°C")
    }
}
```

---

## 性能优化

### 1. ListView虚拟化

```qml
ListView {
    model: printer.fileList

    // 启用缓存，提升滚动性能
    cacheBuffer: 200  // 缓存上下200px的项

    // 异步加载
    delegate: Loader {
        asynchronous: true
        sourceComponent: FileCard { ... }
    }
}
```

### 2. 图片异步加载

```qml
Image {
    source: thumbnailUrl
    asynchronous: true  // 后台线程加载
    cache: true         // 启用缓存
}
```

### 3. 减少信号发射

```python
def _update_temp(self, new_temp):
    # 仅当变化超过0.5°C时更新
    if abs(new_temp - self._extruder_temp) > 0.5:
        self._extruder_temp = new_temp
        self.temperatureUpdated.emit(...)
```

---

## 提交代码

### Git工作流

```bash
# 1. 创建功能分支
git checkout -b 001-metro-ui

# 2. 添加修改
git add qml/pages/FilesPage.qml
git add backend/moonraker_client.py

# 3. 提交（遵循CLAUDE.md：提交前确认）
git commit -m "feat: 添加文件管理页面

- 实现FilesPage.qml文件列表显示
- 添加refreshFileList Python方法
- 集成文件缩略图Base64显示
"

# 4. 推送
git push origin 001-metro-ui
```

**提交消息规范**:
- `feat:` 新功能
- `fix:` Bug修复
- `refactor:` 重构
- `docs:` 文档
- `style:` 代码格式

---

## 下一步学习

### 深入阅读

1. **API合约**: [contracts/qml-python-api.md](./contracts/qml-python-api.md) - 完整的Python-QML接口规范
2. **数据模型**: [data-model.md](./data-model.md) - 核心实体和数据流
3. **技术研究**: [research.md](./research.md) - 关键技术决策

### Qt/QML资源

- [Qt官方文档](https://doc.qt.io/qt-6/)
- [QML类型参考](https://doc.qt.io/qt-6/qmltypes.html)
- [Qt Quick Controls](https://doc.qt.io/qt-6/qtquickcontrols-index.html)

### Moonraker API

- [Moonraker文档](https://moonraker.readthedocs.io/)
- [WebSocket API](https://moonraker.readthedocs.io/en/latest/web_api/#websocket-api)

---

## 常见问题

### Q: 如何调试WebSocket连接？

```python
# backend/moonraker_client.py
async def _on_message(self, message):
    self.logger.debug(f"WebSocket收到: {message}")  # 启用DEBUG日志
```

### Q: 1920x440宽屏如何适配？

使用Row布局横向分割：

```qml
Row {
    spacing: 24
    Rectangle { width: 480; height: 380 }  // 左侧区域
    Rectangle { width: 640; height: 380 }  // 中间区域
    Rectangle { width: 480; height: 380 }  // 右侧区域
}
```

### Q: 占位符功能如何统一？

使用PlaceholderToast组件：

```qml
Button {
    text: "占位符功能"
    onClicked: {
        printer.logPlaceholderClick("功能名称")
        placeholderToast.featureName = "功能名称"
        placeholderToast.open()
    }
}
```

### Q: 如何实现主题切换？

（占位符功能，当前不实现）

未来扩展：修改Style.qml为可变属性，通过ConfigManager切换。

---

## 总结

**关键要点**:

1. **架构**: Python后端（backend/） + QML前端（qml/）分离
2. **通信**: Property/Slot/Signal模式
3. **状态管理**: Application单例 + 属性传递
4. **组件化**: qmldir注册 + 可复用组件
5. **占位符**: 统一Toast + 日志记录
6. **宽屏适配**: Row布局 + 固定宽度

**开发检查清单**:

- [ ] 新组件已在qmldir注册
- [ ] Python Slot有异常处理
- [ ] QML属性有null检查
- [ ] 占位符功能有Toast提示
- [ ] 日志级别合适（INFO/DEBUG）
- [ ] 设计图颜色使用Style.qml
- [ ] 提交前已测试

**获取帮助**:

- 查看规格文档: `specs/001-metro-ui/`
- 查看现有代码: `backend/`, `qml/`
- 查看日志: `tail -f qtks.log`

祝开发愉快！🚀
