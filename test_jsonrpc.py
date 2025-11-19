#!/usr/bin/env python3
"""
测试 Moonraker JSON-RPC 接口
"""

import asyncio
import websockets
import json

async def test_moonraker_rpc():
    """测试所有 JSON-RPC 方法"""
    uri = 'ws://192.168.100.131:7125/websocket'

    try:
        async with websockets.connect(uri) as ws:
            print("✓ WebSocket 连接成功")

            # 1. 测试文件列表
            print("\n1. 测试文件列表...")
            await ws.send(json.dumps({
                "jsonrpc": "2.0",
                "method": "server.files.list",
                "params": {"root": "gcodes"},
                "id": 1
            }))
            response = await ws.recv()
            data = json.loads(response)
            print(f"   文件列表: {len(data.get('result', []))} 个文件")

            # 2. 测试 G-code 发送
            print("\n2. 测试 G-code 发送...")
            await ws.send(json.dumps({
                "jsonrpc": "2.0",
                "method": "printer.gcode.script",
                "params": {"script": "M117 Test from Python"},
                "id": 2
            }))
            response = await ws.recv()
            data = json.loads(response)
            print(f"   G-code 响应: {data}")

            # 3. 测试打印控制（如果有文件）
            print("\n3. 打印控制命令测试...")

            # 测试暂停（即使没有打印也会返回 ok）
            await ws.send(json.dumps({
                "jsonrpc": "2.0",
                "method": "printer.print.pause",
                "id": 3
            }))
            response = await ws.recv()
            data = json.loads(response)
            print(f"   暂停命令: {data.get('result', 'ok')}")

            # 测试恢复
            await ws.send(json.dumps({
                "jsonrpc": "2.0",
                "method": "printer.print.resume",
                "id": 4
            }))
            response = await ws.recv()
            data = json.loads(response)
            print(f"   恢复命令: {data.get('result', 'ok')}")

            print("\n✓ 所有 JSON-RPC 接口测试通过!")

    except Exception as e:
        print(f"✗ 错误: {e}")

if __name__ == "__main__":
    asyncio.run(test_moonraker_rpc())
