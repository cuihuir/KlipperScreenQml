pragma Singleton
import QtQuick

QtObject {
    id: style

    // ============ 主题切换 ============
    property bool isDarkTheme: false  // false = 亮色主题, true = 暗色主题

    // ============ Metro 配色方案（机场指示牌风格） ============

    // 背景色（根据主题动态切换）
    readonly property color bgPrimary: isDarkTheme ? "#000000" : "#F5F5F5"        // 主背景
    readonly property color bgSecondary: isDarkTheme ? "#1a1a1a" : "#ECECEC"     // 次背景
    readonly property color bgCard: isDarkTheme ? "#242424" : "#FFFFFF"          // 卡片背景
    readonly property color bgInput: isDarkTheme ? "#1a1a1a" : "#FFFFFF"         // 输入框背景

    // 分隔线
    readonly property color divider: isDarkTheme ? "#333333" : "#E0E0E0"         // 分隔线
    readonly property color border: isDarkTheme ? "#404040" : "#BDBDBD"          // 边框

    // 文字颜色（根据主题动态切换）
    readonly property color textPrimary: isDarkTheme ? "#FFFFFF" : "#212121"     // 主文字
    readonly property color textSecondary: isDarkTheme ? "#999999" : "#757575"   // 次要文字
    readonly property color textDisabled: isDarkTheme ? "#666666" : "#BDBDBD"    // 禁用文字

    // 强调色（机场风 - 在亮色模式下调深）
    readonly property color accent: isDarkTheme ? "#FFEB3B" : "#F9A825"          // 主强调色-黄
    readonly property color accentDim: isDarkTheme ? "#FBC02D" : "#F57F17"       // 暗黄

    // 状态色（亮色模式下使用更柔和的颜色）
    readonly property color success: isDarkTheme ? "#00FF00" : "#4CAF50"         // 成功-绿
    readonly property color warning: isDarkTheme ? "#FF9800" : "#FF6F00"         // 警告-橙
    readonly property color error: isDarkTheme ? "#FF0000" : "#D32F2F"           // 错误-红
    readonly property color info: isDarkTheme ? "#00BCD4" : "#0097A7"            // 信息-青

    // 连接状态
    readonly property color connected: isDarkTheme ? "#00FF00" : "#4CAF50"       // 已连接-绿
    readonly property color disconnected: isDarkTheme ? "#FF0000" : "#D32F2F"    // 未连接-红

    // ============ 自适应尺寸系统 ============

    // 基础单位（根据窗口尺寸动态计算）
    property real windowWidth: 1920
    property real windowHeight: 1080

    function updateWindowSize(w, h) {
        windowWidth = w
        windowHeight = h
    }

    // 基础单位
    readonly property real baseUnit: Math.min(windowWidth, windowHeight) / 50

    // 字体大小
    readonly property real fontXXLarge: baseUnit * 4.5  // 超超大（主要数字）
    readonly property real fontXLarge: baseUnit * 3.5   // 超大标题
    readonly property real fontLarge: baseUnit * 2.5    // 大标题
    readonly property real fontMedium: baseUnit * 1.8   // 中标题
    readonly property real fontNormal: baseUnit * 1.2   // 正文
    readonly property real fontSmall: baseUnit * 0.9    // 小字
    readonly property real fontXSmall: baseUnit * 0.7   // 超小字

    // 间距
    readonly property real spacingXLarge: baseUnit * 2.5
    readonly property real spacingLarge: baseUnit * 2
    readonly property real spacingMedium: baseUnit * 1.5
    readonly property real spacingNormal: baseUnit * 1
    readonly property real spacingSmall: baseUnit * 0.6
    readonly property real spacingXSmall: baseUnit * 0.3

    // 组件尺寸
    readonly property real buttonHeightLarge: baseUnit * 5    // 主要操作按钮(打印/删除/确认)
    readonly property real buttonHeight: baseUnit * 4.5       // 常用功能按钮(暂停/温度/刷新)
    readonly property real buttonHeightSmall: baseUnit * 3.5  // 辅助按钮
    readonly property real iconSize: baseUnit * 2.5
    readonly property real iconSizeSmall: baseUnit * 1.5

    // 圆角（Metro风格：极小或无）
    readonly property real radiusNone: 0
    readonly property real radiusTiny: 2
    readonly property real radiusSmall: 4

    // 边框宽度
    readonly property real borderThin: 1
    readonly property real borderMedium: 2
    readonly property real borderThick: 3

    // ============ 字体族 ============

    readonly property string fontFamily: "sans-serif"
    readonly property string fontFamilyMono: "monospace"  // 数字使用等宽字体

    // ============ 动画时长 ============

    readonly property int durationFast: 150
    readonly property int durationNormal: 250
    readonly property int durationSlow: 400

    // ============ 工具函数 ============

    /**
     * 根据打印机状态获取颜色
     * @param state - 打印机状态字符串
     * @return 状态对应的颜色
     */
    function getStateColor(state) {
        switch(state) {
            case "ready": return success
            case "printing": return info
            case "paused": return warning
            case "error": return error
            case "shutdown": return error
            default: return textDisabled
        }
    }

    /**
     * 根据温度获取颜色（温度越高颜色越危险）
     * @param temp - 当前温度
     * @param threshold - 警告阈值
     * @return 温度对应的颜色
     */
    function getTempColor(temp, threshold) {
        if (temp > threshold) return error
        else if (temp > threshold * 0.8) return warning
        else return accent
    }

    /**
     * 根据进度百分比获取颜色
     * @param progress - 进度值 (0-100)
     * @return 进度对应的颜色
     */
    function getProgressColor(progress) {
        if (progress >= 100) return success
        else if (progress >= 75) return info
        else if (progress >= 50) return accent
        else return textSecondary
    }

    /**
     * 格式化文件大小
     * @param bytes - 字节数
     * @return 格式化的文件大小字符串
     */
    function formatFileSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        else if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        else if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + " MB"
        else return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
    }

    /**
     * 格式化时间（秒转为HH:MM:SS）
     * @param seconds - 秒数
     * @return 格式化的时间字符串
     */
    function formatTime(seconds) {
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = Math.floor(seconds % 60)
        return (h < 10 ? "0" + h : h) + ":" +
               (m < 10 ? "0" + m : m) + ":" +
               (s < 10 ? "0" + s : s)
    }

    /**
     * 格式化百分比
     * @param value - 数值 (0-1)
     * @return 格式化的百分比字符串
     */
    function formatPercentage(value) {
        return (value * 100).toFixed(1) + "%"
    }

    /**
     * 限制数值范围
     * @param value - 输入值
     * @param min - 最小值
     * @param max - 最大值
     * @return 限制后的值
     */
    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value))
    }

    /**
     * 线性插值
     * @param from - 起始值
     * @param to - 结束值
     * @param t - 插值因子 (0-1)
     * @return 插值结果
     */
    function lerp(from, to, t) {
        return from + (to - from) * clamp(t, 0, 1)
    }

    /**
     * 判断颜色是否为深色
     * @param color - 颜色对象
     * @return 是否为深色
     */
    function isDarkColor(color) {
        var r = color.r * 255
        var g = color.g * 255
        var b = color.b * 255
        var brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness < 128
    }
}
