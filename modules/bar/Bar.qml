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
        if (!_loadingState) state.applyState(root.pinned, root.autoHideEnabled)
    }
    onAutoHideEnabledChanged: {
        if (!_loadingState) state.applyState(root.pinned, root.autoHideEnabled)
    }

    property bool _triggerHovering: false
    property bool _barHovering: false

    property bool pinIndicatorVisible: false
    property bool _pinIndicatorAnimating: false

    Timer {
        id: pinIndicatorTimer
        interval: 1500
        repeat: false
        onTriggered: root.pinIndicatorVisible = false
    }

    function showPinIndicator() {
        root.pinIndicatorVisible = true
        root._pinIndicatorAnimating = true
        pinIndicatorTimer.restart()
    }

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
                root.showPinIndicator()
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
        visible: RightBarState.indicatorVisible
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
                RightBarState.indicatorVisible = false
            }
        }
    }

    readonly property var clockItem: BarLayoutState.getItem("clock")

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
        visible: RightBarState.indicatorVisible
        color: "transparent"
        grabFocus: false

        anchor.window: clockAnchorWin
        anchor.rect.x: root.computeClockX()
        anchor.rect.y: root.isBottom
            ? -(vbIndicator.implicitHeight + Theme.dp(4))
            : (root.clockItem ? root.clockItem.height : bar.height) + Theme.dp(4)

        implicitWidth: vbIndicator.implicitWidth
        implicitHeight: vbIndicator.implicitHeight

        VolumeBrightnessIndicator {
            id: vbIndicator
            anchors.fill: parent
            indicatorType: RightBarState.indicatorType
            indicatorValue: RightBarState.indicatorValue
            indicatorMuted: RightBarState.indicatorMuted
            animating: RightBarState.indicatorVisible
        }
    }

    // ── Pin Indicator ──
    PopupWindow {
        id: pinIndicatorPopup
        visible: root.pinIndicatorVisible
        color: "transparent"
        grabFocus: false

        anchor.window: clockAnchorWin
        anchor.rect.x: root.computeClockX()
        anchor.rect.y: root.isBottom
            ? -(Theme.dp(40) + Theme.dp(4))
            : (root.clockItem ? root.clockItem.height : bar.height) + Theme.dp(4)

        implicitWidth: Theme.dp(180)
        implicitHeight: Theme.dp(40)

        PinIndicator {
            anchors.fill: parent
            isPinned: root.pinned
            animating: root._pinIndicatorAnimating
        }
    }
}
