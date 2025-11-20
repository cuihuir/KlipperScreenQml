#!/usr/bin/env python3
"""
Moonraker WebSocket 客户端
支持同步和异步操作，优化性能
"""

import json
import logging
import asyncio
from typing import Dict, Optional, Callable
import websockets
import requests
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer, QThread


class MoonrakerClient(QObject):
    """Moonraker 客户端 - 负责与打印机通信"""

    # 信号定义
    printerConnected = Signal()
    printerDisconnected = Signal()
    connectionError = Signal(str)

    temperatureUpdated = Signal(dict)
    printerStateChanged = Signal(str)
    printProgressChanged = Signal(dict)
    printStatsUpdated = Signal(dict)  # 打印统计信息更新
    positionUpdated = Signal(dict)  # X, Y, Z 位置信息
    messageReceived = Signal(str, str)  # method, data
    fileListReceived = Signal(str)  # JSON string of file list
    fileMetadataReceived = Signal(str, str)  # filename, metadata JSON string

    # 错误和通知信号
    klipperError = Signal(str)  # Klipper错误消息 (用于全屏错误显示)
    notificationReceived = Signal(str, str)  # type, message (用于通知系统)

    def __init__(self, host="192.168.200.209", port=7125, parent=None):
        super().__init__(parent)

        self.host = host
        self.port = port
        self.base_url = f"http://{host}:{port}"
        self.ws_url = f"ws://{host}:{port}/websocket"

        self._is_connected = False
        self._websocket = None
        self._ws_thread = None
        self._loop = None
        self._req_id = 0

        # 数据缓存
        self._extruder_temp = 0.0
        self._extruder_target = 0.0
        self._bed_temp = 0.0
        self._bed_target = 0.0
        self._printer_state = "offline"
        self._print_progress = 0.0
        self._print_filename = ""
        self._error_message = ""  # Klipper错误消息

        # 打印统计信息
        self._print_duration = 0.0  # 打印时长（秒）
        self._filament_used = 0.0   # 耗材用量（mm）
        self._current_layer = 0     # 当前层
        self._total_layers = 0      # 总层数
        self._print_thumbnail = ""  # 缩略图 URL
        self._layer_height = 0.2    # 层高（mm）

        # Fluidd 算法数据
        self._live_velocity = 0.0          # 实时打印速度 (mm/s)
        self._live_extruder_velocity = 0.0 # 实时挤出机速度 (mm/s)
        self._filament_diameter = 1.75     # 耗材直径 (mm)
        self._file_progress = 0.0          # 文件进度 (0-1)
        self._estimated_time = 0.0         # 切片预估时间 (秒)
        self._first_layer_height = 0.2     # 首层高度 (mm)
        self._object_height = 0.0          # 对象高度 (mm) - 用于计算总层数
        self._total_duration = 0.0         # 总时长 (秒) - 包括暂停时间

        # 位置信息
        self._position_x = 0.0
        self._position_y = 0.0
        self._position_z = 0.0
        self._homed_axes = ""  # 已归零的轴: "xyz" 或 "xy" 等

        # 性能优化：进度更新节流
        self._last_progress_update_time = 0.0  # 上次进度更新时间戳

        self.logger = logging.getLogger(__name__)

        # 重连定时器
        self.reconnect_timer = QTimer()
        self.reconnect_timer.timeout.connect(self.connectPrinter)
        self.reconnect_timer.setSingleShot(True)

    # === 属性访问 ===
    @Property(bool, notify=printerConnected)
    def isConnected(self):
        return self._is_connected

    @Property(float, notify=temperatureUpdated)
    def extruderTemp(self):
        return self._extruder_temp

    @Property(float, notify=temperatureUpdated)
    def extruderTarget(self):
        return self._extruder_target

    @Property(float, notify=temperatureUpdated)
    def bedTemp(self):
        return self._bed_temp

    @Property(float, notify=temperatureUpdated)
    def bedTarget(self):
        return self._bed_target

    @Property(str, notify=printerStateChanged)
    def printerState(self):
        return self._printer_state

    @Property(float, notify=printProgressChanged)
    def printProgress(self):
        return self._print_progress

    @Property(str, notify=printProgressChanged)
    def printFilename(self):
        return self._print_filename

    @Property(float, notify=printStatsUpdated)
    def printDuration(self):
        """打印时长（秒）"""
        return self._print_duration

    @Property(float, notify=printStatsUpdated)
    def filamentUsed(self):
        """耗材用量（mm）"""
        return self._filament_used

    @Property(int, notify=printStatsUpdated)
    def currentLayer(self):
        """当前层 - 使用 Fluidd 算法"""
        # 优先使用 print_stats.info.current_layer（如果Klipper提供）
        # 否则计算：ceil((z - first_layer_height) / layer_height + 1)
        return self._current_layer

    @Property(int, notify=printStatsUpdated)
    def totalLayers(self):
        """总层数 - 使用 Fluidd 算法"""
        # 优先级：
        # 1. print_stats.info.total_layer
        # 2. file_metadata.layer_count
        # 3. 计算：ceil((object_height - first_layer_height) / layer_height + 1)
        return self._total_layers

    @Property(str, notify=printStatsUpdated)
    def printThumbnail(self):
        """缩略图 URL"""
        return self._print_thumbnail

    @Property(float, notify=printStatsUpdated)
    def liveVelocity(self):
        """实时打印速度 (mm/s)"""
        return self._live_velocity

    @Property(float, notify=printStatsUpdated)
    def liveFlow(self):
        """实时流量 (mm³/s) - Fluidd 算法"""
        import math
        return (math.pi / 4) * (self._filament_diameter ** 2) * self._live_extruder_velocity

    @Property(float, notify=printStatsUpdated)
    def fileTimeLeft(self):
        """文件估算剩余时间 (秒)"""
        if self._print_duration > 0 and self._file_progress > 0:
            return (self._print_duration / self._file_progress) - self._print_duration
        return 0.0

    @Property(float, notify=printStatsUpdated)
    def slicerTimeLeft(self):
        """切片估算剩余时间 (秒)"""
        if self._estimated_time > 0:
            return self._estimated_time - self._print_duration
        return 0.0

    @Property(float, notify=printStatsUpdated)
    def etaTimestamp(self):
        """预计完成时间戳 (毫秒)"""
        import time
        time_left = self.fileTimeLeft if self.fileTimeLeft > 0 else self.slicerTimeLeft
        if time_left > 0:
            return (time.time() + time_left) * 1000
        return 0.0

    @Property(str, notify=klipperError)
    def errorMessage(self):
        return self._error_message

    @Property(str, constant=True)
    def apiHost(self):
        """返回 Moonraker API 主机地址"""
        return self.host

    @Property(int, constant=True)
    def apiPort(self):
        """返回 Moonraker API 端口"""
        return self.port

    @Property(float, notify=positionUpdated)
    def positionX(self):
        return self._position_x

    @Property(float, notify=positionUpdated)
    def positionY(self):
        return self._position_y

    @Property(float, notify=positionUpdated)
    def positionZ(self):
        return self._position_z

    @Property(str, notify=positionUpdated)
    def homedAxes(self):
        return self._homed_axes

    # === REST API 同步调用（用于初始化和非关键操作）===
    @Slot(result=bool)
    def testConnection(self):
        """测试连接"""
        try:
            response = requests.get(f"{self.base_url}/server/info", timeout=3)
            if response.status_code == 200:
                data = response.json()
                version = data.get('result', {}).get('klippy_state', 'unknown')
                self.logger.info(f"连接成功: {version}")
                return True
            return False
        except Exception as e:
            self.logger.error(f"连接测试失败: {e}")
            return False

    @Slot(result=dict)
    def getStatus(self):
        """同步获取打印机状态"""
        try:
            url = f"{self.base_url}/printer/objects/query?extruder&heater_bed&print_stats&webhooks&toolhead&gcode_move&virtual_sdcard"
            response = requests.get(url, timeout=3)
            if response.status_code == 200:
                data = response.json()
                status = data.get('result', {}).get('status', {})
                self.logger.info(f"获取到初始状态: print_stats={status.get('print_stats', {})}")
                self.logger.info(f"初始状态: virtual_sdcard={status.get('virtual_sdcard', {})}")
                self._update_from_status(status)
                return status
        except Exception as e:
            self.logger.error(f"获取状态失败: {e}")
        return {}

    @Slot(str, int)
    def setExtruderTemp(self, heater: str, temp: int):
        """设置挤出机温度"""
        try:
            gcode = f"M104 S{temp}"
            self._send_gcode(gcode)
            self.logger.info(f"设置挤出机温度: {temp}°C")
        except Exception as e:
            self.logger.error(f"设置温度失败: {e}")

    @Slot(int)
    def setBedTemp(self, temp: int):
        """设置热床温度"""
        try:
            gcode = f"M140 S{temp}"
            self._send_gcode(gcode)
            self.logger.info(f"设置热床温度: {temp}°C")
        except Exception as e:
            self.logger.error(f"设置温度失败: {e}")

    @Slot()
    def pausePrint(self):
        """暂停打印 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "printer.print.pause",
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info("发送暂停打印命令")
        except Exception as e:
            self.logger.error(f"暂停失败: {e}")

    @Slot()
    def resumePrint(self):
        """恢复打印 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "printer.print.resume",
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info("发送恢复打印命令")
        except Exception as e:
            self.logger.error(f"恢复失败: {e}")

    @Slot()
    def cancelPrint(self):
        """取消打印 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "printer.print.cancel",
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info("发送取消打印命令")
        except Exception as e:
            self.logger.error(f"取消失败: {e}")

    @Slot(str)
    def startPrint(self, filename: str):
        """开始打印 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "printer.print.start",
                "params": {
                    "filename": filename
                },
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info(f"发送开始打印命令: {filename}")
        except Exception as e:
            self.logger.error(f"开始打印失败: {e}")

    @Slot()
    def emergencyStop(self):
        """紧急停止 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "printer.emergency_stop",
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.warning("发送紧急停止命令!")
        except Exception as e:
            self.logger.error(f"紧急停止失败: {e}")

    def _send_gcode(self, gcode: str):
        """发送G代码 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return False

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "printer.gcode.script",
                "params": {
                    "script": gcode
                },
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            return True
        except Exception as e:
            self.logger.error(f"G代码发送失败: {e}")
            return False

    @Slot(str)
    def sendGcode(self, gcode: str):
        """暴露给 QML 的 G-code 发送方法"""
        self._send_gcode(gcode)

    @Slot()
    def requestFileList(self):
        """请求文件列表 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接，无法请求文件列表")
            return

        try:
            req_id = self._get_next_id()
            message = {
                "jsonrpc": "2.0",
                "method": "server.files.list",
                "params": {
                    "root": "gcodes"
                },
                "id": req_id
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info(f"已发送文件列表请求 (id={req_id})")
        except Exception as e:
            self.logger.error(f"请求文件列表失败: {e}")

    @Slot(str)
    def deleteFile(self, filename: str):
        """删除文件 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            message = {
                "jsonrpc": "2.0",
                "method": "server.files.delete_file",
                "params": {
                    "path": f"gcodes/{filename}"
                },
                "id": self._get_next_id()
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info(f"发送删除文件命令: {filename}")
            self.notificationReceived.emit("info", f"Deleted: {filename}")
        except Exception as e:
            self.logger.error(f"删除文件失败: {e}")
            self.notificationReceived.emit("error", f"Delete failed: {e}")

    @Slot(str)
    def requestFileMetadata(self, filename: str):
        """请求文件元数据 (通过 WebSocket JSON-RPC)"""
        if not self._ws_thread:
            self.logger.error("WebSocket 未连接")
            return

        try:
            req_id = self._get_next_id()
            message = {
                "jsonrpc": "2.0",
                "method": "server.files.metadata",
                "params": {
                    "filename": filename
                },
                "id": req_id
            }
            self._ws_thread.send_message(json.dumps(message))
            self.logger.info(f"请求文件元数据: {filename} (id={req_id})")
        except Exception as e:
            self.logger.error(f"请求元数据失败: {e}")

    @Slot()
    def clearError(self):
        """清除错误消息 (用户点击了解错误后)"""
        self._error_message = ""
        self.klipperError.emit("")

    @Slot()
    def restartKlipper(self):
        """重启 Klipper 固件"""
        self.sendGcode("RESTART")
        self.notificationReceived.emit("info", "Restarting Klipper...")

    @Slot()
    def firmwareRestart(self):
        """固件重启 (更彻底的重启)"""
        self.sendGcode("FIRMWARE_RESTART")
        self.notificationReceived.emit("info", "Firmware restarting...")

    # === WebSocket 连接管理 ===
    @Slot()
    def connectPrinter(self):
        """连接到 Moonraker WebSocket"""
        if self._is_connected:
            self.logger.info("已经连接")
            return

        self.logger.info(f"连接到 {self.ws_url}...")

        # 启动 WebSocket 线程
        self._ws_thread = WebSocketThread(self.ws_url, self)
        self._ws_thread.messageReceived.connect(self._on_ws_message)
        self._ws_thread.connectionEstablished.connect(self._on_ws_connected)
        self._ws_thread.connectionLost.connect(self._on_ws_disconnected)
        self._ws_thread.connectionError.connect(self._on_ws_connection_error)
        self._ws_thread.start()

    @Slot()
    def disconnectPrinter(self):
        """断开连接"""
        if self._ws_thread:
            self._ws_thread.stop()
            self._ws_thread.wait()
            self._ws_thread = None
        self._is_connected = False

    def _on_ws_connected(self):
        """WebSocket 连接成功"""
        self._is_connected = True
        self.printerConnected.emit()
        self.logger.info("WebSocket 已连接")

        # 订阅状态更新
        self._subscribe_status()

        # 初始获取状态
        self.logger.info("正在获取初始打印机状态...")
        self.getStatus()

    def _on_ws_disconnected(self):
        """WebSocket 断开"""
        was_connected = self._is_connected
        self._is_connected = False

        if was_connected:
            self.printerDisconnected.emit()
            self.logger.warning("WebSocket 已断开")

            # 5秒后重连
            self.reconnect_timer.start(5000)

    def _on_ws_connection_error(self, error_msg: str):
        """WebSocket 连接错误（限流后的通知）"""
        self.logger.warning(f"显示连接错误通知: {error_msg}")
        self.notificationReceived.emit("error", f"Printer connection error: {error_msg}")

    def _on_ws_message(self, message: str):
        """处理 WebSocket 消息"""
        try:
            data = json.loads(message)

            # 处理 JSON-RPC 响应
            if 'result' in data:
                # 这是一个 RPC 响应
                result = data['result']
                req_id = data.get('id')

                # 判断是文件列表响应 (result 是数组)
                if isinstance(result, list):
                    # 空数组或包含文件的数组都发送信号
                    self.logger.info(f"收到文件列表: {len(result)} 个文件")
                    self.fileListReceived.emit(json.dumps(result))
                    return

                # 判断是元数据响应 (result 包含 filename, thumbnails 等字段)
                if isinstance(result, dict) and 'filename' in result:
                    filename = result['filename']
                    self.logger.info(f"收到文件元数据: {filename}")
                    self.logger.info(f"元数据包含的键: {result.keys()}")
                    if 'thumbnails' in result:
                        self.logger.info(f"缩略图数量: {len(result['thumbnails'])}")
                        for i, thumb in enumerate(result['thumbnails']):
                            self.logger.info(f"  缩略图 {i}: {thumb}")
                    else:
                        self.logger.warning(f"元数据中没有 thumbnails 字段")
                    self.fileMetadataReceived.emit(filename, json.dumps(result))
                    return

                # 其他 RPC 响应，记录日志
                self.logger.debug(f"RPC 响应 (id={req_id}): {result}")
                return

            # 处理通知消息
            method = data.get('method', '')

            if method == 'notify_status_update':
                # 状态更新
                params = data.get('params', [])
                if params and len(params) > 0:
                    status = params[0]
                    self._update_from_status(status)

            elif method == 'notify_klippy_ready':
                self._printer_state = "ready"
                self.printerStateChanged.emit("ready")

            elif method == 'notify_klippy_disconnected':
                self._printer_state = "disconnected"
                self.printerStateChanged.emit("disconnected")

            elif method == 'notify_klippy_shutdown':
                self._printer_state = "shutdown"
                self.printerStateChanged.emit("shutdown")

            elif method == 'notify_gcode_response':
                # G-code响应消息 (可能包含错误)
                params = data.get('params', [])
                if params:
                    response_text = '\n'.join(params) if isinstance(params, list) else str(params)
                    # 检查是否是错误消息
                    if any(keyword in response_text.lower() for keyword in ['error', 'unknown', 'halt', 'shutdown']):
                        self.logger.warning(f"G-code错误响应: {response_text}")
                        self._error_message = response_text
                        self.klipperError.emit(response_text)
                    # 过滤掉温度报告（M105响应，格式如 "B:45.7 /35.0 T0:220.4 /220.0"）
                    elif not (response_text.startswith('B:') or response_text.startswith('T0:') or response_text.startswith('T1:')):
                        # 只发送有意义的消息作为通知
                        self.notificationReceived.emit("info", response_text)

            # 发出通用消息信号
            if method:
                self.messageReceived.emit(method, json.dumps(data))

        except Exception as e:
            self.logger.error(f"消息处理错误: {e}")

    def _subscribe_status(self):
        """订阅状态更新"""
        if not self._ws_thread:
            return

        subscribe_msg = {
            "jsonrpc": "2.0",
            "method": "printer.objects.subscribe",
            "params": {
                "objects": {
                    "extruder": ["temperature", "target", "power"],
                    "heater_bed": ["temperature", "target", "power"],
                    "print_stats": ["state", "filename", "print_duration", "filament_used", "total_duration", "info"],
                    "virtual_sdcard": ["progress", "file_position"],
                    "webhooks": ["state", "state_message"],
                    "toolhead": ["position", "homed_axes"],
                    "gcode_move": ["gcode_position", "speed", "speed_factor"],
                    "display_status": ["progress", "message"],
                    "motion_report": ["live_velocity", "live_extruder_velocity"],
                }
            },
            "id": self._get_next_id()
        }

        self._ws_thread.send_message(json.dumps(subscribe_msg))

    def _update_from_status(self, status: dict):
        """从状态数据更新本地缓存"""
        updated = False

        # 挤出机温度 - 性能优化：只有变化 >= 0.5°C 才更新
        if 'extruder' in status:
            ext = status['extruder']
            if 'temperature' in ext:
                new_temp = round(ext['temperature'], 1)
                if abs(new_temp - self._extruder_temp) >= 0.5:
                    self._extruder_temp = new_temp
                    updated = True
            if 'target' in ext:
                new_target = round(ext['target'], 1)
                if new_target != self._extruder_target:
                    self._extruder_target = new_target
                    updated = True

        # 热床温度 - 性能优化：只有变化 >= 0.5°C 才更新
        if 'heater_bed' in status:
            bed = status['heater_bed']
            if 'temperature' in bed:
                new_temp = round(bed['temperature'], 1)
                if abs(new_temp - self._bed_temp) >= 0.5:
                    self._bed_temp = new_temp
                    updated = True
            if 'target' in bed:
                new_target = round(bed['target'], 1)
                if new_target != self._bed_target:
                    self._bed_target = new_target
                    updated = True

        if updated:
            temps = {
                'extruder_temp': self._extruder_temp,
                'extruder_target': self._extruder_target,
                'bed_temp': self._bed_temp,
                'bed_target': self._bed_target,
            }
            self.temperatureUpdated.emit(temps)

        # 打印状态和统计信息
        stats_updated = False
        if 'print_stats' in status:
            ps = status['print_stats']
            if 'state' in ps:
                self._printer_state = ps['state']
                self.logger.info(f"更新打印状态: {ps['state']}")
                self.printerStateChanged.emit(ps['state'])
            if 'filename' in ps:
                self._print_filename = ps['filename']
                self.logger.info(f"当前打印文件: {ps['filename']}")

            # 打印时长和耗材
            if 'print_duration' in ps:
                self._print_duration = ps['print_duration']
                stats_updated = True
            if 'filament_used' in ps:
                self._filament_used = ps['filament_used']
                stats_updated = True
            if 'total_duration' in ps:
                self._total_duration = ps['total_duration']
                stats_updated = True

            # Fluidd 算法：优先使用 Klipper 提供的层数
            if 'info' in ps and ps['info']:
                info = ps['info']
                if 'total_layer' in info and info['total_layer'] is not None:
                    self._total_layers = info['total_layer']
                    stats_updated = True
                if 'current_layer' in info and info['current_layer'] is not None:
                    self._current_layer = info['current_layer']
                    stats_updated = True

        # 打印进度 - 性能优化：限制更新频率为 1 秒一次
        if 'virtual_sdcard' in status:
            vsd = status['virtual_sdcard']
            if 'progress' in vsd:
                import time
                current_time = time.time()
                new_progress = round(vsd['progress'] * 100, 1)

                # 存储原始进度用于 Fluidd 算法计算
                self._file_progress = vsd['progress']

                # 只在进度变化且距离上次更新超过 1 秒时才更新
                if (new_progress != self._print_progress and
                    current_time - self._last_progress_update_time >= 1.0):
                    self._print_progress = new_progress
                    self._last_progress_update_time = current_time
                    progress_data = {
                        'progress': self._print_progress,
                        'filename': self._print_filename
                    }
                    self.printProgressChanged.emit(progress_data)
                    stats_updated = True  # 进度变化时更新统计

        # Webhooks 状态（仅在没有 print_stats 或状态为 error/shutdown 时使用）
        if 'webhooks' in status:
            wh = status['webhooks']
            # 检查错误消息
            if 'state_message' in wh and wh['state_message']:
                msg = wh['state_message']
                # 如果状态是error或shutdown，发送错误信号并更新状态
                if wh.get('state') in ['error', 'shutdown']:
                    self._error_message = msg
                    self._printer_state = wh['state']
                    self.printerStateChanged.emit(wh['state'])
                    self.klipperError.emit(msg)
                    self.logger.error(f"Klipper错误: {msg}")
            # 只有在没有 print_stats 状态时，才使用 webhooks 状态（例如启动时）
            elif 'print_stats' not in status and 'state' in wh:
                self._printer_state = wh['state']
                self.logger.info(f"使用 webhooks 状态: {wh['state']}")
                self.printerStateChanged.emit(wh['state'])

        # 运动报告 (motion_report) - Fluidd 算法所需
        if 'motion_report' in status:
            mr = status['motion_report']
            if 'live_velocity' in mr:
                self._live_velocity = mr['live_velocity']
                stats_updated = True
            if 'live_extruder_velocity' in mr:
                self._live_extruder_velocity = mr['live_extruder_velocity']
                stats_updated = True

        # 位置信息 (从 gcode_move 获取) + Fluidd 层数计算
        position_updated = False
        if 'gcode_move' in status:
            gm = status['gcode_move']
            if 'gcode_position' in gm:
                pos = gm['gcode_position']
                if len(pos) >= 3:
                    self._position_x = round(pos[0], 2)
                    self._position_y = round(pos[1], 2)
                    new_z = round(pos[2], 2)

                    # Fluidd 算法：计算当前层（如果 Klipper 未提供）
                    # 只在打印中且 Z 变化时计算
                    if (self._printer_state == "printing" and
                        new_z != self._position_z and
                        self._print_duration > 0 and
                        self._layer_height > 0 and
                        self._first_layer_height > 0):

                        import math
                        # Fluidd 公式: ceil((z - first_layer_height) / layer_height + 1)
                        calculated_layer = math.ceil(
                            (new_z - self._first_layer_height) / self._layer_height + 1
                        )

                        if calculated_layer > 0:
                            self._current_layer = calculated_layer
                            stats_updated = True

                    self._position_z = new_z
                    position_updated = True

        # 归零状态 (从 toolhead 获取)
        if 'toolhead' in status:
            th = status['toolhead']
            if 'homed_axes' in th:
                self._homed_axes = th['homed_axes']
                position_updated = True

        # 发送位置更新信号
        if position_updated:
            position_data = {
                'x': self._position_x,
                'y': self._position_y,
                'z': self._position_z,
                'homed_axes': self._homed_axes
            }
            self.positionUpdated.emit(position_data)

        # 发送打印统计更新信号
        if stats_updated:
            stats_data = {
                'duration': self._print_duration,
                'filament': self._filament_used,
                'current_layer': self._current_layer,
                'total_layers': self._total_layers
            }
            self.printStatsUpdated.emit(stats_data)

    def _get_next_id(self):
        """获取下一个请求ID"""
        self._req_id += 1
        return self._req_id


class WebSocketThread(QThread):
    """WebSocket 通信线程"""

    messageReceived = Signal(str)
    connectionEstablished = Signal()
    connectionLost = Signal()
    connectionError = Signal(str)  # 连接错误信号，传递错误消息

    def __init__(self, url: str, parent=None):
        super().__init__(parent)
        self.url = url
        self._running = True
        self._websocket = None
        self._send_queue = []
        self._loop = None
        self.logger = logging.getLogger(__name__)
        self._last_error_time = 0  # 上次错误通知时间

    def run(self):
        """运行 WebSocket 事件循环"""
        try:
            # 创建新的事件循环
            self._loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self._loop)
            self._loop.run_until_complete(self._run_websocket())
        except Exception as e:
            self.logger.error(f"WebSocket 线程错误: {e}")
        finally:
            if self._loop:
                self._loop.close()

    async def _run_websocket(self):
        """WebSocket 主循环"""
        while self._running:
            try:
                async with websockets.connect(self.url) as websocket:
                    self._websocket = websocket
                    self.connectionEstablished.emit()
                    self.logger.info("WebSocket 连接建立")

                    # 接收消息循环
                    while self._running:
                        try:
                            # 非阻塞接收
                            message = await asyncio.wait_for(websocket.recv(), timeout=0.1)
                            self.messageReceived.emit(message)
                        except asyncio.TimeoutError:
                            # 检查是否有待发送消息
                            if self._send_queue:
                                msg = self._send_queue.pop(0)
                                await websocket.send(msg)
                        except Exception as e:
                            self.logger.error(f"消息处理错误: {e}")
                            break

            except websockets.exceptions.WebSocketException as e:
                self.logger.error(f"WebSocket 错误: {e}")
                self.connectionLost.emit()
                self._emit_error_if_needed(f"WebSocket error: {e}")
                if self._running:
                    await asyncio.sleep(5)
            except Exception as e:
                self.logger.error(f"连接错误: {e}")
                self.connectionLost.emit()
                self._emit_error_if_needed(f"Connection failed: {e}")
                if self._running:
                    await asyncio.sleep(5)

    def _emit_error_if_needed(self, error_msg: str):
        """限流发送错误通知：每30秒最多一次"""
        import time
        current_time = time.time()
        if current_time - self._last_error_time >= 30:
            self._last_error_time = current_time
            self.connectionError.emit(error_msg)

    def send_message(self, message: str):
        """添加消息到发送队列"""
        self._send_queue.append(message)

    def stop(self):
        """停止线程"""
        self._running = False
        if self._websocket:
            try:
                if self._loop and self._loop.is_running():
                    asyncio.run_coroutine_threadsafe(self._websocket.close(), self._loop)
            except:
                pass
