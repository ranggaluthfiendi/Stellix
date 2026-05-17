import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.config
import qs.components.widgets.rightbar
import qs.components.widgets.rightbar.popups
import qs.components.widgets.rightbar.services
import qs.components.widgets.rightbar.sections
import qs.components.elements

Scope {
    id: root

    property real s: Scales.uiScale

    readonly property var battery: UPower.displayDevice

    BrightnessService { id: brightnessSvc }
    MprisService { id: mprisSvc }
    PipewireService { id: pwSvc }
    NotificationService { id: notifSvc }

    property bool wifiPopupOpen: false
    property bool btPopupOpen: false
    property bool powerPopupOpen: false
    property bool notifPopupOpen: false
    property bool volumeExpanded: false

    readonly property real popupGap: Theme.dp(8)

    // ── Fixed heights for stacking calculations ──
    readonly property real powerPopupH: Theme.dp(22) + Theme.dp(1) + 4 * Theme.dp(38) + Theme.dp(16)
    readonly property real wifiPopupH: wifiPopupOpen ? wifiPopup.implicitHeight : Theme.dp(200)
    readonly property real btPopupH: btPopupOpen ? btPopup.implicitHeight : Theme.dp(150)

    // ── Stacking: power → wifi → bt → (bar) → notif ──
    readonly property real powerY: 0
    readonly property real wifiY: powerPopupOpen ? (powerPopup.implicitHeight + popupGap) : 0
    readonly property real btY: (powerPopupOpen ? powerPopup.implicitHeight + popupGap : 0) + (wifiPopupOpen ? wifiPopup.implicitHeight + popupGap : 0)

    // ── Notif: always below bar when bar open, at top when bar closed ──
    readonly property real notifY: RightBarState.open ? (panel.implicitHeight + popupGap) : 0

    // ── Track whether notif popup was opened by user ──
    property bool notifPopupUserOpened: false

    onNotifYChanged: scheduleNotifAnchorRefresh()
    onNotifPopupOpenChanged: scheduleNotifAnchorRefresh()
    onVolumeExpandedChanged: scheduleNotifAnchorRefresh()

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

        notifPopup.anchor.rect = Qt.rect(0, Math.round(root.notifY), 1, 1)
        notifPopup.anchor.updateAnchor()
    }

    Connections {
        target: RightBarState
        function onOpenChanged() {
            if (!RightBarState.open) {
                root.wifiPopupOpen = false
                root.btPopupOpen = false
                root.powerPopupOpen = false
                root.notifPopupOpen = false
                RightBarState.calendarOpen = false
            } else {
                root.scheduleNotifAnchorRefresh()
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
        target: RightBarState
        function onNotifPanelRequestedChanged() {
            if (RightBarState.notifPanelRequested) {
                root._notifReqVersion++
                RightBarState.notifPanelRequested = false
                notifToggleTimer.restart()
            }
        }
    }

    function togglePopup(name) {
        if (name === "wifi")      wifiPopupOpen  = !wifiPopupOpen
        else if (name === "bluetooth") btPopupOpen = !btPopupOpen
        else if (name === "power")    powerPopupOpen = !powerPopupOpen
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

    onNotifCountChanged: RightBarState.notifCount = notifCount

    readonly property int notifCount: notifSvc.notifCount
    readonly property var trackedNotifs: notifSvc.trackedNotifs

    // ── Outside overlay (covers everything except the main bar area) ──
    PanelWindow {
        id: outsideOverlay
        visible: RightBarState.open || root.wifiPopupOpen || root.btPopupOpen || root.powerPopupOpen || root.notifPopupOpen
        color: "transparent"

        // FIXED: Use Top layer so it doesn't block the sidebar in Overlay
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: -1

        // Allow the main bar buttons (like battery) to remain interactive
        margins.top: Dimens.barHeight * root.s

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
                if (RightBarState.open) {
                    RightBarState.closeAll()
                }
                root.closeSidePopups()
                root.closeNotifPopup()
                RightBarState.calendarOpen = false
            }
        }
    }

    // ── Main panel ──
    PanelWindow {
        id: panel
        visible: RightBarState.open
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: 0

        anchors {
            top: true
            right: true
        }

        implicitWidth: Theme.dp(372)
        implicitHeight: content.implicitHeight + Theme.dp(16)

        onImplicitHeightChanged: root.scheduleNotifAnchorRefresh()

        margins.top: Theme.dp(5)
        margins.right: Theme.dp(5)
        margins.bottom: Theme.dp(5)

        Component.onCompleted: {
            brightnessSvc.init()
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
            radius: 0

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

    // ── Single anchor for all side popups ──
    PanelWindow {
        id: popupAnchor
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: 0

        anchors {
            top: true
            right: true
        }

        implicitWidth: Theme.dp(1)
        implicitHeight: Theme.dp(1)

        margins.top: Theme.dp(5)
        margins.right: Theme.dp(5)
    }

    // ── Power popup (top) ──
    PowerPopup {
        id: powerPopup
        popupPanel: popupAnchor
        visible: root.powerPopupOpen
        closeCallback: function() { root.powerPopupOpen = false }
        onVisibleChanged: {
            if (!visible) root.powerPopupOpen = false
        }
        anchor.rect.y: root.powerY
    }

    // ── WiFi popup (below power) ──
    WifiPopup {
        id: wifiPopup
        popupPanel: popupAnchor
        visible: root.wifiPopupOpen
        onVisibleChanged: {
            if (!visible) root.wifiPopupOpen = false
        }
        anchor.rect.y: root.wifiY
    }

    // ── Bluetooth popup (below wifi) ──
    BluetoothPopup {
        id: btPopup
        popupPanel: popupAnchor
        visible: root.btPopupOpen
        onVisibleChanged: {
            if (!visible) root.btPopupOpen = false
        }
        anchor.rect.y: root.btY
    }

    // ── Notification popup (below bar when bar open) ──
    NotificationPopup {
        id: notifPopup
        popupPanel: popupAnchor
        visible: root.notifPopupOpen
        grabFocus: false
        trackedNotifs: root.trackedNotifs
        closeCallback: function() { root.notifPopupOpen = false }

        // Use popupAnchor as a stable reference window
        anchor.window: popupAnchor

        anchor.rect: Qt.rect(0, Math.round(root.notifY), 1, 1)

        onVisibleChanged: {
            if (visible) root.scheduleNotifAnchorRefresh()
            else root.notifPopupOpen = false
        }
    }
}
