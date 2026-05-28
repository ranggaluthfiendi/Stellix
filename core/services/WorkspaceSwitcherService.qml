import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config

Item {
    id: wsService

    // ── Core Properties ──
    readonly property var workspaces: Hyprland.workspaces
    readonly property var toplevels: Hyprland.toplevels
    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property int focusedId: activeWorkspaceId
    readonly property var focusedMonitor: Hyprland.focusedMonitor

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged(ws) {
            if (ws) wsService.focusedId = ws.id;
            else wsService.focusedId = wsService.activeWorkspaceId;
            wsService.ensureFocusedVisible();
        }
    }

    // Track focused toplevel to update stack order (The Essence)
    readonly property var _focusedToplevel: Hyprland.focusedToplevel
    on_FocusedToplevelChanged: {
        var tl = _focusedToplevel;
        if (tl && tl.workspace) {
            var addr = getToplevelAddr(tl);
            if (addr && addr !== "0x") {
                wsService.moveWindowToTop(tl.workspace.id, addr);
            }
        }
    }

    property int pageStart: 1
    property int visibleCount: 5
    property int refreshTrigger: 0

    // Expose internal timers for external access (WorkspacePreview.qml)
    property alias cmdExecTimer: cmdExecTimer
    property alias cmdResetTimer: cmdResetTimer
    property alias forceRefreshTimer: forceRefreshTimer

    // ── Manual Z-Order Tracking (The absolute Source of Truth) ──
    property var workspaceWindowOrders: ({})

    function ensureWorkspaceOrder(wsId, windows) {
        if (!windows) return;
        var orders = wsService.workspaceWindowOrders;
        var currentStack = orders[wsId] || [];
        var newStack = [];

        // 1. Maintain order of windows that still exist
        for (var i = 0; i < currentStack.length; i++) {
            var addr = currentStack[i];
            var exists = false;
            for (var j = 0; j < windows.length; j++) {
                if (getToplevelAddr(windows[j]) === addr) {
                    exists = true;
                    break;
                }
            }
            if (exists) newStack.push(addr);
        }

        // 2. Add brand new windows to the FRONT (Top/index 0)
        for (var k = 0; k < windows.length; k++) {
            var wAddr = getToplevelAddr(windows[k]);
            if (newStack.indexOf(wAddr) === -1) {
                newStack.unshift(wAddr);
            }
        }
        
        if (JSON.stringify(currentStack) !== JSON.stringify(newStack)) {
            orders[wsId] = newStack;
            wsService.workspaceWindowOrders = orders;
        }
    }

    function sortWindowsByOrder(wsId, windows) {
        if (!windows) return [];
        var stack = wsService.workspaceWindowOrders[wsId] || [];
        if (stack.length === 0) return windows;
        
        var sorted = [];
        var winMap = {};
        for (var i = 0; i < windows.length; i++) winMap[getToplevelAddr(windows[i])] = windows[i];

        for (var j = 0; j < stack.length; j++) {
            if (winMap[stack[j]]) {
                sorted.push(winMap[stack[j]]);
                delete winMap[stack[j]];
            }
        }

        for (var addr in winMap) sorted.push(winMap[addr]);
        return sorted;
    }

    function windowsForWorkspace(id) {
        var result = [];
        if (!toplevels) return result;

        var allVals = toplevels.values;
        for (var i = 0; i < allVals.length; i++) {
            var tl = allVals[i];
            if (!tl) continue;
            var wsId = -1;
            if (tl.workspace) wsId = tl.workspace.id;
            else if (tl.lastIpcObject && tl.lastIpcObject.workspace) wsId = tl.lastIpcObject.workspace.id;
            if (wsId === id && result.indexOf(tl) === -1) result.push(tl);
        }

        ensureWorkspaceOrder(id, result);
        return sortWindowsByOrder(id, result);
    }

    readonly property var panelWindows: {
        var _ = refreshTrigger;
        var __ = panelWorkspace;
        var ___ = toplevels ? toplevels.count : 0;
        var ____ = workspaces ? workspaces.count : 0;
        var _____ = workspaceWindowOrders; 
        return windowsForWorkspace(panelWorkspace);
    }

    signal closeRequested()

    function activateWorkspace(id) {
        if (id < 1) return;
        wsService.focusedId = id;
        Hyprland.dispatch("workspace " + id);
    }

    function ensureFocusedVisible() {
        var id = focusedId > 0 ? focusedId : 1;
        if (id < pageStart) pageStart = id;
        else if (id >= pageStart + visibleCount) pageStart = id - visibleCount + 1;
        if (pageStart < 1) pageStart = 1;
    }

    function getToplevelAddr(tl) {
        if (!tl) return "";
        if (tl.address !== undefined && tl.address !== null && tl.address !== "") {
            return formatAddr(tl.address);
        }
        if (tl.lastIpcObject && tl.lastIpcObject.address) {
            return formatAddr(tl.lastIpcObject.address);
        }
        return "";
    }

    function formatAddr(addr) {
        if (addr === undefined || addr === null) return "";
        var a = "";
        if (typeof addr === "number") a = addr.toString(16);
        else a = addr.toString().trim().replace(/^0x/, "");
        
        if (a.length === 0) return "";
        return "0x" + a.toLowerCase();
    }

    function getWindowTitle(tl) {
        if (!tl) return "App";
        var t = tl.title || "";
        var c = "";
        var appId = tl.appId || "";
        
        if (tl.lastIpcObject) {
            c = tl.lastIpcObject.class || tl.lastIpcObject.initialClass || "";
            if (!t) t = tl.lastIpcObject.title || "";
        }
        
        var name = t || c || appId || "App";
        var low = name.toLowerCase();
        
        if (low.includes("vscodium")) return "VSCodium";
        if (low.includes("visual studio code") || low.includes("vscode") || low.includes("code")) return "VS Code";
        if (low.includes("firefox")) return "Firefox";
        if (low.includes("foot") || low.includes("kitty") || low.includes("terminal") || low.includes("konsole")) return "Terminal";
        if (low.includes("thunar") || low.includes("dolphin") || low.includes("nemo") || low.includes("files")) return "Files";
        if (low.includes("spotify")) return "Spotify";
        if (low.includes("discord")) return "Discord";
        
        if (name.length > 22) return name.substring(0, 22) + "…";
        return name;
    }

    function highestWorkspaceId() {
        var maxId = 1;
        if (!workspaces) return maxId;
        var wsList = workspaces.values;
        for (var i = 0; i < wsList.length; i++) {
            var ws = wsList[i];
            if (ws && ws.id > maxId) maxId = ws.id;
        }
        return maxId;
    }

    function addWorkspace() {
        var nextId = Math.max(wsService.highestWorkspaceId() + 1, pageStart + visibleCount);
        pageStart = Math.max(1, nextId - visibleCount + 1);
        Hyprland.dispatch("workspace " + nextId);
    }

    function removeWorkspace() {
        var mid = highestWorkspaceId();
        if (mid <= visibleCount) return;
        var removeId = mid;
        var targetId = Math.max(1, removeId - 1);
        var wins = windowsForWorkspace(removeId);
        for (var i = 0; i < wins.length; i++) moveWindowToWorkspace(wins[i], targetId)
        if (focusedId === removeId) Hyprland.dispatch("workspace " + targetId);
        pageStart = Math.max(1, Math.min(pageStart, Math.max(1, targetId - visibleCount + 1)));
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
    }

    function handleDeleteOrBackspace() {
        var wsId = focusedId;
        var wins = windowsForWorkspace(wsId);
        if (wins.length > 0) {
            closeWorkspaceWindows();
        } else if (wsId >= 6) {
            if (wsId === highestWorkspaceId()) {
                removeWorkspace();
            } else {
                var targetId = Math.max(1, wsId - 1);
                pageStart = Math.max(1, Math.min(pageStart, Math.max(1, targetId - visibleCount + 1)));
                Hyprland.dispatch("destroyworkspace " + wsId);
                Hyprland.refreshWorkspaces();
                Hyprland.refreshToplevels();
                focusedId = targetId;
            }
        }
    }

    function moveWindowToWorkspace(toplevel, workspaceId) {
        var address = getToplevelAddr(toplevel);
        if (!address || workspaceId < 1) return;
        Hyprland.dispatch("movetoworkspacesilent " + workspaceId + ",address:" + address);
        forceRefreshTimer.restart();
    }

    function swapWindows(addr1, wsId1, addr2, wsId2) {
        if (!addr1 || !addr2 || addr1 === "0x" || addr2 === "0x") return;
        
        var currentWs = wsService.activeWorkspaceId;
        
        if (wsId1 === wsId2) {
            // Same workspace swap
            wsService.commandRunning = true;
            var cmd = "hyprctl dispatch focuswindow address:" + addr1 + "; sleep 0.05; hyprctl dispatch swapwindow address:" + addr2;
            
            if (wsId1 !== currentWs) {
                cmd += "; sleep 0.05; hyprctl dispatch workspace " + currentWs;
            }
            
            wsService.pendingExecCmd = cmd;
            cmdExecTimer.restart();
            cmdResetTimer.restart();

            // Update manual order for same-workspace swap
            var orders = wsService.workspaceWindowOrders;
            var stack = orders[wsId1] || [];
            var idx1 = stack.indexOf(addr1);
            var idx2 = stack.indexOf(addr2);
            if (idx1 !== -1 && idx2 !== -1) {
                stack[idx1] = addr2;
                stack[idx2] = addr1;
                orders[wsId1] = stack;
                wsService.workspaceWindowOrders = orders;
            }
        } else {
            // Cross workspace swap
            Hyprland.dispatch("movetoworkspacesilent " + wsId2 + ",address:" + addr1);
            Hyprland.dispatch("movetoworkspacesilent " + wsId1 + ",address:" + addr2);
            
            // Proactively update manual orders
            var orders = wsService.workspaceWindowOrders;
            var stack1 = orders[wsId1] || [];
            var stack2 = orders[wsId2] || [];
            
            var idx1 = stack1.indexOf(addr1);
            var idx2 = stack2.indexOf(addr2);
            
            if (idx1 !== -1) stack1[idx1] = addr2;
            else stack1.push(addr2);
            
            if (idx2 !== -1) stack2[idx2] = addr1;
            else stack2.push(addr1);
            
            orders[wsId1] = stack1;
            orders[wsId2] = stack2;
            wsService.workspaceWindowOrders = orders;
        }
        
        refreshTrigger++;
        forceRefreshTimer.restart();
    }

    function closeWorkspaceWindows() {
        var wsId = focusedId;
        var wins = windowsForWorkspace(wsId);
        for (var i = 0; i < wins.length; i++) {
            var addr = getToplevelAddr(wins[i]);
            if (addr && addr !== "0x") Hyprland.dispatch("closewindow address:" + addr);
        }
        forceRefreshTimer.restart();
    }

    function clearDrag() {
        wsService.draggingToplevel = null;
        wsService.draggingToplevelAddress = "";
        wsService.draggingTileCapturedAddr = "";
        wsService.dragSourceWorkspace = -1;
        wsService.targetWorkspaceDuringDrag = -1;
        wsService.draggingMoved = false;
        wsService.dropTargetAddr = "";
        wsService.dropTargetSide = "";
        leftDragPageTimer.stop();
        rightDragPageTimer.stop();
    }

    // ── Panel State ──
    property bool expandablePanelOpen: false
    property int panelWorkspace: 1
    property real expandTargetHeight: 0

    // ── Panel Animation ──
    function calcExpandHeight() {
        var h = Theme.dp(40); // Compact Header
        var wins = windowsForWorkspace(panelWorkspace);
        var count = wins ? wins.length : 0;
        h += 3 * Theme.dp(40); // 3 items fixed slot
        h += 2 * Theme.dp(4);  // 2 gaps
        h += Theme.dp(80); // Actions + Spacings
        return h;
    }

    function expandPanel() {
        expandNumberAnim.to = calcExpandHeight();
        expandAnim.restart();
    }

    function collapsePanel() {
        collapseNumberAnim.to = 0;
        collapseAnim.restart();
    }

    function toggleExpandablePanel() {
        if (expandablePanelOpen) {
            expandablePanelOpen = false;
            collapsePanel();
        } else {
            expandablePanelOpen = true;
            panelWorkspace = focusedId;
            expandPanel();
        }
    }

    ParallelAnimation {
        id: expandAnim
        NumberAnimation { id: expandNumberAnim; target: wsService; property: "expandTargetHeight"; to: 0; duration: 300; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: collapseAnim
        NumberAnimation { id: collapseNumberAnim; target: wsService; property: "expandTargetHeight"; to: 0; duration: 250; easing.type: Easing.InCubic }
    }

    // ── Refresh Timers ──
    Timer {
        id: forceRefreshTimer
        interval: 100
        repeat: false
        onTriggered: {
            refreshTrigger++;
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
            postRefreshTimer.restart();
        }
    }
    Timer {
        id: postRefreshTimer
        interval: 250
        repeat: false
        onTriggered: {
            refreshTrigger++;
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }

    // ── Drag Timers ──
    Timer { id: leftDragPageTimer; interval: 120; repeat: true; onTriggered: { if (wsService.draggingToplevel) pageStart = Math.max(1, pageStart - 1); } }
    Timer { id: rightDragPageTimer; interval: 120; repeat: true; onTriggered: { if (wsService.draggingToplevel) pageStart = pageStart + 1; } }

    // ── Z-Order Logic ──
    function alterZOrder(addr, direction) {
        var cleanAddr = formatAddr(addr);
        if (!cleanAddr || cleanAddr === "0x") return;
        if (direction === "top") {
            Hyprland.dispatch("focuswindow address:" + cleanAddr);
            Hyprland.dispatch("alterzorder top,address:" + cleanAddr);
        } else {
            Hyprland.dispatch("alterzorder bottom,address:" + cleanAddr);
        }
        forceRefreshTimer.restart();
    }

    function moveWindowUp(wsId, addr) {
        var cleanAddr = formatAddr(addr);
        if (!cleanAddr || cleanAddr === "0x") return;
        var orders = wsService.workspaceWindowOrders;
        var stack = orders[wsId] || [];
        var idx = stack.indexOf(cleanAddr);
        if (idx > 0) {
            var temp = stack[idx - 1];
            stack[idx - 1] = stack[idx];
            stack[idx] = temp;
            orders[wsId] = stack;
            wsService.workspaceWindowOrders = orders;
            refreshTrigger++;
            forceRefreshTimer.restart();
        }
    }

    function moveWindowDown(wsId, addr) {
        var cleanAddr = formatAddr(addr);
        if (!cleanAddr || cleanAddr === "0x") return;
        var orders = wsService.workspaceWindowOrders;
        var stack = orders[wsId] || [];
        var idx = stack.indexOf(cleanAddr);
        if (idx !== -1 && idx < stack.length - 1) {
            var temp = stack[idx + 1];
            stack[idx + 1] = stack[idx];
            stack[idx] = temp;
            orders[wsId] = stack;
            wsService.workspaceWindowOrders = orders;
            refreshTrigger++;
            forceRefreshTimer.restart();
        }
    }

    function moveWindowToTop(wsId, addr) {
        var cleanAddr = formatAddr(addr);
        if (!cleanAddr || cleanAddr === "0x") return;
        var orders = wsService.workspaceWindowOrders;
        var stack = orders[wsId] || [];
        var idx = stack.indexOf(cleanAddr);
        if (idx !== 0) {
            if (idx !== -1) stack.splice(idx, 1);
            stack.unshift(cleanAddr);
            orders[wsId] = stack;
            wsService.workspaceWindowOrders = orders;
            refreshTrigger++;
            forceRefreshTimer.restart();
        }
    }

    function moveWindowToBottom(wsId, addr) {
        var cleanAddr = formatAddr(addr);
        if (!cleanAddr || cleanAddr === "0x") return;
        var orders = wsService.workspaceWindowOrders;
        var stack = orders[wsId] || [];
        var idx = stack.indexOf(cleanAddr);
        if (idx !== stack.length - 1) {
            if (idx !== -1) stack.splice(idx, 1);
            stack.push(cleanAddr);
            orders[wsId] = stack;
            wsService.workspaceWindowOrders = orders;
            refreshTrigger++;
            forceRefreshTimer.restart();
        }
    }

    // ── Layout Commands ──
    property var pendingExecCmd: ""
    Timer {
        id: cmdExecTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (pendingExecCmd) {
                scriptProcess.exec(["sh", "-c", pendingExecCmd]);
                pendingExecCmd = "";
                forceRefreshTimer.restart();
            }
        }
    }
    Timer { id: cmdResetTimer; interval: 1000; repeat: false; onTriggered: { wsService.commandRunning = false; } }

    function runLayoutCmd(type, cmd) {
        var wsId = panelWorkspace;
        if (wsId === -1) return;
        var wins = windowsForWorkspace(wsId);
        if (type === "swap" && wins.length >= 2) {
            var a1 = getToplevelAddr(wins[0]), a2 = getToplevelAddr(wins[1]);
            if (a1 && a2 && a1 !== "0x" && a2 !== "0x") {
                wsService.swapWindows(a1, wsId, a2, wsId);
            }
        }
    }

    function fullscreenWindow(addr, wsId) {
        var clean = formatAddr(addr);
        if (!clean || clean === "0x" || wsId < 1) return;
        var currentWs = focusedId;
        wsService.commandRunning = true;
        wsService.pendingExecCmd = (wsId === currentWs)
            ? "hyprctl dispatch focuswindow address:" + clean + "; sleep 0.05; hyprctl dispatch fullscreen"
            : "hyprctl dispatch movetoworkspacesilent " + wsId + ",address:" + clean + "; sleep 0.05; hyprctl dispatch focuswindow address:" + clean + "; sleep 0.05; hyprctl dispatch fullscreen";
        cmdExecTimer.restart();
        cmdResetTimer.restart();
        refreshTrigger++; forceRefreshTimer.restart();
    }

    // ── Drag State ──
    property var draggingToplevel: null
    property string draggingToplevelAddress: ""
    property string draggingTileCapturedAddr: ""
    property int dragSourceWorkspace: -1
    property int targetWorkspaceDuringDrag: -1
    property bool draggingMoved: false
    property string dropTargetAddr: ""
    property string dropTargetSide: ""
    property bool commandRunning: false

    Process { id: scriptProcess }

    // ── Dimensions ──
    readonly property real monW: Math.max(1, focusedMonitor ? focusedMonitor.width : 1920)
    readonly property real monH: Math.max(1, focusedMonitor ? focusedMonitor.height : 1080)
    readonly property real monitorAspect: monH > 0 ? monW / monH : 16 / 9
    readonly property real overlayW: Math.min(parent ? parent.width - Theme.dp(48) : 680, Theme.dp(680))
    readonly property real previewGap: Theme.dp(8)
    readonly property real popupInnerW: overlayW - Theme.dp(24)
    readonly property real previewW: (popupInnerW - (visibleCount - 1) * previewGap) / visibleCount
    readonly property real previewH: previewW / monitorAspect
    readonly property real navH: Theme.dp(30)
    readonly property real hintsH: Theme.dp(24)
    readonly property real overlayH: {
        var h = previewH + navH + hintsH + Theme.dp(48);
        if (expandablePanelOpen) h += calcExpandHeight() + Theme.dp(8);
        return h;
    }
    readonly property real monX: focusedMonitor ? focusedMonitor.x : 0
    readonly property real monY: focusedMonitor ? focusedMonitor.y : 0
    readonly property int maxWorkspaceId: Math.max(highestWorkspaceId(), 5)
    readonly property var workspaceIdList: {
        var ids = [];
        for (var i = 0; i < visibleCount; i++) ids.push(pageStart + i);
        return ids;
    }

    // ── Fit Params for Previews ──
    function getFitParams(id) {
        var wins = windowsForWorkspace(id);
        if (wins.length === 0) return { scale: 1.0, offsetX: 0, offsetY: 0, minX: 0, minY: 0 };
        var minX = 999999, minY = 999999, maxX = -999999, maxY = -999999;
        for (var i = 0; i < wins.length; i++) {
            var tl = wins[i];
            var ipc = tl.lastIpcObject || {};
            var at = ipc.at || [0, 0];
            var sz = ipc.size || [400, 300];
            var x = at[0] - monX, y = at[1] - monY;
            if (x < minX) minX = x; if (y < minY) minY = y;
            if (x + sz[0] > maxX) maxX = x + sz[0]; if (y + sz[1] > maxY) maxY = y + sz[1];
        }
        var contentW = Math.max(1, maxX - minX), contentH = Math.max(1, maxY - minY);
        var padding = Theme.dp(10);
        var availableW = Math.max(1, previewW - padding * 2), availableH = Math.max(1, previewH - padding * 2);
        var sc = Math.min(availableW / contentW, availableH / contentH);
        var ox = (previewW - (contentW * sc)) / 2, oy = (previewH - (contentH * sc)) / 2;
        return { scale: sc, offsetX: ox, offsetY: oy, minX: minX, minY: minY };
    }

    // ── Drop Detection ──
    function dropWorkspaceAtPopup(x, y, previewsRepeater, popup) {
        if (!previewsRepeater) return -1;
        for (var i = 0; i < previewsRepeater.count; i++) {
            var item = previewsRepeater.itemAt(i);
            if (!item) continue;
            var p = item.mapFromItem(popup, x, y);
            if (p.x >= 0 && p.y >= 0 && p.x <= item.width && p.y <= item.height) return item.workspaceId;
        }
        return -1;
    }

    function findWindowAtWithDetails(workspaceId, popupX, popupY, excludeAddress, previewsRepeater, popup) {
        if (!previewsRepeater) return null;
        var formattedExclude = formatAddr(excludeAddress);
        for (var i = 0; i < previewsRepeater.count; i++) {
            var previewItem = previewsRepeater.itemAt(i);
            if (!previewItem || previewItem.workspaceId !== workspaceId) continue;
            var localP = previewItem.mapFromItem(popup, popupX, popupY);
            var wins = windowsForWorkspace(workspaceId), fit = getFitParams(workspaceId);
            var closest = null, closestDist = Infinity;
            for (var j = 0; j < wins.length; j++) {
                var tl = wins[j];
                var formattedAddr = getToplevelAddr(tl);
                if (formattedAddr === formattedExclude || !formattedAddr) continue;
                var ipc = tl.lastIpcObject || {}, at = ipc.at || [0, 0], sz = ipc.size || [400, 300];
                var x = ((at[0] - monX) - fit.minX) * fit.scale + fit.offsetX;
                var y = ((at[1] - monY) - fit.minY) * fit.scale + fit.offsetY;
                var w = sz[0] * fit.scale, h = sz[1] * fit.scale;
                var dist = Math.sqrt(Math.pow(localP.x - (x + w/2), 2) + Math.pow(localP.y - (y + h/2), 2));
                if (dist < closestDist) { closestDist = dist; closest = { address: formattedAddr, x: x, y: y, w: w, h: h, localX: localP.x, localY: localP.y }; }
            }
            if (!closest) return null;
            var nx = (closest.localX - closest.x) / closest.w, ny = (closest.localY - closest.y) / closest.h;
            var side = "center";
            if (nx < 0.3) side = "left"; else if (nx > 0.7) side = "right"; else if (ny < 0.3) side = "top"; else if (ny > 0.7) side = "bottom";
            return { address: closest.address, side: side };
        }
        return null;
    }
}
