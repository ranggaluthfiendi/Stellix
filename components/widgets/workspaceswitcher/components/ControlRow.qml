import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.components.elements

Item {
    id: controlRow
    required property var wsService
    required property real navH

    Layout.fillWidth: true
    Layout.preferredHeight: navH

    // Left side: First, arrows, workspace numbers
    RowLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(5)

        Rectangle {
            Layout.preferredWidth: Theme.dp(44)
            Layout.preferredHeight: Theme.dp(26)
            color: firstWsMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
            border.width: 1
            border.color: wsService.focusedId === 1 ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
            radius: 0
            Text {
                anchors.centerIn: parent
                text: "First"
                color: wsService.focusedId === 1 ? Theme.accent : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.8)
                font.pixelSize: Theme.dp(8)
                font.weight: Font.Bold
            }
            MouseArea {
                id: firstWsMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    wsService.focusedId = 1;
                    wsService.pageStart = 1;
                    wsService.activateWorkspace(1);
                    wsService.closeRequested();
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: Theme.dp(28)
            Layout.preferredHeight: Theme.dp(26)
            color: leftMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
            border.width: 1; border.color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
            IconChevronLeft {
                anchors.centerIn: parent; iconSize: Theme.dp(12)
                iconColor: wsService.focusedId > 1 ? Theme.textPrimary : Theme.textMuted
            }
            MouseArea {
                id: leftMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wsService.focusedId > 1) {
                        wsService.focusedId = wsService.focusedId - 1;
                        wsService.ensureFocusedVisible();
                    }
                }
                onEntered: { if (wsService.draggingToplevel && wsService.pageStart > 1 && wsService.leftDragPageTimer) wsService.leftDragPageTimer.restart() }
                onExited: { if (wsService.leftDragPageTimer) wsService.leftDragPageTimer.stop() }
            }
        }

        Repeater {
            model: wsService.workspaceIdList
            delegate: Rectangle {
                required property int modelData
                readonly property bool active: modelData === wsService.focusedId
                Layout.preferredWidth: Theme.dp(22); Layout.preferredHeight: Theme.dp(22)
                Layout.alignment: Qt.AlignVCenter; radius: 0
                color: active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : "transparent"
                border.width: active ? 1 : 0
                border.color: active ? Theme.accent : "transparent"
                Text {
                    anchors.centerIn: parent; text: String(modelData)
                    color: active ? Theme.accent : Theme.textPrimary
                    font.pixelSize: Theme.dp(10)
                    font.weight: active ? Font.Bold : Font.Normal
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: wsService.activateWorkspace(modelData) }
            }
        }

        Rectangle {
            Layout.preferredWidth: Theme.dp(28)
            Layout.preferredHeight: Theme.dp(26)
            color: rightMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
            border.width: 1; border.color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
            IconChevronRight { anchors.centerIn: parent; iconSize: Theme.dp(12); iconColor: Theme.textPrimary }
            MouseArea {
                id: rightMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wsService.focusedId >= wsService.maxWorkspaceId) wsService.addWorkspace();
                    else {
                        wsService.focusedId = wsService.focusedId + 1;
                        wsService.ensureFocusedVisible();
                    }
                }
                onEntered: { if (wsService.draggingToplevel && wsService.rightDragPageTimer) wsService.rightDragPageTimer.restart() }
                onExited: { if (wsService.rightDragPageTimer) wsService.rightDragPageTimer.stop() }
            }
        }
    }

    // Right side: remove/add, Options, Close WS, Close All
    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(4)

        Rectangle {
            Layout.preferredWidth: Theme.dp(24); Layout.preferredHeight: Theme.dp(26)
            color: removeWsMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.25) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
            border.width: 1; border.color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
            Text {
                anchors.centerIn: parent; text: "−"
                color: wsService.maxWorkspaceId > wsService.visibleCount ? Theme.textPrimary : Theme.textMuted
                font.pixelSize: Theme.dp(14); font.bold: true
            }
            MouseArea {
                id: removeWsMouse
                anchors.fill: parent; enabled: wsService.maxWorkspaceId > wsService.visibleCount
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: wsService.removeWorkspace()
            }
        }
        Rectangle {
            Layout.preferredWidth: Theme.dp(24); Layout.preferredHeight: Theme.dp(26)
            color: addWsMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
            border.width: 1; border.color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
            Text {
                anchors.centerIn: parent; text: "+"
                color: Theme.textPrimary; font.pixelSize: Theme.dp(14); font.bold: true
            }
            MouseArea {
                id: addWsMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: wsService.addWorkspace()
            }
        }

        Rectangle { width: 1; Layout.preferredHeight: Theme.dp(18); color: Theme.border }

        Rectangle {
            Layout.preferredWidth: Theme.dp(48); Layout.preferredHeight: Theme.dp(26)
            color: panelToggleMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : (wsService.expandablePanelOpen ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04))
            border.width: 1; border.color: wsService.expandablePanelOpen ? Theme.accent : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
            Text { anchors.centerIn: parent; text: "Options"; color: Theme.accent; font.pixelSize: Theme.dp(8); font.bold: true }
            MouseArea {
                id: panelToggleMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: wsService.toggleExpandablePanel()
            }
        }

        Rectangle { width: 1; Layout.preferredHeight: Theme.dp(18); color: Theme.border }

        Rectangle {
            id: closeWsBtn
            visible: wsService.windowsForWorkspace(wsService.focusedId).length > 0
            Layout.preferredWidth: Theme.dp(80); Layout.preferredHeight: Theme.dp(26)
            color: closeWsMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.25) : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.08)
            border.width: 1; border.color: closeWsMouse.containsMouse ? Theme.danger : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.2); radius: 0
            RowLayout {
                anchors.centerIn: parent; spacing: Theme.dp(3)
                Text { text: "close"; color: Theme.danger; font.pixelSize: Theme.dp(9) 
                font.family: Typography.materialSymbols
                font.styleName: "Regular"
                                                       }
                Text { text: "Close WS"; color: Theme.danger; font.pixelSize: Theme.dp(8); font.weight: Font.Bold }
            }
            MouseArea {
                id: closeWsMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: wsService.closeWorkspaceWindows()
            }
        }

        Rectangle {
            Layout.preferredWidth: Theme.dp(72); Layout.preferredHeight: Theme.dp(26)
            color: closeAllMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.25) : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.08)
            border.width: 1; border.color: closeAllMouse.containsMouse ? Theme.danger : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.2); radius: 0
            RowLayout {
                anchors.centerIn: parent; spacing: Theme.dp(3)
                IconClose { iconSize: Theme.dp(10); iconColor: Theme.danger }
                Text { text: "Close All"; color: Theme.danger; font.pixelSize: Theme.dp(8); font.weight: Font.Bold }
            }
            MouseArea {
                id: closeAllMouse
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: wsService.closeAllAndReset()
            }
        }
    }
}
