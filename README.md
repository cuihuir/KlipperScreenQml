# QtKs - Modern 3D Printer Interface

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-green.svg)
![Qt](https://img.shields.io/badge/PySide6-6.0+-red.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

QtKs 是一个现代化的 3D 打印机控制界面，采用 **Metro 设计语言**（机场指示牌风格），为 Klipper 固件提供简洁、高效的触控界面。

## ✨ 特性

### 🎨 Metro 设计风格
- **纯黑背景** (#000000) - 极简专业
- **亮黄强调色** (#FFEB3B) - 机场指示牌风格
- **扁平设计** - 无/极小圆角，清晰易读
- **等宽数字** - 专业显示温度和坐标
- **完全自适应** - 支持任意屏幕尺寸
  <img width="1019" height="598" alt="image" src="https://github.com/user-attachments/assets/4b99f742-3157-4458-81ea-9a32f213d3ec" />


### 🖥️ 核心功能
- **主页（Dashboard）**
  - 实时温度控制（挤出机 + 热床）
  - 打印控制（暂停/恢复/取消/急停）
  - 系统状态监控

- **移动控制（Move）**
  - XYZ 三轴精确控制
  - 7档步进距离（0.1-50mm）
  - 归零功能（全部 + 单轴）
  - 电机禁用

- **文件管理（Files）**
  - G-code 文件浏览（2x4 大图标网格）
  - 缩略图预览显示
  - 分页浏览（每页 8 个文件）
  - 滑动翻页手势支持
  - 一键打印启动
  - 文件详情（大小、时间、预估时长）

- **AFC 多色支持（AFC）**
  - 多色材料管理（MMU/ERCF）
  - 材料快速切换
  - 状态实时监控

- **系统设置（Settings）**
  - 打印机连接配置
  - 系统信息显示
  - Klipper 控制（重启固件、清除错误）

## 🚀 快速开始

### 系统要求
- Python 3.8+
- PySide6 6.0+
- Klipper + Moonraker

### 安装

#### 方法一：使用 pip（推荐用于 ARM 设备如 Orange Pi）

```bash
# 克隆项目
git clone <repository-url>
cd QtKs

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置打印机连接
cp config.example.json config.json
nano config.json  # 修改 printer.host 为你的打印机 IP

# 运行应用
python main.py
```

#### 方法二：使用 uv（推荐用于 x86_64 开发环境）

```bash
# 安装 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 克隆并运行
git clone <repository-url>
cd QtKs
cp config.example.json config.json
nano config.json

# 使用 uv 运行
uv run python main.py
```

> **注意**: 在 ARM 设备（如 Orange Pi）上，由于 PySide6 的 aarch64 版本兼容性问题，建议使用 pip 而不是 uv。

### 配置

编辑 `config.json` 配置文件：

```json
{
  "printer": {
    "host": "192.168.200.209",
    "port": 7125,
    "name": "My 3D Printer"
  },
  "ui": {
    "width": 800,
    "height": 480,
    "fullscreen": false
  }
}
```

## 📁 项目结构

```
QtKs/
├── main.py                 # 应用入口
├── config.json             # 配置文件
├── requirements.txt        # Python依赖
│
├── backend/                # Python后端
│   ├── application.py      # 应用管理器
│   ├── config_manager.py   # 配置管理器
│   └── moonraker_client.py # Moonraker客户端
│
└── qml/                    # QML界面
    ├── Style.qml           # 全局样式（单例）
    ├── ApiClient.qml       # API客户端（单例）
    ├── MainWindow.qml      # 主窗口
    │
    ├── components/         # 可复用组件
    │   ├── MetroButton.qml
    │   ├── MetroDialog.qml
    │   ├── StatusBar.qml
    │   ├── TempControl.qml
    │   ├── PrintControl.qml
    │   └── ...
    │
    └── pages/              # 页面组件
        ├── DashboardPage.qml
        ├── MovePage.qml
        ├── FilesPage.qml
        └── SettingsPage.qml
```

## 🎯 使用方法

### 1. 温度控制
1. 进入主页（Dashboard）
2. 选择温度预设或手动输入
3. 点击设置按钮应用温度

### 2. 打印文件
1. 进入文件页面（Files）
2. 点击 REFRESH 加载文件列表
3. 选择文件，点击 PRINT
4. 确认后开始打印

### 3. 移动轴
1. 进入移动页面（Move）
2. 选择步进距离（0.1-50mm）
3. 点击方向按钮移动
4. 使用 HOME 按钮归零

### 4. 系统设置
1. 进入设置页面（Settings）
2. 修改 IP 地址和端口
3. 点击 SAVE & RECONNECT
4. 执行系统操作（需确认）

## 🎨 Metro 设计规范

### 配色方案
```
主背景:   #000000 (纯黑)
次背景:   #1a1a1a (深灰)
卡片:     #242424
强调色:   #FFEB3B (亮黄)
成功:     #00FF00 (工业绿)
警告:     #FF9800 (橙色)
错误:     #FF0000 (纯红)
信息:     #00BCD4 (青色)
```

### 字体规范
- **标题**: 大写 + 字间距
- **数字**: 等宽字体（monospace）
- **按钮**: 粗体 + 大写

### 布局原则
- **自适应**: 所有尺寸基于 `baseUnit`
- **最小宽度**: 防止内容挤压
- **弹性填充**: 利用 Layout 系统

## 🔧 开发

### 添加新页面

1. 在 `qml/pages/` 创建新页面：
```qml
import QtQuick
import QtQuick.Controls
import ".."

Page {
    id: root
    property var printer: null
    signal showError(string message)

    background: Rectangle {
        color: Style.bgPrimary
    }

    // 页面内容...
}
```

2. 在 `MainWindow.qml` 中注册页面

### 添加新组件

1. 在 `qml/components/` 创建组件
2. 在 `qml/components/qmldir` 注册
3. 使用 `import "../components" as Components`

### API 调用

使用 `ApiClient` 单例：
```qml
ApiClient.sendGcode("G28", function(response) {
    console.log("Success:", response)
}, function(error) {
    showError(error)
})
```

## 📊 性能优化

QtKs 针对嵌入式设备进行了深度优化：

### 核心优化
- ✅ **按需渲染** - 使用 Loader 仅渲染当前页面，非活动页面不占用 CPU
- ✅ **温度节流** - 温度变化 < 0.5°C 不更新界面，减少 QML 重绘
- ✅ **进度限流** - 打印进度最多每秒更新一次
- ✅ **日志优化** - 生产环境禁用 QML/Python 调试日志
- ✅ **时钟优化** - 时钟显示仅 HH:mm，每分钟更新一次

### 架构优化
- ✅ 单例模式减少实例化
- ✅ WebSocket 独立线程处理
- ✅ 缓存频繁访问的属性
- ✅ 使用 Behavior 平滑动画
- ✅ 统一的 API 调用封装

### 性能表现
**Orange Pi CM4 (2GB RAM) 实测**：
- Dashboard 页面: ~10% CPU
- 其他页面: ~3-5% CPU
- 内存占用: ~250MB (11.6%)
- 温度更新: 0.5 秒延迟
- 界面响应: < 50ms

## 🐛 故障排除

### 连接失败
1. 检查打印机 IP 和端口
2. 确认 Moonraker 正在运行：`curl http://IP:7125/server/info`
3. 查看日志文件 `qtks.log`

### 界面显示异常
1. 检查窗口尺寸配置（config.json）
2. 确认 QT_QPA_PLATFORM 环境变量
3. 尝试不同的显示后端（wayland/xcb）

```bash
# Wayland
export QT_QPA_PLATFORM=wayland

# X11
export QT_QPA_PLATFORM=xcb
```

### 温度不更新
1. 检查 WebSocket 连接状态
2. 确认打印机固件状态
3. 查看控制台日志

## 📦 Orange Pi 部署

### 1. 安装依赖

```bash
sudo apt update
sudo apt install python3 python3-pip qt6-base-dev

pip3 install -r requirements.txt
```

### 2. 配置环境

```bash
# 设置显示后端
export QT_QPA_PLATFORM=wayland  # 或 xcb
```

### 3. 设置自动启动

创建 systemd 服务 `/etc/systemd/system/qtks.service`：

```ini
[Unit]
Description=QtKs 3D Printer Interface
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/QtKs
Environment="QT_QPA_PLATFORM=wayland"
ExecStart=/usr/bin/python3 /home/pi/QtKs/main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

启用服务：

```bash
sudo systemctl enable qtks
sudo systemctl start qtks
```

## 📝 开发日志



## 🗂️ 代码统计

```
QML 代码:    ~3200+ 行
Python 代码:  ~650 行
组件数量:     10+ 个
页面数量:     4 个
总完成度:     20%
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发规范
- 遵循 Metro 设计语言
- 添加详细的代码注释
- 测试所有功能后提交
- 保持代码风格一致

## 📄 许可证

MIT License

## 👤 作者

[cuihuir](https://github.com/cuihuir)

---

**⚡ 提示**: 在 Orange Pi 等嵌入式设备上运行时，建议设置分辨率为 800x480 以获得最佳性能。

**🔗 相关链接**:
- [Klipper 文档](https://www.klipper3d.org/)
- [Moonraker API](https://moonraker.readthedocs.io/)
- [PySide6 文档](https://doc.qt.io/qtforpython/)
