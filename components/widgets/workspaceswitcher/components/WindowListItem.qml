import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.config

Item {
    id: listItem
    property var modelData: null
    property int itemIndex: -1
    property var wsService: null

    width: parent ? parent.width : 0
    height: Theme.dp(40)

    opacity: modelData ? 1 : 0
    visible: modelData !== null

    property bool itemHover: false
    property string winAddr: modelData && listItem.wsService ? listItem.wsService.getToplevelAddr(modelData) : ""
    property bool winActivated: modelData && modelData.activated ? true : false
    property bool winFloating: {
        if (!modelData || !modelData.lastIpcObject) return false;
        return modelData.lastIpcObject.floating === true || modelData.lastIpcObject.floating === 1;
    }
    property bool winFullscreen: modelData && modelData.fullscreen ? true : false

    // Background Card
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.dp(1)
        color: (modelData && modelData.activated) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : (listItem.itemHover ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.05) : "transparent")
        border.width: 1
        border.color: (modelData && modelData.activated) ? Theme.accent : (listItem.itemHover ? Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5) : "transparent")
        radius: Theme.dp(6)
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.dp(12)
        anchors.rightMargin: Theme.dp(8)
        spacing: Theme.dp(12)

        // Status Indicator (No numbers)
        Rectangle {
            width: Theme.dp(10)
            height: Theme.dp(10)
            radius: 5
            color: (modelData && modelData.activated) ? Theme.accent : Theme.textMuted
            opacity: (modelData && modelData.activated) ? 1.0 : 0.3
        }

        // App Info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            
            Text {
                Layout.fillWidth: true
                text: modelData && listItem.wsService ? listItem.wsService.getWindowTitle(modelData) : "Unknown App"
                color: (modelData && modelData.activated) ? Theme.accent : Theme.textPrimary
                font.pixelSize: Theme.dp(10)
                font.weight: (modelData && modelData.activated) ? Font.Bold : Font.Medium
                elide: Text.ElideRight
            }
            
            Text {
                Layout.fillWidth: true
                text: winFloating ? "Floating" : "Tiled"
                color: Theme.textMuted
                font.pixelSize: Theme.dp(7.5)
                font.italic: true
            }
        }

        // Action Buttons
        RowLayout {
            spacing: Theme.dp(6)

            // Layer Controls (Floating Only)
            RowLayout {
                spacing: Theme.dp(4)
                visible: winFloating && (listItem.wsService ? listItem.wsService.panelWindows.length > 1 : false)

                CommandBtn {
                    label: "RAISE"
                    onClicked: {
                        listItem.wsService.moveWindowToTop(listItem.wsService.panelWorkspace, listItem.winAddr);
                        listItem.wsService.alterZOrder(listItem.winAddr, "top");
                    }
                }

                CommandBtn {
                    label: "LOWER"
                    onClicked: {
                        listItem.wsService.moveWindowToBottom(listItem.wsService.panelWorkspace, listItem.winAddr);
                        listItem.wsService.alterZOrder(listItem.winAddr, "bottom");
                    }
                }
            }

            Rectangle { width: 1; height: Theme.dp(14); color: Theme.border; opacity: 0.3; visible: listItem.winAddr !== "" }

            IconButton {
                text: winFloating ? "T" : "F"
                onClicked: Hyprland.dispatch("togglefloating address:" + listItem.winAddr)
                highlighted: winFloating
            }

            IconButton {
                text: "FS"
                onClicked: listItem.wsService.fullscreenWindow(listItem.winAddr, listItem.wsService.panelWorkspace)
                highlighted: winFullscreen
            }

            IconButton {
                text: "close"
                                    onClicked: Hyprland.dispatch("closewindow address:" + listItem.winAddr)
                isDanger: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (listItem.winAddr) {
                listItem.wsService.moveWindowToTop(listItem.wsService.panelWorkspace, listItem.winAddr);
                listItem.wsService.alterZOrder(listItem.winAddr, "top");
            }
        }
        hoverEnabled: true
        onEntered: listItem.itemHover = true
        onExited: listItem.itemHover = false
        z: -1
    }

    // --- Sub Components ---
    
    component CommandBtn: Rectangle {
        id: cmdBtn
        property string label: ""
        signal clicked()
        
        width: Theme.dp(48); height: Theme.dp(22)
        radius: Theme.dp(4)
        color: cmdMouse.containsMouse ? Theme.accent : Theme.bgSecondary
        border.width: 1
        border.color: cmdMouse.containsMouse ? Theme.accent : Theme.border
        
        Text {
            anchors.centerIn: parent
            text: cmdBtn.label
            color: cmdMouse.containsMouse ? Theme.bgPrimary : Theme.textPrimary
            font.pixelSize: Theme.dp(7)
            font.weight: Font.Bold
            // letterSpacing removed as it caused load errors
        }
        
        MouseArea {
            id: cmdMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cmdBtn.clicked()
        }
    }

    component IconButton: Rectangle {
        id: iconBtn
        property string text: ""
        property bool highlighted: false
        property bool isDanger: false
        signal clicked()
        
        width: Theme.dp(24); height: Theme.dp(24)
        radius: Theme.dp(4)
        color: btnMouse.containsMouse ? (isDanger ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.15) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)) : "transparent"
        border.width: highlighted ? 1 : 0
        border.color: Theme.accent
        
        Text {
            anchors.centerIn: parent
            text: iconBtn.text
            color: btnMouse.containsMouse ? (isDanger ? Theme.danger : Theme.accent) : (highlighted ? Theme.accent : Theme.textPrimary)
            font.pixelSize: Theme.dp(9)
            font.weight: Font.Bold
        }
        
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: iconBtn.clicked()
        }
    }
}
