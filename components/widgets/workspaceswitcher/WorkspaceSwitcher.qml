import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.elements
import qs.components.widgets.workspaceswitcher.components

PanelWindow {
    id: root

    signal closeRequested()

    property real s: Scales.uiScale

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

    Connections {
        target: wsService
        function onCloseRequested() {
            root.closeRequested();
        }
    }

    // ── Background click to close ──
    MouseArea {
        anchors {
            top: parent.top
            topMargin: BarLayoutState.isBottom ? 0 : BarLayoutState.barHeight * s
            bottom: parent.bottom
            bottomMargin: BarLayoutState.isBottom ? BarLayoutState.barHeight * s : 0
            left: parent.left
            right: parent.right
        }
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

            // ── Keyboard Hints (Footer) ──
            RowLayout {
                id: footerHint
                Layout.fillWidth: true
                Layout.preferredHeight: wsService.hintsH
                spacing: Theme.dp(6)
                Layout.topMargin: Theme.dp(2)
                Layout.bottomMargin: Theme.dp(2)

                Text {
                    text: "←→ Navigate"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

                Text {
                    text: "Enter Select"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

                Text {
                    text: "1-5 Switch"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

                Text {
                    text: "X Options"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

                Text {
                    text: "Esc Close"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }
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
                wsService.focusedId = Math.max(1, wsService.focusedId - 1);
                wsService.ensureFocusedVisible();
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                if (wsService.focusedId >= wsService.maxWorkspaceId) {
                    wsService.addWorkspace();
                } else {
                    wsService.focusedId = wsService.focusedId + 1;
                    wsService.ensureFocusedVisible();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab) {
                wsService.focusedId = Math.max(1, wsService.focusedId - 1);
                wsService.ensureFocusedVisible();
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                if (wsService.focusedId >= wsService.maxWorkspaceId) {
                    wsService.addWorkspace();
                } else {
                    wsService.focusedId = wsService.focusedId + 1;
                    wsService.ensureFocusedVisible();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                wsService.activateWorkspace(wsService.focusedId);
                root.closeRequested();
                event.accepted = true;
            } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                wsService.handleDeleteOrBackspace();
                event.accepted = true;
            } else if (event.key === Qt.Key_1 || event.key === Qt.Key_2 || event.key === Qt.Key_3 || event.key === Qt.Key_4 || event.key === Qt.Key_5) {
                var targetWs = event.key - Qt.Key_1 + 1;
                wsService.activateWorkspace(targetWs);
                root.closeRequested();
                event.accepted = true;
            } else if (event.key === Qt.Key_X) {
                wsService.toggleExpandablePanel();
                event.accepted = true;
            }
        }
    }
}
