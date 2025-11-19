#!/bin/bash
# QtKs GUI 启动脚本 - 用于有显示环境的系统

echo "═══════════════════════════════════════════════════════"
echo "  QtKs - 3D 打印机 GUI 界面"
echo "═══════════════════════════════════════════════════════"
echo

# 检测显示环境
if [ -n "$DISPLAY" ]; then
    echo "✓ 检测到 X11 显示环境: $DISPLAY"
    export QT_QPA_PLATFORM=xcb
elif [ -n "$WAYLAND_DISPLAY" ]; then
    echo "✓ 检测到 Wayland 显示环境: $WAYLAND_DISPLAY"
    export QT_QPA_PLATFORM=wayland
else
    echo "✗ 未检测到显示环境"
    echo
    echo "请选择运行模式："
    echo "  1) 尝试使用 X11 (xcb)"
    echo "  2) 尝试使用 Wayland"
    echo "  3) Offscreen 模式（无 GUI，仅测试）"
    echo
    read -p "请输入选项 [1-3]: " choice

    case $choice in
        1)
            export QT_QPA_PLATFORM=xcb
            export DISPLAY=:0
            echo "设置为 X11 模式"
            ;;
        2)
            export QT_QPA_PLATFORM=wayland
            echo "设置为 Wayland 模式"
            ;;
        3)
            export QT_QPA_PLATFORM=offscreen
            echo "设置为 Offscreen 模式（无显示）"
            ;;
        *)
            echo "无效选项，使用默认 X11 模式"
            export QT_QPA_PLATFORM=xcb
            export DISPLAY=:0
            ;;
    esac
fi

echo
echo "显示平台: $QT_QPA_PLATFORM"
echo

# 设置环境变量
export QT_QUICK_CONTROLS_STYLE=Material
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# 检查依赖
echo "检查依赖..."
python3 -c "import PySide6" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "✗ PySide6 未安装"
    echo "请运行: pip install -r requirements.txt"
    exit 1
fi
echo "✓ 依赖检查通过"
echo

# 启动 GUI
echo "启动 QtKs GUI..."
echo "═══════════════════════════════════════════════════════"
echo

python3 main.py

# 捕获退出状态
EXIT_CODE=$?

echo
echo "═══════════════════════════════════════════════════════"
if [ $EXIT_CODE -eq 0 ]; then
    echo "  GUI 正常退出"
else
    echo "  GUI 异常退出 (代码: $EXIT_CODE)"
    echo
    echo "常见问题："
    echo "  - 如果提示找不到 Qt 平台插件，尝试安装:"
    echo "    sudo apt install libxcb-cursor0 或 xcb-cursor0"
    echo "  - 如果是 Wayland 环境，尝试:"
    echo "    export QT_QPA_PLATFORM=wayland"
    echo "  - 查看日志文件: qtks.log"
fi
echo "═══════════════════════════════════════════════════════"

exit $EXIT_CODE
