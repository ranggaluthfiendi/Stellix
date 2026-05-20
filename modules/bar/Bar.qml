import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.ui.bar.sections
import qs.components.widgets.rightbar
import qs.config
import qs.services

Scope {
    id: root

    property real s: Scales.uiScale

    property bool pinned: true
    property bool autoHideEnabled: true

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
        if (!_loadingState) state.applyState(root.pinned, root.autoHideEnabled)
    }
    onAutoHideEnabledChanged: {
        if (!_loadingState) state.applyState(root.pinned, root.autoHideEnabled)
    }

    property bool _triggerHovering: false
    property bool _barHovering: false

    readonly property bool expanded: pinned || (autoHideEnabled && (_triggerHovering || _barHovering))

    // ── Hover trigger zone (only visible when bar is hidden) ──
    PanelWindow {
        id: trigger
        visible: !root.expanded
        color: "transparent"

        anchors {
            top: true
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
        implicitHeight: Dimens.barHeight * s
        color: Theme.bgPrimary

        anchors {
            top: true
            left: true
            right: true
        }

        margins.top: root.expanded ? 0 : -(Dimens.barHeight * s)

        Behavior on margins.top {
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
        }

        MouseArea {
            id: barMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.RightButton

            onEntered: root._barHovering = true
            onExited: {
                if (!root.pinned && root.autoHideEnabled)
                    root._barHovering = false
            }

            onPressed: function(mouse) {
                root.pinned = !root.pinned
            }
        }

        Item {
            anchors.fill: parent

            BarLeft {
                anchors.left: parent.left
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

    // ── Calendar outside overlay ──
    PanelWindow {
        id: calendarOutsideOverlay
        visible: RightBarState.calendarOpen
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Component.onCompleted: {
            if (calendarOutsideOverlay.WlrLayershell) {
                calendarOutsideOverlay.WlrLayershell.layer = WlrLayer.Top
                calendarOutsideOverlay.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                calendarOutsideOverlay.WlrLayershell.exclusiveZone = -1
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: RightBarState.calendarOpen = false
        }
    }

    // ── Calendar popup ──
    PopupWindow {
        id: calendarPopup
        visible: RightBarState.calendarOpen
        color: "transparent"
        grabFocus: false

        anchor.window: bar
        anchor.rect.x: Math.round((bar.width - implicitWidth) / 2)
        anchor.rect.y: bar.height + Theme.dp(4)

        implicitWidth: Theme.dp(244)
        implicitHeight: calendarCard.implicitHeight

        Rectangle {
            id: calendarBg
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: 0

            opacity: 0
            y: -Theme.dp(8)

            states: State {
                name: "visible"
                when: calendarPopup.visible
                PropertyChanges { target: calendarBg; opacity: 1; y: 0 }
            }

            transitions: [
                Transition {
                    from: ""
                    to: "visible"
                    NumberAnimation { target: calendarBg; property: "opacity"; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { target: calendarBg; property: "y"; duration: 200; easing.type: Easing.OutCubic }
                },
                Transition {
                    from: "visible"
                    to: ""
                    NumberAnimation { target: calendarBg; property: "opacity"; duration: 140; easing.type: Easing.InCubic }
                    NumberAnimation { target: calendarBg; property: "y"; duration: 140; easing.type: Easing.InCubic }
                }
            ]

            CalendarCard {
                id: calendarCard
                anchors.fill: parent
            }
        }
    }
}
