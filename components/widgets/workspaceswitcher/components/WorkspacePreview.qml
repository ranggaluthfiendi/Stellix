import qs.components.utils
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.core.settings
import qs.components.elements

Rectangle {
    id: previewRoot
    required property int wsId
    required property var wsService
    required property var popup
    required property var previewsRepeater

    property int workspaceId: wsId
    readonly property bool active: (previewRoot.wsService && previewRoot.wsService.focusedId !== undefined) ? workspaceId === previewRoot.wsService.focusedId : false
    readonly property bool dropTarget: (previewRoot.wsService && previewRoot.wsService.targetWorkspaceDuringDrag !== undefined) ? workspaceId === previewRoot.wsService.targetWorkspaceDuringDrag : false

    readonly property var wsWindows: {
        var svc = previewRoot.wsService;
        if (!svc) return [];
        var _ = svc.refreshTrigger;
        var __ = svc.toplevels ? svc.toplevels.values : [];
        var ___ = svc.workspaces ? svc.workspaces.values : [];
        return svc.windowsForWorkspace(workspaceId);
    }

    readonly property var fit: {
        var svc = previewRoot.wsService;
        if (!svc) return { scale: 1.0, offsetX: 0, offsetY: 0, minX: 0, minY: 0 };
        var _ = svc.refreshTrigger;
        return svc.getFitParams(workspaceId);
    }

    width: previewRoot.wsService ? previewRoot.wsService.previewW : 200
    height: previewRoot.wsService ? previewRoot.wsService.previewH : 150

    color: active
        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
        : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.3)

    border.width: active ? 2 : 1
    border.color: dropTarget ? Theme.accent : (active ? Theme.accent : Theme.border)
    radius: 0

    clip: previewRoot.wsService ? !previewRoot.wsService.draggingToplevel : true
    z: (previewRoot.wsService && previewRoot.wsService.draggingToplevel) ? 10 : 1

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            var svc = previewRoot.wsService;
            if (!svc) return;
            if (mouse.button === Qt.RightButton) {
                svc.panelWorkspace = previewRoot.workspaceId
                svc.expandablePanelOpen = true
                svc.expandPanel()
            } else {
                BarPopupState.workspaceSwitcherOpen = false
                svc.activateWorkspace(previewRoot.workspaceId)
            }
        }
    }

    // Workspace number indicator (always visible)
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
            text: String(previewRoot.workspaceId)
            color: active ? Theme.accent : Theme.textPrimary
            font.pixelSize: Theme.dp(12)
            font.weight: Font.Bold
        }
    }

    Repeater {
        model: previewRoot.wsWindows
        delegate: Rectangle {
            id: winTile
            required property var modelData
            required property int index
            readonly property var ipc: {
                var svc = previewRoot.wsService;
                if (!svc) return modelData.lastIpcObject || ({});
                var _ = svc.refreshTrigger;
                return modelData.lastIpcObject || ({});
            }
            readonly property var at: ipc.at || [0, 0]
            readonly property var size: ipc.size || [400, 300]

            readonly property real relX: previewRoot.wsService ? (at[0] - previewRoot.wsService.monX) - previewRoot.fit.minX : 0
            readonly property real relY: previewRoot.wsService ? (at[1] - previewRoot.wsService.monY) - previewRoot.fit.minY : 0

            readonly property real scaledWidth: size[0] * previewRoot.fit.scale
            readonly property real scaledHeight: size[1] * previewRoot.fit.scale

            width: scaledWidth
            height: scaledHeight

            property point dragOffset: Qt.point(0, 0)
            property real dragStartGlobalX: 0
            property real dragStartGlobalY: 0
            property string myAddr: previewRoot.wsService ? previewRoot.wsService.formatAddr(modelData.address || (modelData.lastIpcObject ? modelData.lastIpcObject.address : "")) : ""
            property bool isDragging: previewRoot.wsService ? (previewRoot.wsService.draggingTileCapturedAddr !== "" && previewRoot.wsService.draggingMoved && myAddr === previewRoot.wsService.draggingTileCapturedAddr) : false
            property bool isDropTarget: previewRoot.wsService ? (previewRoot.wsService.dropTargetAddr !== "" && myAddr === previewRoot.wsService.dropTargetAddr) : false
            property bool isFullscreen: modelData && modelData.fullscreen ? true : false

            x: (relX * previewRoot.fit.scale) + previewRoot.fit.offsetX + dragOffset.x
            y: (relY * previewRoot.fit.scale) + previewRoot.fit.offsetY + dragOffset.y

            z: isDragging ? 9999 : (100 - winTile.index)
            scale: isDragging ? 1.08 : 1.0

            opacity: (previewRoot.wsService && previewRoot.wsService.draggingMoved) ? (isDragging ? 1.0 : 0.45) : 1.0

            Behavior on x { enabled: !winTile.isDragging; NumberAnimation { duration: 200; easing.type: Easing.OutCubic }}
            Behavior on y { enabled: !winTile.isDragging; NumberAnimation { duration: 200; easing.type: Easing.OutCubic }}
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic }}
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            color: isDragging ? Theme.bgSecondary : Theme.surface
            border.width: isDragging ? 2 : 1
            border.color: isDragging ? Theme.accent : (modelData.activated ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.6))
            radius: 0
            clip: false

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
                visible: winTile.isDropTarget && previewRoot.wsService && previewRoot.wsService.draggingMoved
                z: 5

                Rectangle { visible: previewRoot.wsService && previewRoot.wsService.dropTargetSide === "top"; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 3; color: Theme.accent }
                Rectangle { visible: previewRoot.wsService && previewRoot.wsService.dropTargetSide === "bottom"; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 3; color: Theme.accent }
                Rectangle { visible: previewRoot.wsService && previewRoot.wsService.dropTargetSide === "left"; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 3; color: Theme.accent }
                Rectangle { visible: previewRoot.wsService && previewRoot.wsService.dropTargetSide === "right"; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 3; color: Theme.accent }
            }

            // Title bar
            Rectangle {
                anchors.left: parent.left; anchors.leftMargin: Theme.dp(2); anchors.top: parent.top; anchors.topMargin: Theme.dp(2); anchors.right: parent.right; anchors.rightMargin: Theme.dp(2)
                height: Theme.dp(16)
                color: modelData.activated ? Theme.accent : Theme.bgSecondary
                radius: 0; z: 10; clip: true
                MarqueeText {
                    anchors.fill: parent; anchors.margins: Theme.dp(2)
                    text: previewRoot.wsService ? previewRoot.wsService.getWindowTitle(modelData) : "App"
                    textColor: modelData.activated ? Theme.bgPrimary : Theme.textPrimary
                    fontSize: Theme.dp(8); fontWeight: modelData.activated ? Font.Bold : Font.Normal
                }
            }

            // Drag mouse area
            MouseArea {
                id: dragMouse
                anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton
                cursorShape: winTile.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                preventStealing: true; propagateComposedEvents: false
                property bool dragArmed: false
                property string capturedSourceAddr: ""

                onPressed: function(mouse) {
                    var svc = previewRoot.wsService;
                    if (!svc) return;
                    dragArmed = false; svc.draggingMoved = false; svc.targetWorkspaceDuringDrag = -1;
                    var globalPos = dragMouse.mapToItem(null, mouse.x, mouse.y);
                    winTile.dragStartGlobalX = globalPos.x; winTile.dragStartGlobalY = globalPos.y;
                    capturedSourceAddr = svc.getToplevelAddr(modelData);
                    holdDragTimer.restart();
                }

                onPositionChanged: function(mouse) {
                    var svc = previewRoot.wsService;
                    if (!dragArmed || !svc) return;
                    var globalPos = dragMouse.mapToItem(null, mouse.x, mouse.y);
                    var dx = globalPos.x - winTile.dragStartGlobalX, dy = globalPos.y - winTile.dragStartGlobalY;
                    if (!svc.draggingMoved && (Math.abs(dx) > Theme.dp(3) || Math.abs(dy) > Theme.dp(3))) svc.draggingMoved = true;
                    if (svc.draggingMoved) {
                        winTile.dragOffset = Qt.point(dx, dy);
                        var posInPopup = dragMouse.mapToItem(popup, mouse.x, mouse.y);
                        svc.targetWorkspaceDuringDrag = svc.dropWorkspaceAtPopup(posInPopup.x, posInPopup.y, previewsRepeater, popup);
                        if (svc.targetWorkspaceDuringDrag > 0) {
                            var targetInfo = svc.findWindowAtWithDetails(svc.targetWorkspaceDuringDrag, posInPopup.x, posInPopup.y, capturedSourceAddr, previewsRepeater, popup);
                            if (targetInfo && targetInfo.address) { svc.dropTargetAddr = targetInfo.address; svc.dropTargetSide = targetInfo.side; }
                            else { svc.dropTargetAddr = ""; svc.dropTargetSide = ""; }
                        } else { svc.dropTargetAddr = ""; svc.dropTargetSide = ""; }
                    }
                }

                onReleased: function(mouse) {
                    holdDragTimer.stop();
                    var svc = previewRoot.wsService;
                    if (!svc) return;
                    
                    try {
                        if (dragArmed && svc.draggingMoved) {
                            var posInPopup = dragMouse.mapToItem(popup, mouse.x, mouse.y);
                            var targetWs = svc.dropWorkspaceAtPopup(posInPopup.x, posInPopup.y, previewsRepeater, popup);
                            if (targetWs > 0 && capturedSourceAddr !== "" && capturedSourceAddr !== "0x") {
                                var targetInfo = svc.findWindowAtWithDetails(targetWs, posInPopup.x, posInPopup.y, capturedSourceAddr, previewsRepeater, popup);
                                var side = targetInfo && targetInfo.side ? targetInfo.side : "center";
                                var dir = (side === "left") ? "l" : (side === "right") ? "r" : (side === "top") ? "u" : (side === "bottom") ? "d" : "";

                                if (targetWs !== svc.dragSourceWorkspace) {
                                    if (targetInfo && targetInfo.address && side === "center") {
                                        svc.swapWindows(capturedSourceAddr, svc.dragSourceWorkspace, targetInfo.address, targetWs);
                                    } else if (dir !== "" && targetInfo && targetInfo.address && targetWs === svc.focusedId) {
                                        svc.commandRunning = true;
                                        svc.pendingExecCmd = "hyprctl dispatch movetoworkspacesilent " + targetWs + ",address:" + capturedSourceAddr + "; sleep 0.1; hyprctl dispatch focuswindow address:" + capturedSourceAddr + "; sleep 0.05; hyprctl dispatch movewindow " + dir;
                                        svc.cmdExecTimer.restart();
                                    } else {
                                        Hyprland.dispatch("movetoworkspacesilent " + targetWs + ",address:" + capturedSourceAddr);
                                    }
                                } else if (targetInfo && targetInfo.address) {
                                    if (side === "center") {
                                        svc.swapWindows(capturedSourceAddr, targetWs, targetInfo.address, targetWs);
                                    } else if (dir !== "" && targetWs === svc.focusedId) {
                                        svc.commandRunning = true;
                                        svc.pendingExecCmd = "hyprctl dispatch focuswindow address:" + capturedSourceAddr + "; sleep 0.05; hyprctl dispatch movewindow " + dir;
                                        svc.cmdExecTimer.restart();
                                    }
                                }
                                svc.refreshTrigger++; svc.forceRefreshTimer.restart();
                            }
                        } else if (!svc.draggingMoved) {
                            BarPopupState.workspaceSwitcherOpen = false;
                            svc.activateWorkspace(previewRoot.workspaceId);
                        }
                    } finally {
                        dragArmed = false; capturedSourceAddr = ""; winTile.dragOffset = Qt.point(0, 0); svc.clearDrag();
                    }
                }

                Timer {
                    id: holdDragTimer; interval: 120; repeat: false
                    onTriggered: {
                        var svc = previewRoot.wsService;
                        if (!svc) return;
                        dragMouse.dragArmed = true;
                        svc.draggingToplevel = modelData;
                        svc.draggingTileCapturedAddr = dragMouse.capturedSourceAddr;
                        svc.dragSourceWorkspace = previewRoot.workspaceId;
                    }
                }
            }
        }
    }
}
