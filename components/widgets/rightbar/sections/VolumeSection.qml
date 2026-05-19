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
    Layout.preferredHeight: volumeHeader.height + volumeBodyClip.height + Theme.dp(4)
    color: Theme.bgPrimary
    border.width: 1
    border.color: root.volumeExpanded ? Theme.accent : Theme.border
    radius: 0
    clip: true

    property var pipewireService: null
    property real s: Scales.uiScale
    property bool volumeExpanded: false
    property string volumeFilter: "all"

    readonly property var sink: pipewireService ? pipewireService.sink : null
    readonly property bool sinkReady: pipewireService ? pipewireService.sinkReady : false
    readonly property var sinkAudio: sink && sink.audio ? sink.audio : null

    readonly property var source: pipewireService ? pipewireService.source : null
    readonly property bool sourceReady: source && source.audio && source.ready && !isNaN(source.audio.volume)
    readonly property var sourceAudio: source && source.audio ? source.audio : null

    readonly property real maxBodyHeight: Theme.dp(300)
    readonly property real itemH: Theme.dp(40)
    readonly property int maxVisibleItems: 2

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

    function getEmptyText() {
        var f = root.volumeFilter
        if (f === "all") return "No other sources"
        if (f === "apps") return "No app outputs"
        if (f === "outputs") return "No other outputs"
        if (f === "inputs") return "No other inputs"
        return "Empty"
    }

    function nodeName(node) {
        if (!node) return "Unknown"
        var appName = node.properties ? node.properties["application.name"] : null
        if (appName) return appName
        return node.nickname || node.description || node.name || "Device"
    }

    function nodeIconPath(node) {
        if (!node) return ""
        var props = node.properties || {}
        var rawIconName = props["application.icon-name"] || ""
        var rawMediaIcon = props["media.icon-name"] || ""
        var rawAppName = props["application.name"] || node.name || ""
        var rawBinary = props["application.process.binary"] || ""
        var candidates = []
        if (rawIconName.length > 0) {
            candidates.push(rawIconName)
            candidates.push(rawIconName.toLowerCase())
        }
        if (rawMediaIcon.length > 0) {
            candidates.push(rawMediaIcon)
            candidates.push(rawMediaIcon.toLowerCase())
        }
        if (rawBinary.length > 0) {
            candidates.push(rawBinary)
            candidates.push(rawBinary.toLowerCase())
            var baseName = rawBinary.split("/").pop()
            candidates.push(baseName)
            candidates.push(baseName.toLowerCase())
        }
        if (rawAppName.length > 0) {
            candidates.push(rawAppName.toLowerCase())
            candidates.push(rawAppName.toLowerCase().replace(/ /g, "-"))
            candidates.push(rawAppName.toLowerCase().replace(/ /g, ""))
        }
        for (var i = 0; i < candidates.length; i++) {
            var c = candidates[i]
            if (!c || c.length === 0) continue
            var p = Quickshell.iconPath(c, true)
            if (p && p.length > 0) return p
        }
        return ""
    }

    function allSinkDevices() {
        return pipewireService ? pipewireService.sinkDevices() : []
    }

    function allSourceDevices() {
        return pipewireService ? pipewireService.sourceDevices() : []
    }

    // ── HEADER: Main volume bar ──
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
                iconColor: root.sinkReady && root.sinkAudio && root.sinkAudio.muted ? Theme.textMuted : Theme.textPrimary
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
                    width: root.sinkReady && root.sinkAudio
                        ? Math.max(0, Math.min(parent.width, (root.sinkAudio.volume || 0) * parent.width))
                        : 0
                    color: root.sinkReady && root.sinkAudio && root.sinkAudio.muted ? Theme.border : Theme.accentSoft
                    radius: 0
                }

                MouseArea {
                    id: volumeMouse
                    anchors.fill: parent
                    property bool dragging: false
                    cursorShape: Qt.SizeHorCursor
                    onPressed: function(mouse) {
                        dragging = true
                        if (root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, mouse.x / volumeMouse.width))
                    }
                    onPositionChanged: function(mouse) {
                        if (dragging && root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, mouse.x / volumeMouse.width))
                    }
                    onReleased: dragging = false
                    onWheel: function(wheel) {
                        if (!root.sinkAudio) return
                        var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                        root.sinkAudio.volume = Math.max(0, Math.min(1, (root.sinkAudio.volume || 0) + delta))
                    }
                }
            }

            Text {
                text: root.sinkAudio ? Math.round((root.sinkAudio.volume || 0) * 100) + "%" : "--"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
            }

            Rectangle {
                Layout.preferredWidth: Theme.dp(22)
                Layout.preferredHeight: Theme.dp(22)
                Layout.alignment: Qt.AlignVCenter
                color: muteMouse.containsMouse
                    ? (root.sinkAudio && root.sinkAudio.muted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                    : (root.sinkAudio && root.sinkAudio.muted ? Theme.accent : Theme.bgSecondary)
                border.width: 1
                border.color: muteMouse.containsMouse ? (root.sinkAudio && root.sinkAudio.muted ? Theme.accent : Theme.textPrimary) : Theme.border
                radius: 0

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: root.sinkAudio && root.sinkAudio.muted ? "U" : "M"
                    color: root.sinkAudio && root.sinkAudio.muted ? Theme.bgPrimary : Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                    font.weight: Typography.weightBold || Font.Bold
                }

                MouseArea {
                    id: muteMouse
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.sinkReady
                    onClicked: { if (root.sinkAudio) root.sinkAudio.muted = !root.sinkAudio.muted }
                }
            }

            Rectangle {
                Layout.preferredWidth: Theme.dp(22)
                Layout.preferredHeight: Theme.dp(22)
                Layout.alignment: Qt.AlignVCenter
                color: expandMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                border.width: 1
                border.color: expandMouse.containsMouse ? Theme.textPrimary : Theme.border
                radius: 0

                Behavior on color { ColorAnimation { duration: 100 } }

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

    // ── BODY: Expandable content ──
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
                anchors.topMargin: Theme.dp(4)
                anchors.leftMargin: Theme.dp(4)
                anchors.rightMargin: Theme.dp(4)
                anchors.bottomMargin: Theme.dp(8)
                spacing: Theme.dp(6)

                // ── Main Output Section ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)
                    visible: root.sinkReady

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(4)

                        Text {
                            text: "Output"
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(1)
                            color: Theme.border
                        }

                        // Device selector button
                        Rectangle {
                            implicitWidth: Theme.dp(16) + outDevLbl.implicitWidth + Theme.dp(14)
                            implicitHeight: Theme.dp(18)
                            color: outDevMouse.containsMouse ? Theme.accent : Theme.bgPrimary
                            border.width: 1
                            border.color: outDevMouse.containsMouse ? Theme.accent : Theme.border
                            radius: 0
                            visible: root.allSinkDevices().length > 1

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(3)
                                spacing: Theme.dp(3)

                                Text {
                                    text: "▾"
                                    color: outDevMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted
                                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                    font.weight: Typography.weightBold || Font.Bold
                                }

                                Text {
                                    id: outDevLbl
                                    text: root.nodeName(root.sink)
                                    color: outDevMouse.containsMouse ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            MouseArea {
                                id: outDevMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (outputDevicePopup.visible) {
                                        outputDevicePopup.close()
                                    } else {
                                        outputDevicePopup.open()
                                    }
                                }
                            }
                        }
                    }

                    // Main Output Item: Icon | Name | % | Mute (top), Slider (bottom)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(38)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(4)
                            spacing: Theme.dp(6)

                            // Icon
                            Item {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(20)
                                Layout.alignment: Qt.AlignVCenter

                                Image {
                                    id: outIconImg
                                    anchors.fill: parent
                                    source: root.nodeIconPath(root.sink)
                                    fillMode: Image.PreserveAspectFit
                                    visible: source.length > 0 && status === Image.Ready
                                    asynchronous: true
                                }

                                IconVolume {
                                    anchors.fill: parent
                                    iconColor: root.sinkAudio && root.sinkAudio.muted ? Theme.textMuted : Theme.accent
                                    iconSize: Theme.dp(12)
                                    visible: !outIconImg.visible
                                }
                            }

                            // Name + Slider column
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: Theme.dp(2)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.dp(4)

                                    MarqueeText {
                                        text: root.nodeName(root.sink)
                                        textColor: Theme.textPrimary
                                        fontSize: Typography.sizeXXS || 8
                                        fontScale: s
                                        textPadding: 0
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.sinkAudio ? Math.round((root.sinkAudio.volume || 0) * 100) + "%" : "--"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(6)
                                    color: Theme.bgPrimary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: root.sinkAudio ? Math.max(0, Math.min(parent.width, (root.sinkAudio.volume || 0) * parent.width)) : 0
                                        color: root.sinkAudio && root.sinkAudio.muted ? Theme.border : Theme.accent
                                        radius: 0
                                    }

                                    MouseArea {
                                        id: outSliderMouse
                                        anchors.fill: parent
                                        property bool dragging: false
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: function(mouse) {
                                            dragging = true
                                            if (root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, mouse.x / outSliderMouse.width))
                                        }
                                        onPositionChanged: function(mouse) {
                                            if (dragging && root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, mouse.x / outSliderMouse.width))
                                        }
                                        onReleased: dragging = false
                                        onWheel: function(wheel) {
                                            if (!root.sinkAudio) return
                                            var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                            root.sinkAudio.volume = Math.max(0, Math.min(1, (root.sinkAudio.volume || 0) + delta))
                                        }
                                    }
                                }
                            }

                            // Mute button
                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(20)
                                Layout.alignment: Qt.AlignVCenter
                                color: outMuteMouse.containsMouse
                                    ? (root.sinkAudio && root.sinkAudio.muted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                    : (root.sinkAudio && root.sinkAudio.muted ? Theme.accent : Theme.bgPrimary)
                                border.width: 1
                                border.color: outMuteMouse.containsMouse ? (root.sinkAudio && root.sinkAudio.muted ? Theme.accent : Theme.textPrimary) : Theme.border
                                radius: 0

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.sinkAudio && root.sinkAudio.muted ? "U" : "M"
                                    color: root.sinkAudio && root.sinkAudio.muted ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: Typography.weightBold || Font.Bold
                                }

                                MouseArea {
                                    id: outMuteMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: { if (root.sinkAudio) root.sinkAudio.muted = !root.sinkAudio.muted }
                                }
                            }
                        }
                    }
                }

                // ── Main Input Section ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)
                    visible: root.sourceReady

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(4)

                        Text {
                            text: "Input"
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(1)
                            color: Theme.border
                        }

                        // Device selector button
                        Rectangle {
                            implicitWidth: Theme.dp(16) + inDevLbl.implicitWidth + Theme.dp(14)
                            implicitHeight: Theme.dp(18)
                            color: inDevSelMouse.containsMouse ? Theme.accent : Theme.bgPrimary
                            border.width: 1
                            border.color: inDevSelMouse.containsMouse ? Theme.accent : Theme.border
                            radius: 0
                            visible: root.allSourceDevices().length > 1

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(3)
                                spacing: Theme.dp(3)

                                Text {
                                    text: "▾"
                                    color: inDevSelMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted
                                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                    font.weight: Typography.weightBold || Font.Bold
                                }

                                Text {
                                    id: inDevLbl
                                    text: root.nodeName(root.source)
                                    color: inDevSelMouse.containsMouse ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            MouseArea {
                                id: inDevSelMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (inputDevicePopup.visible) {
                                        inputDevicePopup.close()
                                    } else {
                                        inputDevicePopup.open()
                                    }
                                }
                            }
                        }
                    }

                    // Main Input Item: Icon | Name | % | Mute (top), Slider (bottom)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(38)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(4)
                            spacing: Theme.dp(6)

                            // Icon
                            Item {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(20)
                                Layout.alignment: Qt.AlignVCenter

                                Image {
                                    id: inIconImg
                                    anchors.fill: parent
                                    source: root.nodeIconPath(root.source)
                                    fillMode: Image.PreserveAspectFit
                                    visible: source.length > 0 && status === Image.Ready
                                    asynchronous: true
                                }

                                IconMic {
                                    anchors.fill: parent
                                    iconColor: root.sourceAudio && root.sourceAudio.muted ? Theme.danger : Theme.textPrimary
                                    iconSize: Theme.dp(12)
                                    visible: !inIconImg.visible
                                }
                            }

                            // Name + Slider column
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: Theme.dp(2)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.dp(4)

                                    MarqueeText {
                                        text: root.nodeName(root.source)
                                        textColor: Theme.textPrimary
                                        fontSize: Typography.sizeXXS || 8
                                        fontScale: s
                                        textPadding: 0
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.sourceAudio ? Math.round((root.sourceAudio.volume || 0) * 100) + "%" : "--"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(6)
                                    color: Theme.bgPrimary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: root.sourceAudio ? Math.max(0, Math.min(parent.width, (root.sourceAudio.volume || 0) * parent.width)) : 0
                                        color: root.sourceAudio && root.sourceAudio.muted ? Theme.danger : Theme.accentSoft
                                        radius: 0
                                    }

                                    MouseArea {
                                        id: inSliderMouse
                                        anchors.fill: parent
                                        property bool dragging: false
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: function(mouse) {
                                            dragging = true
                                            if (root.sourceAudio) root.sourceAudio.volume = Math.max(0, Math.min(1, mouse.x / inSliderMouse.width))
                                        }
                                        onPositionChanged: function(mouse) {
                                            if (dragging && root.sourceAudio) root.sourceAudio.volume = Math.max(0, Math.min(1, mouse.x / inSliderMouse.width))
                                        }
                                        onReleased: dragging = false
                                        onWheel: function(wheel) {
                                            if (!root.sourceAudio) return
                                            var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                            root.sourceAudio.volume = Math.max(0, Math.min(1, (root.sourceAudio.volume || 0) + delta))
                                        }
                                    }
                                }
                            }

                            // Mute button
                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(20)
                                Layout.alignment: Qt.AlignVCenter
                                color: inMuteMouse.containsMouse
                                    ? (root.sourceAudio && root.sourceAudio.muted ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                    : (root.sourceAudio && root.sourceAudio.muted ? Theme.danger : Theme.bgPrimary)
                                border.width: 1
                                border.color: inMuteMouse.containsMouse ? (root.sourceAudio && root.sourceAudio.muted ? Theme.danger : Theme.textPrimary) : Theme.border
                                radius: 0

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.sourceAudio && root.sourceAudio.muted ? "U" : "M"
                                    color: root.sourceAudio && root.sourceAudio.muted ? "white" : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: Typography.weightBold || Font.Bold
                                }

                                MouseArea {
                                    id: inMuteMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: { if (root.sourceAudio) root.sourceAudio.muted = !root.sourceAudio.muted }
                                }
                            }
                        }
                    }
                }

                // ── Category Filter ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)

                    Rectangle {
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.preferredWidth: catAllLbl.implicitWidth + Theme.dp(8)
                        color: catAllMouse.containsMouse && root.volumeFilter !== "all"
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            : (root.volumeFilter === "all" ? Theme.accentSoft : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.volumeFilter === "all" ? Theme.accent : Theme.border
                        radius: 0
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: catAllLbl
                            anchors.centerIn: parent
                            text: "All"
                            color: root.volumeFilter === "all" ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: root.volumeFilter === "all" ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                        }
                        MouseArea {
                            id: catAllMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.volumeFilter = "all"
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.preferredWidth: catAppsLbl.implicitWidth + Theme.dp(8)
                        color: catAppsMouse.containsMouse && root.volumeFilter !== "apps"
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            : (root.volumeFilter === "apps" ? Theme.labelApp : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.volumeFilter === "apps" ? Theme.labelApp : Theme.border
                        radius: 0
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: catAppsLbl
                            anchors.centerIn: parent
                            text: "Apps"
                            color: root.volumeFilter === "apps" ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        }
                        MouseArea {
                            id: catAppsMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.volumeFilter = "apps"
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.preferredWidth: catOutLbl.implicitWidth + Theme.dp(8)
                        color: catOutMouse.containsMouse && root.volumeFilter !== "outputs"
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            : (root.volumeFilter === "outputs" ? Theme.labelOutput : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.volumeFilter === "outputs" ? Theme.labelOutput : Theme.border
                        radius: 0
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: catOutLbl
                            anchors.centerIn: parent
                            text: "Outputs"
                            color: root.volumeFilter === "outputs" ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        }
                        MouseArea {
                            id: catOutMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.volumeFilter = "outputs"
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.preferredWidth: catInLbl.implicitWidth + Theme.dp(8)
                        color: catInMouse.containsMouse && root.volumeFilter !== "inputs"
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            : (root.volumeFilter === "inputs" ? Theme.labelInput : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.volumeFilter === "inputs" ? Theme.labelInput : Theme.border
                        radius: 0
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: catInLbl
                            anchors.centerIn: parent
                            text: "Inputs"
                            color: root.volumeFilter === "inputs" ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        }
                        MouseArea {
                            id: catInMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.volumeFilter = "inputs"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(1)
                    color: Theme.border
                }

                // ── Volume Item Delegate ──
                Component {
                    id: volItemDelegate
                    Rectangle {
                        id: volItemRoot
                        property var itemData: modelData
                        Layout.fillWidth: true
                        height: root.itemH
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.border
                        radius: 0

                        readonly property string categoryLabel: {
                            if (!itemData) return ""
                            if (itemData.isStream) return "App"
                            if (itemData.isSink) return "Out"
                            return "In"
                        }
                        readonly property bool isApp: categoryLabel === "App"
                        readonly property bool isInput: !itemData.isSink && !itemData.isStream
                        readonly property bool isOutput: itemData.isSink && !itemData.isStream
                        readonly property color badgeColor: isInput ? Theme.labelInput : (isApp ? Theme.labelApp : Theme.labelOutput)
                        readonly property color sliderSoft: isInput ? Qt.rgba(Theme.labelInput.r, Theme.labelInput.g, Theme.labelInput.b, 0.2) : (isApp ? Theme.accentSoft : Qt.rgba(Theme.labelOutput.r, Theme.labelOutput.g, Theme.labelOutput.b, 0.2))

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(4)
                            spacing: Theme.dp(6)

                            // Icon
                            Item {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(20)
                                Layout.alignment: Qt.AlignVCenter

                                readonly property string resolvedIcon: pipewireService ? pipewireService.nodeIconPath(itemData) : ""

                                Image {
                                    id: volItemIcon
                                    anchors.fill: parent
                                    source: parent.resolvedIcon
                                    fillMode: Image.PreserveAspectFit
                                    visible: parent.resolvedIcon.length > 0 && status === Image.Ready
                                    asynchronous: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.bgSecondary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0
                                    visible: !volItemIcon.visible

                                    Text {
                                        anchors.centerIn: parent
                                        text: pipewireService ? pipewireService.nodeName(itemData).charAt(0).toUpperCase() : "?"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                    }
                                }
                            }

                            // Name + Slider column
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: Theme.dp(2)

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.dp(4)

                                    // Category Label Badge
                                    Rectangle {
                                        height: Theme.dp(12)
                                        width: catLbl.implicitWidth + Theme.dp(6)
                                        color: volItemRoot.badgeColor
                                        border.width: 1
                                        border.color: volItemRoot.badgeColor
                                        radius: Theme.dp(2)

                                        Text {
                                            id: catLbl
                                            anchors.centerIn: parent
                                            text: volItemRoot.categoryLabel
                                            color: Theme.bgPrimary
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 6) * s)
                                            font.weight: Typography.weightBold || Font.Bold
                                        }
                                    }

                                    MarqueeText {
                                        text: pipewireService ? pipewireService.nodeName(itemData) : ""
                                        textColor: Theme.textPrimary
                                        fontSize: Typography.sizeXXS || 8
                                        fontScale: s
                                        textPadding: 0
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: itemData.audio ? Math.round((itemData.audio.volume || 0) * 100) + "%" : "--"
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(6)
                                    color: Theme.bgSecondary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: itemData.audio ? Math.max(0, Math.min(parent.width, (itemData.audio.volume || 0) * parent.width)) : 0
                                        color: itemData.audio && itemData.audio.muted ? (volItemRoot.isInput ? Theme.danger : Theme.border) : volItemRoot.sliderSoft
                                        radius: 0
                                    }

                                    MouseArea {
                                        id: volBarMouse
                                        anchors.fill: parent
                                        property bool dragging: false
                                        cursorShape: Qt.SizeHorCursor
                                        onPressed: function(mouse) {
                                            dragging = true
                                            if (itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / volBarMouse.width))
                                        }
                                        onPositionChanged: function(mouse) {
                                            if (dragging && itemData.audio) itemData.audio.volume = Math.max(0, Math.min(1, mouse.x / volBarMouse.width))
                                        }
                                        onReleased: dragging = false
                                        onWheel: function(wheel) {
                                            if (!itemData.audio) return
                                            var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                            itemData.audio.volume = Math.max(0, Math.min(1, (itemData.audio.volume || 0) + delta))
                                        }
                                    }
                                }
                            }

                            // Mute button
                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(20)
                                Layout.alignment: Qt.AlignVCenter
                                color: volMuteMouse.containsMouse
                                    ? (itemData.audio && itemData.audio.muted ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                    : (itemData.audio && itemData.audio.muted ? Theme.danger : Theme.bgPrimary)
                                border.width: 1
                                border.color: volMuteMouse.containsMouse ? (itemData.audio && itemData.audio.muted ? Theme.danger : Theme.textPrimary) : Theme.border
                                radius: 0
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: itemData.audio && itemData.audio.muted ? "U" : "M"
                                    color: itemData.audio && itemData.audio.muted ? "white" : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    id: volMuteMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: { if (itemData.audio) itemData.audio.muted = !itemData.audio.muted }
                                }
                            }
                        }
                    }
                }

                // ── All Sources ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)
                    visible: root.volumeFilter === "all"

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: {
                            var c = allRepeater.count
                            var vis = Math.min(c, root.maxVisibleItems)
                            return vis > 0 ? vis * root.itemH + Math.max(vis - 1, 0) * Theme.dp(3) + Theme.dp(4) : Theme.dp(40)
                        }

                        Flickable {
                            anchors.fill: parent
                            contentWidth: parent.width
                            contentHeight: allColumn.implicitHeight
                            interactive: contentHeight > height
                            clip: true

                            ScrollBar.vertical: ScrollBar {
                                policy: allRepeater.count > root.maxVisibleItems ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                                width: Theme.dp(4)
                            }

                            ColumnLayout {
                                id: allColumn
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Theme.dp(3)

                                Repeater {
                                    id: allRepeater
                                    model: pipewireService ? pipewireService.sinkApps() : []
                                    delegate: volItemDelegate
                                }

                                Repeater {
                                    id: allSinksRepeater
                                    model: pipewireService ? pipewireService.sinkDevices().filter(function(d) { return d !== pipewireService.sink }) : []
                                    delegate: volItemDelegate
                                }

                                Repeater {
                                    id: allSourcesRepeater
                                    model: pipewireService ? pipewireService.sourceDevices().slice(1) : []
                                    delegate: volItemDelegate
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Theme.dp(4)
                            visible: (allRepeater.count + allSinksRepeater.count + allSourcesRepeater.count) === 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.getEmptyText()
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }
                        }
                    }
                }

                // ── Apps ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)
                    visible: root.volumeFilter === "apps"

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: {
                            var c = appsRepeater.count
                            var vis = Math.min(c, root.maxVisibleItems)
                            return vis > 0 ? vis * root.itemH + Math.max(vis - 1, 0) * Theme.dp(3) + Theme.dp(4) : Theme.dp(40)
                        }

                        Flickable {
                            anchors.fill: parent
                            contentWidth: parent.width
                            contentHeight: appsColumn.implicitHeight
                            interactive: contentHeight > height
                            clip: true

                            ScrollBar.vertical: ScrollBar {
                                policy: appsRepeater.count > root.maxVisibleItems ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                                width: Theme.dp(4)
                            }

                            ColumnLayout {
                                id: appsColumn
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Theme.dp(3)

                                Repeater {
                                    id: appsRepeater
                                    model: pipewireService ? pipewireService.sinkApps() : []
                                    delegate: volItemDelegate
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Theme.dp(4)
                            visible: appsRepeater.count === 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.getEmptyText()
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }
                        }
                    }
                }

                // ── Outputs ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)
                    visible: root.volumeFilter === "outputs"

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: {
                            var c = outputsRepeater.count
                            var vis = Math.min(c, root.maxVisibleItems)
                            return vis > 0 ? vis * root.itemH + Math.max(vis - 1, 0) * Theme.dp(3) + Theme.dp(4) : Theme.dp(40)
                        }

                        Flickable {
                            anchors.fill: parent
                            contentWidth: parent.width
                            contentHeight: outputsColumn.implicitHeight
                            interactive: contentHeight > height
                            clip: true

                            ScrollBar.vertical: ScrollBar {
                                policy: outputsRepeater.count > root.maxVisibleItems ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                                width: Theme.dp(4)
                            }

                            ColumnLayout {
                                id: outputsColumn
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Theme.dp(3)

                                Repeater {
                                    id: outputsRepeater
                                    model: pipewireService ? pipewireService.sinkDevices().filter(function(d) { return d !== pipewireService.sink }) : []
                                    delegate: volItemDelegate
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Theme.dp(4)
                            visible: outputsRepeater.count === 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.getEmptyText()
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }
                        }
                    }
                }

                // ── Inputs ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)
                    visible: root.volumeFilter === "inputs"

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: {
                            var c = inputsRepeater.count
                            var vis = Math.min(c, root.maxVisibleItems)
                            return vis > 0 ? vis * root.itemH + Math.max(vis - 1, 0) * Theme.dp(3) + Theme.dp(4) : Theme.dp(40)
                        }

                        Flickable {
                            anchors.fill: parent
                            contentWidth: parent.width
                            contentHeight: inputsColumn.implicitHeight
                            interactive: contentHeight > height
                            clip: true

                            ScrollBar.vertical: ScrollBar {
                                policy: inputsRepeater.count > root.maxVisibleItems ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                                width: Theme.dp(4)
                            }

                            ColumnLayout {
                                id: inputsColumn
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Theme.dp(3)

                                Repeater {
                                    id: inputsRepeater
                                    model: pipewireService ? pipewireService.sourceDevices().slice(1) : []
                                    delegate: volItemDelegate
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Theme.dp(4)
                            visible: inputsRepeater.count === 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.getEmptyText()
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Output Device Popup ──
    Popup {
        id: outputDevicePopup
        x: Theme.dp(4)
        y: Theme.dp(44) + Theme.dp(4)
        width: parent.width - Theme.dp(8)
        implicitHeight: outputDeviceContent.implicitHeight + Theme.dp(8)
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.accent
            radius: 0
        }

        ColumnLayout {
            id: outputDeviceContent
            anchors.fill: parent
            anchors.margins: Theme.dp(4)
            spacing: Theme.dp(2)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(4)

                Text {
                    text: "🔊"
                    font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                }

                Text {
                    text: "Select Output"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    font.weight: Typography.weightBold || Font.Bold
                    Layout.fillWidth: true
                }

                Text {
                    text: "✕"
                    color: outPopupCloseMouse.containsMouse ? Theme.danger : Theme.textMuted
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        id: outPopupCloseMouse
                        anchors.fill: parent
                        anchors.margins: -Theme.dp(4)
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: outputDevicePopup.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(1)
                color: Theme.border
            }

            Repeater {
                model: root.allSinkDevices()

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(30)
                    color: outDevItemMouse.containsMouse ? Theme.accent : (root.sink && modelData.id === root.sink.id ? Theme.accentSoft : Theme.bgPrimary)
                    border.width: 1
                    border.color: root.sink && modelData.id === root.sink.id ? Theme.accent : Theme.border
                    radius: 0

                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(6)
                        spacing: Theme.dp(6)

                        Text {
                            text: root.sink && modelData.id === root.sink.id ? "✓" : "○"
                            color: root.sink && modelData.id === root.sink.id ? Theme.bgPrimary : (outDevItemMouse.containsMouse ? Theme.bgPrimary : Theme.accent)
                            font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Text {
                            text: root.nodeName(modelData)
                            color: outDevItemMouse.containsMouse || (root.sink && modelData.id === root.sink.id) ? Theme.bgPrimary : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: root.sink && modelData.id === root.sink.id ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: outDevItemMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            Pipewire.preferredDefaultAudioSink = modelData
                            outputDevicePopup.close()
                        }
                    }
                }
            }
        }

        function open() {
            visible = true
        }

        function close() {
            visible = false
        }
    }

    // ── Input Device Popup ──
    Popup {
        id: inputDevicePopup
        x: Theme.dp(4)
        y: Theme.dp(44) + Theme.dp(4) + Theme.dp(38) + Theme.dp(6) + Theme.dp(38) + Theme.dp(6)
        width: parent.width - Theme.dp(8)
        implicitHeight: inputDeviceContent.implicitHeight + Theme.dp(8)
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.accent
            radius: 0
        }

        ColumnLayout {
            id: inputDeviceContent
            anchors.fill: parent
            anchors.margins: Theme.dp(4)
            spacing: Theme.dp(2)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(4)

                Text {
                    text: "🎤"
                    font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                }

                Text {
                    text: "Select Input"
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    font.weight: Typography.weightBold || Font.Bold
                    Layout.fillWidth: true
                }

                Text {
                    text: "✕"
                    color: inPopupCloseMouse.containsMouse ? Theme.danger : Theme.textMuted
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        id: inPopupCloseMouse
                        anchors.fill: parent
                        anchors.margins: -Theme.dp(4)
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: inputDevicePopup.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(1)
                color: Theme.border
            }

            Repeater {
                model: root.allSourceDevices()

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(30)
                    color: inDevItemMouse.containsMouse ? Theme.accent : (root.source && modelData.id === root.source.id ? Theme.accentSoft : Theme.bgPrimary)
                    border.width: 1
                    border.color: root.source && modelData.id === root.source.id ? Theme.accent : Theme.border
                    radius: 0

                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(6)
                        spacing: Theme.dp(6)

                        Text {
                            text: root.source && modelData.id === root.source.id ? "✓" : "○"
                            color: root.source && modelData.id === root.source.id ? Theme.bgPrimary : (inDevItemMouse.containsMouse ? Theme.bgPrimary : Theme.accent)
                            font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Text {
                            text: root.nodeName(modelData)
                            color: inDevItemMouse.containsMouse || (root.source && modelData.id === root.source.id) ? Theme.bgPrimary : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: root.source && modelData.id === root.source.id ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: inDevItemMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            Pipewire.preferredDefaultAudioSource = modelData
                            inputDevicePopup.close()
                        }
                    }
                }
            }
        }

        function open() {
            visible = true
        }

        function close() {
            visible = false
        }
    }
}
