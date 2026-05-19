import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.config
import qs.components.elements
import "components"

PanelWindow {
    id: root

    signal closeRequested()

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: wsService.commandRunning ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1

    // ── Service (all state, timers, logic) ──
    WorkspaceSwitcherService {
        id: wsService
        anchors.fill: parent
    }

    // ── Behavior ──
    property real animY: -Theme.dp(12)
    Behavior on animY {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    color: "transparent"
    onVisibleChanged: {
        if (visible) {
            wsService.refreshTrigger++;
            wsService.ensureFocusedVisible();
            animY = -Theme.dp(12);
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        } else {
            wsService.clearDrag();
            wsService.expandablePanelOpen = false;
            wsService.expandTargetHeight = 0;
        }
    }
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Connections {
        function onFocusedWorkspaceChanged() {
            if (root.visible) wsService.ensureFocusedVisible();
        }
        target: Hyprland
    }

    // ── Background click to close ──
    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        acceptedButtons: Qt.AllButtons
        onPressed: { root.closeRequested() }
    }

    // ── Main Popup ──
    Rectangle {
        id: popup
        anchors.horizontalCenter: parent.horizontalCenter
        y: (parent.height * 0.7) - (height / 2) + root.animY
        width: wsService.overlayW
        height: wsService.overlayH
        color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0.82)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        radius: 0

        Behavior on height {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: function(mouse) { mouse.accepted = true; }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(12)
            spacing: Theme.dp(8)

            // ── Control Buttons Row ──
            ControlRow {
                wsService: wsService
                navH: wsService.navH
            }

            // ── Workspace Previews ──
            WorkspacePreviews {
                wsService: wsService
                popup: popup
                previewH: wsService.previewH
            }

            // ── Options Panel ──
            OptionsPanel {
                wsService: wsService
            }
        }
    }

    // ── Keyboard Navigation ──
    Item {
        anchors.fill: parent
        focus: true
        Keys.enabled: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.closeRequested()
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                var prevWs = Math.max(1, wsService.focusedId - 1);
                Hyprland.dispatch("workspace " + prevWs);
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                if (wsService.focusedId >= wsService.maxWorkspaceId) {
                    wsService.addWorkspace();
                } else {
                    var nextWs = wsService.focusedId + 1;
                    Hyprland.dispatch("workspace " + nextWs);
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab) {
                var prevWs = Math.max(1, wsService.focusedId - 1);
                Hyprland.dispatch("workspace " + prevWs);
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                if (wsService.focusedId >= wsService.maxWorkspaceId) {
                    wsService.addWorkspace();
                } else {
                    var nextWs = wsService.focusedId + 1;
                    Hyprland.dispatch("workspace " + nextWs);
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                wsService.activateWorkspace(wsService.focusedId);
                root.closeRequested();
                event.accepted = true;
            }
        }
    }
}
