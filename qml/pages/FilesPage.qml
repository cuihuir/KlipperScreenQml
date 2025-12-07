import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro风格文件页 - 2行4列大图标网格布局
Page {
    id: root
    property var printer: null
    property var app: null
    property StackView stackView: StackView.view
    property bool isLoading: false
    property string selectedFile: ""  // 当前选中的文件

    // 分页相关
    property var allFiles: []  // 完整文件列表
    property int currentPage: 0
    property int filesPerPage: 8  // 每页8个文件（2行4列）
    property int totalPages: 0

    // 缩略图加载控制
    property var pendingMetadataRequests: []  // 待加载的元数据请求队列
    property bool isLoadingMetadata: false

    signal showError(string message)
    signal navigateToDashboard()  // 开始打印后跳转到首页

    background: Rectangle {
        color: Style.bgPrimary
    }

    // 监听文件列表响应
    Connections {
        target: printer
        enabled: printer !== null

        function onFileListReceived(jsonData) {
            console.log("=== File list received, data length:", jsonData.length)
            isLoading = false

            try {
                var files = JSON.parse(jsonData)
                console.log("Parsed files array, length:", files.length)

                // 过滤并存储所有gcode文件
                allFiles = []
                for (var i = 0; i < files.length; i++) {
                    var file = files[i]
                    var filename = file.path || file.filename
                    if (filename && filename.endsWith(".gcode")) {
                        allFiles.push({
                            filename: filename,
                            size: file.size || 0,
                            modified: file.modified || 0,
                            thumbnail: ""
                        })
                    }
                }

                // 计算总页数
                totalPages = Math.ceil(allFiles.length / filesPerPage)
                console.log("=== Total files:", allFiles.length, "Total pages:", totalPages)

                // 加载第一页
                currentPage = 0
                loadCurrentPage()
            } catch (e) {
                console.error("Parse error:", e)
                showError("Failed to parse file list: " + e)
            }
        }

        // 监听元数据响应
        function onFileMetadataReceived(filename, metadataJson) {
            try {
                var metadata = JSON.parse(metadataJson)
                var thumbnailUrl = ""

                if (metadata.thumbnails && metadata.thumbnails.length > 0) {
                    // 按照 size 排序，选择合适的缩略图
                    var sortedThumbs = metadata.thumbnails.slice().sort(function(a, b) {
                        return a.size - b.size
                    })

                    // 选择第二个（如果有的话），否则用第一个
                    var selectedThumb = sortedThumbs.length > 1 ? sortedThumbs[1] : sortedThumbs[0]

                    if (selectedThumb && selectedThumb.relative_path && printer && printer.apiHost && printer.apiPort) {
                        var apiUrl = "http://" + printer.apiHost + ":" + printer.apiPort
                        var filePath = "gcodes/" + selectedThumb.relative_path
                        thumbnailUrl = apiUrl + "/server/files/" + filePath + "?date=" + Date.now()
                    }
                }

                // 更新文件模型中的缩略图
                for (var j = 0; j < fileModel.count; j++) {
                    if (fileModel.get(j).filename === filename) {
                        fileModel.setProperty(j, "thumbnail", thumbnailUrl)
                        break
                    }
                }

                // 继续加载下一个元数据
                isLoadingMetadata = false
                loadNextMetadata()
            } catch (e) {
                console.error("=== Failed to parse metadata:", e)
                isLoadingMetadata = false
                loadNextMetadata()
            }
        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // 左侧主内容区
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Style.spacingLarge

            // 顶部工具栏
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingMedium

                Label {
                    text: "G-CODE FILES"
                    font.pixelSize: Style.fontLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.textPrimary
                }

                // 分页信息
                Label {
                    text: totalPages > 0 ? "Page " + (currentPage + 1) + " / " + totalPages + " (" + allFiles.length + " files)" : ""
                    font.pixelSize: Style.fontSmall
                    font.family: Style.fontFamily
                    color: Style.textSecondary
                    visible: totalPages > 1
                }

                Item { Layout.fillWidth: true }

                // 刷新按钮
                Rectangle {
                    Layout.preferredWidth: Style.baseUnit * 9
                    Layout.preferredHeight: Style.buttonHeight
                    color: isLoading ? Style.warning : Style.info
                    border.width: Style.borderThin
                    border.color: Style.divider

                    // 旋转动画图标
                    Label {
                        anchors.centerIn: parent
                        text: "⟳"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        color: Style.bgPrimary
                        visible: isLoading

                        RotationAnimation on rotation {
                            running: isLoading
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 1000
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: "REFRESH"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 2
                        color: Style.bgPrimary
                        visible: !isLoading
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !isLoading
                        cursorShape: isLoading ? Qt.BusyCursor : Qt.PointingHandCursor
                        onClicked: loadFiles()
                    }
                }
            }

            // 文件网格 (2行4列) - 带滑动手势
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                // 滑动手势检测
                property real dragStartX: 0
                property real dragCurrentX: 0
                property bool isDragging: false
                readonly property real swipeThreshold: Style.baseUnit * 10  // 滑动阈值

                MouseArea {
                    id: swipeArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    preventStealing: false

                    onPressed: function(mouse) {
                        parent.dragStartX = mouse.x
                        parent.isDragging = true
                        mouse.accepted = false  // 让底层GridView也能处理点击
                    }

                    onPositionChanged: function(mouse) {
                        if (parent.isDragging) {
                            parent.dragCurrentX = mouse.x
                        }
                    }

                    onReleased: function(mouse) {
                        if (parent.isDragging) {
                            var dragDistance = parent.dragCurrentX - parent.dragStartX

                            // 向左滑动 = 下一页
                            if (dragDistance < -parent.swipeThreshold && currentPage < totalPages - 1) {
                                console.log("Swipe left detected, next page")
                                currentPage++
                                loadCurrentPage()
                            }
                            // 向右滑动 = 上一页
                            else if (dragDistance > parent.swipeThreshold && currentPage > 0) {
                                console.log("Swipe right detected, previous page")
                                currentPage--
                                loadCurrentPage()
                            }

                            parent.isDragging = false
                        }
                        mouse.accepted = false
                    }
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    clip: true

                    GridView {
                        id: fileGrid
                        // 计算单元格大小以适应 2 行 4 列
                        cellWidth: (width - Style.spacingMedium * 3) / 4
                        cellHeight: (height - Style.spacingMedium) / 2
                        model: fileModel
                        interactive: false  // 禁用GridView自带的滚动，使用外层手势

                    delegate: Item {
                        width: fileGrid.cellWidth
                        height: fileGrid.cellHeight

                        // 文件卡片
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Style.spacingSmall
                            color: selectedFile === model.filename ? Style.bgSecondary : Style.bgPrimary
                            border.width: selectedFile === model.filename ? Style.borderThick : Style.borderThin
                            border.color: selectedFile === model.filename ? Style.accent : Style.divider

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Style.spacingMedium
                                spacing: Style.spacingSmall

                                // 缩略图区域
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: parent.height * 0.55
                                    color: Style.bgSecondary
                                    border.width: Style.borderThin
                                    border.color: Style.divider

                                    Image {
                                        anchors.centerIn: parent
                                        width: parent.width - Style.spacingMedium * 2
                                        height: parent.height - Style.spacingMedium * 2
                                        source: model.thumbnail
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                        cache: false

                                        // 占位符图标
                                        Label {
                                            anchors.centerIn: parent
                                            text: "⬛"
                                            font.pixelSize: Style.baseUnit * 4
                                            color: Style.accent
                                            visible: parent.status !== Image.Ready || model.thumbnail === ""
                                        }
                                    }
                                }

                                // 文件名
                                Label {
                                    Layout.fillWidth: true
                                    text: model.filename
                                    font.pixelSize: Style.fontSmall
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    color: Style.textPrimary
                                    elide: Text.ElideMiddle
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.NoWrap
                                }

                                // 文件大小
                                Label {
                                    Layout.fillWidth: true
                                    text: Style.formatFileSize(model.size)
                                    font.pixelSize: Style.fontXSmall
                                    font.family: Style.fontFamilyMono
                                    color: Style.textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.fillHeight: true }
                            }

                            // 点击卡片显示详细信息对话框
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                z: -1
                                onClicked: {
                                    showFileDetails(model.filename)
                                }
                            }
                        }
                    }
                }
            }

            // 加载状态和空状态
            Label {
                anchors.centerIn: parent
                visible: fileModel.count === 0
                text: isLoading ? "LOADING..." : "NO FILES FOUND\nClick REFRESH to load"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.letterSpacing: 1
                color: isLoading ? Style.accent : Style.textDisabled
                horizontalAlignment: Text.AlignHCenter

                // 加载动画
                SequentialAnimation on opacity {
                    running: isLoading
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                    NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                }
            }
        }
        }

        // 右侧翻页按钮区域
        ColumnLayout {
            Layout.preferredWidth: Style.baseUnit * 8
            Layout.fillHeight: true
            spacing: Style.spacingLarge
            visible: totalPages > 1

            // 上一页按钮 (大)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: currentPage > 0 ? Style.accent : Style.bgCard
                border.width: Style.borderMedium
                border.color: currentPage > 0 ? Style.accent : Style.divider

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingSmall

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "◀"
                        font.pixelSize: Style.baseUnit * 5
                        font.bold: true
                        color: currentPage > 0 ? Style.bgPrimary : Style.textDisabled
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "PREV"
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 2
                        color: currentPage > 0 ? Style.bgPrimary : Style.textDisabled
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: currentPage > 0 ? (currentPage) : "-"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: currentPage > 0 ? Style.bgPrimary : Style.textDisabled
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: currentPage > 0
                    cursorShape: currentPage > 0 ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: {
                        if (currentPage > 0) {
                            currentPage--
                            loadCurrentPage()
                        }
                    }
                }
            }

            // 下一页按钮 (大)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: currentPage < totalPages - 1 ? Style.info : Style.bgCard
                border.width: Style.borderMedium
                border.color: currentPage < totalPages - 1 ? Style.info : Style.divider

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingSmall

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: currentPage < totalPages - 1 ? (currentPage + 2) : "-"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: currentPage < totalPages - 1 ? Style.bgPrimary : Style.textDisabled
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "NEXT"
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 2
                        color: currentPage < totalPages - 1 ? Style.bgPrimary : Style.textDisabled
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "▶"
                        font.pixelSize: Style.baseUnit * 5
                        font.bold: true
                        color: currentPage < totalPages - 1 ? Style.bgPrimary : Style.textDisabled
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: currentPage < totalPages - 1
                    cursorShape: currentPage < totalPages - 1 ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: {
                        if (currentPage < totalPages - 1) {
                            currentPage++
                            loadCurrentPage()
                        }
                    }
                }
            }
        }
    }

    // 文件模型
    ListModel {
        id: fileModel
    }

    // 文件详情对话框 - 使用 Loader 按需加载
    Loader {
        id: fileDetailsDialogLoader
        active: false  // 初始不加载，节省内存

        // 暴露属性供外部访问
        property string selectedFile: ""
        property string thumbnailData: ""
        property var metadata: null

        sourceComponent: Component {
            Dialog {
                id: fileDetailsDialog

                // Dialog 配置
                modal: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside  // ESC 键或点击外部关闭

                // 去除默认内边距和标题
                padding: 0
                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0

                // 去除默认的标题栏
                title: ""

                // 辅助属性 - 计算布局位置
                readonly property int dialogNavWidth: ApplicationWindow.window ? ApplicationWindow.window.navButtonWidth : 80
                readonly property int paginationWidth: Style.baseUnit * 8  // 翻页按钮区域宽度

                // 计算文件列表区域：窗口宽度 - 导航按钮 - 页面外边距*2 - 翻页按钮 - 列表与翻页间距
                readonly property int fileListDisplayWidth: (ApplicationWindow.window ? ApplicationWindow.window.width : 1920)
                                                           - dialogNavWidth
                                                           - Style.spacingLarge * 2  // 页面左右外边距
                                                           - paginationWidth
                                                           - Style.spacingLarge  // 列表与翻页间距

                // 对话框宽度匹配文件列表显示区域，减少400px避免覆盖翻页按钮
                width: fileListDisplayWidth - 400
                height: Math.min(ApplicationWindow.window ? ApplicationWindow.window.height * 0.85 : 350, Style.baseUnit * 45)

                // x 定位：左侧贴近文件列表左边界
                x: dialogNavWidth + Style.spacingLarge
                y: ApplicationWindow.window ? (ApplicationWindow.window.height - height) / 2 : 0

                // 背景和边框
                background: Rectangle {
                    color: Style.bgCard
                    border.width: Style.borderMedium
                    border.color: Style.divider
                }

                // 属性绑定到 Loader
                property string selectedFile: fileDetailsDialogLoader.selectedFile
                property string thumbnailData: fileDetailsDialogLoader.thumbnailData
                property var metadata: fileDetailsDialogLoader.metadata

                // Dialog 内容 - 三部分纵向布局
                contentItem: RowLayout {
                    spacing: Style.spacingLarge

                    // ===== 第一部分：缩略图（左侧，正方形）=====
                    Rectangle {
                        Layout.preferredWidth: Math.min(fileDetailsDialog.height * 0.8, Style.baseUnit * 35)
                        Layout.preferredHeight: Layout.preferredWidth  // 正方形
                        Layout.alignment: Qt.AlignVCenter
                        color: Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.divider

                        Image {
                            anchors.fill: parent
                            anchors.margins: Style.spacingMedium
                            source: fileDetailsDialog.thumbnailData
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false

                            Label {
                                anchors.centerIn: parent
                                text: "NO\nPREVIEW"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 2
                                color: Style.textDisabled
                                horizontalAlignment: Text.AlignHCenter
                                visible: parent.status !== Image.Ready || fileDetailsDialog.thumbnailData === ""
                            }
                        }
                    }

                    // ===== 第二部分：信息区域（中间，更长）=====
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Style.spacingMedium

                        // 文件名标题
                        Label {
                            Layout.fillWidth: true
                            text: fileDetailsDialog.selectedFile
                            font.pixelSize: Style.fontXLarge
                            font.family: Style.fontFamily
                            font.bold: true
                            color: Style.textPrimary
                            elide: Text.ElideMiddle
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                        }

                        // 分隔线
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.borderThin
                            color: Style.divider
                        }

                        // 元数据信息（可滚动）
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                width: parent.width - Style.spacingMedium
                                columns: 2
                                rowSpacing: Style.spacingSmall
                                columnSpacing: Style.spacingLarge

                                    // 已修改时间
                                    Label {
                                        text: "已修改:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? formatTimestamp(fileDetailsDialog.metadata.modified) : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }

                                    // 层高
                                    Label {
                                        text: "层高:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? (fileDetailsDialog.metadata.layer_height + " mm") : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }

                                    // 材料
                                    Label {
                                        text: "耗材:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? (fileDetailsDialog.metadata.filament_type || "-") : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }

                                    // 材料名称
                                    Label {
                                        text: "材料名:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                        visible: fileDetailsDialog.metadata && fileDetailsDialog.metadata.filament_name
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? (fileDetailsDialog.metadata.filament_name || "") : ""
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        visible: fileDetailsDialog.metadata && fileDetailsDialog.metadata.filament_name
                                    }

                                    // 材料重量
                                    Label {
                                        text: "耗材重量:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? (fileDetailsDialog.metadata.filament_weight_total.toFixed(2) + " 克") : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }

                                    // 喷嘴直径
                                    Label {
                                        text: "喷嘴直径:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? (fileDetailsDialog.metadata.nozzle_diameter + " mm") : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }

                                    // 切片软件
                                    Label {
                                        text: "切片软件:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? (fileDetailsDialog.metadata.slicer + " " + (fileDetailsDialog.metadata.slicer_version || "")) : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }

                                    // 文件大小
                                    Label {
                                        text: "大小:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? Style.formatFileSize(fileDetailsDialog.metadata.size) : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }

                                    // 预估时间
                                    Label {
                                        text: "预估时间:"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamily
                                        color: Style.textSecondary
                                    }
                                    Label {
                                        text: fileDetailsDialog.metadata ? formatDuration(fileDetailsDialog.metadata.estimated_time) : "-"
                                        font.pixelSize: Style.fontNormal
                                        font.family: Style.fontFamilyMono
                                        color: Style.textPrimary
                                    }
                                }  // GridLayout
                        }  // ScrollView
                    }  // ColumnLayout (第二部分信息区域)

                    // ===== 第三部分：按钮区域（右侧，纵向排列）=====
                    ColumnLayout {
                        Layout.preferredWidth: Style.baseUnit * 12
                        Layout.fillHeight: true
                        spacing: Style.spacingMedium

                        // 打印按钮
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Style.success
                            border.width: Style.borderMedium
                            border.color: Style.divider
                            radius: Style.radiusSmall

                            Label {
                                anchors.centerIn: parent
                                text: "打印"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    startPrint(fileDetailsDialog.selectedFile)
                                    fileDetailsDialog.close()
                                }
                            }
                        }  // Rectangle (打印按钮)

                        // 删除按钮
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Style.error
                            border.width: Style.borderMedium
                            border.color: Style.divider
                            radius: Style.radiusSmall

                            Label {
                                anchors.centerIn: parent
                                text: "删除"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    fileDetailsDialog.close()
                                    confirmDelete(fileDetailsDialog.selectedFile)
                                }
                            }
                        }  // Rectangle (删除按钮)

                        // 取消按钮
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Style.bgSecondary
                            border.width: Style.borderMedium
                            border.color: Style.divider
                            radius: Style.radiusSmall

                            Label {
                                anchors.centerIn: parent
                                text: "取消"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.textPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: fileDetailsDialog.close()
                            }
                        }  // Rectangle (取消按钮)
                    }  // ColumnLayout (第三部分按钮区域)
                }  // RowLayout (contentItem)
            }  // Dialog
        }  // Component
    }  // Loader

    // 删除确认对话框
    Rectangle {
        id: deleteDialog
        anchors.fill: parent
        visible: false
        color: Qt.rgba(0, 0, 0, 0.8)
        z: 999

        property string selectedFile: ""

        MouseArea {
            anchors.fill: parent
            onClicked: {}  // 阻止点击穿透
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.7, Style.baseUnit * 50)
            height: Math.min(parent.height * 0.5, Style.baseUnit * 25)
            color: Style.bgCard
            border.width: Style.borderMedium
            border.color: Style.error

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 5
                    color: Style.error

                    Label {
                        anchors.centerIn: parent
                        text: "DELETE FILE"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 5
                        color: Style.bgPrimary
                    }
                }

                // 内容区域
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Style.spacingLarge * 2
                        spacing: Style.spacingLarge

                        Label {
                            text: "Are you sure you want to delete this file?"
                            font.pixelSize: Style.fontXLarge
                            font.family: Style.fontFamily
                            color: Style.textPrimary
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // 文件名框
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.bgSecondary
                            border.width: Style.borderThick
                            border.color: Style.error

                            Label {
                                anchors.fill: parent
                                anchors.margins: Style.spacingLarge
                                text: deleteDialog.selectedFile
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamilyMono
                                font.bold: true
                                color: Style.error
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAnywhere
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                // 按钮区域
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 7

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Style.spacingLarge
                        spacing: Style.spacingLarge

                        // CANCEL 按钮
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Style.bgSecondary
                            border.width: Style.borderMedium
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "CANCEL"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 4
                                color: Style.textPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: deleteDialog.visible = false
                            }
                        }

                        // DELETE 按钮
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Style.error
                            border.width: Style.borderMedium
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "DELETE"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 4
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    deleteFile(deleteDialog.selectedFile)
                                    deleteDialog.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 辅助函数
    function loadFiles() {
        if (!printer) {
            console.warn("Printer not connected")
            showError("Printer not connected")
            return
        }

        console.log("Loading files via WebSocket...")
        isLoading = true
        fileModel.clear()
        selectedFile = ""  // 清除选中状态

        // 使用 WebSocket/JSON-RPC 请求文件列表
        printer.requestFileList()
    }

    function showFileDetails(filename) {
        // 设置 Loader 的属性
        fileDetailsDialogLoader.selectedFile = filename
        fileDetailsDialogLoader.metadata = null
        fileDetailsDialogLoader.thumbnailData = ""

        // 先使用已有的小缩略图作为临时显示
        for (var i = 0; i < fileModel.count; i++) {
            if (fileModel.get(i).filename === filename) {
                fileDetailsDialogLoader.thumbnailData = fileModel.get(i).thumbnail
                break
            }
        }

        console.log("Showing file details for:", filename)

        // 激活 Loader 并打开 Dialog
        if (!fileDetailsDialogLoader.active) {
            fileDetailsDialogLoader.active = true
        }
        // 使用 Qt.callLater 确保 Loader 完成加载
        Qt.callLater(function() {
            if (fileDetailsDialogLoader.item) {
                fileDetailsDialogLoader.item.open()
            }
        })

        // 异步请求完整元数据和大尺寸缩略图
        if (printer) {
            printer.requestFileMetadata(filename)
        }
    }

    function formatTimestamp(timestamp) {
        if (!timestamp) return "-"
        var date = new Date(timestamp * 1000)
        return Qt.formatDateTime(date, "yyyy/M/d HH:mm")
    }

    function formatDuration(seconds) {
        if (!seconds) return "-"
        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        if (hours > 0) {
            return hours + " 小时 " + minutes + " 分钟"
        } else {
            return minutes + " 分钟"
        }
    }

    // 加载当前页的文件
    function loadCurrentPage() {
        fileModel.clear()
        pendingMetadataRequests = []

        var startIndex = currentPage * filesPerPage
        var endIndex = Math.min(startIndex + filesPerPage, allFiles.length)

        console.log("=== Loading page", currentPage + 1, "files", startIndex, "-", endIndex - 1)

        // 添加当前页的文件到模型
        for (var i = startIndex; i < endIndex; i++) {
            var file = allFiles[i]
            fileModel.append({
                filename: file.filename,
                size: file.size,
                modified: file.modified,
                thumbnail: ""
            })

            // 添加到待加载队列
            pendingMetadataRequests.push(file.filename)
        }

        // 开始懒加载缩略图
        loadNextMetadata()
    }

    // 懒加载下一个缩略图
    function loadNextMetadata() {
        if (isLoadingMetadata || pendingMetadataRequests.length === 0) {
            return
        }

        isLoadingMetadata = true
        var filename = pendingMetadataRequests.shift()
        console.log("=== Loading metadata for:", filename, "Remaining:", pendingMetadataRequests.length)
        printer.requestFileMetadata(filename)
    }

    // 监听元数据响应以更新详情对话框
    Connections {
        target: printer
        enabled: printer !== null && fileDetailsDialogLoader.active && fileDetailsDialogLoader.item && fileDetailsDialogLoader.item.opened

        function onFileMetadataReceived(filename, metadataJson) {
            if (fileDetailsDialogLoader.active && fileDetailsDialogLoader.item &&
                fileDetailsDialogLoader.item.opened && fileDetailsDialogLoader.selectedFile === filename) {
                try {
                    var metadata = JSON.parse(metadataJson)
                    fileDetailsDialogLoader.metadata = metadata

                    var largeThumbUrl = ""

                    if (metadata.thumbnails && metadata.thumbnails.length > 0) {
                        // 按 size 降序排序，选择最大的缩略图
                        var sortedThumbs = metadata.thumbnails.slice().sort(function(a, b) {
                            return b.size - a.size  // 从大到小排序
                        })

                        var largestThumb = sortedThumbs[0]  // 第一个就是最大的

                        if (largestThumb && largestThumb.relative_path && printer && printer.apiHost && printer.apiPort) {
                            var apiUrl = "http://" + printer.apiHost + ":" + printer.apiPort
                            var filePath = "gcodes/" + largestThumb.relative_path
                            largeThumbUrl = apiUrl + "/server/files/" + filePath + "?date=" + Date.now()
                            fileDetailsDialogLoader.thumbnailData = largeThumbUrl
                            console.log("Updated dialog with large thumbnail:", largestThumb.width + "x" + largestThumb.height)
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse metadata for dialog:", e)
                }
            }
        }
    }

    function confirmDelete(filename) {
        deleteDialog.selectedFile = filename
        console.log("Delete confirmation for:", filename)
        deleteDialog.visible = true
    }

    function startPrint(filename) {
        if (!printer) {
            console.warn("Printer not connected")
            showError("Printer not connected")
            return
        }

        console.log("=== Starting print via WebSocket:", filename)
        printer.startPrint(filename)
        selectedFile = ""  // 清除选中状态

        // 开始打印后自动跳转到首页
        console.log("=== Emitting navigateToDashboard signal")
        navigateToDashboard()
        console.log("=== navigateToDashboard signal emitted")
    }

    function deleteFile(filename) {
        if (!printer) {
            console.warn("Printer not connected")
            showError("Printer not connected")
            return
        }

        console.log("Deleting file via WebSocket:", filename)
        printer.deleteFile(filename)
        selectedFile = ""  // 清除选中状态

        // 删除后刷新列表
        Qt.callLater(loadFiles)
    }

    // 监听页面可见性，每次进入页面时自动刷新
    onVisibleChanged: {
        if (visible && printer && printer.isConnected) {
            console.log("FilesPage became visible, auto-refreshing...")
            Qt.callLater(loadFiles)
        }
    }

    Component.onCompleted: {
        // 初始加载
        if (printer && printer.isConnected) {
            loadFiles()
        }
        console.log("FilesPage created")
    }

    // ===== 生命周期钩子 =====
    StackView.onActivated: {
        console.log("FilesPage activated, stackView:", stackView)
    }

    StackView.onDeactivated: {
        console.log("FilesPage deactivated")
    }
}
