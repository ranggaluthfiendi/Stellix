import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.config
import qs.components.widgets.barpopup
import qs.components.elements
import Quickshell.Wayland

PopupWindow {
    id: root
    color: "transparent"

    property var popupPanel: null
    property var closeCallback: null
    visible: false
    grabFocus: false

    property real s: Scales.uiScale

    property bool slideIn: false
    property real slideY: -Theme.dp(20)

    readonly property real itemH: Theme.dp(32)
    readonly property real headerH: Theme.dp(36)
    readonly property real maxAvailableH: itemH * 2

    property var btAdapter: Bluetooth.defaultAdapter

    readonly property var connectedDevices: sortedDevices().filter(function(d) { return d.connected })
    readonly property var pairedDevices: sortedDevices().filter(function(d) { return !d.connected && d.bonded })
    readonly property var availableDevices: sortedDevices().filter(function(d) { return !d.connected && !d.bonded })

    readonly property int connectedCount: connectedDevices.length
    readonly property int pairedCount: pairedDevices.length
    readonly property int availableCount: availableDevices.length

    readonly property real connectedH: connectedCount > 0 ? connectedCount * itemH : 0
    readonly property real pairedH: pairedCount > 0 ? pairedCount * itemH : 0
    readonly property real availableH: availableCount > 0 ? Math.min(availableCount * itemH, maxAvailableH) : 0

    readonly property real listH: {
        var h = connectedH
        if (pairedCount > 0) h += Theme.dp(24) + pairedH
        if (availableCount > 0) h += Theme.dp(24) + availableH
        if (h === 0) h = itemH
        return h
    }

    implicitWidth: Theme.dp(252)
    implicitHeight: headerH + Theme.dp(28) + listH + Theme.dp(8)

    anchor.window: popupPanel
    anchor.rect.x: -(implicitWidth + Theme.dp(372) + Theme.dp(8))

    onVisibleChanged: {
        if (visible) {
            slideY = -Theme.dp(20)
            slideIn = true
        }
    }

    function sortedDevices() {
        if (!btAdapter || !btAdapter.devices) return []
        var arr = btAdapter.devices.values.slice()
        arr.sort(function(a, b) {
            if (a.connected && !b.connected) return -1
            if (!a.connected && b.connected) return 1
            if (a.bonded && !b.bonded) return -1
            if (!a.bonded && b.bonded) return 1
            return 0
        })
        return arr
    }

    function isAdapterDiscoverable() {
        return root.btAdapter && root.btAdapter.discoverable === true
    }

    Rectangle {
        anchors.fill: parent
        y: root.slideY
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0
        clip: true

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(6)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.headerH
                color: Theme.bgPrimary
                border.width: 1
                border.color: Theme.border
                radius: 0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(8)
                    spacing: Theme.dp(8)

                    IconBluetooth {
                        Layout.preferredWidth: Theme.dp(16)
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.alignment: Qt.AlignVCenter
                        iconColor: root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.textPrimary
                        iconSize: Theme.dp(12)
                    }

                    MarqueeText {
                        Layout.fillWidth: true
                        text: root.btAdapter && root.btAdapter.enabled ? "Bluetooth — On" : "Bluetooth — Off"
                        textColor: root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.textPrimary
                        fontSize: 10
                        fontScale: s
                        fontWeight: Typography.weightMedium || Font.Normal
                        scrolling: true
                        textPadding: 0
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(36)
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.alignment: Qt.AlignVCenter
                        color: btToggleMouse.containsMouse
                            ? (root.btAdapter && root.btAdapter.enabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                            : (root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.bgSecondary)
                        border.width: 1
                        border.color: root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.btAdapter && root.btAdapter.enabled ? "On" : "Off"
                            color: root.btAdapter && root.btAdapter.enabled ? Theme.bgPrimary : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: root.btAdapter && root.btAdapter.enabled
                                ? (Typography.weightBold || Font.Bold)
                                : (Typography.weightRegular || Font.Normal)
                        }

                        MouseArea {
                            id: btToggleMouse
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: root.btAdapter
                            onClicked: { if (root.btAdapter) root.btAdapter.enabled = !root.btAdapter.enabled }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(36)
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.alignment: Qt.AlignVCenter
                        color: discToggleMouse.containsMouse
                            ? (isAdapterDiscoverable() ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                            : (isAdapterDiscoverable() ? Theme.accent : Theme.bgPrimary)
                        border.width: 1
                        border.color: isAdapterDiscoverable() ? Theme.accent : Theme.border
                        radius: 0
                        visible: root.btAdapter && root.btAdapter.enabled

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "SHOW"
                            color: isAdapterDiscoverable() ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        MouseArea {
                            id: discToggleMouse
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: root.btAdapter && root.btAdapter.enabled
                            onClicked: {
                                if (root.btAdapter && root.btAdapter.discoverable !== undefined) {
                                    root.btAdapter.discoverable = !root.btAdapter.discoverable
                                }
                            }
                        }
                    }
                }
            }

            // ── Connected ──
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.connectedCount > 0 ? Theme.dp(20) : 0
                visible: root.connectedCount > 0
                spacing: Theme.dp(4)

                Text {
                    text: "Connected"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                    font.weight: Typography.weightMedium || Font.Normal
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(1)
                    color: Theme.border
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: Theme.dp(3)
                visible: root.connectedCount > 0

                Repeater {
                    model: root.connectedDevices

                    delegate: Rectangle {
                        property var device: modelData
                        width: parent.width
                        height: root.itemH
                        color: connRowMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : Theme.bgPrimary
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        MouseArea {
                            id: connRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {}
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(6)
                            spacing: Theme.dp(6)
                            z: 1

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(6)
                                Layout.preferredHeight: Theme.dp(6)
                                Layout.alignment: Qt.AlignVCenter
                                radius: Theme.dp(3)
                                color: Theme.accent
                            }

                            MarqueeText {
                                text: device.name || device.deviceName || "Unknown"
                                textColor: Theme.textPrimary
                                fontSize: 9
                                fontScale: s
                                fontWeight: Typography.weightBold || Font.Bold
                                scrolling: true
                                textPadding: 0
                                Layout.fillWidth: true
                            }

                            Text {
                                text: device.batteryAvailable ? Math.round(device.battery * 100) + "%" : ""
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(50)
                                Layout.preferredHeight: Theme.dp(20)
                                color: discBtnMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgPrimary
                                border.width: 1
                                border.color: discBtnMouse.containsMouse ? Theme.textPrimary : Theme.border
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Disc."
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: Typography.weightRegular || Font.Normal
                                }

                                MouseArea {
                                    id: discBtnMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: device.disconnect()
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(24)
                                Layout.preferredHeight: Theme.dp(20)
                                color: forgetBtnMouse.containsMouse ? Theme.danger : Theme.bgPrimary
                                border.width: 1
                                border.color: forgetBtnMouse.containsMouse ? Theme.danger : Theme.border
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: forgetBtnMouse.containsMouse ? "#ffffff" : Theme.danger
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: forgetBtnMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        try { device.disconnect() } catch(e) {}
                                        try { device.forget() } catch(e) {}
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Paired ──
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.pairedCount > 0 ? Theme.dp(20) : 0
                visible: root.pairedCount > 0
                spacing: Theme.dp(4)

                Text {
                    text: "Paired"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                    font.weight: Typography.weightMedium || Font.Normal
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(1)
                    color: Theme.border
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: Theme.dp(3)
                visible: root.pairedCount > 0

                Repeater {
                    model: root.pairedDevices

                    delegate: Rectangle {
                        property var device: modelData
                        width: parent.width
                        height: root.itemH
                        color: pairedRowMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04) : Theme.bgPrimary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        MouseArea {
                            id: pairedRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {}
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(6)
                            spacing: Theme.dp(6)
                            z: 1

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(6)
                                Layout.preferredHeight: Theme.dp(6)
                                Layout.alignment: Qt.AlignVCenter
                                radius: Theme.dp(3)
                                color: Theme.accentSoft
                            }

                            MarqueeText {
                                text: device.name || device.deviceName || "Unknown"
                                textColor: Theme.textPrimary
                                fontSize: 9
                                fontScale: s
                                fontWeight: Typography.weightRegular || Font.Normal
                                scrolling: true
                                textPadding: 0
                                Layout.fillWidth: true
                            }

                            Text {
                                text: device.batteryAvailable ? Math.round(device.battery * 100) + "%" : ""
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(50)
                                Layout.preferredHeight: Theme.dp(20)
                                color: pairConnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Theme.accentSoft
                                border.width: 1
                                border.color: Theme.accent
                                radius: 0
                                visible: !device.pairing

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Connect"
                                    color: Theme.bgPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: Typography.weightBold || Font.Bold
                                }

                                MouseArea {
                                    id: pairConnMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    enabled: root.btAdapter && root.btAdapter.enabled
                                    onClicked: device.connect()
                                }
                            }
                        }
                    }
                }
            }

            // ── Available ──
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.availableCount > 0 ? Theme.dp(20) : 0
                visible: root.availableCount > 0
                spacing: Theme.dp(4)

                Text {
                    text: "Available"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                    font.weight: Typography.weightMedium || Font.Normal
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(1)
                    color: Theme.border
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: root.availableCount > 0 ? root.availableH : 0
                visible: root.availableCount > 0
                contentHeight: availableCol.implicitHeight
                interactive: contentHeight > height
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: availableCol.implicitHeight > parent.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    width: Theme.dp(6)
                }

                Column {
                    id: availableCol
                    width: parent.width
                    spacing: Theme.dp(3)

                    Repeater {
                        model: root.availableDevices.slice(0, 6)

                        delegate: Rectangle {
                            property var device: modelData
                            width: parent.width
                            height: root.itemH
                            color: availRowMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04) : "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            MouseArea {
                                id: availRowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {}
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(6)
                                spacing: Theme.dp(6)
                                z: 1

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(6)
                                    Layout.preferredHeight: Theme.dp(6)
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: Theme.dp(3)
                                    color: Theme.border
                                }

                                MarqueeText {
                                    text: device.name || device.deviceName || "Unknown"
                                    textColor: Theme.textPrimary
                                    fontSize: 9
                                    fontScale: s
                                    fontWeight: Typography.weightRegular || Font.Normal
                                    scrolling: true
                                    textPadding: 0
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: device.batteryAvailable ? Math.round(device.battery * 100) + "%" : ""
                                    color: Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                }

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(50)
                                    Layout.preferredHeight: Theme.dp(20)
                                    color: availPairMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Theme.accentSoft
                                    border.width: 1
                                    border.color: Theme.accent
                                    radius: 0
                                    visible: !device.pairing

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Pair"
                                        color: Theme.bgPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        font.weight: Typography.weightBold || Font.Bold
                                    }

                                    MouseArea {
                                        id: availPairMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        enabled: root.btAdapter && root.btAdapter.enabled
                                        onClicked: device.pair()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Empty state ──
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.connectedCount === 0 && root.pairedCount === 0 && root.availableCount === 0 ? Theme.dp(28) : 0
                visible: root.connectedCount === 0 && root.pairedCount === 0 && root.availableCount === 0

                Text {
                    anchors.centerIn: parent
                    text: "No devices found"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                }
            }
        }
    }
}
