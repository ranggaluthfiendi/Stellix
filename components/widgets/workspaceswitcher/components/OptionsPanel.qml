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
        color: Theme.bgPrimary
        border.width: 1
        border.color: Theme.border
        radius: Theme.dp(8)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(6)

            // ── Header ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)

                Rectangle {
                    width: Theme.dp(28); height: Theme.dp(28)
                    radius: Theme.dp(14)
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                    Text {
                        anchors.centerIn: parent
                        text: "⌥"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(14)
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Text {
                        text: "Workspace " + wsService.panelWorkspace
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                    }
                }

                Item { Layout.fillWidth: true }

                // Quick Navigation
                RowLayout {
                    spacing: Theme.dp(4)
                    
                    NavBtn { 
                        text: "1"
                        onClicked: wsService.panelWorkspace = 1
                        highlighted: wsService.panelWorkspace === 1
                    }
                    
                    Rectangle { width: 1; height: Theme.dp(14); color: Theme.border; Layout.leftMargin: Theme.dp(2); Layout.rightMargin: Theme.dp(2) }

                    NavBtn { 
                        text: "◀"
                        enabled: wsService.panelWorkspace > 1
                        onClicked: wsService.panelWorkspace--
                    }
                    
                    NavBtn { 
                        text: "▶"
                        enabled: wsService.panelWorkspace < wsService.maxWorkspaceId
                        onClicked: wsService.panelWorkspace++
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.border; opacity: 0.3 }

            // ── Window List ──
            Item {
                id: listContainer
                Layout.fillWidth: true
                // Compact height for 3 items
                Layout.preferredHeight: (3 * Theme.dp(40)) + (2 * Theme.dp(4))

                Flickable {
                    id: flick
                    anchors.fill: parent
                    contentHeight: layerList.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: true // Always interactive

                    Column {
                        id: layerList
                        width: flick.width
                        spacing: Theme.dp(4)

                        Repeater {
                            model: wsService.panelWindows
                            delegate: WindowListItem {
                                width: layerList.width
                                modelData: model.modelData
                                itemIndex: index
                                wsService: optionsPanel.wsService
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar { 
                        width: Theme.dp(4)
                        policy: layerList.implicitHeight > flick.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                        anchors.right: flick.right
                    }
                }

                // Empty State
                Text {
                    visible: wsService.panelWindows.length === 0
                    anchors.centerIn: parent
                    text: "No active windows in this workspace"
                    color: Theme.textMuted
                    font.pixelSize: Theme.dp(9)
                    font.italic: true
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.border; opacity: 0.5 }

            // ── Actions ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)

                LargeBtn {
                    text: "Swap Layout"
                    icon: "⇅"
                    Layout.fillWidth: true
                    onClicked: wsService.runLayoutCmd("swap", "")
                }
            }
        }
    }

    // Components
    component NavBtn: Rectangle {
        id: navBtnRoot
        property alias text: navText.text
        property bool highlighted: false
        signal clicked()

        width: Theme.dp(26); height: Theme.dp(26)
        radius: Theme.dp(6)
        color: highlighted ? Theme.accent : (navBtnMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.1) : "transparent")
        border.width: 1
        border.color: highlighted ? Theme.accent : Theme.border
        opacity: enabled ? 1.0 : 0.3

        Text {
            id: navText
            anchors.centerIn: parent
            color: highlighted ? Theme.bgPrimary : Theme.textPrimary
            font.pixelSize: Theme.dp(10)
            font.weight: Font.Bold
        }

        MouseArea {
            id: navBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navBtnRoot.clicked()
        }
    }

    component LargeBtn: Rectangle {
        id: largeBtnRoot
        property string text: ""
        property string icon: ""
        property bool danger: false
        signal clicked()

        height: Theme.dp(34)
        radius: Theme.dp(6)
        color: largeBtnMouse.containsMouse ? (danger ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.15) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)) : Theme.bgSecondary
        border.width: 1
        border.color: largeBtnMouse.containsMouse ? (danger ? Theme.danger : Theme.accent) : Theme.border

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.dp(6)
            Text { text: largeBtnRoot.icon; color: danger ? Theme.danger : Theme.accent; font.pixelSize: Theme.dp(12); font.weight: Font.Bold }
            Text { text: largeBtnRoot.text; color: Theme.textPrimary; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
        }

        MouseArea {
            id: largeBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: largeBtnRoot.clicked()
        }
    }
}
