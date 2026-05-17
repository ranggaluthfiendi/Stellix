import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
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
    readonly property real maxAvailableH: Theme.dp(168)

    property var wifiDevice: null
    property var selectedNetwork: null
    property bool showAvailable: false

    readonly property var connectedNetworks: sortedNetworks().filter(function(n) { return n.connected })
    readonly property var availableNetworks: showAvailable ? sortedNetworks().filter(function(n) { return !n.connected }) : []
    readonly property int connectedCount: connectedNetworks.length
    readonly property int availableCount: availableNetworks.length

    readonly property real connectedH: connectedCount > 0 ? connectedCount * itemH : 0
    readonly property real availableH: availableCount * itemH
    readonly property real displayedAvailableH: Math.min(availableH, maxAvailableH)
    readonly property real listH: {
        var h = connectedH
        if (availableCount > 0) h += Theme.dp(24) + displayedAvailableH
        if (h === 0) h = itemH
        return h
    }

    implicitWidth: Theme.dp(252)
    implicitHeight: headerH + Theme.dp(40) + listH + Theme.dp(8)

    anchor.window: popupPanel
    anchor.rect.x: -(implicitWidth + Theme.dp(372) + Theme.dp(8))

    onVisibleChanged: {
        if (visible) {
            slideX = Theme.dp(20)
            slideIn = true
            refreshWifiDevice()
            showAvailable = false
        } else {
            if (wifiDevice && wifiDevice.scannerEnabled)
                wifiDevice.scannerEnabled = false
        }
    }

    function refreshWifiDevice() {
        var devices = Networking.devices ? Networking.devices.values : []
        for (var i = 0; i < devices.length; i++) {
            var dev = devices[i]
            if (dev && dev.type === DeviceType.Wifi) {
                wifiDevice = dev
                return
            }
        }
    }

    function startScan() {
        refreshWifiDevice()
        if (wifiDevice) {
            wifiDevice.scannerEnabled = true
            showAvailable = true
        }
    }

    function getNetworkName(network) {
        if (!network) return "Unknown"
        if (network.name && typeof network.name === "string" && network.name.length > 0) return network.name
        return "Hidden Network"
    }

    function sortedNetworks() {
        if (!wifiDevice || !wifiDevice.networks) return []
        var arr = wifiDevice.networks.values.slice()
        arr.sort(function(a, b) {
            if (a.connected && !b.connected) return -1
            if (!a.connected && b.connected) return 1
            if (a.known && !b.known) return -1
            if (!a.known && b.known) return 1
            return b.signalStrength - a.signalStrength
        })
        return arr
    }

    function isNetConnected(nd) { return nd && nd.network && nd.network.connected }
    function isNetKnown(nd) { return nd && nd.network && nd.network.known }

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

                    IconWifi {
                        Layout.preferredWidth: Theme.dp(16)
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.alignment: Qt.AlignVCenter
                        iconColor: Networking.wifiEnabled ? Theme.accent : Theme.textPrimary
                        iconSize: Theme.dp(12)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (!Networking.wifiEnabled) return "WiFi — Off"
                            try {
                                var devs = Networking.devices ? Networking.devices.values : []
                                for (var i = 0; i < devs.length; i++) {
                                    var d = devs[i]
                                    if (!d) continue
                                    if (d.activeNetwork && d.activeNetwork.name) return d.activeNetwork.name
                                    if (d.activeSsid) return d.activeSsid
                                }
                            } catch(e) {}
                            return "WiFi"
                        }
                        color: Networking.wifiEnabled ? Theme.accent : Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                        font.weight: Typography.weightMedium || Font.Normal
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(36)
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.alignment: Qt.AlignVCenter
                        color: Networking.wifiEnabled ? Theme.accent : Theme.bgSecondary
                        border.width: 1
                        border.color: Networking.wifiEnabled ? Theme.accent : Theme.border
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: Networking.wifiEnabled ? "On" : "Off"
                            color: Networking.wifiEnabled ? Theme.bgPrimary : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Networking.wifiEnabled ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                        }

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(36)
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.alignment: Qt.AlignVCenter
                        color: root.showAvailable ? Theme.accentSoft : Theme.bgPrimary
                        border.width: 1
                        border.color: root.showAvailable ? Theme.accent : Theme.border
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "⟳"
                            color: root.showAvailable ? Theme.accent : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 11) * s)
                        }

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            onClicked: root.startScan()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(20)
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

                Repeater {
                    model: root.connectedNetworks

                    delegate: Rectangle {
                        property var network: modelData
                        width: parent.width
                        height: root.itemH
                        color: Theme.bgPrimary
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(6)
                            spacing: Theme.dp(6)

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(6)
                                Layout.preferredHeight: Theme.dp(6)
                                Layout.alignment: Qt.AlignVCenter
                                radius: Theme.dp(3)
                                color: Theme.accent
                            }

                            Text {
                                text: root.getNetworkName(network)
                                color: Theme.textPrimary
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                font.weight: Typography.weightBold || Font.Bold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Connected"
                                color: Theme.accent
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(50)
                                Layout.preferredHeight: Theme.dp(20)
                                color: Theme.bgPrimary
                                border.width: 1
                                border.color: Theme.border
                                radius: 0

                                Text {
                                    anchors.centerIn: parent
                                    text: "Disc."
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: Typography.weightRegular || Font.Normal
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: network.disconnect()
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(20)
                visible: root.showAvailable && root.availableCount > 0
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
                Layout.preferredHeight: root.showAvailable ? root.displayedAvailableH : 0
                visible: root.showAvailable
                contentHeight: availableCol.implicitHeight
                interactive: contentHeight > height
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: availableCol.implicitHeight > parent.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    width: Theme.dp(4)
                }

                Column {
                    id: availableCol
                    width: parent.width
                    spacing: Theme.dp(3)

                    Repeater {
                        model: root.availableNetworks

                        delegate: Rectangle {
                            property var network: modelData
                            width: parent.width
                            height: root.itemH
                            color: "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(6)
                                spacing: Theme.dp(6)

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(6)
                                    Layout.preferredHeight: Theme.dp(6)
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: Theme.dp(3)
                                    color: network.known ? Theme.accentSoft : Theme.border
                                }

                                Text {
                                    text: root.getNetworkName(network)
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                    font.weight: Typography.weightRegular || Font.Normal
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: network.known ? "Saved" : ""
                                    color: Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                }

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(50)
                                    Layout.preferredHeight: Theme.dp(20)
                                    color: network.known ? Theme.accentSoft : Theme.bgPrimary
                                    border.width: 1
                                    border.color: network.known ? Theme.accent : Theme.border
                                    radius: 0

                                    Text {
                                        anchors.centerIn: parent
                                        text: network.known ? "Connect" : "Join"
                                        color: network.known ? Theme.bgPrimary : Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        font.weight: Typography.weightBold || Font.Bold
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (network.known) {
                                                network.connect()
                                            } else {
                                                root.selectedNetwork = network
                                                pskDialog.visible = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.connectedCount === 0 && !root.showAvailable ? Theme.dp(28) : 0
                visible: root.connectedCount === 0 && !root.showAvailable

                Text {
                    anchors.centerIn: parent
                    text: "No networks connected"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                }
            }
        }
    }

    PopupWindow {
        id: pskDialog
        visible: false
        implicitWidth: Theme.dp(260)
        implicitHeight: Theme.dp(140)
        grabFocus: false

        anchor.window: root
        anchor.rect.x: Theme.dp(8)
        anchor.rect.y: Theme.dp(50)

        Rectangle {
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(8)
                spacing: Theme.dp(6)

                Text {
                    text: root.selectedNetwork ? root.getNetworkName(root.selectedNetwork) : ""
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                    font.weight: Typography.weightBold || Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                TextField {
                    id: pskField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "Password"
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    color: Theme.textPrimary
                    selectionColor: Theme.accentSoft
                    selectedTextColor: Theme.textPrimary

                    background: Rectangle {
                        color: Theme.bgPrimary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                    }

                    onAccepted: {
                        if (root.selectedNetwork) root.selectedNetwork.connectWithPsk(pskField.text)
                        pskDialog.visible = false
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(4)

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(26)
                        color: Theme.accentSoft
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: Theme.bgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.selectedNetwork) root.selectedNetwork.connectWithPsk(pskField.text)
                                pskDialog.visible = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(26)
                        color: Theme.bgPrimary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pskDialog.visible = false
                        }
                    }
                }
            }
        }
    }
}
