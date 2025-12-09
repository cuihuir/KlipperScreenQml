# QtKs 性能调优指南（高 CPU 占用问题）

如果在 Orange Pi 上运行时 CPU 占用率仍然很高（> 30%），请按以下步骤排查和优化。

## 🔍 问题诊断

### 1. 确认高 CPU 占用的原因

```bash
# 查看所有 Python 进程
ps aux | grep python | grep main.py

# 查看线程数
ps -eLf | grep python | grep main.py | wc -l

# 使用 htop 详细监控
htop -p $(pgrep -f "python.*main.py" | tr '\n' ',')
```

### 2. 使用性能监控脚本

```bash
./monitor-performance.sh
```

实时显示：
- CPU 占用率
- 内存占用
- 线程数量

---

## ⚡ 进一步优化措施

### 优化级别 1: 使用极致优化启动脚本

```bash
# 停止当前运行的实例
pkill -f "python.*main.py"

# 使用极致优化模式
./run-extreme.sh
```

**极致模式包含**:
- ✅ 禁用所有 Qt 日志输出
- ✅ Python -OO 优化模式
- ✅ 过滤所有警告信息
- ✅ 最小化图像内存分配
- ✅ 强制 QML 磁盘缓存

---

### 优化级别 2: 检查 WebSocket 连接

**问题**: 如果打印机未连接，WebSocket 会持续重连导致 CPU 占用

**解决方案**:
```bash
# 检查打印机是否在线
ping 192.168.1.100

# 测试 Moonraker 是否响应
curl http://192.168.1.100:7125/server/info
```

如果打印机离线，临时禁用自动重连：
1. 编辑 `config.json`
2. 注释掉或修改 `printer.host`
3. 重启应用

---

### 优化级别 3: 降低 WebSocket 刷新率

编辑 `backend/moonraker_client.py`，找到 `timeout` 参数：

```python
# 当前：1.0 秒 timeout
message = await asyncio.wait_for(websocket.recv(), timeout=1.0)

# 改为：2.0 秒（进一步降低 CPU）
message = await asyncio.wait_for(websocket.recv(), timeout=2.0)
```

---

### 优化级别 4: 禁用不必要的订阅

编辑 `backend/moonraker_client.py`，找到订阅对象列表，减少订阅项：

```python
# 当前订阅了大量对象
objects = {
    "webhooks": None,
    "print_stats": None,
    "virtual_sdcard": None,
    "display_status": None,
    # ... 更多对象
}

# 仅订阅关键对象
objects = {
    "webhooks": None,
    "print_stats": None,
    "heater_bed": None,
    "extruder": None
}
```

---

### 优化级别 5: 使用 EGLFS 而不是 XCB

XCB (X11) 需要 X Server，占用额外资源。如果不需要桌面环境，直接渲染到 framebuffer：

```bash
export QT_QPA_PLATFORM=eglfs
python main.py
```

或修改 `run-extreme.sh`:
```bash
export QT_QPA_PLATFORM=eglfs  # 替换 xcb
```

---

### 优化级别 6: 降低 QML 刷新率

编辑 `qml/pages/DashboardPage.qml` 等页面，增加定时器间隔：

```qml
// 温度刷新定时器
Timer {
    id: tempRefreshTimer
    interval: 2000  // 从 1000ms 改为 2000ms
    running: true
    repeat: true
    onTriggered: updateTemperature()
}
```

---

### 优化级别 7: 系统层面优化

#### a. 限制 CPU 频率（省电模式）
```bash
# 查看当前 CPU 频率
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# 设置为节能模式
sudo cpufreq-set -g powersave
```

#### b. 关闭图形合成（如果使用桌面环境）
```bash
# Xfce
xfconf-query -c xfwm4 -p /general/use_compositing -s false

# LXDE
# 编辑 ~/.config/openbox/lxde-rc.xml，禁用 compositor
```

#### c. 降低屏幕分辨率
编辑 `config.json`:
```json
{
  "ui": {
    "width": 800,
    "height": 480
  }
}
```

改为更低分辨率（如果可接受）:
```json
{
  "ui": {
    "width": 640,
    "height": 360
  }
}
```

---

## 📊 预期性能指标

### 正常范围（Orange Pi CM4 / 3B）

| 状态 | CPU 占用 | 内存占用 | 线程数 |
|------|----------|----------|--------|
| **空闲**（主页显示） | 5-15% | 250-300MB | 4-6 |
| **页面切换时** | 15-30% | 250-300MB | 4-6 |
| **FilesPage 加载** | 20-40% | 280-320MB | 4-6 |
| **打印中** | 8-18% | 260-310MB | 5-7 |

### 异常情况

如果出现以下情况，说明有问题：

- ❌ CPU 持续 > 50%
- ❌ 内存 > 400MB
- ❌ 线程数 > 10
- ❌ 多个 Python 进程（应该只有 1 个）

**排查步骤**:
1. 检查是否有僵尸进程：`ps aux | grep python | grep defunct`
2. 检查日志文件大小：`ls -lh qtks.log`（如果 > 100MB，清空它）
3. 检查 WebSocket 连接状态：查看日志中是否有频繁重连

---

## 🛠️ 调试工具

### 1. Python 性能分析

```bash
# 使用 cProfile 分析
python -m cProfile -o profile.stats main.py

# 分析结果（需要 snakeviz）
pip install snakeviz
snakeviz profile.stats
```

### 2. Qt 性能分析

```bash
# 启用 Qt 性能统计
export QSG_RENDER_TIMING=1
python main.py

# 查看渲染性能
export QSG_VISUALIZE=overdraw  # 显示过度绘制
python main.py
```

### 3. 实时 CPU 占用（按线程）

```bash
# 查看每个线程的 CPU 占用
top -H -p $(pgrep -f "python.*main.py")
```

---

## 🎯 终极优化方案

如果上述所有优化都无效，考虑：

### 1. 降级到更简单的 UI

创建一个精简版本：
- 移除动画
- 使用简单的 Rectangle 而不是复杂组件
- 减少 Layout 嵌套

### 2. 使用轻量级后端

将 WebSocket 改为定时 REST API 轮询（虽然实时性差，但 CPU 占用更低）：

```python
# 每 5 秒轮询一次状态，而不是保持 WebSocket 连接
QTimer.singleShot(5000, self.refreshStatus)
```

### 3. 硬件加速检查

确认 Orange Pi 的 GPU 驱动已安装：

```bash
# 检查 OpenGL
glxinfo | grep "OpenGL version"

# 检查 EGL
eglinfo

# 安装 Mali GPU 驱动（Orange Pi 3B/CM4 使用 Mali GPU）
sudo apt install mali-fbdev
```

---

## 📞 获取帮助

如果问题仍然存在，请提供以下信息：

```bash
# 1. 系统信息
uname -a
cat /etc/os-release

# 2. Python 版本
python3 --version

# 3. Qt 版本
python3 -c "from PySide6 import __version__; print(__version__)"

# 4. CPU 信息
lscpu

# 5. 性能监控输出（运行 1 分钟）
./monitor-performance.sh

# 6. 进程树
pstree -p $(pgrep -f "python.*main.py")

# 7. 日志最后 50 行
tail -50 qtks.log
```

将以上信息提交到 GitHub Issues。

---

**最后更新**: 2025-12-09
**适用版本**: QtKs v2.0+
