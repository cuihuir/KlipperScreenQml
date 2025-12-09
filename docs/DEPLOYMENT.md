# QtKs 部署文档

本文档详细说明如何在 Orange Pi、Raspberry Pi 等嵌入式设备上部署 QtKs 3D 打印机界面。

> **⚠️ 重要提示**: 自动化安装脚本（`install.sh`, `setup-autostart.sh`）尚未在实际环境中完整验证。
> 建议首次部署时使用手动安装方法，验证通过后再使用自动化脚本。
> 验证状态请查看项目根目录的 `CLAUDE.md` 文件。

## 目录

- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [手动安装](#手动安装)
- [开机自启动配置](#开机自启动配置)
- [故障排除](#故障排除)
- [性能优化](#性能优化)

## 系统要求

### 硬件要求

- **开发板**: Orange Pi 3B / CM4, Raspberry Pi 3/4/5 或其他 ARM/x86 单板计算机
- **内存**: 至少 512MB RAM（推荐 1GB+）
- **存储**: 至少 2GB 可用空间
- **显示**: 支持 HDMI/DSI 显示输出

### 软件要求

- **操作系统**: Debian 11+, Ubuntu 20.04+, Armbian
- **Python**: 3.8 或更高版本
- **Qt**: Qt 6.0+ (PySide6)
- **显示服务器**: X11 或 Wayland

## 快速开始

### 方法 1: 使用自动化安装脚本（推荐）

```bash
# 克隆项目
git clone https://github.com/your-repo/QtKs.git
cd QtKs

# 运行安装脚本
chmod +x install.sh
./install.sh
```

安装脚本会自动完成：

- ✅ 检测系统环境
- ✅ 安装所有依赖
- ✅ 创建 Python 虚拟环境
- ✅ 配置 systemd 服务
- ✅ 设置开机自启动

### 方法 2: 分步手动安装

参见 [手动安装](#手动安装) 章节。

## 手动安装

### 1. 安装系统依赖

#### Debian/Ubuntu/Armbian

```bash
sudo apt update

# 安装 Python 和 Qt 基础依赖
sudo apt install -y python3 python3-pip python3-venv qt6-base-dev

# 安装 Qt XCB 平台插件依赖（必需！）
sudo apt install -y \
    libxcb-cursor0 \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xfixes0

# 安装其他工具
sudo apt install -y git curl
```

> **⚠️ 重要**: `libxcb-cursor0` 是 Qt 6.5.0+ 的必需依赖。缺少此库会导致启动失败：
>
> ```
> [FATAL] This application failed to start because no Qt platform plugin could be initialized.
> ```

### 2. 克隆项目

```bash
git clone https://github.com/your-repo/QtKs.git
cd QtKs
```

### 3. 创建 Python 虚拟环境

```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 升级 pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt
```

### 4. 配置应用

```bash
# 复制配置文件模板
cp config.example.json config.json

# 编辑配置（修改打印机 IP 地址）
nano config.json
```

**config.json 示例**:

```json
{
  "printer": {
    "host": "192.168.1.100",
    "port": 7125,
    "name": "My 3D Printer"
  },
  "ui": {
    "width": 800,
    "height": 480,
    "fullscreen": true
  }
}
```

### 5. 测试运行

```bash
# 激活虚拟环境
source venv/bin/activate

# 选择合适的 Qt 平台并运行
export QT_QPA_PLATFORM=xcb  # 或 wayland / eglfs
python main.py
```

**平台选择说明**:

| 平台     | 适用场景                 | 要求             |
| -------- | ------------------------ | ---------------- |
| `xcb`    | X11 桌面环境（推荐）     | 已安装 X server  |
| `wayland`| Wayland 桌面环境         | 已安装 Wayland   |
| `eglfs`  | 无桌面环境，直接渲染     | 有显示硬件支持   |

## 开机自启动配置

### 方法 A: 使用配置脚本（推荐）

```bash
chmod +x setup-autostart.sh
./setup-autostart.sh
```

脚本会引导你完成：

1. 选择 Qt 平台（xcb/wayland/eglfs）
2. 生成 systemd 服务文件
3. 安装并启用服务
4. 可选：立即启动服务

### 方法 B: 手动配置 systemd 服务

#### 1. 创建服务文件

编辑 `/etc/systemd/system/qtks.service`:

```bash
sudo nano /etc/systemd/system/qtks.service
```

内容如下（**注意替换用户名和路径**）:

```ini
[Unit]
Description=QtKs 3D Printer Interface
After=network.target graphical.target
Wants=graphical.target

[Service]
Type=simple
User=orangepi
WorkingDirectory=/home/orangepi/QtKs
Environment="DISPLAY=:0"
Environment="QT_QPA_PLATFORM=xcb"
Environment="PATH=/home/orangepi/QtKs/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/orangepi/QtKs/venv/bin/python /home/orangepi/QtKs/main.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=graphical.target
```

**需要替换的内容**:

- `User=orangepi` → 实际的用户名
- `/home/orangepi/QtKs` → 实际的安装路径
- `QT_QPA_PLATFORM=xcb` → 根据需要选择平台

#### 2. 启用并启动服务

```bash
# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 启用开机自启动
sudo systemctl enable qtks.service

# 启动服务
sudo systemctl start qtks.service

# 查看状态
sudo systemctl status qtks.service
```

### 方法 C: 使用 .bashrc 自动启动（简单场景）

适合测试环境或个人开发环境。

编辑 `~/.bashrc`:

```bash
nano ~/.bashrc
```

在文件末尾添加:

```bash
# QtKs 自动启动
if [ -z "$QTKS_STARTED" ]; then
    export QTKS_STARTED=1
    export QT_QPA_PLATFORM=xcb
    cd ~/QtKs
    source venv/bin/activate
    python main.py
fi
```

## 故障排除

### 问题 1: Qt platform plugin "xcb" could not be initialized

**症状**:

```
[WARNING] From 6.5.0, xcb-cursor0 or libxcb-cursor0 is needed to load the Qt xcb platform plugin.
[FATAL] This application failed to start because no Qt platform plugin could be initialized.
```

**解决方案**:

```bash
# 安装缺失的依赖
sudo apt install libxcb-cursor0

# 检查依赖是否满足
ldd venv/lib/python3.*/site-packages/PySide6/Qt/plugins/platforms/libqxcb.so | grep "not found"
```

如果仍有缺失，安装完整的 XCB 依赖:

```bash
sudo apt install -y \
    libxcb-cursor0 libxcb-xinerama0 libxcb-icccm4 \
    libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
    libxcb-render-util0 libxcb-shape0 libxcb-xfixes0
```

### 问题 2: DISPLAY 环境变量未设置

**症状**:

```
qt.qpa.xcb: could not connect to display
```

**解决方案**:

```bash
# 检查 DISPLAY
echo $DISPLAY

# 设置 DISPLAY
export DISPLAY=:0

# 授权访问 X server
xhost +local:
```

在 systemd 服务中确保设置了 `Environment="DISPLAY=:0"`。

### 问题 3: systemd 服务启动失败

**排查步骤**:

```bash
# 查看详细日志
sudo journalctl -u qtks.service -n 50 --no-pager

# 检查文件权限
ls -la /home/orangepi/QtKs/main.py
ls -la /home/orangepi/QtKs/venv/bin/python

# 手动测试
sudo -u orangepi /home/orangepi/QtKs/venv/bin/python /home/orangepi/QtKs/main.py
```

常见原因:

- Python 虚拟环境路径错误
- 用户权限问题
- DISPLAY 环境变量未设置
- Qt 平台插件选择错误

### 问题 4: 无法连接打印机

**排查步骤**:

```bash
# 测试网络连通性
ping 192.168.1.100

# 测试 Moonraker API
curl http://192.168.1.100:7125/server/info

# 查看应用日志
tail -f qtks.log
```

确认 `config.json` 中的 IP 地址和端口正确。

### 问题 5: 性能问题 / 界面卡顿

**优化建议**:

1. **降低分辨率**:

   ```json
   {
     "ui": {
       "width": 800,
       "height": 480
     }
   }
   ```

2. **禁用日志** (编辑 `main.py`):

   ```python
   # 将 INFO 改为 WARNING
   logging.basicConfig(level=logging.WARNING)
   ```

3. **使用 EGLFS** (无桌面环境):

   ```bash
   export QT_QPA_PLATFORM=eglfs
   ```

4. **关闭不必要的系统服务**:

   ```bash
   sudo systemctl disable bluetooth.service
   sudo systemctl disable avahi-daemon.service
   ```

## 性能优化

### Orange Pi CM4 / 3B 优化建议

1. **设置 CPU 性能模式**:

   ```bash
   sudo apt install cpufrequtils
   sudo cpufreq-set -g performance
   ```

2. **禁用不必要的服务**:

   ```bash
   sudo systemctl disable bluetooth
   sudo systemctl disable cups
   sudo systemctl disable ModemManager
   ```

3. **增加 GPU 内存** (编辑 `/boot/config.txt` 或 `/boot/armbianEnv.txt`):

   ```
   gpu_mem=256
   ```

4. **使用轻量级桌面环境**:

   - LXDE
   - XFCE
   - 或直接使用 EGLFS 无桌面模式

### 应用层面优化

QtKs 已内置以下优化:

- ✅ 按需渲染（仅渲染当前页面）
- ✅ 温度节流（< 0.5°C 变化不更新）
- ✅ 进度限流（最多每秒更新一次）
- ✅ 日志节流（生产环境建议使用 WARNING 级别）

## 常用命令

### systemd 服务管理

```bash
# 启动服务
sudo systemctl start qtks.service

# 停止服务
sudo systemctl stop qtks.service

# 重启服务
sudo systemctl restart qtks.service

# 查看状态
sudo systemctl status qtks.service

# 查看实时日志
sudo journalctl -u qtks.service -f

# 查看最近 100 行日志
sudo journalctl -u qtks.service -n 100 --no-pager

# 启用开机自启动
sudo systemctl enable qtks.service

# 禁用开机自启动
sudo systemctl disable qtks.service
```

### 手动运行（调试）

```bash
cd ~/QtKs
source venv/bin/activate
export QT_QPA_PLATFORM=xcb
python main.py
```

### 更新代码

```bash
cd ~/QtKs
git pull
source venv/bin/activate
pip install -r requirements.txt --upgrade
sudo systemctl restart qtks.service
```

## 卸载

```bash
# 停止并禁用服务
sudo systemctl stop qtks.service
sudo systemctl disable qtks.service

# 删除服务文件
sudo rm /etc/systemd/system/qtks.service
sudo systemctl daemon-reload

# 删除项目目录
rm -rf ~/QtKs
```

## 附录

### A. 支持的 Qt 平台插件

| 插件      | 说明                           | 使用场景                       |
| --------- | ------------------------------ | ------------------------------ |
| xcb       | X11 协议                       | 标准 Linux 桌面环境            |
| wayland   | Wayland 协议                   | 现代 Linux 桌面环境            |
| eglfs     | 直接渲染到 OpenGL framebuffer  | 嵌入式设备，无桌面环境         |
| linuxfb   | Linux framebuffer              | 旧设备，无 GPU 加速            |
| minimal   | 最小化平台                     | 无 GUI 测试                    |

### B. 环境变量参考

| 变量                 | 说明                 | 示例值                |
| -------------------- | -------------------- | --------------------- |
| QT_QPA_PLATFORM      | Qt 平台插件          | xcb, wayland, eglfs   |
| DISPLAY              | X11 显示编号         | :0                    |
| QT_DEBUG_PLUGINS     | 调试插件加载         | 1                     |
| QT_QPA_FB_DRM        | DRM 设备（eglfs）    | /dev/dri/card0        |

### C. 配置文件示例

**完整 config.json**:

```json
{
  "printer": {
    "host": "192.168.1.100",
    "port": 7125,
    "name": "Voron 2.4",
    "reconnect_interval": 5
  },
  "ui": {
    "width": 800,
    "height": 480,
    "fullscreen": true,
    "theme": "metro"
  },
  "logging": {
    "level": "INFO",
    "file": "qtks.log",
    "max_size": 10485760
  }
}
```

---

**需要帮助?**

- 提交 Issue: https://github.com/your-repo/QtKs/issues
- 查看主 README: [README.md](../README.md)
