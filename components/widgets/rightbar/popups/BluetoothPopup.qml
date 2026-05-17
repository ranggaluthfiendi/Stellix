import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.config
import qs.components.widgets.rightbar
import qs.components.elements
import Quickshell.Wayland

PopupWindow {
    id: root

    property var popupPanel: null
    property var closeCallback: null
    visible: false
    grabFocus: false

    property real s: Scales.uiScale

    property bool slideIn: false
    property real slideX: Theme.dp(20)

    readonly property real itemH: Theme.dp(32)
    readonly property real headerH: Theme.dp(36)
    readonly property real maxListH: Theme.dp(200)

    property var btAdapter: Bluetooth.defaultAdapter

    readonly property var connectedDevices: sortedDevices().filter(function(d) { return d.connected })
    readonly property var pairedDevices: sortedDevices().filter(function(d) { return !d.connected && d.bonded })
    readonly property var availableDevices: sortedDevices().filter(function(d) { return !d.connected && !d.bonded })
    readonly property int totalItems: connectedDevices.length + pairedDevices.length + availableDevices.length
        + (pairedDevices.length > 0 ? 1 : 0) + (availableDevices.length > 0 ? 1 : 0)
    readonly property real listH: Math.min(Math.max(totalItems * itemH, itemH), maxListH)

    implicitWidth: Theme.dp(252)
    implicitHeight: headerH + Theme.dp(28) + listH + Theme.dp(8)

    anchor.window: popupPanel
    anchor.rect.x: -(implicitWidth + Theme.dp(372) + Theme.dp(8))

    onVisibleChanged: {
        if (visible) {
            slideX = Theme.dp(20)
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

    function buildDeviceModel() {
        var result = []
        var connected = root.connectedDevices
        var paired = root.pairedDevices
        var available = root.availableDevices

        for (var i = 0; i < connected.length; i++) {
            result.push({ device: connected[i], isHeader: false })
        }

        if (paired.length > 0) {
            result.push({ isHeader: true, label: "Paired" })
            for (var j = 0; j < paired.length; j++) {
                result.push({ device: paired[j], isHeader: false })
            }
        }

        if (available.length > 0) {
            result.push({ isHeader: true, label: "Available" })
            var showCount = Math.min(available.length, 6)
            for (var k = 0; k < showCount; k++) {
                result.push({ device: available[k], isHeader: false })
            }
        }

        return result
    }

    function isDevConnected(dd) { return dd && dd.device && dd.device.connected }
    function isDevBonded(dd) { return dd && dd.device && dd.device.bonded }
    function isHeader(dd) { return dd && dd.isHeader }

    Rectangle {
        anchors.fill: parent
        x: -root.slideX
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0
        clip: true

        Behavior on x {
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

                    Text {
                        Layout.fillWidth: true
                        text: root.btAdapter && root.btAdapter.enabled ? "Bluetooth — On" : "Bluetooth — Off"
                        color: root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                        font.weight: Typography.weightMedium || Font.Normal
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(36)
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.alignment: Qt.AlignVCenter
                        color: root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.bgSecondary
                        border.width: 1
                        border.color: root.btAdapter && root.btAdapter.enabled ? Theme.accent : Theme.border
                        radius: 0

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
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            enabled: root.btAdapter
                            onClicked: { if (root.btAdapter) root.btAdapter.enabled = !root.btAdapter.enabled }
                        }
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: Theme.dp(3)

                Repeater {
                    model: root.buildDeviceModel()

                    delegate: Rectangle {
                        property var dd: modelData
                        width: parent.width
                        height: isHeader(dd) ? Theme.dp(20) : root.itemH
                        color: isHeader(dd) ? "transparent" : (isDevConnected(dd) ? Theme.bgPrimary : "transparent")
                        border.width: isHeader(dd) ? 0 : 1
                        border.color: isHeader(dd) ? "transparent" : (isDevConnected(dd) ? Theme.accent : Theme.border)
                        radius: 0

                        Text {
                            visible: isHeader(dd)
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Theme.dp(6)
                            text: dd ? dd.label : ""
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Typography.weightMedium || Font.Normal
                        }

                        RowLayout {
                            visible: dd && !isHeader(dd) && dd.device
                            anchors.fill: parent
                            anchors.margins: Theme.dp(6)
                            spacing: Theme.dp(6)

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(6)
                                Layout.preferredHeight: Theme.dp(6)
                                Layout.alignment: Qt.AlignVCenter
                                radius: Theme.dp(3)
                                color: isDevConnected(dd) ? Theme.accent
                                    : (isDevBonded(dd) ? Theme.accentSoft : Theme.border)
                            }

                            Text {
                                text: dd.device.name || dd.device.deviceName || "Unknown"
                                color: Theme.textPrimary
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                font.weight: isDevConnected(dd)
                                    ? (Typography.weightBold || Font.Bold)
                                    : (Typography.weightRegular || Font.Normal)
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: dd.device.batteryAvailable ? Math.round(dd.device.battery * 100) + "%" : ""
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(50)
                                Layout.preferredHeight: Theme.dp(20)
                                color: isDevConnected(dd) ? Theme.bgPrimary : Theme.accentSoft
                                border.width: 1
                                border.color: isDevConnected(dd) ? Theme.border : Theme.accent
                                radius: 0
                                visible: !dd.device.pairing

                                Text {
                                    anchors.centerIn: parent
                                    text: isDevConnected(dd) ? "Disc." : (isDevBonded(dd) ? "Connect" : "Pair")
                                    color: isDevConnected(dd) ? Theme.textPrimary : Theme.bgPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: !isDevConnected(dd)
                                        ? (Typography.weightBold || Font.Bold)
                                        : (Typography.weightRegular || Font.Normal)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: root.btAdapter && root.btAdapter.enabled
                                    onClicked: {
                                        if (isDevConnected(dd)) dd.device.disconnect()
                                        else if (isDevBonded(dd)) dd.device.connect()
                                        else dd.device.pair()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.totalItems === 0 ? Theme.dp(28) : 0
                visible: root.totalItems === 0

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
