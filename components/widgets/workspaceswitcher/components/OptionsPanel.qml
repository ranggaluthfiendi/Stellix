import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.config

Item {
    id: optionsPanel
    required property var wsService

    Layout.fillWidth: true
    Layout.preferredHeight: wsService.expandTargetHeight
    clip: true
    visible: wsService.expandablePanelOpen

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
        border.width: 1
        border.color: wsService.expandablePanelOpen ? Theme.accent : Theme.border
        radius: 0

        Column {
            id: expandableInner
            anchors.fill: parent
            anchors.margins: Theme.dp(6)
            spacing: Theme.dp(4)

            // ── Header: Workspace selector + navigation ──
            RowLayout {
                width: parent.width
                height: Theme.dp(24)
                spacing: Theme.dp(6)

                Text {
                    text: "Workspace " + String(wsService.panelWorkspace)
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: Theme.dp(10)
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { width: 1; height: 1; Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(22); Layout.preferredHeight: Theme.dp(20)
                    Layout.alignment: Qt.AlignVCenter
                    color: panelWs1Mouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
                    border.width: 1; border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3); radius: 0
                    Text {
                        anchors.centerIn: parent; text: "1"; color: Theme.accent; font.pixelSize: Theme.dp(8); font.bold: true
                    }
                    MouseArea {
                        id: panelWs1Mouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: wsService.panelWorkspace = 1
                    }
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(22); Layout.preferredHeight: Theme.dp(20)
                    Layout.alignment: Qt.AlignVCenter
                    color: panelLeftMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
                    border.width: 1; border.color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
                    Text {
                        anchors.centerIn: parent; text: "◀"; color: wsService.panelWorkspace > 1 ? Theme.textPrimary : Theme.textMuted; font.pixelSize: Theme.dp(8); font.bold: true
                    }
                    MouseArea {
                        id: panelLeftMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (wsService.panelWorkspace > 1) wsService.panelWorkspace-- }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(22); Layout.preferredHeight: Theme.dp(20)
                    Layout.alignment: Qt.AlignVCenter
                    color: panelRightMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
                    border.width: 1; border.color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15); radius: 0
                    Text {
                        anchors.centerIn: parent; text: "▶"; color: wsService.panelWorkspace < wsService.maxWorkspaceId ? Theme.textPrimary : Theme.textMuted; font.pixelSize: Theme.dp(8); font.bold: true
                    }
                    MouseArea {
                        id: panelRightMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (wsService.panelWorkspace < wsService.maxWorkspaceId) wsService.panelWorkspace++ }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            // ── Window List (Layer) ──
            Item {
                width: parent.width
                height: wsService._layerItemH * wsService._layerVisibleItems
                clip: true

                Flickable {
                    anchors.fill: parent
                    contentWidth: parent.width
                    contentHeight: layerList.implicitHeight
                    interactive: contentHeight > height
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        policy: layerList.implicitHeight > parent.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        width: Theme.dp(6)
                    }

                    Column {
                        id: layerList
                        width: parent.width
                        spacing: Theme.dp(3)

                        Repeater {
                            model: {
                                var _ = wsService.refreshTrigger;
                                var __ = wsService.panelWorkspace;
                                var wins = wsService.panelWindows;
                                wins.length;
                            }
                            delegate: WindowListItem {
                                modelData: {
                                    var wins = wsService.panelWindows;
                                    wins.length > index ? wins[index] : null;
                                }
                                itemIndex: index
                                wsService: optionsPanel.wsService
                            }
                        }
                    }
                }


            }

            // ── Swap Button ──
            Item {
                width: parent.width
                height: Theme.dp(36)
                clip: true

                Rectangle {
                    height: Theme.dp(28)
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: swapBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
                    border.width: 1
                    border.color: swapBtnMouse.containsMouse ? Theme.accent : Theme.border
                    radius: 0

                    Text {
                        anchors.centerIn: parent
                        text: "Swap"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(9)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: swapBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wsService.runLayoutCmd("swap", "")
                    }
                }
            }
        }
    }
}
