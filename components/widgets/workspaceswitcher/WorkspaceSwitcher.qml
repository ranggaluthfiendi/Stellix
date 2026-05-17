import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root
    
    signal closeRequested()

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1

    property real s: Scales.uiScale
    property int pageStart: 1
    property int visibleCount: 5
    property var draggingToplevel: null
    property int dragSourceWorkspace: -1
    property int targetWorkspaceDuringDrag: -1
    property bool draggingMoved: false
    property real dragStartX: 0
    property real dragStartY: 0
    property real animY: -Theme.dp(12)
    property int refreshTrigger: 0

    Timer {
        id: forceRefreshTimer
        interval: 100
        repeat: false
        onTriggered: {
            root.refreshTrigger++;
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }

    readonly property var workspaces: Hyprland.workspaces ? Hyprland.workspaces.values : []
    readonly property var toplevels: Hyprland.toplevels ? Hyprland.toplevels.values : []
    readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property int maxWorkspaceId: Math.max(highestWorkspaceId(), visibleCount)
    readonly property var focusedMonitor: Hyprland.focusedMonitor

    readonly property real monX: focusedMonitor ? focusedMonitor.x : 0
    readonly property real monY: focusedMonitor ? focusedMonitor.y : 0
    readonly property real monW: Math.max(1, focusedMonitor ? focusedMonitor.width : 1920)
    readonly property real monH: Math.max(1, focusedMonitor ? focusedMonitor.height : 1080)
    readonly property real monitorAspect: monH > 0 ? monW / monH : 16 / 9

    readonly property real overlayW: Math.min(width - Theme.dp(64), Theme.dp(1300))
    readonly property real previewGap: Theme.dp(16)
    readonly property real previewW: Math.min((overlayW - Theme.dp(40) - (visibleCount - 1) * previewGap) / visibleCount, Theme.dp(240))
    readonly property real previewH: previewW / monitorAspect

    readonly property real navH: Theme.dp(32)
    readonly property real overlayH: previewH + navH + Theme.dp(64)

    // ── Restored Auto-Fit Logic (The one you liked) ──
    function getFitParams(id) {
        var wins = root.windowsForWorkspace(id);
        if (wins.length === 0) return { scale: 1.0, offsetX: 0, offsetY: 0, minX: 0, minY: 0 };

        var minX = 999999, minY = 999999, maxX = -999999, maxY = -999999;
        for (var i = 0; i < wins.length; i++) {
            var tl = wins[i];
            var ipc = tl.lastIpcObject || {};
            var at = ipc.at || [0, 0];
            var sz = ipc.size || [400, 300];

            var x = at[0] - root.monX;
            var y = at[1] - root.monY;

            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x + sz[0] > maxX) maxX = x + sz[0];
            if (y + sz[1] > maxY) maxY = y + sz[1];
        }

        var contentW = Math.max(1, maxX - minX);
        var contentH = Math.max(1, maxY - minY);
        
        var padding = Theme.dp(10);
        var availableW = Math.max(1, root.previewW - padding * 2);
        var availableH = Math.max(1, root.previewH - padding * 2);

        var s = Math.min(availableW / contentW, availableH / contentH);
        
        var ox = (root.previewW - (contentW * s)) / 2;
        var oy = (root.previewH - (contentH * s)) / 2;

        return { scale: s, offsetX: ox, offsetY: oy, minX: minX, minY: minY };
    }

    Behavior on animY {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    function highestWorkspaceId() {
        var maxId = 1;
        for (var i = 0; i < root.workspaces.length; i++) {
            var ws = root.workspaces[i];
            if (ws && ws.id > maxId)
                maxId = ws.id;
        }
        return maxId;
    }

    function ensureFocusedVisible() {
        var id = root.focusedId > 0 ? root.focusedId : 1;
        if (id < root.pageStart)
            root.pageStart = id;
        else if (id >= root.pageStart + root.visibleCount)
            root.pageStart = id - root.visibleCount + 1;
        if (root.pageStart < 1)
            root.pageStart = 1;
    }

    function workspaceIds() {
        var ids = [];
        for (var i = 0; i < root.visibleCount; i++) ids.push(root.pageStart + i)
        return ids;
    }

    function windowsForWorkspace(id) {
        var result = [];
        for (var i = 0; i < root.toplevels.length; i++) {
            var tl = root.toplevels[i];
            if (tl && tl.workspace && tl.workspace.id === id)
                result.push(tl);
        }
        return result;
    }

    function activateWorkspace(id) {
        Hyprland.dispatch("workspace " + id);
    }

    function addWorkspace() {
        var nextId = Math.max(root.maxWorkspaceId + 1, root.pageStart + root.visibleCount);
        root.pageStart = Math.max(1, nextId - root.visibleCount + 1);
        Hyprland.dispatch("workspace " + nextId);
    }

    function removeWorkspace() {
        if (root.maxWorkspaceId <= root.visibleCount)
            return;

        var removeId = root.maxWorkspaceId;
        var targetId = Math.max(1, removeId - 1);
        var wins = root.windowsForWorkspace(removeId);
        for (var i = 0; i < wins.length; i++) root.moveWindowToWorkspace(wins[i], targetId)
        if (root.focusedId === removeId)
            Hyprland.dispatch("workspace " + targetId);

        root.pageStart = Math.max(1, Math.min(root.pageStart, Math.max(1, targetId - root.visibleCount + 1)));
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
    }

    function moveWindowToWorkspace(toplevel, workspaceId) {
        var address = "";
        if (toplevel) {
            if (toplevel.lastIpcObject && toplevel.lastIpcObject.address)
                address = toplevel.lastIpcObject.address;
            else if (toplevel.address)
                address = toplevel.address;
        }

        if (!address || workspaceId < 1) return;

        Hyprland.dispatch("movetoworkspacesilent " + workspaceId + ",address:" + address);
        forceRefreshTimer.restart();
    }

    function dropWorkspaceAtPopup(x, y) {
        for (var i = 0; i < previewsRepeater.count; i++) {
            var item = previewsRepeater.itemAt(i);
            if (!item) continue;

            var p = item.mapFromItem(popup, x, y);
            if (p.x >= 0 && p.y >= 0 && p.x <= item.width && p.y <= item.height)
                return item.workspaceId;
        }
        return -1;
    }

    function clearDrag() {
        draggingToplevel = null;
        dragSourceWorkspace = -1;
        targetWorkspaceDuringDrag = -1;
        draggingMoved = false;
        leftDragPageTimer.stop();
        rightDragPageTimer.stop();
    }

    color: "transparent"
    onVisibleChanged: {
        if (visible) {
            refreshTrigger++;
            ensureFocusedVisible();
            animY = -Theme.dp(12);
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        } else {
            clearDrag();
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
            if (root.visible)
                root.ensureFocusedVisible();
        }
        target: Hyprland
    }

    Timer {
        id: leftDragPageTimer
        interval: 120
        repeat: true
        onTriggered: {
            if (root.draggingToplevel)
                root.pageStart = Math.max(1, root.pageStart - 1);
        }
    }

    Timer {
        id: rightDragPageTimer
        interval: 120
        repeat: true
        onTriggered: {
            if (root.draggingToplevel)
                root.pageStart = root.pageStart + 1;
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        acceptedButtons: Qt.AllButtons
        onPressed: {
            root.closeRequested()
        }
    }

    Rectangle {
        id: popup
        anchors.centerIn: parent
        y: root.animY
        width: root.overlayW
        height: root.overlayH
        
        // glass effect
        color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0.82)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        radius: Theme.dp(12)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: (mouse) => { mouse.accepted = true; }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(12)
            spacing: Theme.dp(10)

            Item {
                id: previewsArea
                Layout.fillWidth: true
                Layout.preferredHeight: root.previewH

                Row {
                    anchors.centerIn: parent
                    spacing: root.previewGap

                    Repeater {
                        id: previewsRepeater
                        model: root.workspaceIds()

                        delegate: Rectangle {
                            id: preview

                            required property int modelData
                            property int workspaceId: modelData
                            readonly property bool active: workspaceId === root.focusedId
                            readonly property bool dropTarget: workspaceId === root.targetWorkspaceDuringDrag
                            
                            readonly property var wsWindows: {
                                var _ = root.refreshTrigger;
                                return root.windowsForWorkspace(workspaceId);
                            }

                            readonly property var fit: {
                                var _ = root.refreshTrigger;
                                return root.getFitParams(workspaceId);
                            }

                            width: root.previewW
                            height: root.previewH
                            
                            color: active 
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) 
                                : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.3)
                            
                            border.width: active ? 2 : 1
                            border.color: dropTarget ? Theme.accent : (active ? Theme.accent : Theme.border)
                            radius: Theme.dp(4)
                            
                            clip: !root.draggingToplevel
                            z: root.draggingToplevel ? 10 : 1

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activateWorkspace(preview.workspaceId)
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
                                    
                                    readonly property real relX: (at[0] - root.monX) - preview.fit.minX
                                    readonly property real relY: (at[1] - root.monY) - preview.fit.minY

                                    readonly property real scaledWidth: size[0] * preview.fit.scale
                                    readonly property real scaledHeight: size[1] * preview.fit.scale

                                    width: scaledWidth
                                    height: scaledHeight

                                    property point dragOffset: Qt.point(0, 0)
                                    property bool isDragging: root.draggingToplevel === modelData && root.draggingMoved

                                    x: (relX * preview.fit.scale) + preview.fit.offsetX + dragOffset.x
                                    y: (relY * preview.fit.scale) + preview.fit.offsetY + dragOffset.y

                                    z: isDragging ? 9999 : 2
                                    scale: isDragging ? 1.1 : 1.0
                                    
                                    opacity: root.draggingToplevel ? (isDragging ? 1.0 : 0.35) : 1.0

                                    Behavior on x { enabled: !winTile.isDragging; NumberAnimation { duration: 200; easing.type: Easing.OutQuad }}
                                    Behavior on y { enabled: !winTile.isDragging; NumberAnimation { duration: 200; easing.type: Easing.OutQuad }}
                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad }}
                                    Behavior on opacity { NumberAnimation { duration: 200 } }

                                    color: isDragging ? Theme.bgSecondary : Theme.surface
                                    border.width: isDragging ? 2 : 1
                                    border.color: isDragging ? Theme.accent : (modelData.activated ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.6))
                                    radius: Theme.dp(1)
                                    clip: false

                                    ScreencopyView {
                                        anchors.fill: parent
                                        captureSource: modelData.wayland || null
                                        live: root.visible && !winTile.isDragging
                                    }

                                    MouseArea {
                                        id: dragMouse
                                        preventStealing: true
                                        propagateComposedEvents: false
                                        property bool dragArmed: false

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.LeftButton
                                        cursorShape: winTile.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor

                                        onPressed: function(mouse) {
                                            dragArmed = false;
                                            root.draggingMoved = false;
                                            root.targetWorkspaceDuringDrag = -1;
                                            root.dragStartX = mouse.x;
                                            root.dragStartY = mouse.y;
                                            holdDragTimer.restart();
                                        }

                                        onPositionChanged: function(mouse) {
                                            if (!dragArmed) return;
                                            var dx = mouse.x - root.dragStartX;
                                            var dy = mouse.y - root.dragStartY;
                                            if (!root.draggingMoved && (Math.abs(dx) > Theme.dp(3) || Math.abs(dy) > Theme.dp(3))) {
                                                root.draggingMoved = true;
                                            }
                                            if (root.draggingMoved) {
                                                winTile.dragOffset = Qt.point(winTile.dragOffset.x + dx, winTile.dragOffset.y + dy);
                                                var p = popup.mapFromItem(winTile, winTile.width / 2, winTile.height / 2);
                                                root.targetWorkspaceDuringDrag = root.dropWorkspaceAtPopup(p.x, p.y);
                                            }
                                        }

                                        onReleased: function(mouse) {
                                            holdDragTimer.stop();
                                            
                                            if (dragArmed && root.draggingMoved) {
                                                var p = popup.mapFromItem(winTile, winTile.width / 2, winTile.height / 2);
                                                var targetWs = root.dropWorkspaceAtPopup(p.x, p.y);
                                                if (targetWs > 0 && targetWs !== root.dragSourceWorkspace) {
                                                    root.moveWindowToWorkspace(modelData, targetWs);
                                                }
                                            } else if (!root.draggingMoved) {
                                                root.activateWorkspace(preview.workspaceId);
                                            }

                                            dragArmed = false;
                                            winTile.dragOffset = Qt.point(0, 0);
                                            root.clearDrag();
                                        }

                                        onCanceled: {
                                            holdDragTimer.stop();
                                            dragArmed = false;
                                            winTile.dragOffset = Qt.point(0, 0);
                                            root.clearDrag();
                                        }

                                        Timer {
                                            id: holdDragTimer
                                            interval: 160
                                            repeat: false
                                            onTriggered: {
                                                dragMouse.dragArmed = true;
                                                root.draggingToplevel = modelData;
                                                root.dragSourceWorkspace = preview.workspaceId;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: root.navH
                spacing: Theme.dp(6)

                Rectangle {
                    Layout.preferredWidth: Theme.dp(30)
                    Layout.preferredHeight: Theme.dp(28)
                    color: leftMouse.containsMouse ? Theme.bgPrimary : Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.42)
                    border.width: 1
                    border.color: Theme.border
                    radius: Theme.dp(4)

                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        color: root.pageStart > 1 ? Theme.textPrimary : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
                        font.weight: Typography.weightBold || Font.Bold
                    }

                    MouseArea {
                        id: leftMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: root.pageStart > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.pageStart = Math.max(1, root.pageStart - 1)
                        onEntered: {
                            if (root.draggingToplevel && root.pageStart > 1)
                                leftDragPageTimer.restart();
                        }
                        onExited: leftDragPageTimer.stop()
                    }
                }

                Repeater {
                    model: root.workspaceIds()
                    delegate: Text {
                        required property int modelData
                        readonly property bool active: modelData === root.focusedId
                        Layout.preferredWidth: Theme.dp(20)
                        Layout.alignment: Qt.AlignVCenter
                        text: String(modelData)
                        color: active ? Theme.accent : Theme.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
                        font.weight: active ? (Typography.weightBold || Font.Bold) : (Typography.weightMedium || Font.Normal)
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activateWorkspace(modelData)
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(30)
                    Layout.preferredHeight: Theme.dp(28)
                    color: rightMouse.containsMouse ? Theme.bgPrimary : Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.42)
                    border.width: 1
                    border.color: Theme.border
                    radius: Theme.dp(4)

                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        color: root.pageStart > 1 ? Theme.textPrimary : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
                        font.weight: Typography.weightBold || Font.Bold
                    }

                    MouseArea {
                        id: rightMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pageStart = root.pageStart + 1
                        onEntered: {
                            if (root.draggingToplevel)
                                rightDragPageTimer.restart();
                        }
                        onExited: rightDragPageTimer.stop()
                    }
                }

                Text {
                    Layout.preferredWidth: Theme.dp(18)
                    Layout.alignment: Qt.AlignVCenter
                    text: "-"
                    color: root.maxWorkspaceId > root.visibleCount ? Theme.textPrimary : Theme.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
                    font.weight: Typography.weightBold || Font.Bold

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.maxWorkspaceId > root.visibleCount
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.removeWorkspace()
                    }
                }

                Text {
                    Layout.preferredWidth: Theme.dp(18)
                    Layout.alignment: Qt.AlignVCenter
                    text: "+"
                    color: Theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
                    font.weight: Typography.weightBold || Font.Bold

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.addWorkspace()
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.enabled: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.closeRequested()
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                root.pageStart = Math.max(1, root.pageStart - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                root.pageStart = root.pageStart + 1;
                event.accepted = true;
            }
        }
    }
}
