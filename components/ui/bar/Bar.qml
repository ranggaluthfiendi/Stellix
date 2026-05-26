import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.ui.bar.sections
import qs.components.widgets.barpopup
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Scope {
    id: root

    property real s: Scales.uiScale

    property bool pinned: true
    property bool autoHideEnabled: true

    readonly property bool isBottom: BarLayoutState.barPosition === "bottom"
    readonly property int barH: BarLayoutState.barHeight * s

    BarState {
        id: state
    }

    Component.onCompleted: {
        state.loadState()
    }

    property bool _loadingState: false

    Connections {
        target: state
        function onStateLoaded(p, a) {
            root._loadingState = true
            root.pinned = p
            root.autoHideEnabled = a
            root._loadingState = false
        }
    }

    onPinnedChanged: {
        if (!_loadingState) {
            state.applyState(root.pinned, root.autoHideEnabled)
            if (BarLayoutState.showPinnedIndicator) {
                BarPopupState.showIndicator("pinned", pinned ? 1.0 : 0.0, false)
            }
        }
    }
    onAutoHideEnabledChanged: {
        if (!_loadingState) state.applyState(root.pinned, root.autoHideEnabled)
    }

    property bool _triggerHovering: false
    property bool _barHovering: false

    readonly property bool expanded: pinned || (_triggerHovering || _barHovering)

    // ── Hover trigger zone (always visible when unpinned, bar covers it when expanded) ──
    PanelWindow {
        id: trigger
        visible: !root.pinned
        color: "transparent"

        anchors {
            top: !root.isBottom
            bottom: root.isBottom
            left: true
            right: true
        }

        implicitHeight: Theme.dp(12)

        Component.onCompleted: {
            if (trigger.WlrLayershell) {
                trigger.WlrLayershell.layer = WlrLayer.Overlay
                trigger.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                trigger.WlrLayershell.exclusiveZone = -1
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root._triggerHovering = true
            onExited: root._triggerHovering = false
        }
    }

    // ── Main bar ──
    PanelWindow {
        id: bar
        implicitHeight: root.barH
        color: "transparent"

        anchors {
            top: !root.isBottom
            bottom: root.isBottom
            left: true
            right: true
        }

        margins.top: (!root.isBottom) ? (root.expanded ? 0 : -(root.barH)) : 0
        margins.bottom: root.isBottom ? (root.expanded ? 0 : -(root.barH)) : 0

        Behavior on margins.top {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on margins.bottom {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Component.onCompleted: {
            if (bar.WlrLayershell) {
                bar.WlrLayershell.layer = WlrLayer.Overlay
                bar.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
            }
            BarLayoutState.barScreenWidth = bar.screen ? bar.screen.width : Screen.width
        }

        Rectangle {
            id: barBg
            anchors.fill: parent
            color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, BarLayoutState.barOpacity)

            Rectangle {
                visible: BarLayoutState.barBorder
                anchors.bottom: !root.isBottom ? parent.bottom : undefined
                anchors.top: root.isBottom ? parent.top : undefined
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, BarLayoutState.barOpacity)
            }
        }

        MouseArea {
            id: barMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.RightButton

            onEntered: root._barHovering = true
            onExited: root._barHovering = false

            onPressed: function(mouse) {
                root.pinned = !root.pinned
            }
        }

        Item {
            anchors.fill: parent

            BarLeft {
                anchors.left: parent.left
                anchors.leftMargin: Theme.dp(14)
                anchors.verticalCenter: parent.verticalCenter
            }

            BarCenter {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            BarRight {
                anchors.right: parent.right
                anchors.rightMargin: Theme.dp(10)
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── Overlay to close sys tray menus ──
        Item {
            anchors.fill: parent
            z: 9999
            visible: SysTrayState.openedMenu !== null

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: SysTrayState.closeAll()
            }
        }
    }

    // ── Overlay to close VB indicator ──
    PanelWindow {
        id: indicatorOutsideOverlay
        visible: BarPopupState.indicatorVisible
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Component.onCompleted: {
            if (indicatorOutsideOverlay.WlrLayershell) {
                indicatorOutsideOverlay.WlrLayershell.layer = WlrLayer.Top
                indicatorOutsideOverlay.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                indicatorOutsideOverlay.WlrLayershell.exclusiveZone = -1
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: {
                BarPopupState.indicatorVisible = false
            }
        }
    }

    readonly property var clockItem: BarLayoutState.getItem("clock")

    // Indicators are now automated via shell.qml hub

    PanelWindow {
        id: clockAnchorWin
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

        margins.top: root.isBottom ? 0 : BarLayoutState.barHeight * s
        margins.bottom: root.isBottom ? BarLayoutState.barHeight * s : 0
        margins.left: 0
    }

    function computeClockX() {
        if (!root.clockItem) return Math.round((bar.width - vbIndicator.implicitWidth) / 2)
        try {
            var pos = root.clockItem.mapToGlobal(0, 0)
            return Math.round(pos.x + root.clockItem.width / 2 - vbIndicator.implicitWidth / 2)
        } catch(e) {
            return Math.round((bar.width - vbIndicator.implicitWidth) / 2)
        }
    }

    // ── Volume/Brightness Indicator ──
    PopupWindow {
        id: vbIndicatorPopup
        visible: BarPopupState.indicatorVisible
        color: "transparent"
        grabFocus: false

        anchor.window: bar
        anchor.rect.x: Math.round((bar.width - vbIndicator.width) / 2)
        anchor.rect.y: root.isBottom
            ? -(vbIndicator.height + Theme.dp(4))
            : bar.height + Theme.dp(4)

        implicitWidth: vbIndicator.width
        implicitHeight: vbIndicator.height

        VolumeBrightnessIndicator {
            id: vbIndicator
            indicatorType: BarPopupState.indicatorType
            indicatorValue: BarPopupState.indicatorValue
            indicatorMuted: BarPopupState.indicatorMuted
            animating: BarPopupState.indicatorVisible
        }
    }

    // --- Separate PinIndicator removed as it is now integrated ---
}
