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
    height: wsService ? wsService._layerItemH : Theme.dp(30)

    opacity: modelData ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    visible: modelData !== null && modelData !== undefined

    property bool itemHover: false
    property string winAddr: modelData && wsService ? wsService.getToplevelAddr(modelData) : ""
    property bool winActivated: modelData && modelData.activated ? true : false
    property bool winFloating: {
        if (!modelData || !modelData.lastIpcObject) return false;
        return modelData.lastIpcObject.floating === true || modelData.lastIpcObject.floating === 1;
    }
    property bool winFullscreen: modelData && modelData.fullscreen ? true : false

    Rectangle {
        anchors.fill: parent
        color: listItem.itemHover ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.3)
        border.width: 1
        border.color: winActivated ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4)
        radius: 0
    }

    // Background MouseArea for hover + title click (behind buttons)
    MouseArea {
        id: bgMouse
        anchors.fill: parent
        anchors.rightMargin: actionRow.width + Theme.dp(8)
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 1
        onContainsMouseChanged: listItem.itemHover = containsMouse
        onClicked: {
            if (winAddr && winAddr !== "0x") Hyprland.dispatch("focuswindow address:" + winAddr);
        }
    }

    // Title text (left)
    Text {
        id: titleText
        anchors.left: parent.left
        anchors.leftMargin: Theme.dp(8)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: actionRow.left
        anchors.rightMargin: Theme.dp(8)
        z: 2

        text: modelData && wsService ? wsService.getWindowTitle(modelData) : ""
        color: Theme.textPrimary
        font.pixelSize: Theme.dp(8)
        font.weight: Font.Medium
        elide: Text.ElideRight
    }

    // Action Buttons Row (Right anchored)
    Row {
        id: actionRow
        anchors.right: parent.right
        anchors.rightMargin: Theme.dp(4)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(4)
        height: Theme.dp(20)
        z: 10

        // Arrow buttons (z-order) - only for floating windows
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.dp(2)
            visible: winFloating && (wsService ? wsService.panelWindows.length > 1 : false)

            // Up Arrow (▲) - move to top of stack
            // Show if not already at top
            Rectangle {
                width: Theme.dp(20)
                height: Theme.dp(18)
                color: zUpMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                border.width: 1
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
                radius: 0
                visible: listItem.itemIndex > 0

                Text {
                    anchors.centerIn: parent
                    text: "▲"
                    color: Theme.accent
                    font.pixelSize: Theme.dp(7)
                }

                MouseArea {
                    id: zUpMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!winAddr || winAddr === "0x") return;
                        var wsId = modelData && modelData.workspace ? modelData.workspace.id : wsService.panelWorkspace;
                        wsService.moveWindowToTop(wsId, winAddr);
                        Hyprland.dispatch("alterzorder top,address:" + winAddr);
                        Qt.callLater(function() {
                            wsService.refreshTrigger++;
                            wsService.forceRefreshTimer.restart();
                        });
                    }
                }
            }

            // Down Arrow (▼) - move to bottom of stack
            // Show if not already at bottom
            Rectangle {
                width: Theme.dp(20)
                height: Theme.dp(18)
                color: zDownMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                border.width: 1
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
                radius: 0
                visible: {
                    var wins = wsService ? wsService.panelWindows : [];
                    var cnt = wins ? wins.length : 0;
                    return listItem.itemIndex < cnt - 1;
                }

                Text {
                    anchors.centerIn: parent
                    text: "▼"
                    color: Theme.accent
                    font.pixelSize: Theme.dp(7)
                }

                MouseArea {
                    id: zDownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!winAddr || winAddr === "0x") return;
                        var wsId = modelData && modelData.workspace ? modelData.workspace.id : wsService.panelWorkspace;
                        wsService.moveWindowToBottom(wsId, winAddr);
                        Hyprland.dispatch("alterzorder bottom,address:" + winAddr);
                        Qt.callLater(function() {
                            wsService.refreshTrigger++;
                            wsService.forceRefreshTimer.restart();
                        });
                    }
                }
            }
        }

        // Float button
        Rectangle {
            width: Theme.dp(20)
            height: Theme.dp(18)
            anchors.verticalCenter: parent.verticalCenter
            color: winFloating ? Theme.accent : (floatBtn.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1))
            border.width: 1
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
            radius: 0
            visible: winAddr && winAddr !== "0x"

            Text {
                anchors.centerIn: parent
                text: "F"
                color: winFloating ? Theme.bgPrimary : Theme.accent
                font.pixelSize: Theme.dp(8)
                font.weight: Font.Bold
            }

            MouseArea {
                id: floatBtn
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!winAddr || winAddr === "0x") return;
                    Hyprland.dispatch("togglefloating address:" + winAddr);
                    wsService.forceRefreshTimer.restart();
                }
            }
        }

        // Fullscreen button
        Rectangle {
            width: Theme.dp(20)
            height: Theme.dp(18)
            anchors.verticalCenter: parent.verticalCenter
            color: winFullscreen ? Theme.accent : (fsBtn.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1))
            border.width: 1
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
            radius: 0
            visible: winAddr && winAddr !== "0x"

            Text {
                anchors.centerIn: parent
                text: "FS"
                color: winFullscreen ? Theme.bgPrimary : Theme.accent
                font.pixelSize: Theme.dp(7)
                font.weight: Font.Bold
            }

                MouseArea {
                    id: fsBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!winAddr || winAddr === "0x") return;
                        var wsId = modelData && modelData.workspace ? modelData.workspace.id : wsService.panelWorkspace;
                        wsService.fullscreenWindow(winAddr, wsId);
                    }
                }
        }
        
        // Go to workspace button
        Rectangle {
            width: Theme.dp(20)
            height: Theme.dp(18)
            anchors.verticalCenter: parent.verticalCenter
            color: goWsBtn.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
            border.width: 1
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
            radius: 0
            visible: winAddr && winAddr !== "0x" && modelData && modelData.workspace && modelData.workspace.id !== wsService.focusedId

            Text {
                anchors.centerIn: parent
                text: "➤"
                color: Theme.accent
                font.pixelSize: Theme.dp(8)
                font.weight: Font.Bold
            }

            MouseArea {
                id: goWsBtn
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData && modelData.workspace) {
                        wsService.activateWorkspace(modelData.workspace.id);
                    }
                }
            }
        }
    }
}
