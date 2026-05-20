import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services

Rectangle {
    id: root

    color: "transparent"

    property real s: Scales.uiScale
    property var currentModel: wallpaper.wallpapers
    property int animIndex: 0
    property int monitorIndex: -1 // -1 for all, 0..N for specific
    property bool konamiMode: false
    property int konamiIndex: 0
    property var konamiCode: [Qt.Key_Down, Qt.Key_Up, Qt.Key_Up, Qt.Key_Down, Qt.Key_Down, Qt.Key_Up, Qt.Key_Up]
    property string konamiText: ""
    property string hoverWallpaperPath: ""

    Timer {
        id: konamiTimer
        interval: 5000
        repeat: false
        onTriggered: {
            root.konamiMode = false
            root.konamiText = ""
        }
    }

    readonly property var konamiMessages: [
        "⬇⬆⬆⬇⬇⬆⬆ - Downhill Domination!",
        "🏔️ Mountain Crusher!",
        "🎮 Cheat Code ActivATED!",
        "🚵 Speed Demon!",
        "⚡ Turbo Boost!",
        "🎵 Rock On!",
        "🔥 Unstoppable!",
        "💀 Total Domination!"
    ]

    function getRandomKonamiMessage() {
        return root.konamiMessages[Math.floor(Math.random() * root.konamiMessages.length)]
    }

    readonly property var animNames: [
        "instant", "simple", "fade", "left", "right", "top", "bottom",
        "wipe", "wave", "grow", "center", "outer", "random"
    ]

    readonly property string currentAnimName: animNames[animIndex]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(10)

        // Header
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(32)
                spacing: Theme.dp(8)

                Text {
                    text: "Wallpaper Switcher"
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(13 * s)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                // Monitor selector
                Rectangle {
                    Layout.preferredWidth: monitorText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(24)
                    color: monitorMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                    border.width: 1
                    border.color: Theme.border
                    radius: 0
                    visible: Quickshell.screens.length > 1

                    Text {
                        id: monitorText
                        anchors.centerIn: parent
                        text: root.monitorIndex === -1 ? "All Screens" : "Screen " + root.monitorIndex
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                    }

                    MouseArea {
                        id: monitorMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.monitorIndex++
                            if (root.monitorIndex >= Quickshell.screens.length) root.monitorIndex = -1
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(10)

                Text {
                    text: "Images: ~/Pictures/Wallpapers"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Text {
                    text: wallpaper.wallpapers.length + " Wallpapers"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Transition: " + root.currentAnimName
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Text {
                    text: root.konamiText
                    color: Theme.warning
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                    font.weight: Font.Bold
                    visible: root.konamiMode && root.konamiText !== ""
                }
            }
        }

        // Current wallpaper preview
        Rectangle {
            Layout.fillWidth: true
            // Calculate height based on aspect ratio
            Layout.preferredHeight: (parent.width / (Quickshell.screens[0] ? Quickshell.screens[0].width / Quickshell.screens[0].height : 1.77)) * 0.4
            color: Theme.bgPrimary
            border.width: 1
            border.color: Theme.border
            radius: 0
            clip: true

            Item {
                anchors.fill: parent
                clip: true

                Image {
                    id: previewImage
                    anchors.fill: parent
                    source: root.hoverWallpaperPath !== "" ? root.hoverWallpaperPath : wallpaper.currentWallpaperPath
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    opacity: 0

                    property point dragOffset: Qt.point(0, 0)
                    property real dragStartGlobalX: 0
                    property real dragStartGlobalY: 0
                    property bool isDragging: false

                    x: dragOffset.x
                    y: dragOffset.y

                    Behavior on x { enabled: !previewImage.isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutBack }}
                    Behavior on y { enabled: !previewImage.isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutBack }}
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic }}
                    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }

                    PropertyAnimation on opacity {
                        id: fadeAnim
                        to: 1
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }

                    MouseArea {
                        id: previewDragMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: previewImage.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        preventStealing: true
                        property bool dragArmed: false

                        onPressed: function(mouse) {
                            dragArmed = false
                            previewImage.isDragging = false
                            var globalPos = previewDragMouse.mapToItem(null, mouse.x, mouse.y)
                            previewImage.dragStartGlobalX = globalPos.x
                            previewImage.dragStartGlobalY = globalPos.y
                            previewImage.dragOffset = Qt.point(0, 0)
                            previewHoldTimer.restart()
                        }

                        onPositionChanged: function(mouse) {
                            if (!dragArmed) return
                            var globalPos = previewDragMouse.mapToItem(null, mouse.x, mouse.y)
                            var dx = globalPos.x - previewImage.dragStartGlobalX
                            var dy = globalPos.y - previewImage.dragStartGlobalY
                            if (!previewImage.isDragging && (Math.abs(dx) > Theme.dp(4) || Math.abs(dy) > Theme.dp(4))) {
                                previewImage.isDragging = true
                            }
                            if (previewImage.isDragging) {
                                previewImage.dragOffset = Qt.point(dx, dy)
                            }
                        }

                        onReleased: function(mouse) {
                            previewHoldTimer.stop()
                            dragArmed = false
                            previewImage.isDragging = false
                            previewImage.dragOffset = Qt.point(0, 0)
                        }

                        onCanceled: {
                            previewHoldTimer.stop()
                            dragArmed = false
                            previewImage.isDragging = false
                            previewImage.dragOffset = Qt.point(0, 0)
                        }

                        onWheel: function(wheel) {
                            if (!previewImage.isDragging) {
                                if (wheel.angleDelta.y > 0) {
                                    wallpaper.prev()
                                } else {
                                    wallpaper.next()
                                }
                            }
                        }

                        Timer {
                            id: previewHoldTimer
                            interval: 100
                            repeat: false
                            onTriggered: {
                                previewDragMouse.dragArmed = true
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.dp(24)
                color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.85)

                Text {
                    anchors.centerIn: parent
                    text: wallpaper.getWallpaperName(wallpaper.currentIndex)
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: Theme.dp(24)
                height: Theme.dp(24)
                color: Qt.rgba(0, 0, 0, 0.5)
                radius: Theme.dp(12)
                visible: wallpaper.isApplying

                Rectangle {
                    anchors.centerIn: parent
                    width: Theme.dp(16)
                    height: Theme.dp(16)
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.accent
                    radius: Theme.dp(8)

                    RotationAnimation on rotation {
                        running: wallpaper.isApplying
                        from: 0
                        to: 360
                        duration: 800
                        loops: Animation.Infinite
                    }
                }
            }
        }

        // Wallpaper grid
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 0
            clip: true

            GridView {
                id: wallpaperGrid
                anchors.fill: parent
                model: wallpaper.wallpapers
                cellWidth: Theme.dp(80)
                cellHeight: Theme.dp(90)
                currentIndex: wallpaper.currentIndex

                delegate: Item {
                    id: gridDelegate
                    width: Theme.dp(80)
                    height: Theme.dp(90)

                    property point dragOffset: Qt.point(0, 0)
                    property real dragStartGlobalX: 0
                    property real dragStartGlobalY: 0
                    property bool isDragging: false

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(2)
                        color: wallpaperGrid.currentIndex === index
                            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            : wpMouse.containsMouse
                                ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                                : "transparent"
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.dp(4)

                        x: gridDelegate.dragOffset.x
                        y: gridDelegate.dragOffset.y

                        Behavior on x { enabled: !gridDelegate.isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutBack }}
                        Behavior on y { enabled: !gridDelegate.isDragging; NumberAnimation { duration: 300; easing.type: Easing.OutBack }}
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic }}

                        scale: gridDelegate.isDragging ? 1.08 : 1.0

                        Rectangle {
                            Layout.preferredWidth: Theme.dp(64)
                            Layout.preferredHeight: Theme.dp(64)
                            Layout.alignment: Qt.AlignHCenter
                            color: Theme.bgPrimary
                            border.width: 2
                            border.color: wallpaperGrid.currentIndex === index ? Theme.accent : Theme.border
                            radius: 0
                            clip: true

                            Behavior on border.color {
                                ColorAnimation { duration: 100 }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -Theme.dp(3)
                                color: "transparent"
                                border.width: gridDelegate.isDragging ? Theme.dp(2) : 0
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                                radius: 0
                                visible: gridDelegate.isDragging
                                z: -1
                            }

                            Image {
                                anchors.fill: parent
                                source: modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        Text {
                            text: {
                                var name = modelData.toString().split("/").pop()
                                if (name.length > 12) name = name.substring(0, 10) + "..."
                                return name
                            }
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(7 * s)
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredWidth: Theme.dp(72)
                        }
                    }

                    MouseArea {
                        id: wpMouse
                        anchors.fill: gridDelegate
                        hoverEnabled: true
                        cursorShape: gridDelegate.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        preventStealing: true
                        property bool dragArmed: false

                        onPressed: function(mouse) {
                            dragArmed = false
                            gridDelegate.isDragging = false
                            var globalPos = wpMouse.mapToItem(null, mouse.x, mouse.y)
                            gridDelegate.dragStartGlobalX = globalPos.x
                            gridDelegate.dragStartGlobalY = globalPos.y
                            gridDelegate.dragOffset = Qt.point(0, 0)
                            gridHoldTimer.restart()
                        }

                        onPositionChanged: function(mouse) {
                            if (!dragArmed) return
                            var globalPos = wpMouse.mapToItem(null, mouse.x, mouse.y)
                            var dx = globalPos.x - gridDelegate.dragStartGlobalX
                            var dy = globalPos.y - gridDelegate.dragStartGlobalY
                            if (!gridDelegate.isDragging && (Math.abs(dx) > Theme.dp(4) || Math.abs(dy) > Theme.dp(4))) {
                                gridDelegate.isDragging = true
                            }
                            if (gridDelegate.isDragging) {
                                gridDelegate.dragOffset = Qt.point(dx, dy)
                            }
                        }

                        onReleased: function(mouse) {
                            gridHoldTimer.stop()
                            dragArmed = false
                            if (!gridDelegate.isDragging) {
                                wallpaper.goTo(index)
                            }
                            gridDelegate.isDragging = false
                            gridDelegate.dragOffset = Qt.point(0, 0)
                        }

                        onCanceled: {
                            gridHoldTimer.stop()
                            dragArmed = false
                            gridDelegate.isDragging = false
                            gridDelegate.dragOffset = Qt.point(0, 0)
                        }

                        onEntered: {
                            if (!gridDelegate.isDragging) {
                                wallpaperGrid.currentIndex = index
                                root.hoverWallpaperPath = modelData
                            }
                        }

                        onExited: {
                            if (!gridDelegate.isDragging) {
                                root.hoverWallpaperPath = ""
                            }
                        }

                        Timer {
                            id: gridHoldTimer
                            interval: 100
                            repeat: false
                            onTriggered: {
                                wpMouse.dragArmed = true
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: Theme.dp(6)
                }

                highlightMoveDuration: 100
            }
        }

        // Footer hints
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(24)
            spacing: Theme.dp(6)

            Text {
                text: "↑↓←→ Navigate"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "Drag Preview/Grid"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "Enter Apply"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "T Transition"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "Esc Back"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }
        }
    }

    function playTransition() {
        previewImage.x = 0
        previewImage.y = 0
        previewImage.scale = 1
        previewImage.opacity = 0
        fadeAnim.start()
    }

    function nextAnim() {
        root.animIndex = (root.animIndex + 1) % root.animNames.length
        wallpaper.transitionType = root.animNames[root.animIndex]
    }

    function prevAnim() {
        root.animIndex = (root.animIndex - 1 + root.animNames.length) % root.animNames.length
        wallpaper.transitionType = root.animNames[root.animIndex]
    }

    function apply() {
        wallpaper.applyWallpaper(root.monitorIndex)
    }

    function checkKonami(key) {
        if (root.konamiCode[root.konamiIndex] === key) {
            root.konamiIndex++
            if (root.konamiIndex >= root.konamiCode.length) {
                root.konamiMode = true
                root.konamiText = root.getRandomKonamiMessage()
                root.konamiIndex = 0
                konamiTimer.restart()
            }
        } else {
            root.konamiIndex = 0
        }
    }

    Connections {
        target: wallpaper
        function onCurrentWallpaperPathChanged() {
            root.playTransition()
        }
    }
}
