import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.components.elements

Rectangle {
    id: preview
    required property int wsId
    required property var wsService
    required property var popup
    required property var previewsRepeater

    property int workspaceId: wsId
    readonly property bool active: workspaceId === wsService.focusedId
    readonly property bool dropTarget: workspaceId === wsService.targetWorkspaceDuringDrag

    readonly property var wsWindows: {
        var _ = wsService.refreshTrigger;
        var __ = wsService.toplevels ? wsService.toplevels.values : [];
        var ___ = wsService.workspaces ? wsService.workspaces.values : [];
        wsService.windowsForWorkspace(workspaceId);
    }

    readonly property var fit: {
        var _ = wsService.refreshTrigger;
        return wsService.getFitParams(workspaceId);
    }

    width: wsService.previewW
    height: wsService.previewH

    color: active
        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
        : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.3)

    border.width: active ? 2 : 1
    border.color: dropTarget ? Theme.accent : (active ? Theme.accent : Theme.border)
    radius: 0

    clip: !wsService.draggingToplevel
    z: wsService.draggingToplevel ? 10 : 1

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                wsService.panelWorkspace = preview.workspaceId
                wsService.expandablePanelOpen = true
                wsService.expandPanel()
            } else {
                wsService.activateWorkspace(preview.workspaceId)
            }
        }
    }

    // Workspace number indicator (always visible, behind window tiles)
    Rectangle {
        anchors.centerIn: parent
        width: Theme.dp(22)
        height: Theme.dp(22)
        color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.7)
        border.width: 1
        border.color: active ? Theme.accent : Theme.border
        radius: 0
        z: 0

        Text {
            anchors.centerIn: parent
            text: String(preview.workspaceId)
            color: active ? Theme.accent : Theme.textPrimary
            font.pixelSize: Theme.dp(12)
            font.weight: Font.Bold
        }
    }

    Repeater {
        model: preview.wsWindows
        delegate: Rectangle {
            id: winTile
            required property var modelData
            required property int index
            readonly property var ipc: modelData.lastIpcObject || ({})
            readonly property var at: ipc.at || [0, 0]
            readonly property var size: ipc.size || [400, 300]

            readonly property real relX: (at[0] - wsService.monX) - preview.fit.minX
            readonly property real relY: (at[1] - wsService.monY) - preview.fit.minY

            readonly property real scaledWidth: size[0] * preview.fit.scale
            readonly property real scaledHeight: size[1] * preview.fit.scale

            width: scaledWidth
            height: scaledHeight

            property point dragOffset: Qt.point(0, 0)
            property real dragStartGlobalX: 0
            property real dragStartGlobalY: 0
            property string myAddr: wsService.formatAddr(modelData.address || (modelData.lastIpcObject ? modelData.lastIpcObject.address : ""))
            property bool isDragging: wsService.draggingTileCapturedAddr !== "" && wsService.draggingMoved && myAddr === wsService.draggingTileCapturedAddr
            property bool isDropTarget: wsService.dropTargetAddr !== "" && myAddr === wsService.dropTargetAddr
            property bool isFullscreen: modelData && modelData.fullscreen ? true : false

            x: (relX * preview.fit.scale) + preview.fit.offsetX + dragOffset.x
            y: (relY * preview.fit.scale) + preview.fit.offsetY + dragOffset.y

            z: isDragging ? 9999 : 2
            scale: isDragging ? 1.08 : 1.0

            opacity: wsService.draggingMoved ? (isDragging ? 1.0 : 0.45) : 1.0

            Behavior on x { enabled: !winTile.isDragging; NumberAnimation { duration: 200; easing.type: Easing.OutCubic }}
            Behavior on y { enabled: !winTile.isDragging; NumberAnimation { duration: 200; easing.type: Easing.OutCubic }}
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic }}
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            color: isDragging ? Theme.bgSecondary : Theme.surface
            border.width: isDragging ? 2 : 1
            border.color: isDragging ? Theme.accent : (modelData.activated ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.6))
            radius: 0
            clip: false

            // Glow shadow for dragged tile
            Rectangle {
                anchors.fill: parent
                anchors.margins: -Theme.dp(4)
                color: "transparent"
                border.width: winTile.isDragging ? Theme.dp(3) : 0
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                radius: 0
                visible: winTile.isDragging
                z: -1
            }

            ScreencopyView {
                anchors.fill: parent
                captureSource: modelData.wayland || null
                live: popup.visible && !winTile.isDragging
            }

            // Drop target indicators
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: winTile.isDropTarget ? 2 : 0
                border.color: Theme.accent
                visible: winTile.isDropTarget && wsService.draggingMoved
                z: 5

                Rectangle {
                    visible: wsService.dropTargetSide === "top"
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 3; color: Theme.accent
                }
                Rectangle {
                    visible: wsService.dropTargetSide === "bottom"
                    anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 3; color: Theme.accent
                }
                Rectangle {
                    visible: wsService.dropTargetSide === "left"
                    anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 3; color: Theme.accent
                }
                Rectangle {
                    visible: wsService.dropTargetSide === "right"
                    anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 3; color: Theme.accent
                }
            }

            // Fullscreen button on tile (right top)
            Rectangle {
                id: fsBtn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.dp(2)
                width: Theme.dp(26)
                height: Theme.dp(18)
                color: winTile.isFullscreen ? Theme.accent : (fsPreviewMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5) : Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.7))
                border.width: 1
                border.color: fsPreviewMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                radius: 0
                visible: !winTile.isDragging && !wsService.draggingToplevel
                z: 15

                Text {
                    anchors.centerIn: parent
                    text: "FS"
                    color: winTile.isFullscreen ? Theme.bgPrimary : Theme.accent
                    font.pixelSize: Theme.dp(8)
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: fsPreviewMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var addr = wsService.formatAddr(modelData.address);
                        if (!addr || addr === "0x") return;
                        var wsId = modelData.workspace ? modelData.workspace.id : preview.workspaceId;
                        wsService.fullscreenWindow(addr, wsId);
                    }
                }
            }

            // Title bar (left top, fills to FS button with no gap)
            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: Theme.dp(2)
                anchors.top: parent.top
                anchors.topMargin: Theme.dp(2)
                anchors.right: fsBtn.left
                anchors.rightMargin: 0
                height: Theme.dp(18)
                color: modelData.activated ? Theme.accent : Theme.bgSecondary
                border.width: 1
                border.color: modelData.activated ? Theme.accent : Theme.border
                radius: 0
                z: 10
                clip: true

                MarqueeText {
                    id: nameMarquee
                    anchors.fill: parent
                    anchors.margins: Theme.dp(3)
                    text: wsService.getWindowTitle(modelData)
                    textColor: modelData.activated ? Theme.bgPrimary : Theme.textPrimary
                    fontSize: Theme.dp(9)
                    fontWeight: modelData.activated ? Font.Bold : Font.Normal
                    textPadding: 0
                }
            }

            // Drag mouse area
            MouseArea {
                id: dragMouse
                preventStealing: true
                propagateComposedEvents: false
                property bool dragArmed: false
                property string capturedSourceAddr: ""

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: winTile.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor

                onPressed: function(mouse) {
                    dragArmed = false;
                    wsService.draggingMoved = false;
                    wsService.targetWorkspaceDuringDrag = -1;
                    var globalPos = dragMouse.mapToItem(null, mouse.x, mouse.y);
                    winTile.dragStartGlobalX = globalPos.x;
                    winTile.dragStartGlobalY = globalPos.y;
                    winTile.dragOffset = Qt.point(0, 0);
                    capturedSourceAddr = wsService.getToplevelAddr(modelData);
                    holdDragTimer.restart();
                }

                onPositionChanged: function(mouse) {
                    if (!dragArmed) return;
                    var globalPos = dragMouse.mapToItem(null, mouse.x, mouse.y);
                    var dx = globalPos.x - winTile.dragStartGlobalX;
                    var dy = globalPos.y - winTile.dragStartGlobalY;
                    if (!wsService.draggingMoved && (Math.abs(dx) > Theme.dp(3) || Math.abs(dy) > Theme.dp(3))) {
                        wsService.draggingMoved = true;
                    }
                    if (wsService.draggingMoved) {
                        winTile.dragOffset = Qt.point(dx, dy);

                        var posInPreview = dragMouse.mapToItem(preview, mouse.x, mouse.y);
                        var posInPopup = preview.mapToItem(popup, posInPreview.x, posInPreview.y);
                        wsService.targetWorkspaceDuringDrag = wsService.dropWorkspaceAtPopup(posInPopup.x, posInPopup.y, previewsRepeater, popup);

                        if (wsService.targetWorkspaceDuringDrag > 0) {
                            var targetInfo = wsService.findWindowAtWithDetails(wsService.targetWorkspaceDuringDrag, posInPopup.x, posInPopup.y, capturedSourceAddr, previewsRepeater, popup);
                            if (targetInfo && targetInfo.address) {
                                wsService.dropTargetAddr = targetInfo.address;
                                wsService.dropTargetSide = targetInfo.side;
                            } else {
                                wsService.dropTargetAddr = "";
                                wsService.dropTargetSide = "";
                            }
                        } else {
                            wsService.dropTargetAddr = "";
                            wsService.dropTargetSide = "";
                        }
                    }
                }

                onReleased: function(mouse) {
                    holdDragTimer.stop();
                    if (dragArmed && wsService.draggingMoved) {
                        var posInPreview = dragMouse.mapToItem(preview, mouse.x, mouse.y);
                        var posInPopup = preview.mapToItem(popup, posInPreview.x, posInPreview.y);
                        var targetWs = wsService.dropWorkspaceAtPopup(posInPopup.x, posInPopup.y, previewsRepeater, popup);

                        if (targetWs > 0 && capturedSourceAddr !== "" && capturedSourceAddr !== "0x") {
                            var targetInfo = wsService.findWindowAtWithDetails(targetWs, posInPopup.x, posInPopup.y, capturedSourceAddr, previewsRepeater, popup);
                            var side = targetInfo && targetInfo.side ? targetInfo.side : "center";
                            var dir = "";
                            if (side === "left") dir = "l";
                            else if (side === "right") dir = "r";
                            else if (side === "top") dir = "u";
                            else if (side === "bottom") dir = "d";

                            if (targetWs !== wsService.dragSourceWorkspace) {
                                if (dir !== "" && targetInfo && targetInfo.address) {
                                    // Cross-workspace directional drop: move then position
                                    wsService.commandRunning = true;
                                    wsService.pendingExecCmd =
                                        "hyprctl dispatch movetoworkspacesilent " + targetWs + ",address:" + capturedSourceAddr +
                                        "; sleep 0.1; hyprctl dispatch focuswindow address:" + capturedSourceAddr +
                                        "; sleep 0.05; hyprctl dispatch movewindow " + dir;
                                    wsService.cmdResetTimer.restart();
                                    wsService.cmdExecTimer.restart();
                                } else {
                                    Hyprland.dispatch("movetoworkspacesilent " + targetWs + ",address:" + capturedSourceAddr);
                                }
                            } else {
                                if (dir !== "" && targetInfo && targetInfo.address) {
                                    // Same-workspace directional drop
                                    wsService.commandRunning = true;
                                    wsService.pendingExecCmd =
                                        "hyprctl dispatch focuswindow address:" + capturedSourceAddr +
                                        "; sleep 0.05; hyprctl dispatch movewindow " + dir;
                                    wsService.cmdResetTimer.restart();
                                    wsService.cmdExecTimer.restart();
                                } else if (targetInfo && targetInfo.address) {
                                    // Fallback: top/bottom z-order for center drops
                                    if (side === "top") {
                                        Hyprland.dispatch("alterzorder top,address:" + capturedSourceAddr);
                                        wsService.moveWindowToTop(targetWs, capturedSourceAddr);
                                    } else if (side === "bottom") {
                                        Hyprland.dispatch("alterzorder bottom,address:" + capturedSourceAddr);
                                        wsService.moveWindowToBottom(targetWs, capturedSourceAddr);
                                    }
                                }
                            }
                            wsService.refreshTrigger++;
                            wsService.forceRefreshTimer.restart();
                        }
                    } else if (!wsService.draggingMoved) {
                        wsService.activateWorkspace(preview.workspaceId);
                    }
                    dragArmed = false;
                    capturedSourceAddr = "";
                    winTile.dragOffset = Qt.point(0, 0);
                    wsService.clearDrag();
                }

                onCanceled: {
                    holdDragTimer.stop();
                    dragArmed = false;
                    winTile.dragOffset = Qt.point(0, 0);
                    wsService.clearDrag();
                }

                Timer {
                    id: holdDragTimer
                    interval: 120
                    repeat: false
                    onTriggered: {
                        dragMouse.dragArmed = true;
                        wsService.draggingToplevel = modelData;
                        wsService.draggingTileCapturedAddr = dragMouse.capturedSourceAddr;
                        wsService.dragSourceWorkspace = preview.workspaceId;
                    }
                }
            }
        }
    }
}
