pragma Singleton
import QtQuick

/**
 * API 客户端单例
 * 封装所有 Moonraker API 调用，统一错误处理
 */
QtObject {
    id: apiClient

    // 配置
    property string baseUrl: "http://192.168.200.209:7125"

    // 信号
    signal error(string message)

    /**
     * 发送 G-code 命令
     * @param gcode - G-code 字符串
     * @param callback - 成功回调函数
     * @param errorCallback - 错误回调函数（可选）
     */
    function sendGcode(gcode, callback, errorCallback) {
        var xhr = new XMLHttpRequest()
        var url = baseUrl + "/printer/gcode/script"

        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("[API] G-code sent successfully:", gcode)
                    if (callback) callback(JSON.parse(xhr.responseText))
                } else {
                    console.error("[API] G-code failed:", xhr.status)
                    var errorMsg = "G-code command failed (HTTP " + xhr.status + ")"
                    error(errorMsg)
                    if (errorCallback) errorCallback(errorMsg)
                }
            }
        }

        xhr.send(JSON.stringify({ script: gcode }))
    }

    /**
     * 获取文件列表
     * @param root - 根目录（默认 gcodes）
     * @param callback - 成功回调函数
     * @param errorCallback - 错误回调函数（可选）
     */
    function getFileList(root, callback, errorCallback) {
        root = root || "gcodes"
        var xhr = new XMLHttpRequest()
        var url = baseUrl + "/server/files/list?root=" + root

        xhr.open("GET", url, true)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        console.log("[API] File list loaded:", response.result.length, "files")
                        if (callback) callback(response.result)
                    } catch (e) {
                        console.error("[API] Failed to parse file list:", e)
                        var errorMsg = "Failed to parse file list"
                        error(errorMsg)
                        if (errorCallback) errorCallback(errorMsg)
                    }
                } else {
                    console.error("[API] Failed to load files:", xhr.status)
                    var errorMsg = "Failed to load files (HTTP " + xhr.status + ")"
                    error(errorMsg)
                    if (errorCallback) errorCallback(errorMsg)
                }
            }
        }

        xhr.send()
    }

    /**
     * 启动打印
     * @param filename - 文件名
     * @param callback - 成功回调函数
     * @param errorCallback - 错误回调函数（可选）
     */
    function startPrint(filename, callback, errorCallback) {
        var xhr = new XMLHttpRequest()
        var url = baseUrl + "/printer/print/start"

        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("[API] Print started:", filename)
                    if (callback) callback()
                } else {
                    console.error("[API] Print failed:", xhr.status)
                    var errorMsg = "Failed to start print (HTTP " + xhr.status + ")"
                    error(errorMsg)
                    if (errorCallback) errorCallback(errorMsg)
                }
            }
        }

        xhr.send(JSON.stringify({ filename: filename }))
    }

    /**
     * 执行系统命令
     * @param command - 命令名称（reboot, shutdown）
     * @param callback - 成功回调函数
     * @param errorCallback - 错误回调函数（可选）
     */
    function systemCommand(command, callback, errorCallback) {
        var xhr = new XMLHttpRequest()
        var url = baseUrl + "/machine/" + command

        xhr.open("POST", url, true)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("[API] System command executed:", command)
                    if (callback) callback()
                } else {
                    console.error("[API] System command failed:", xhr.status)
                    var errorMsg = "System command failed (HTTP " + xhr.status + ")"
                    error(errorMsg)
                    if (errorCallback) errorCallback(errorMsg)
                }
            }
        }

        xhr.send()
    }

    /**
     * 更新 API 基础 URL
     * @param host - 主机地址
     * @param port - 端口号
     */
    function updateBaseUrl(host, port) {
        baseUrl = "http://" + host + ":" + port
        console.log("[API] Base URL updated:", baseUrl)
    }
}
