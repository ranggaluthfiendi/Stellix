import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.config
import qs.components.widgets.rightbar
import qs.components.elements

Item {
    id: root
    property real s: Scales.uiScale

    property var popupController: null

    readonly property var networkingObj: Networking
    readonly property var bluetoothObj: Bluetooth

    readonly property bool networkingAvailable: networkingObj !== null && networkingObj !== undefined
    readonly property bool bluetoothAvailable: bluetoothObj !== null && bluetoothObj !== undefined

    readonly property bool wifiToggleAvailable: networkingAvailable && networkingObj.wifiEnabled !== undefined
    readonly property bool wifiHwEnabled: networkingAvailable && networkingObj.wifiHardwareEnabled !== undefined ? networkingObj.wifiHardwareEnabled : true
    readonly property bool wifiEnabled: wifiToggleAvailable ? networkingObj.wifiEnabled : false

    readonly property var btAdapter: bluetoothAvailable ? bluetoothObj.defaultAdapter : null
    readonly property bool btToggleAvailable: btAdapter !== null && btAdapter !== undefined && btAdapter.enabled !== undefined
    readonly property bool btEnabled: btToggleAvailable ? btAdapter.enabled : false

    readonly property string connectedSsidName: {
        if (!wifiToggleAvailable || !wifiEnabled) return "No WiFi"
        try {
            var devices = Networking.devices.values
            for (var i = 0; i < devices.length; i++) {
                var dev = devices[i]
                if (!dev) continue
                if (dev.activeNetwork && dev.activeNetwork.name) {
                    return dev.activeNetwork.name
                }
                if (dev.activeSsid) {
                    return dev.activeSsid
                }
                if (dev.networks) {
                    var nets = dev.networks.values
                    for (var j = 0; j < nets.length; j++) {
                        var net = nets[j]
                        if (net && net.connected && net.name) {
                            return net.name
                        }
                    }
                }
            }
        } catch (e) {}
        return "Not Connected"
    }

    readonly property string btAdapterName: {
        if (!btToggleAvailable || !btEnabled) return "No BT"
        if (btAdapter && btAdapter.name) return btAdapter.name
        return "Bluetooth"
    }

    function toggleWifi() {
        if (!wifiToggleAvailable || !wifiHwEnabled) return
        try { networkingObj.wifiEnabled = !networkingObj.wifiEnabled } catch (e) {}
    }

    function toggleBluetooth() {
        if (!btToggleAvailable) return
        try { btAdapter.enabled = !btAdapter.enabled } catch (e) {}
    }

    // Toggle wifi popup independently (BT can stay open simultaneously)
    function openWifiPopup() {
        if (!popupController) return
        popupController.togglePopup("wifi")
    }

    // Toggle BT popup independently (WiFi can stay open simultaneously)
    function openBtPopup() {
        if (!popupController) return
        popupController.togglePopup("bluetooth")
    }

    implicitWidth: Theme.dp(300)
    implicitHeight: Theme.dp(38)

    RowLayout {
        anchors.fill: parent
        spacing: Theme.dp(6)

        // Wifi row
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            color: Theme.bgPrimary
            border.width: 1
            border.color: wifiEnabled ? Theme.accent : Theme.border
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(4)
                spacing: Theme.dp(4)

                IconWifi {
                    Layout.preferredWidth: Theme.dp(16)
                    Layout.preferredHeight: Theme.dp(16)
                    Layout.alignment: Qt.AlignVCenter
                    iconColor: wifiEnabled ? Theme.accent : Theme.textPrimary
                    iconSize: Theme.dp(10)
                }

                MarqueeText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: root.connectedSsidName
                    textColor: wifiEnabled ? Theme.accent : Theme.textPrimary
                    fontSize: Typography.sizeXXS || 10
                    fontScale: s
                    fontWeight: Typography.weightMedium || Font.Normal
                    scrolling: wifiEnabled
                    textPadding: 0
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(32)
                    Layout.preferredHeight: Theme.dp(22)
                    Layout.alignment: Qt.AlignVCenter
                    color: wifiEnabled ? Theme.accent : Theme.bgSecondary
                    border.width: 1
                    border.color: wifiEnabled ? Theme.accent : Theme.border
                    radius: 0

                    Text {
                        anchors.centerIn: parent
                        text: wifiEnabled ? "On" : "Off"
                        color: wifiEnabled ? Theme.bgPrimary : Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        font.weight: wifiEnabled ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: root.toggleWifi()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(24)
                    Layout.preferredHeight: Theme.dp(22)
                    Layout.alignment: Qt.AlignVCenter
                    color: Theme.bgSecondary
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Text {
                        anchors.centerIn: parent
                        text: "..."
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: root.openWifiPopup()
                    }
                }
            }
        }

        // Bluetooth row
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            color: Theme.bgPrimary
            border.width: 1
            border.color: btEnabled ? Theme.accent : Theme.border
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(4)
                spacing: Theme.dp(4)

                IconBluetooth {
                    Layout.preferredWidth: Theme.dp(16)
                    Layout.preferredHeight: Theme.dp(16)
                    Layout.alignment: Qt.AlignVCenter
                    iconColor: btEnabled ? Theme.accent : Theme.textPrimary
                    iconSize: Theme.dp(10)
                }

                MarqueeText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: root.btAdapterName
                    textColor: btEnabled ? Theme.accent : Theme.textPrimary
                    fontSize: Typography.sizeXXS || 10
                    fontScale: s
                    fontWeight: Typography.weightMedium || Font.Normal
                    scrolling: btEnabled
                    textPadding: 0
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(32)
                    Layout.preferredHeight: Theme.dp(22)
                    Layout.alignment: Qt.AlignVCenter
                    color: btEnabled ? Theme.accent : Theme.bgSecondary
                    border.width: 1
                    border.color: btEnabled ? Theme.accent : Theme.border
                    radius: 0

                    Text {
                        anchors.centerIn: parent
                        text: btEnabled ? "On" : "Off"
                        color: btEnabled ? Theme.bgPrimary : Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        font.weight: btEnabled ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: root.toggleBluetooth()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(24)
                    Layout.preferredHeight: Theme.dp(22)
                    Layout.alignment: Qt.AlignVCenter
                    color: Theme.bgSecondary
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Text {
                        anchors.centerIn: parent
                        text: "..."
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: root.openBtPopup()
                    }
                }
            }
        }
    }
}
