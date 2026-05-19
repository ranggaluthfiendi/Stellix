import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.config
import qs.components.elements

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: volumeHeader.height + volumeBodyClip.height + Theme.dp(6)
    color: Theme.bgPrimary
    border.width: 1
    border.color: root.volumeExpanded ? Theme.accent : Theme.border
    radius: 0
    clip: true

    property var pipewireService: null
    property real s: Scales.uiScale
    property bool volumeExpanded: false

    readonly property var sink: pipewireService ? pipewireService.sink : null
    readonly property bool sinkReady: pipewireService ? pipewireService.sinkReady : false

    readonly property real maxBodyHeight: Theme.dp(500)

    property real targetBodyHeight: 0

    Behavior on targetBodyHeight {
        enabled: !expandAnim.running && !collapseAnim.running
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: expandAnim
        NumberAnimation {
            target: root
            property: "targetBodyHeight"
            to: Math.min(volumeBodyContainer.implicitHeight, maxBodyHeight)
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: collapseAnim
        NumberAnimation {
            target: root
            property: "targetBodyHeight"
            to: 0
            duration: 200
            easing.type: Easing.InCubic
        }
    }

    onVolumeExpandedChanged: {
        if (root.volumeExpanded) {
            collapseAnim.stop()
            expandAnim.restart()
        } else {
            expandAnim.stop()
            collapseAnim.restart()
        }
    }

    Item {
        id: volumeHeader
        width: parent.width
        height: Theme.dp(44)

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(6)
            spacing: Theme.dp(6)

            IconVolume {
                Layout.preferredWidth: Theme.dp(16)
                Layout.preferredHeight: Theme.dp(16)
                Layout.alignment: Qt.AlignVCenter
                iconColor: root.sinkReady && root.sink.audio.muted ? Theme.textMuted : Theme.textPrimary
                iconSize: Theme.dp(12)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(8)
                color: Theme.bgSecondary
                border.width: 1
                border.color: Theme.border
                radius: 0

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: root.sinkReady
                        ? Math.max(0, Math.min(parent.width, (root.sink.audio.volume || 0) * parent.width))
                        : 0
                    color: root.sinkReady && root.sink.audio.muted ? Theme.border : Theme.accentSoft
                    radius: 0
                }

                MouseArea {
                    id: volumeMouse
                    anchors.fill: parent
                    property bool dragging: false
                    cursorShape: Qt.SizeHorCursor
                    onPressed: function(mouse) {
                        dragging = true
                        if (root.sinkReady) root.sink.audio.volume = Math.max(0, Math.min(1, mouse.x / volumeMouse.width))
                    }
                    onPositionChanged: function(mouse) {
                        if (dragging && root.sinkReady) root.sink.audio.volume = Math.max(0, Math.min(1, mouse.x / volumeMouse.width))
                    }
                    onReleased: dragging = false
                    onWheel: function(wheel) {
                        if (!root.sinkReady) return
                        var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                        root.sink.audio.volume = Math.max(0, Math.min(1, (root.sink.audio.volume || 0) + delta))
                    }
                }
            }

            Text {
                text: root.sinkReady ? Math.round((root.sink.audio.volume || 0) * 100) + "%" : "--"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
            }

            Rectangle {
                Layout.preferredWidth: Theme.dp(24)
                Layout.preferredHeight: Theme.dp(24)
                Layout.alignment: Qt.AlignVCenter
                color: muteMouse.containsMouse
                    ? (root.sinkReady && root.sink.audio.muted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                    : (root.sinkReady && root.sink.audio.muted ? Theme.accent : Theme.bgSecondary)
                border.width: 1
                border.color: muteMouse.containsMouse ? (root.sinkReady && root.sink.audio.muted ? Theme.accent : Theme.textPrimary) : Theme.border
                radius: 0

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.sinkReady && root.sink.audio.muted ? "M" : "♪"
                    color: root.sinkReady && root.sink.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                }

                MouseArea {
                    id: muteMouse
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.sinkReady
                    onClicked: root.sink.audio.muted = !root.sink.audio.muted
                }
            }

            Rectangle {
                Layout.preferredWidth: Theme.dp(24)
                Layout.preferredHeight: Theme.dp(24)
                Layout.alignment: Qt.AlignVCenter
                color: expandMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                border.width: 1
                border.color: expandMouse.containsMouse ? Theme.textPrimary : Theme.border
                radius: 0

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.volumeExpanded ? "▲" : "▼"
                    color: expandMouse.containsMouse ? Theme.textPrimary : Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                }

                MouseArea {
                    id: expandMouse
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.volumeExpanded = !root.volumeExpanded
                }
            }
        }
    }

    Item {
        id: volumeBodyClip
        anchors.top: volumeHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.targetBodyHeight
        clip: true

        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: volumeBodyContainer.implicitHeight
            interactive: contentHeight > height
            clip: true

            ScrollBar.vertical: ScrollBar {
                policy: volumeBodyContainer.implicitHeight > parent.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                width: Theme.dp(4)
            }

            ColumnLayout {
                id: volumeBodyContainer
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: Theme.dp(8)
                anchors.leftMargin: Theme.dp(8)
                anchors.rightMargin: Theme.dp(8)
                anchors.bottomMargin: Theme.dp(24)
                spacing: Theme.dp(16)

                ColumnLayout {
                    id: volumeBody
                    Layout.fillWidth: true
                    spacing: Theme.dp(10)

                    // ── Main Output (always at top) ──
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(20)
                        visible: root.sinkReady
                        spacing: Theme.dp(6)

                        Text {
                            text: "Main Output"
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(1)
                            color: Theme.border
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(48)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(4)
                            spacing: Theme.dp(3)


                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(4)

                                IconVolume {
                                    Layout.preferredWidth: Theme.dp(14)
                                    Layout.preferredHeight: Theme.dp(14)
                                    Layout.alignment: Qt.AlignVCenter
                                    iconColor: root.sink && root.sink.audio && root.sink.audio.muted ? Theme.textMuted : Theme.accent
                                    iconSize: Theme.dp(11)
                                }

                                MarqueeText {
                                    text: pipewireService ? pipewireService.nodeName(root.sink) : ""
                                    textColor: Theme.textPrimary
                                    fontSize: Typography.sizeXXS || 9
                                    fontScale: s
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: root.sinkReady && root.sink ? Math.round((root.sink.audio.volume || 0) * 100) + "%" : "--"
                                    color: Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(20)
                                    Layout.preferredHeight: Theme.dp(18)
                                    color: mainMuteMouse.containsMouse
                                        ? (root.sink && root.sink.audio && root.sink.audio.muted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                        : (root.sink && root.sink.audio && root.sink.audio.muted ? Theme.accent : Theme.bgPrimary)
                                    border.width: 1
                                    border.color: mainMuteMouse.containsMouse ? (root.sink && root.sink.audio && root.sink.audio.muted ? Theme.accent : Theme.textPrimary) : Theme.border
                                    radius: 0

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.sink && root.sink.audio && root.sink.audio.muted ? "U" : "M"
                                        color: root.sink && root.sink.audio && root.sink.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }

                                    MouseArea {
                                        id: mainMuteMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        enabled: root.sinkReady
                                        onClicked: root.sink.audio.muted = !root.sink.audio.muted
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.dp(5)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: root.sinkReady
                                        ? Math.max(0, Math.min(parent.width, (root.sink.audio.volume || 0) * parent.width))
                                        : 0
                                    color: Theme.accent
                                    radius: 0
                                }

                                MouseArea {
                                    id: mainSinkMouse
                                    anchors.fill: parent
                                    property bool dragging: false
                                    cursorShape: Qt.SizeHorCursor
                                    onPressed: function(mouse) {
                                        dragging = true
                                        if (root.sinkReady) root.sink.audio.volume = Math.max(0, Math.min(1, mouse.x / mainSinkMouse.width))
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (dragging && root.sinkReady) root.sink.audio.volume = Math.max(0, Math.min(1, mouse.x / mainSinkMouse.width))
                                    }
                                    onReleased: dragging = false
                                    onWheel: function(wheel) {
                                        if (!root.sinkReady) return
                                        var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                        root.sink.audio.volume = Math.max(0, Math.min(1, (root.sink.audio.volume || 0) + delta))
                                    }
                                }
                            }
                        }
                    }

                    // ── Main Input (always at top) ──
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(20)
                        visible: pipewireService && pipewireService.sourceDevices().length > 0
                        spacing: Theme.dp(6)

                        Text {
                            text: "Main Input"
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(1)
                            color: Theme.border
                        }
                    }

                    Rectangle {
                        id: mainInputBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(48)
                        visible: pipewireService && pipewireService.sourceDevices().length > 0
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0

                        property var mainSource: pipewireService ? pipewireService.sourceDevices()[0] : null

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(4)
                            spacing: Theme.dp(3)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(4)

                                IconMic {
                                    Layout.preferredWidth: Theme.dp(16)
                                    Layout.preferredHeight: Theme.dp(16)
                                    Layout.alignment: Qt.AlignVCenter
                                    iconColor: mainInputBox.mainSource && mainInputBox.mainSource.audio && mainInputBox.mainSource.audio.muted
                                        ? Theme.danger : Theme.textPrimary
                                    iconSize: Theme.dp(13)
                                }

                                MarqueeText {
                                    text: pipewireService && mainInputBox.mainSource ? pipewireService.nodeName(mainInputBox.mainSource) : ""
                                    textColor: Theme.textPrimary
                                    fontSize: Typography.sizeXXS || 9
                                    fontScale: s
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: mainInputBox.mainSource && mainInputBox.mainSource.audio ? Math.round((mainInputBox.mainSource.audio.volume || 0) * 100) + "%" : "--"
                                    color: Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(20)
                                    Layout.preferredHeight: Theme.dp(18)
                                    color: inputMuteMouse.containsMouse
                                        ? (mainInputBox.mainSource && mainInputBox.mainSource.audio && mainInputBox.mainSource.audio.muted ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                        : (mainInputBox.mainSource && mainInputBox.mainSource.audio && mainInputBox.mainSource.audio.muted ? Theme.danger : Theme.bgPrimary)
                                    border.width: 1
                                    border.color: inputMuteMouse.containsMouse ? (mainInputBox.mainSource && mainInputBox.mainSource.audio && mainInputBox.mainSource.audio.muted ? Theme.danger : Theme.textPrimary) : Theme.border
                                    radius: 0

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: mainInputBox.mainSource && mainInputBox.mainSource.audio && mainInputBox.mainSource.audio.muted ? "U" : "M"
                                        color: mainInputBox.mainSource && mainInputBox.mainSource.audio && mainInputBox.mainSource.audio.muted ? "white" : Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }

                                    MouseArea {
                                        id: inputMuteMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: mainInputBox.mainSource != null && mainInputBox.mainSource.audio != null
                                        onClicked: {
                                            if (mainInputBox.mainSource && mainInputBox.mainSource.audio)
                                                mainInputBox.mainSource.audio.muted = !mainInputBox.mainSource.audio.muted
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.dp(5)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: mainInputBox.mainSource && mainInputBox.mainSource.audio
                                        ? Math.max(0, Math.min(parent.width, (mainInputBox.mainSource.audio.volume || 0) * parent.width))
                                        : 0
                                    color: Theme.accentSoft
                                    radius: 0
                                }

                                MouseArea {
                                    id: mainSourceMouse
                                    anchors.fill: parent
                                    property bool dragging: false
                                    cursorShape: Qt.SizeHorCursor
                                    onPressed: function(mouse) {
                                        dragging = true
                                        if (mainInputBox.mainSource && mainInputBox.mainSource.audio) mainInputBox.mainSource.audio.volume = Math.max(0, Math.min(1, mouse.x / mainSourceMouse.width))
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (dragging && mainInputBox.mainSource && mainInputBox.mainSource.audio) mainInputBox.mainSource.audio.volume = Math.max(0, Math.min(1, mouse.x / mainSourceMouse.width))
                                    }
                                    onReleased: dragging = false
                                    onWheel: function(wheel) {
                                        if (!mainInputBox.mainSource || !mainInputBox.mainSource.audio) return
                                        var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                        mainInputBox.mainSource.audio.volume = Math.max(0, Math.min(1, (mainInputBox.mainSource.audio.volume || 0) + delta))
                                    }
                                }
                            }
                        }
                    }

                    // ── Other Outputs ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(6)
                        visible: pipewireService && pipewireService.sinkDevices().length > 0

                        IconVolume {
                            Layout.preferredWidth: Theme.dp(14)
                            Layout.preferredHeight: Theme.dp(14)
                            iconColor: Theme.accent
                            iconSize: Theme.dp(11)
                        }

                        Text {
                            text: "Other Outputs"
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Typography.weightMedium || Font.Normal
                            Layout.fillWidth: true
                        }
                    }

                    Repeater {
                        model: pipewireService ? pipewireService.sinkDevices().filter(function(d) { return d !== pipewireService.sink }) : []

                        delegate: Rectangle {
                            property var itemData: modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(48)
                            color: "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(4)
                                spacing: Theme.dp(3)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.dp(4)

                                    IconVolume {
                                        Layout.preferredWidth: Theme.dp(14)
                                        Layout.preferredHeight: Theme.dp(14)
                                        Layout.alignment: Qt.AlignVCenter
                                        iconColor: itemData.audio && itemData.audio.muted
                                            ? Theme.textMuted
                                            : Theme.textPrimary
                                        iconSize: Theme.dp(11)
                                    }

                                    MarqueeText {
                                        text: pipewireService.nodeName(itemData)
                                        textColor: Theme.textPrimary
                                        fontSize: Typography.sizeXXS || 9
                                        fontScale: s
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: itemData.audio ? Math.round((itemData.audio.volume || 0) * 100) + "%" : "--"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: Theme.dp(20)
                                        Layout.preferredHeight: Theme.dp(18)
                                        color: sinkMuteMouse.containsMouse
                                            ? (itemData.audio && itemData.audio.muted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                            : (itemData.audio && itemData.audio.muted ? Theme.accent : Theme.bgPrimary)
                                        border.width: 1
                                        border.color: sinkMuteMouse.containsMouse ? (itemData.audio && itemData.audio.muted ? Theme.accent : Theme.textPrimary) : Theme.border
                                        radius: 0

                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: itemData.audio && itemData.audio.muted ? "U" : "M"
                                            color: itemData.audio && itemData.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        }

                                        MouseArea {
                                            id: sinkMuteMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            enabled: itemData.audio
                                            onClicked: itemData.audio.muted = !itemData.audio.muted
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: Theme.dp(28)
                                        Layout.preferredHeight: Theme.dp(18)
                                        color: sinkSetMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Theme.bgPrimary
                                        border.width: 1
                                        border.color: sinkSetMouse.containsMouse ? Theme.accent : Theme.border
                                        radius: 0

                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Set"
                                            color: sinkSetMouse.containsMouse ? Theme.accent : Theme.textPrimary
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        }

                                        MouseArea {
                                            id: sinkSetMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            enabled: itemData.audio
                                            onClicked: itemData.audio.muted = !itemData.audio.muted
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(5)
                                    color: Theme.bgPrimary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: itemData.audio ? Math.max(0, Math.min(parent.width, (itemData.audio.volume || 0) * parent.width)) : 0
                                        color: Theme.accent
                                        radius: 0
                                    }

                                    MouseArea {
                                        id: sinkDeviceMouse
                                        anchors.fill: parent
                                        property bool dragging: false
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: function(mouse) {
                                            dragging = true
                                            if (itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / sinkDeviceMouse.width))
                                        }
                                        onPositionChanged: function(mouse) {
                                            if (dragging && itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / sinkDeviceMouse.width))
                                        }
                                        onReleased: dragging = false
                                        onWheel: function(wheel) {
                                            if (!itemData.audio) return
                                            var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                            itemData.audio.volume = Math.max(0, Math.min(1, (itemData.audio.volume || 0) + delta))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── App Outputs ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(6)
                        visible: pipewireService && pipewireService.sinkApps().length > 0

                        IconVolume {
                            Layout.preferredWidth: Theme.dp(14)
                            Layout.preferredHeight: Theme.dp(14)
                            iconColor: Theme.textMuted
                            iconSize: Theme.dp(11)
                        }

                        Text {
                            text: "App Outputs"
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            Layout.fillWidth: true
                        }
                    }

                    Repeater {
                        model: pipewireService ? pipewireService.sinkApps() : []

                        delegate: Rectangle {
                            property var itemData: modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(46)
                            color: "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(6)
                                spacing: Theme.dp(6)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.dp(4)

                                    Item {
                                        Layout.preferredWidth: Theme.dp(18)
                                        Layout.preferredHeight: Theme.dp(18)
                                        Layout.alignment: Qt.AlignVCenter

                                        readonly property string resolvedIcon: pipewireService.nodeIconPath(itemData)

                                        Image {
                                            id: appIcon
                                            anchors.fill: parent
                                            source: parent.resolvedIcon
                                            fillMode: Image.PreserveAspectFit
                                            visible: parent.resolvedIcon.length > 0 && status === Image.Ready
                                            asynchronous: true
                                            cache: false
                                            sourceSize.width: Theme.dp(18)
                                            sourceSize.height: Theme.dp(18)
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: Theme.bgSecondary
                                            border.width: 1
                                            border.color: Theme.border
                                            radius: 0
                                            visible: !appIcon.visible

                                            Text {
                                                anchors.centerIn: parent
                                                text: {
                                                    var n = pipewireService.nodeName(itemData)
                                                    return n.length > 0 ? n.charAt(0).toUpperCase() : "♪"
                                                }
                                                color: Theme.textMuted
                                                font.family: Typography.fontFamily
                                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                                font.weight: Typography.weightMedium || Font.Normal
                                            }
                                        }
                                    }

                                    MarqueeText {
                                        text: pipewireService.nodeName(itemData)
                                        textColor: Theme.textPrimary
                                        fontSize: Typography.sizeXXS || 9
                                        fontScale: s
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: itemData.audio ? Math.round((itemData.audio.volume || 0) * 100) + "%" : "--"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: Theme.dp(20)
                                        Layout.preferredHeight: Theme.dp(18)
                                        color: appMuteMouse.containsMouse
                                            ? (itemData.audio && itemData.audio.muted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                            : (itemData.audio && itemData.audio.muted ? Theme.accent : Theme.bgPrimary)
                                        border.width: 1
                                        border.color: appMuteMouse.containsMouse ? (itemData.audio && itemData.audio.muted ? Theme.accent : Theme.textPrimary) : Theme.border
                                        radius: 0

                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: itemData.audio && itemData.audio.muted ? "U" : "M"
                                            color: itemData.audio && itemData.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        }

                                        MouseArea {
                                            id: appMuteMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            enabled: itemData.audio
                                            onClicked: itemData.audio.muted = !itemData.audio.muted
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(5)
                                    color: Theme.bgPrimary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: itemData.audio ? Math.max(0, Math.min(parent.width, (itemData.audio.volume || 0) * parent.width)) : 0
                                        color: Theme.accentSoft
                                        radius: 0
                                    }

                                    MouseArea {
                                        id: sinkAppMouse
                                        anchors.fill: parent
                                        property bool dragging: false
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: function(mouse) {
                                            dragging = true
                                            if (itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / sinkAppMouse.width))
                                        }
                                        onPositionChanged: function(mouse) {
                                            if (dragging && itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / sinkAppMouse.width))
                                        }
                                        onReleased: dragging = false
                                        onWheel: function(wheel) {
                                            if (!itemData.audio) return
                                            var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                            itemData.audio.volume = Math.max(0, Math.min(1, (itemData.audio.volume || 0) + delta))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Other Inputs ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(6)
                        visible: pipewireService && pipewireService.sourceDevices().length > 1

                        IconMic {
                            Layout.preferredWidth: Theme.dp(14)
                            Layout.preferredHeight: Theme.dp(14)
                            iconColor: Theme.textMuted
                            iconSize: Theme.dp(11)
                        }

                        Text {
                            text: "Other Inputs"
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            Layout.fillWidth: true
                        }
                    }

                    Repeater {
                        model: pipewireService ? pipewireService.sourceDevices().slice(1) : []

                        delegate: Rectangle {
                            property var itemData: modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(46)
                            color: "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(6)
                                spacing: Theme.dp(6)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.dp(4)

                                    IconMic {
                                        Layout.preferredWidth: Theme.dp(16)
                                        Layout.preferredHeight: Theme.dp(16)
                                        Layout.alignment: Qt.AlignVCenter
                                        iconColor: itemData.audio && itemData.audio.muted
                                            ? Theme.danger : Theme.textPrimary
                                        iconSize: Theme.dp(13)
                                    }

                                    MarqueeText {
                                        text: pipewireService.nodeName(itemData)
                                        textColor: Theme.textPrimary
                                        fontSize: Typography.sizeXXS || 9
                                        fontScale: s
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: itemData.audio ? Math.round((itemData.audio.volume || 0) * 100) + "%" : "--"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: Theme.dp(20)
                                        Layout.preferredHeight: Theme.dp(18)
                                        color: sourceMuteMouse.containsMouse
                                            ? (itemData.audio && itemData.audio.muted ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                            : (itemData.audio && itemData.audio.muted ? Theme.danger : Theme.bgPrimary)
                                        border.width: 1
                                        border.color: sourceMuteMouse.containsMouse ? (itemData.audio && itemData.audio.muted ? Theme.danger : Theme.textPrimary) : Theme.border
                                        radius: 0

                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: itemData.audio && itemData.audio.muted ? "U" : "M"
                                            color: itemData.audio && itemData.audio.muted ? "white" : Theme.textPrimary
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        }

                                        MouseArea {
                                            id: sourceMuteMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            enabled: itemData.audio
                                            onClicked: itemData.audio.muted = !itemData.audio.muted
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(5)
                                    color: Theme.bgPrimary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: itemData.audio ? Math.max(0, Math.min(parent.width, (itemData.audio.volume || 0) * parent.width)) : 0
                                        color: Theme.accentSoft
                                        radius: 0
                                    }

                                    MouseArea {
                                        id: sourceMouse
                                        anchors.fill: parent
                                        property bool dragging: false
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: function(mouse) {
                                            dragging = true
                                            if (itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / sourceMouse.width))
                                        }
                                        onPositionChanged: function(mouse) {
                                            if (dragging && itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / sourceMouse.width))
                                        }
                                        onReleased: dragging = false
                                        onWheel: function(wheel) {
                                            if (!itemData.audio) return
                                            var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                            itemData.audio.volume = Math.max(0, Math.min(1, (itemData.audio.volume || 0) + delta))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Bottom Spacer for Visibility ──
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(10)
                    }
                }
            }
        }
    }
}
