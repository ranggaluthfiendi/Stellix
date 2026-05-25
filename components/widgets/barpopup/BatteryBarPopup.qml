import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.components.widgets.barpopup
import qs.components.widgets.barpopup.popups
import qs.components.widgets.barpopup.services
import qs.components.widgets.barpopup.sections
import qs.components.elements

Scope {
    id: root

    property real s: Scales.uiScale

    readonly property bool isBottom: BarLayoutState.isBottom

    readonly property var battery: UPower.displayDevice

    property var brightnessService: null
    property var mprisService: null
    property var pipewireService: null
    property var notificationService: null

    // For internal alias compatibility
    readonly property alias brightnessSvc: root.brightnessService
    readonly property alias mprisSvc: root.mprisService
    readonly property alias pwSvc: root.pipewireService
    readonly property alias notifSvc: root.notificationService

    property bool wifiPopupOpen: false
    property bool btPopupOpen: false
    property bool powerPopupOpen: false
    property bool notifPopupOpen: false
    property bool volumeExpanded: false

    readonly property real popupGap: Theme.dp(8)

    readonly property string batterySection: BarLayoutState.findItemSection("battery")
    readonly property string notifSection: BarLayoutState.findItemSection("notif")
    readonly property bool batteryIsLeft: batterySection === "left"
    readonly property bool batteryIsCenter: batterySection === "center"
    readonly property bool batteryIsRight: batterySection === "right"
    readonly property bool notifIsLeft: notifSection === "left"
    readonly property bool notifIsCenter: notifSection === "center"
    readonly property bool notifIsRight: notifSection === "right"

    readonly property real panelW: Theme.dp(372)
    readonly property real screenW: panel.screen ? panel.screen.width : 1920
    readonly property real centerMargin: Math.max(0, (screenW - panelW) / 2)

    readonly property real powerPopupH: Theme.dp(22) + Theme.dp(1) + 4 * Theme.dp(38) + Theme.dp(16)
    readonly property real wifiPopupH: wifiPopupOpen ? wifiPopup.implicitHeight : Theme.dp(200)
    readonly property real btPopupH: btPopupOpen ? btPopup.implicitHeight : Theme.dp(150)

    readonly property real powerY: isBottom ? -powerPopup.implicitHeight : 0
    readonly property real wifiY: isBottom
        ? -(powerPopupOpen ? (powerPopup.implicitHeight + popupGap + wifiPopup.implicitHeight) : wifiPopup.implicitHeight)
        : (powerPopupOpen ? (powerPopup.implicitHeight + popupGap) : 0)
    readonly property real btY: isBottom
        ? -((powerPopupOpen ? powerPopup.implicitHeight + popupGap : 0) + (wifiPopupOpen ? wifiPopup.implicitHeight + popupGap : 0) + btPopup.implicitHeight)
        : ((powerPopupOpen ? powerPopup.implicitHeight + popupGap : 0) + (wifiPopupOpen ? wifiPopup.implicitHeight + popupGap : 0))

    readonly property real notifY: isBottom
        ? -(notifPopup.implicitHeight + Theme.dp(5))
        : (BarPopupState.open ? (panel.implicitHeight + Theme.dp(5)) : Theme.dp(5))

    readonly property real panelHeight: panel.implicitHeight

    property bool notifPopupUserOpened: false

    readonly property var notifItemRef: BarLayoutState.getItem("notif")

    onNotifYChanged: scheduleNotifAnchorRefresh()
    onNotifPopupOpenChanged: {
        if (notifPopupOpen && BarPopupState.open) {
            BarPopupState.open = false
        }
        scheduleNotifAnchorRefresh()
    }
    onVolumeExpandedChanged: {
        if (volumeExpanded) {
            root.closeNotifPopup()
        }
        scheduleNotifAnchorRefresh()
    }

    Timer {
        id: notifAnchorRefreshTimer
        interval: 0
        repeat: false
        onTriggered: root.refreshNotifAnchor()
    }

    function scheduleNotifAnchorRefresh() {
        if (root.notifPopupOpen)
            notifAnchorRefreshTimer.restart()
    }

    function refreshNotifAnchor() {
        if (!root.notifPopupOpen)
            return

        notifPopup.anchor.rect = Qt.rect(Math.round(root.computeNotifX()), Math.round(root.notifY), 1, 1)
        notifPopup.anchor.updateAnchor()
    }

    Connections {
        target: BarPopupState
        function onOpenChanged() {
            if (BarPopupState.open) {
                root.closeNotifPopup()
                root.scheduleNotifAnchorRefresh()
            } else {
                root.wifiPopupOpen = false
                root.btPopupOpen = false
                root.powerPopupOpen = false
                root.notifPopupOpen = false
                BarPopupState.calendarOpen = false
            }
        }
        function onCalendarOpenChanged() {
            if (BarPopupState.calendarOpen) {
                root.closeNotifPopup()
            }
        }
        function onWorkspaceSwitcherOpenChanged() {
            if (BarPopupState.workspaceSwitcherOpen) {
                root.closeNotifPopup()
            }
        }
        function onWeatherDetailOpenChanged() {
            if (BarPopupState.weatherDetailOpen) {
                root.closeNotifPopup()
            }
        }
    }

    property int _notifReqVersion: 0

    Timer {
        id: notifToggleTimer
        interval: 50
        repeat: false
        onTriggered: {
            root.notifPopupOpen = !root.notifPopupOpen
            root.notifPopupUserOpened = root.notifPopupOpen
        }
    }

    Connections {
        target: BarPopupState
        function onNotifPanelRequestedChanged() {
            if (BarPopupState.notifPanelRequested) {
                root._notifReqVersion++
                BarPopupState.notifPanelRequested = false
                notifToggleTimer.restart()
            }
        }
    }

    function togglePopup(name) {
        if (name === "wifi") {
            wifiPopupOpen  = !wifiPopupOpen
            if (wifiPopupOpen) {
                powerPopupOpen = false
                root.closeNotifPopup()
            }
        } else if (name === "bluetooth") {
            btPopupOpen = !btPopupOpen
            if (btPopupOpen) {
                powerPopupOpen = false
                root.closeNotifPopup()
            }
        } else if (name === "power") {
            powerPopupOpen = !powerPopupOpen
            if (powerPopupOpen) {
                wifiPopupOpen = false
                btPopupOpen = false
                root.closeNotifPopup()
            }
        }
    }

    function closeAllPopups() {
        wifiPopupOpen  = false
        btPopupOpen    = false
        powerPopupOpen = false
        notifPopupOpen = false
        notifPopupUserOpened = false
    }

    function closeSidePopups() {
        wifiPopupOpen  = false
        btPopupOpen    = false
        powerPopupOpen = false
    }

    function closeNotifPopup() {
        notifPopupOpen = false
        notifPopupUserOpened = false
    }

    onNotifCountChanged: BarPopupState.notifCount = notifCount

    readonly property int notifCount: notifSvc.notifCount
    readonly property var trackedNotifs: notifSvc.trackedNotifs

    PanelWindow {
        id: outsideOverlay
        visible: BarPopupState.open || root.wifiPopupOpen || root.btPopupOpen || root.powerPopupOpen || root.notifPopupOpen || BarPopupState.calendarOpen || BarPopupState.weatherDetailOpen || BarPopupState.workspaceSwitcherOpen
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: -1

        margins.top: root.isBottom ? 0 : BarLayoutState.barHeight * root.s
        margins.bottom: root.isBottom ? BarLayoutState.barHeight * root.s : 0

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: {
                if (BarPopupState.open) {
                    BarPopupState.closeAll()
                }
                root.closeSidePopups()
                root.closeNotifPopup()
                BarPopupState.calendarOpen = false
                BarPopupState.weatherDetailOpen = false
            }
        }
    }

    readonly property real popupRadius: BarLayoutState.barPopupRounded ? Theme.radiusMedium : 0

    PanelWindow {
        id: panel
        visible: BarPopupState.open
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: 0

        anchors {
            top: !root.isBottom
            bottom: root.isBottom
            left: true
            right: true
        }

        implicitWidth: root.panelW
        implicitHeight: content.implicitHeight + Theme.dp(16)

        onImplicitHeightChanged: root.scheduleNotifAnchorRefresh()

        margins.top: root.isBottom ? 0 : Theme.dp(5)
        margins.bottom: root.isBottom ? Theme.dp(5) : 0
        margins.left: root.batteryIsLeft ? Theme.dp(5) : (root.batteryIsCenter ? root.centerMargin : root.screenW - root.panelW - Theme.dp(5))
        margins.right: root.batteryIsRight ? Theme.dp(5) : (root.batteryIsCenter ? root.centerMargin : root.screenW - root.panelW - Theme.dp(5))

        Component.onCompleted: {
            if (root.brightnessSvc) root.brightnessSvc.init()
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: root.popupRadius

            ColumnLayout {
                id: content
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.dp(8)
                spacing: Theme.dp(6)

                BatteryCard {
                    s: root.s
                    onPowerClicked: root.togglePopup("power")
                }

                QuickToggles {
                    id: quickTogglesInline
                    Layout.fillWidth: true
                    popupController: root
                }

                MediaCard {
                    mprisService: mprisSvc
                    s: root.s
                }

                BrightnessSlider {
                    brightnessService: brightnessSvc
                    s: root.s
                }

                VolumeSection {
                    pipewireService: pwSvc
                    s: root.s
                    volumeExpanded: root.volumeExpanded
                    onVolumeExpandedChanged: root.volumeExpanded = volumeExpanded
                }
            }
        }
    }

    PanelWindow {
        id: popupAnchor
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: 0

        anchors {
            top: !root.isBottom
            bottom: root.isBottom
            left: true
            right: true
        }

        implicitWidth: Theme.dp(1)
        implicitHeight: Theme.dp(1)

        margins.top: root.isBottom ? 0 : Theme.dp(5)
        margins.bottom: root.isBottom ? Theme.dp(5) : 0
        margins.left: root.batteryIsLeft ? Theme.dp(5) : (root.batteryIsCenter ? root.centerMargin : root.screenW - root.panelW - Theme.dp(5))
        margins.right: root.batteryIsRight ? Theme.dp(5) : (root.batteryIsCenter ? root.centerMargin : root.screenW - root.panelW - Theme.dp(5))
    }

    PowerPopup {
        id: powerPopup
        popupPanel: popupAnchor
        visible: root.powerPopupOpen
        closeCallback: function() { root.powerPopupOpen = false }
        onVisibleChanged: {
            if (!visible) root.powerPopupOpen = false
        }
        anchor.rect.x: root.batteryIsLeft
            ? root.panelW + Theme.dp(8)
            : -(implicitWidth + Theme.dp(8))
        anchor.rect.y: root.powerY
    }

    WifiPopup {
        id: wifiPopup
        popupPanel: popupAnchor
        visible: root.wifiPopupOpen
        onVisibleChanged: {
            if (!visible) root.wifiPopupOpen = false
        }
        anchor.rect.x: root.batteryIsLeft
            ? root.panelW + Theme.dp(8)
            : -(implicitWidth + Theme.dp(8))
        anchor.rect.y: root.wifiY
    }

    BluetoothPopup {
        id: btPopup
        popupPanel: popupAnchor
        visible: root.btPopupOpen
        onVisibleChanged: {
            if (!visible) root.btPopupOpen = false
        }
        anchor.rect.x: root.batteryIsLeft
            ? root.panelW + Theme.dp(8)
            : -(implicitWidth + Theme.dp(8))
        anchor.rect.y: root.btY
    }

    PanelWindow {
        id: notifAnchorWin
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: !root.isBottom
            bottom: root.isBottom
            left: true
        }

        implicitWidth: Theme.dp(1)
        implicitHeight: Theme.dp(1)

        margins.top: root.isBottom ? 0 : BarLayoutState.barHeight * root.s
        margins.bottom: root.isBottom ? BarLayoutState.barHeight * root.s : 0
        margins.left: 0
    }

    function computeNotifX() {
        if (root.notifIsCenter) return root.centerMargin
        if (root.notifIsLeft) return Theme.dp(5)
        if (root.notifIsRight) return root.screenW - notifPopup.implicitWidth - Theme.dp(5)
        if (!root.notifItemRef) return root.screenW / 2 - notifPopup.implicitWidth / 2
        try {
            var pos = root.notifItemRef.mapToGlobal(0, 0)
            return pos.x + root.notifItemRef.width / 2 - notifPopup.implicitWidth / 2
        } catch(e) {
            return root.screenW / 2 - notifPopup.implicitWidth / 2
        }
    }

    NotificationPopup {
        id: notifPopup
        popupPanel: notifAnchorWin
        visible: root.notifPopupOpen
        grabFocus: false
        trackedNotifs: root.trackedNotifs
        closeCallback: function() { root.notifPopupOpen = false }
        barRightPanelHeight: root.panelHeight

        anchor.window: notifAnchorWin

        anchor.rect: Qt.rect(Math.round(root.computeNotifX()), Math.round(root.notifY), 1, 1)

        onVisibleChanged: {
            if (visible) root.scheduleNotifAnchorRefresh()
            else root.notifPopupOpen = false
        }
    }
}
