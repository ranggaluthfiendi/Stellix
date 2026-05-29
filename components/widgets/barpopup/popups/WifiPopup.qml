import qs.components.utils
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
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
    grabFocus: true

    property real s: Scales.uiScale

    property bool slideIn: false
    property real slideY: -Theme.dp(20)

    readonly property real itemH: Theme.dp(32)
    readonly property real headerH: Theme.dp(36)
    readonly property real maxAvailableH: itemH * 2 // Limiting to 2 items height

    property var wifiDevice: null
    property var selectedNetwork: null
    property bool showAvailable: false
    property bool pskVisible: false
    property string pskError: ""

    readonly property var connectedNetworks: sortedNetworks().filter(function(n) { return n.connected })
    readonly property var availableNetworks: showAvailable ? sortedNetworks().filter(function(n) { return !n.connected }) : []
    readonly property int connectedCount: connectedNetworks.length
    readonly property int availableCount: availableNetworks.length

    readonly property real connectedH: connectedCount > 0 ? connectedCount * itemH : 0
    readonly property real availableH: (availableCount * itemH) + (root.selectedNetwork ? Theme.dp(58) : 0)
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
            slideY = -Theme.dp(20)
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

                    IconWifi {
                        Layout.preferredWidth: Theme.dp(16)
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.alignment: Qt.AlignVCenter
                        iconColor: Networking.wifiEnabled ? Theme.accent : Theme.textPrimary
                        iconSize: Theme.dp(12)
                    }

                    MarqueeText {
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
                        textColor: Networking.wifiEnabled ? Theme.accent : Theme.textPrimary
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
                        color: wifiToggleMouse.containsMouse
                            ? (Networking.wifiEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                            : (Networking.wifiEnabled ? Theme.accent : Theme.bgSecondary)
                        border.width: 1
                        border.color: Networking.wifiEnabled ? Theme.accent : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Networking.wifiEnabled ? "On" : "Off"
                            color: Networking.wifiEnabled ? Theme.bgPrimary : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Networking.wifiEnabled ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                        }

                        MouseArea {
                            id: wifiToggleMouse
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(36)
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.alignment: Qt.AlignVCenter
                        color: scanMouse.containsMouse
                            ? (root.showAvailable ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                            : (root.showAvailable ? Theme.accentSoft : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.showAvailable ? Theme.accent : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "SCAN"
                            color: root.showAvailable ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        MouseArea {
                            id: scanMouse
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
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
                            onClicked: {} // Row itself is not clickable; inner buttons handle actions
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
                                text: root.getNetworkName(network)
                                textColor: Theme.textPrimary
                                fontSize: 9
                                fontScale: s
                                fontWeight: Typography.weightBold || Font.Bold
                                scrolling: true
                                textPadding: 0
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
                                color: discMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgPrimary
                                border.width: 1
                                border.color: discMouse.containsMouse ? Theme.textPrimary : Theme.border
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Disc."
                                    color: discMouse.containsMouse ? Theme.textPrimary : Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                    font.weight: Typography.weightRegular || Font.Normal
                                }

                                MouseArea {
                                    id: discMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: network.disconnect()
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.dp(24)
                                Layout.preferredHeight: Theme.dp(20)
                                color: forgetNetMouse.containsMouse ? Theme.danger : Theme.bgPrimary
                                border.width: 1
                                border.color: forgetNetMouse.containsMouse ? Theme.danger : Theme.border
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "close"
                                    font.family: Typography.materialSymbols
                                    font.styleName: "Regular"
                                    color: forgetNetMouse.containsMouse ? "#ffffff" : Theme.danger
                                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: forgetNetMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        try { network.forget() } catch(e) {}
                                    }
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
                    width: Theme.dp(6)
                }

                Column {
                    id: availableCol
                    width: parent.width
                    spacing: Theme.dp(3)

                    Repeater {
                        model: root.availableNetworks

                        delegate: Item {
                            id: availDelegate
                            property var network: modelData
                            property string passwordText: ""
                            width: parent.width
                            height: root.itemH + (isExpanded ? Theme.dp(76) : 0)
                            property bool isExpanded: root.selectedNetwork === network

                            onIsExpandedChanged: {
                                if (isExpanded && pskField) {
                                    pskField.forceActiveFocus()
                                }
                            }

                            Rectangle {
                                id: availRowRect
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
                                        color: network.known ? Theme.accentSoft : Theme.border
                                    }

                                    MarqueeText {
                                        text: root.getNetworkName(network)
                                        textColor: Theme.textPrimary
                                        fontSize: 9
                                        fontScale: s
                                        fontWeight: Typography.weightRegular || Font.Normal
                                        scrolling: true
                                        textPadding: 0
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
                                        color: connBtnMouse.containsMouse
                                            ? (network.known ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                                            : (network.known ? Theme.accentSoft : Theme.bgPrimary)
                                        border.width: 1
                                        border.color: network.known ? Theme.accent : Theme.border
                                        radius: 0

                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: network.known ? "Connect" : (availDelegate.isExpanded ? "Cancel" : "Join")
                                            color: network.known ? Theme.bgPrimary : Theme.textPrimary
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                            font.weight: Typography.weightBold || Font.Bold
                                        }

                                        MouseArea {
                                            id: connBtnMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            onClicked: {
                                                if (network.known) {
                                                    network.connect()
                                                } else {
                                                    if (availDelegate.isExpanded) {
                                                        root.selectedNetwork = null
                                                        root.pskError = ""
                                                    } else {
                                                        // Open networks connect directly without password
                                                        if (network.security === WifiSecurityType.Open) {
                                                            network.connect()
                                                        } else {
                                                            root.selectedNetwork = network
                                                            root.pskError = ""
                                                            root.pskVisible = false
                                                            availDelegate.passwordText = ""
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        visible: network.known
                                        Layout.preferredWidth: Theme.dp(24)
                                        Layout.preferredHeight: Theme.dp(20)
                                        color: forgetAvailMouse.containsMouse ? Theme.danger : Theme.bgPrimary
                                        border.width: 1
                                        border.color: forgetAvailMouse.containsMouse ? Theme.danger : Theme.border
                                        radius: 0

                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "close"
                                            font.family: Typography.materialSymbols
                                            font.styleName: "Regular"
                                            color: forgetAvailMouse.containsMouse ? "#ffffff" : Theme.danger
                                            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                            font.weight: Font.Bold
                                        }

                                        MouseArea {
                                            id: forgetAvailMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            onClicked: network.forget()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: expandArea
                                y: root.itemH
                                width: parent.width
                                height: availDelegate.isExpanded ? Theme.dp(68) : 0
                                visible: availDelegate.isExpanded
                                color: Theme.bgSecondary
                                border.width: 1
                                border.color: Theme.border
                                radius: Theme.radiusSmall
                                clip: true

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.dp(8)
                                    spacing: Theme.dp(6)

                                    Text {
                                        text: "Enter Password"
                                        color: Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                                        font.weight: Font.Medium
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Theme.dp(32)
                                        spacing: Theme.dp(4)

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            color: Theme.bgPrimary
                                            border.width: 1
                                            border.color: root.pskError.length > 0 ? Theme.danger : Theme.border
                                            radius: Theme.radiusSmall

                                            TextField {
                                                id: pskField
                                                anchors.fill: parent
                                                anchors.margins: Theme.dp(8)
                                                text: availDelegate.passwordText
                                                focus: availDelegate.isExpanded
                                                echoMode: root.pskVisible ? TextInput.Normal : TextInput.Password
                                                placeholderText: "Password"
                                                placeholderTextColor: Theme.textMuted
                                                font.family: Typography.fontFamily
                                                font.pixelSize: Math.round((Typography.sizeSM || 12) * s)
                                                font.weight: Font.Medium
                                                color: Theme.textPrimary
                                                selectionColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                                                selectedTextColor: Theme.textPrimary
                                                background: Item {}
                                                verticalAlignment: TextInput.AlignVCenter

                                                onTextChanged: availDelegate.passwordText = text

                                                onAccepted: {
                                                    if (!root.selectedNetwork) return
                                                    root.pskError = ""
                                                    try {
                                                        root.selectedNetwork.connectWithPsk(availDelegate.passwordText)
                                                        root.selectedNetwork = null
                                                    } catch(e) {
                                                        root.pskError = "Incorrect password or connection failed"
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: Theme.dp(32)
                                            Layout.preferredHeight: Theme.dp(32)
                                            Layout.alignment: Qt.AlignVCenter
                                            color: showPskMouse.containsMouse
                                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                                : "transparent"
                                            border.width: 1
                                            border.color: showPskMouse.containsMouse ? Theme.accent : Theme.border
                                            radius: Theme.radiusSmall

                                            Behavior on color {
                                                ColorAnimation { duration: 120 }
                                            }

                                            IconEye {
                                                anchors.centerIn: parent
                                                iconColor: root.pskVisible ? Theme.accent : Theme.textMuted
                                                iconSize: Theme.dp(16)
                                                visible: root.pskVisible
                                            }
                                            IconEyeOff {
                                                anchors.centerIn: parent
                                                iconColor: !root.pskVisible ? Theme.accent : Theme.textMuted
                                                iconSize: Theme.dp(16)
                                                visible: !root.pskVisible
                                            }

                                            MouseArea {
                                                id: showPskMouse
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                onClicked: root.pskVisible = !root.pskVisible
                                            }
                                        }
                                    }

                                    Text {
                                        visible: root.pskError.length > 0
                                        text: root.pskError
                                        color: Theme.danger
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                        font.weight: Font.Medium
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
}
