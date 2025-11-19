#!/usr/bin/env python3
"""
测试 Moonraker 连接和温度控制
"""

import sys
import logging
import time
from backend.moonraker_client import MoonrakerClient
from PySide6.QtCore import QCoreApplication, QTimer

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def test_moonraker():
    """测试 Moonraker 客户端"""
    app = QCoreApplication(sys.argv)

    logger.info("=== Moonraker 连接测试 ===")

    # 创建客户端
    client = MoonrakerClient(host="192.168.200.209", port=7125)

    # 连接信号
    def on_connected():
        logger.info("✓ WebSocket 已连接")

    def on_disconnected():
        logger.warning("✗ WebSocket 已断开")

    def on_temp_update(temps):
        logger.info(f"温度更新: 挤出机={temps['extruder_temp']:.1f}°C (目标={temps['extruder_target']:.1f}°C), "
                   f"热床={temps['bed_temp']:.1f}°C (目标={temps['bed_target']:.1f}°C)")

    def on_state_change(state):
        logger.info(f"状态变化: {state}")

    client.connected.connect(on_connected)
    client.disconnected.connect(on_disconnected)
    client.temperatureUpdated.connect(on_temp_update)
    client.printerStateChanged.connect(on_state_change)

    # 1. 测试 REST 连接
    logger.info("\n1. 测试 REST API 连接...")
    if client.testConnection():
        logger.info("✓ REST API 连接成功")
    else:
        logger.error("✗ REST API 连接失败")
        return 1

    # 2. 获取初始状态
    logger.info("\n2. 获取打印机状态...")
    status = client.getStatus()
    if status:
        logger.info("✓ 状态获取成功")
        logger.info(f"  挤出机温度: {client.extruderTemp:.1f}°C / {client.extruderTarget:.1f}°C")
        logger.info(f"  热床温度: {client.bedTemp:.1f}°C / {client.bedTarget:.1f}°C")
        logger.info(f"  打印机状态: {client.printerState}")
    else:
        logger.error("✗ 状态获取失败")

    # 3. 连接 WebSocket
    logger.info("\n3. 连接 WebSocket...")
    client.connect()

    # 4. 等待连接并测试温度设置
    def test_temperature():
        logger.info("\n4. 测试温度设置...")
        logger.info("设置挤出机温度到 200°C...")
        client.setExtruderTemp("extruder", 200)

        # 等待2秒
        QTimer.singleShot(2000, lambda: set_bed_temp())

    def set_bed_temp():
        logger.info("设置热床温度到 60°C...")
        client.setBedTemp(60)

        # 等待3秒后关闭温度
        QTimer.singleShot(3000, lambda: turn_off_heaters())

    def turn_off_heaters():
        logger.info("\n5. 关闭所有加热器...")
        client.setExtruderTemp("extruder", 0)
        client.setBedTemp(0)

        # 等待2秒后退出
        QTimer.singleShot(2000, lambda: finish_test())

    def finish_test():
        logger.info("\n=== 测试完成 ===")
        client.disconnect()
        QTimer.singleShot(1000, app.quit)

    # 连接成功后开始测试温度
    QTimer.singleShot(3000, test_temperature)

    # 30秒后超时退出
    QTimer.singleShot(30000, app.quit)

    return app.exec()


if __name__ == "__main__":
    sys.exit(test_moonraker())
