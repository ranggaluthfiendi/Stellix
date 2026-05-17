import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.config
import qs.components.widgets.rightbar
import qs.components.elements
import Quickshell.Wayland

PopupWindow {
    id: root
    property var popupPanel: null
    property var closeCallback: null
    visible: false

    PwObjectTracker {
        id: pwTracker
        objects: Pipewire.nodes.values
    }

    readonly property var allSinks: Pipewire.nodes.values.filter(function(n) { return n && n.isSink && n.audio })
    readonly property var allSources: Pipewire.nodes.values.filter(function(n) { return n && n.audio && !n.isSink })

    function setSinkVolume(node, value) {
        if (!node || !node.audio) return
        node.audio.volume = Math.max(0, Math.min(1, value))
    }

    function setSourceVolume(node, value) {
        if (!node || !node.audio) return
        node.audio.volume = Math.max(0, Math.min(1, value))
    }

    function sortedSinks() {
        var arr = root.allSinks.slice()
        arr.sort(function(a, b) {
            if (a === Pipewire.defaultAudioSink) return -1
            if (b === Pipewire.defaultAudioSink) return 1
            return 0
        })
        return arr
    }

    function sortedSources() {
        var arr = root.allSources.slice()
        arr.sort(function(a, b) {
            if (a === Pipewire.defaultAudioSource) return -1
            if (b === Pipewire.defaultAudioSource) return 1
            return 0
        })
        return arr
    }

    function sinkDevices() { return root.sortedSinks().filter(function(n) { return !n.isStream }) }
    function sinkApps() { return root.sortedSinks().filter(function(n) { return n.isStream }) }
    function sourceDevices() { return root.sortedSources().filter(function(n) { return !n.isStream }) }
    function sourceApps() { return root.sortedSources().filter(function(n) { return n.isStream }) }

    readonly property int sinkDeviceCount: sinkDevices().length
    readonly property int sinkAppCount: sinkApps().length
    readonly property int sourceDeviceCount: sourceDevices().length
    readonly property int sourceAppCount: sourceApps().length

    readonly property real itemH: Theme.dp(52)
    readonly property real sinkDeviceH: Math.max(sinkDeviceCount, 0) * itemH
    readonly property real sinkAppH: Math.max(sinkAppCount, 0) * itemH
    readonly property real sourceDeviceH: Math.max(sourceDeviceCount, 0) * itemH
    readonly property real sourceAppH: Math.max(sourceAppCount, 0) * itemH
    readonly property real labelH: Theme.dp(16)
    readonly property real sectionDivH: Theme.dp(1)

    readonly property real sinkH: sinkDeviceH + sinkAppH + (sinkDeviceCount > 0 && sinkAppCount > 0 ? (labelH + sectionDivH) : 0) + (sinkDeviceCount > 0 ? labelH : 0) + (sinkAppCount > 0 ? labelH : 0)
    readonly property real sourceH: sourceDeviceH + sourceAppH + (sourceDeviceCount > 0 && sourceAppCount > 0 ? (labelH + sectionDivH) : 0) + (sourceDeviceCount > 0 ? labelH : 0) + (sourceAppCount > 0 ? labelH : 0)
    readonly property real contentH: Theme.dp(22) + Theme.dp(1) + Theme.dp(16) + sinkH + Theme.dp(1) + Theme.dp(16) + sourceH + Theme.dp(16) + Theme.dp(40)

    implicitWidth: Theme.dp(320)
    implicitHeight: Math.min(Math.max(contentH, Theme.dp(120)), Theme.dp(420))
    grabFocus: true

    anchor.window: popupPanel
    anchor.rect.x: -Theme.dp(325)
    anchor.rect.y: Theme.dp(0)

    Rectangle {
        anchors.fill: parent
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(4)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(4)

                Text {
                    text: "Volume"
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 12) * s)
                    font.weight: Typography.weightBold || Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Close"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { if (root.closeCallback) root.closeCallback() }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(1)
                color: Theme.border
            }

            Text {
                text: "Output"
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                font.weight: Typography.weightMedium || Font.Normal
            }

            Text {
                text: "Devices"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                visible: root.sinkDeviceCount > 0
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: sinkDeviceH
                clip: true
                spacing: Theme.dp(3)
                model: root.sinkDevices()
                visible: root.sinkDeviceCount > 0

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: itemH
                    color: modelData === Pipewire.defaultAudioSink ? Theme.bgPrimary : "transparent"
                    border.width: 1
                    border.color: modelData === Pipewire.defaultAudioSink ? Theme.accent : Theme.border
                    radius: 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(6)
                        spacing: Theme.dp(3)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData === Pipewire.defaultAudioSink ? "Main" : ""
                                color: Theme.accent
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                font.weight: Typography.weightBold || Font.Bold
                            }

                            MarqueeText {
                                text: modelData.nickname || modelData.description || modelData.name || "Device"
                                textColor: Theme.textPrimary
                                fontSize: Typography.sizeXXS || 9
                                fontScale: s
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(8)
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: modelData.audio ? Math.max(0, Math.min(parent.width, (modelData.audio.volume || 0) * parent.width)) : 0
                                color: Theme.accent
                                radius: 0
                            }

                            MouseArea {
                                anchors.fill: parent
                                property bool dragging: false
                                onPressed: function(mouse) {
                                    dragging = true
                                    root.setSinkVolume(modelData, mouse.x / width)
                                }
                                onPositionChanged: function(mouse) {
                                    if (dragging) root.setSinkVolume(modelData, mouse.x / width)
                                }
                                onReleased: dragging = false
                                onWheel: function(wheel) {
                                    if (!modelData.audio) return
                                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                    root.setSinkVolume(modelData, (modelData.audio.volume || 0) + delta)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData.audio ? Math.round((modelData.audio.volume || 0) * 100) + "%" : "--"
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(18)
                                color: modelData.audio && modelData.audio.muted ? Theme.accent : Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.audio && modelData.audio.muted ? "U" : "M"
                                    color: modelData.audio && modelData.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: modelData.audio
                                    onClicked: modelData.audio.muted = !modelData.audio.muted
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(36)
                                Layout.preferredHeight: Theme.dp(18)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0
                                visible: modelData !== Pipewire.defaultAudioSink

                                Text {
                                    anchors.centerIn: parent
                                    text: "Set"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: "Applications"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                visible: root.sinkAppCount > 0
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: sinkAppH
                clip: true
                spacing: Theme.dp(3)
                model: root.sinkApps()
                visible: root.sinkAppCount > 0

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: itemH
                    color: modelData === Pipewire.defaultAudioSink ? Theme.bgPrimary : "transparent"
                    border.width: 1
                    border.color: modelData === Pipewire.defaultAudioSink ? Theme.accent : Theme.border
                    radius: 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(6)
                        spacing: Theme.dp(3)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData === Pipewire.defaultAudioSink ? "Main" : ""
                                color: Theme.accent
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                font.weight: Typography.weightBold || Font.Bold
                            }

                            MarqueeText {
                                text: modelData.nickname || modelData.description || modelData.name || "App"
                                textColor: Theme.textPrimary
                                fontSize: Typography.sizeXXS || 9
                                fontScale: s
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(8)
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: modelData.audio ? Math.max(0, Math.min(parent.width, (modelData.audio.volume || 0) * parent.width)) : 0
                                color: Theme.accent
                                radius: 0
                            }

                            MouseArea {
                                anchors.fill: parent
                                property bool dragging: false
                                onPressed: function(mouse) {
                                    dragging = true
                                    root.setSinkVolume(modelData, mouse.x / width)
                                }
                                onPositionChanged: function(mouse) {
                                    if (dragging) root.setSinkVolume(modelData, mouse.x / width)
                                }
                                onReleased: dragging = false
                                onWheel: function(wheel) {
                                    if (!modelData.audio) return
                                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                    root.setSinkVolume(modelData, (modelData.audio.volume || 0) + delta)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData.audio ? Math.round((modelData.audio.volume || 0) * 100) + "%" : "--"
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(18)
                                color: modelData.audio && modelData.audio.muted ? Theme.accent : Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.audio && modelData.audio.muted ? "U" : "M"
                                    color: modelData.audio && modelData.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: modelData.audio
                                    onClicked: modelData.audio.muted = !modelData.audio.muted
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(36)
                                Layout.preferredHeight: Theme.dp(18)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0
                                visible: modelData !== Pipewire.defaultAudioSink

                                Text {
                                    anchors.centerIn: parent
                                    text: "Set"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(1)
                color: Theme.border
            }

            Text {
                text: "Input"
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                font.weight: Typography.weightMedium || Font.Normal
            }

            Text {
                text: "Devices"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                visible: root.sourceDeviceCount > 0
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: sourceDeviceH
                clip: true
                spacing: Theme.dp(3)
                model: root.sourceDevices()
                visible: root.sourceDeviceCount > 0

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: itemH
                    color: modelData === Pipewire.defaultAudioSource ? Theme.bgPrimary : "transparent"
                    border.width: 1
                    border.color: modelData === Pipewire.defaultAudioSource ? Theme.accent : Theme.border
                    radius: 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(6)
                        spacing: Theme.dp(3)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData === Pipewire.defaultAudioSource ? "Main" : ""
                                color: Theme.accent
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                font.weight: Typography.weightBold || Font.Bold
                            }

                            MarqueeText {
                                text: modelData.nickname || modelData.description || modelData.name || "Device"
                                textColor: Theme.textPrimary
                                fontSize: Typography.sizeXXS || 9
                                fontScale: s
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(8)
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: modelData.audio ? Math.max(0, Math.min(parent.width, (modelData.audio.volume || 0) * parent.width)) : 0
                                color: Theme.accent
                                radius: 0
                            }

                            MouseArea {
                                anchors.fill: parent
                                property bool dragging: false
                                onPressed: function(mouse) {
                                    dragging = true
                                    root.setSourceVolume(modelData, mouse.x / width)
                                }
                                onPositionChanged: function(mouse) {
                                    if (dragging) root.setSourceVolume(modelData, mouse.x / width)
                                }
                                onReleased: dragging = false
                                onWheel: function(wheel) {
                                    if (!modelData.audio) return
                                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                    root.setSourceVolume(modelData, (modelData.audio.volume || 0) + delta)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData.audio ? Math.round((modelData.audio.volume || 0) * 100) + "%" : "--"
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(18)
                                color: modelData.audio && modelData.audio.muted ? Theme.accent : Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.audio && modelData.audio.muted ? "U" : "M"
                                    color: modelData.audio && modelData.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: modelData.audio
                                    onClicked: modelData.audio.muted = !modelData.audio.muted
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(36)
                                Layout.preferredHeight: Theme.dp(18)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0
                                visible: modelData !== Pipewire.defaultAudioSource

                                Text {
                                    anchors.centerIn: parent
                                    text: "Set"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Pipewire.preferredDefaultAudioSource = modelData
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: "Applications"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                visible: root.sourceAppCount > 0
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: sourceAppH
                clip: true
                spacing: Theme.dp(3)
                model: root.sourceApps()
                visible: root.sourceAppCount > 0

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: itemH
                    color: modelData === Pipewire.defaultAudioSource ? Theme.bgPrimary : "transparent"
                    border.width: 1
                    border.color: modelData === Pipewire.defaultAudioSource ? Theme.accent : Theme.border
                    radius: 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(6)
                        spacing: Theme.dp(3)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData === Pipewire.defaultAudioSource ? "Main" : ""
                                color: Theme.accent
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                font.weight: Typography.weightBold || Font.Bold
                            }

                            MarqueeText {
                                text: modelData.nickname || modelData.description || modelData.name || "App"
                                textColor: Theme.textPrimary
                                fontSize: Typography.sizeXXS || 9
                                fontScale: s
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(8)
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: modelData.audio ? Math.max(0, Math.min(parent.width, (modelData.audio.volume || 0) * parent.width)) : 0
                                color: Theme.accent
                                radius: 0
                            }

                            MouseArea {
                                anchors.fill: parent
                                property bool dragging: false
                                onPressed: function(mouse) {
                                    dragging = true
                                    root.setSourceVolume(modelData, mouse.x / width)
                                }
                                onPositionChanged: function(mouse) {
                                    if (dragging) root.setSourceVolume(modelData, mouse.x / width)
                                }
                                onReleased: dragging = false
                                onWheel: function(wheel) {
                                    if (!modelData.audio) return
                                    var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01
                                    root.setSourceVolume(modelData, (modelData.audio.volume || 0) + delta)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(4)

                            Text {
                                text: modelData.audio ? Math.round((modelData.audio.volume || 0) * 100) + "%" : "--"
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(20)
                                Layout.preferredHeight: Theme.dp(18)
                                color: modelData.audio && modelData.audio.muted ? Theme.accent : Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.audio && modelData.audio.muted ? "U" : "M"
                                    color: modelData.audio && modelData.audio.muted ? Theme.bgPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: modelData.audio
                                    onClicked: modelData.audio.muted = !modelData.audio.muted
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(36)
                                Layout.preferredHeight: Theme.dp(18)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0
                                visible: modelData !== Pipewire.defaultAudioSource

                                Text {
                                    anchors.centerIn: parent
                                    text: "Set"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Pipewire.preferredDefaultAudioSource = modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
