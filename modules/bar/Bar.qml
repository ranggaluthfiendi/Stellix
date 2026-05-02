import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.ui.bar.sections
import qs.config
import qs.services

Scope {
    id: root

    property real s: Scales.uiScale

    property bool hovering: false
    property bool pinned: true
    property bool autoHideEnabled: true

    readonly property bool expanded: (
        pinned || (autoHideEnabled && hovering)
    )

    BarState {
        id: state
    }

    Component.onCompleted: {
        state.loadState()
    }

    Connections {
        target: state
        function onStateLoaded(p, a) {
            root.pinned = p
            root.autoHideEnabled = a
        }
    }

    onPinnedChanged: state.applyState(root.pinned, root.autoHideEnabled)
    onAutoHideEnabledChanged: state.applyState(root.pinned, root.autoHideEnabled)

    PanelWindow {
        id: trigger

        implicitHeight: 2 * s
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        visible: !root.expanded

        Component.onCompleted: {
            if (trigger.WlrLayershell) {
                trigger.WlrLayershell.layer = WlrLayer.Overlay
                trigger.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                if (!root.pinned)
                    root.hovering = true
            }
        }
    }

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
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.RightButton

            onPressed: function(mouse) {
                if (mouse.button === Qt.RightButton)
                    root.pinned = !root.pinned
            }

            onDoubleClicked: function(mouse) {
                if (mouse.button === Qt.RightButton)
                    root.autoHideEnabled = !root.autoHideEnabled
            }

            onEntered: {
                if (!root.pinned)
                    root.hovering = true
            }

            onExited: {
                if (!root.pinned)
                    root.hovering = false
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            BarLeft {}
            Item { Layout.fillWidth: true }
            BarCenter { }
            Item { Layout.fillWidth: true }
            BarRight {  }
        }
    }
}
