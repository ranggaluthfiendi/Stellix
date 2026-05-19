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
    readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property var focusedMonitor: Hyprland.focusedMonitor

    property int pageStart: 1
    property int visibleCount: 5
    property int refreshTrigger: 0

    // ── Manual Z-Order Tracking ──
    property var workspaceWindowOrders: ({})

    function ensureWorkspaceOrder(wsId, windows) {
        if (!workspaceWindowOrders[wsId]) {
            workspaceWindowOrders[wsId] = [];
        }
        var order = workspaceWindowOrders[wsId];
        var newOrder = [];
        // Preserve existing manual order: keep addresses that still exist
        for (var i = 0; i < order.length; i++) {
            var found = false;
            for (var j = 0; j < windows.length; j++) {
                if (getToplevelAddr(windows[j]) === order[i]) {
                    found = true;
                    break;
                }
            }
            if (found) newOrder.push(order[i]);
        }
        // Append new windows not yet tracked (preserve manual order, don't reorder from Hyprland)
        for (var k = 0; k < windows.length; k++) {
            var addr = getToplevelAddr(windows[k]);
            if (newOrder.indexOf(addr) === -1) {
                newOrder.push(addr);
            }
        }
        workspaceWindowOrders[wsId] = newOrder;
    }

    function sortWindowsByOrder(wsId, windows) {
        if (!workspaceWindowOrders[wsId] || workspaceWindowOrders[wsId].length === 0) return windows;
        var order = workspaceWindowOrders[wsId];
        var sorted = [];
        var used = {};
        for (var i = 0; i < order.length; i++) {
            for (var j = 0; j < windows.length; j++) {
                var addr = getToplevelAddr(windows[j]);
                if (addr === order[i] && !used[addr]) {
                    sorted.push(windows[j]);
                    used[addr] = true;
                    break;
                }
            }
        }
        // Append any missed windows
        for (var k = 0; k < windows.length; k++) {
            var a = getToplevelAddr(windows[k]);
            if (!used[a]) sorted.push(windows[k]);
        }
        return sorted;
    }

    function moveWindowToTop(wsId, addr) {
        if (!workspaceWindowOrders[wsId] || !addr || addr === "0x") return;
        var order = workspaceWindowOrders[wsId];
        var idx = order.indexOf(addr);
        if (idx > 0) {
            order.splice(idx, 1);
            order.unshift(addr);
            workspaceWindowOrders[wsId] = order;
        }
    }

    function moveWindowToBottom(wsId, addr) {
        if (!workspaceWindowOrders[wsId] || !addr || addr === "0x") return;
        var order = workspaceWindowOrders[wsId];
        var idx = order.indexOf(addr);
        if (idx >= 0 && idx < order.length - 1) {
            order.splice(idx, 1);
            order.push(addr);
            workspaceWindowOrders[wsId] = order;
        }
    }

    function reverseWorkspaceOrder(wsId) {
        if (!workspaceWindowOrders[wsId]) return;
        var order = workspaceWindowOrders[wsId];
        var reversed = [];
        for (var i = order.length - 1; i >= 0; i--) {
            reversed.push(order[i]);
        }
        workspaceWindowOrders[wsId] = reversed;
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

    // ── Script Process ──
    Process {
        id: scriptProcess
    }

    // ── Command Exec Timer ──
    property var pendingExecCmd: ""
    Timer {
        id: cmdExecTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (pendingExecCmd) {
                scriptProcess.exec(["sh", "-c", pendingExecCmd]);
                pendingExecCmd = "";
            }
        }
    }

    Timer {
        id: cmdResetTimer
        interval: 1000
        repeat: false
        onTriggered: {
            commandRunning = false;
        }
    }

    // ── Panel State ──
    property bool expandablePanelOpen: false
    property int panelWorkspace: 1
    property real expandTargetHeight: 0

    // ── Dimension Constants ──
    readonly property real _layerItemH: Theme.dp(30)
    readonly property real _layerVisibleItems: 2
    readonly property real _headerH: Theme.dp(28)
    readonly property real _separatorH: Theme.dp(1)
    readonly property real _layoutBtnH: Theme.dp(36)
    readonly property real _panelPadding: Theme.dp(12)

    // ── Monitor Dimensions ──
    readonly property real monX: focusedMonitor ? focusedMonitor.x : 0
    readonly property real monY: focusedMonitor ? focusedMonitor.y : 0
    readonly property real monW: Math.max(1, focusedMonitor ? focusedMonitor.width : 1920)
    readonly property real monH: Math.max(1, focusedMonitor ? focusedMonitor.height : 1080)
    readonly property real monitorAspect: monH > 0 ? monW / monH : 16 / 9

    // ── Overlay Dimensions ──
    readonly property real overlayW: Math.min(parent ? parent.width - Theme.dp(48) : 680, Theme.dp(680))
    readonly property real previewGap: Theme.dp(8)
    readonly property real popupInnerW: overlayW - Theme.dp(24)
    readonly property real previewW: (popupInnerW - (visibleCount - 1) * previewGap) / visibleCount
    readonly property real previewH: previewW / monitorAspect
    readonly property real navH: Theme.dp(30)
    readonly property real overlayH: {
        var h = previewH + navH + Theme.dp(40);
        if (expandablePanelOpen) h += calcExpandHeight();
        return h;
    }

    // ── Expose timers for external access ──
    property alias leftDragPageTimer: leftDragPageTimer
    property alias rightDragPageTimer: rightDragPageTimer
    property alias cmdExecTimer: cmdExecTimer
    property alias cmdResetTimer: cmdResetTimer

    // ── Utility Functions ──
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

    readonly property var workspaceIdList: {
        var _ = pageStart;
        var __ = visibleCount;
        var ids = [];
        for (var i = 0; i < visibleCount; i++) ids.push(pageStart + i);
        ids;
    }

    readonly property int maxWorkspaceId: Math.max(highestWorkspaceId(), visibleCount)

    function windowsForWorkspace(id) {
        var result = [];
        if (!workspaces) return result;

        var wsList = workspaces.values;
        for (var i = 0; i < wsList.length; i++) {
            var ws = wsList[i];
            if (ws && ws.id === id) {
                var tls = ws.toplevels;
                if (tls && tls.values) {
                    var vals = tls.values;
                    for (var j = 0; j < vals.length; j++) {
                        if (vals[j]) result.push(vals[j]);
                    }
                }
                return result;
            }
        }

        // Fallback: scan all toplevels
        if (toplevels) {
            var allVals = toplevels.values;
            for (var k = 0; k < allVals.length; k++) {
                var tl = allVals[k];
                if (!tl) continue;
                var wsId = -1;
                if (tl.workspace) wsId = tl.workspace.id;
                else if (tl.lastIpcObject && tl.lastIpcObject.workspace) wsId = tl.lastIpcObject.workspace.id;
                if (wsId === id && result.indexOf(tl) === -1) {
                    result.push(tl);
                }
            }
        }
        ensureWorkspaceOrder(id, result);
        return sortWindowsByOrder(id, result);
    }

    readonly property var panelWindows: {
        var _ = refreshTrigger;
        var __ = panelWorkspace;
        var ___ = toplevels ? toplevels.count : 0;
        var ____ = workspaces ? workspaces.count : 0;
        windowsForWorkspace(panelWorkspace);
    }

    function activateWorkspace(id) {
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
        if (typeof addr === "number") return "0x" + addr.toString(16);
        var a = addr.toString().trim();
        if (a.length === 0) return "";
        if (a.indexOf("0x") === 0) return a;
        if (/^[0-9a-fA-F]+$/.test(a)) return "0x" + a;
        return "0x" + a;
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

    function addWorkspace() {
        var nextId = Math.max(maxWorkspaceId + 1, pageStart + visibleCount);
        pageStart = Math.max(1, nextId - visibleCount + 1);
        Hyprland.dispatch("workspace " + nextId);
    }

    function removeWorkspace() {
        if (maxWorkspaceId <= visibleCount) return;
        var removeId = maxWorkspaceId;
        var targetId = Math.max(1, removeId - 1);
        var wins = windowsForWorkspace(removeId);
        for (var i = 0; i < wins.length; i++) moveWindowToWorkspace(wins[i], targetId)
        if (focusedId === removeId) Hyprland.dispatch("workspace " + targetId);
        pageStart = Math.max(1, Math.min(pageStart, Math.max(1, targetId - visibleCount + 1)));
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
    }

    function moveWindowToWorkspace(toplevel, workspaceId) {
        var address = getToplevelAddr(toplevel);
        if (!address || workspaceId < 1) return;
        Hyprland.dispatch("movetoworkspacesilent " + workspaceId + ",address:" + address);
        forceRefreshTimer.restart();
    }

    function moveWindowToWorkspaceByAddr(address, workspaceId) {
        if (!address || workspaceId < 1) return;
        Hyprland.dispatch("movetoworkspacesilent " + workspaceId + ",address:" + address);
        forceRefreshTimer.restart();
    }

    function closeAllAndReset() {
        if (!toplevels) return;
        var tls = toplevels.values;
        var addrs = [];
        for (var i = 0; i < tls.length; i++) {
            var tl = tls[i];
            if (!tl) continue;
            var addr = getToplevelAddr(tl);
            if (addr && addr !== "0x" && addr !== "") addrs.push(addr);
        }
        for (var j = 0; j < addrs.length; j++) {
            Hyprland.dispatch("closewindow address:" + addrs[j]);
        }
        Qt.callLater(function() {
            Hyprland.dispatch("workspace 1");
            pageStart = 1;
            forceRefreshTimer.restart();
        });
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
        draggingToplevel = null;
        draggingToplevelAddress = "";
        draggingTileCapturedAddr = "";
        dragSourceWorkspace = -1;
        targetWorkspaceDuringDrag = -1;
        draggingMoved = false;
        dropTargetAddr = "";
        dropTargetSide = "";
        leftDragPageTimer.stop();
        rightDragPageTimer.stop();
    }

    // ── Panel Animation ──
    function calcExpandHeight() {
        var h = _panelPadding;
        h += _headerH;
        h += _separatorH;
        var count = windowsForWorkspace(panelWorkspace).length;
        var visibleH = Math.max(count, _layerVisibleItems) * _layerItemH;
        h += visibleH;
        h += _layoutBtnH;
        h += Theme.dp(4);
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
        NumberAnimation {
            id: expandNumberAnim
            target: wsService
            property: "expandTargetHeight"
            to: 0
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: collapseAnim
        NumberAnimation {
            id: collapseNumberAnim
            target: wsService
            property: "expandTargetHeight"
            to: 0
            duration: 250
            easing.type: Easing.InCubic
        }
    }

    // ── Refresh Timer ──
    property alias forceRefreshTimer: forceRefreshTimer

    Timer {
        id: forceRefreshTimer
        interval: 100
        repeat: false
        onTriggered: {
            refreshTrigger++;
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }

    // ── Drag Page Timers ──
    Timer {
        id: leftDragPageTimer
        interval: 120
        repeat: true
        onTriggered: {
            if (draggingToplevel) pageStart = Math.max(1, pageStart - 1);
        }
    }

    Timer {
        id: rightDragPageTimer
        interval: 120
        repeat: true
        onTriggered: {
            if (draggingToplevel) pageStart = pageStart + 1;
        }
    }

    // ── Z-Order Logic ──
    function alterZOrder(addr, direction) {
        if (!addr || addr === "0x") return;
        Hyprland.dispatch("alterzorder " + direction + ",address:" + addr);
        forceRefreshTimer.restart();
    }

    // ── Fullscreen a specific window by address ──
    function fullscreenWindow(addr, wsId) {
        if (!addr || addr === "0x" || wsId < 1) return;
        var oldWs = focusedId;
        commandRunning = true;
        cmdExecTimer.stop();
        pendingExecCmd = "";
        cmdResetTimer.restart();
        
        if (wsId === oldWs) {
            var cmd = "hyprctl dispatch focuswindow address:" + addr + "; sleep 0.05; hyprctl dispatch fullscreen";
            pendingExecCmd = cmd;
            cmdExecTimer.restart();
        } else {
            var cmd = "hyprctl dispatch workspace " + wsId + "; sleep 0.15; hyprctl dispatch focuswindow address:" + addr + "; sleep 0.15; hyprctl dispatch fullscreen; sleep 0.15; hyprctl dispatch workspace " + oldWs;
            pendingExecCmd = cmd;
            cmdExecTimer.restart();
        }
        
        refreshTrigger++;
        forceRefreshTimer.restart();
    }

    // ── Layout Commands (Swap, Float, Fullscreen) ──
    function runLayoutCmd(type, cmd) {
        var wsId = panelWorkspace;
        if (wsId === -1) return;
        var wins = windowsForWorkspace(wsId);
        if (type === "swap") {
            if (wins.length >= 2) {
                var a1 = getToplevelAddr(wins[0]);
                var a2 = getToplevelAddr(wins[1]);
                if (a1 && a2 && a1 !== "0x" && a2 !== "0x") {
                    var oldWs = focusedId;
                    commandRunning = true;
                    cmdExecTimer.stop();
                    pendingExecCmd = "";
                    cmdResetTimer.restart();
                    
                    if (wsId === oldWs) {
                        var cmd = "hyprctl dispatch focuswindow address:" + a2 + "; sleep 0.05; hyprctl dispatch swapnext";
                        pendingExecCmd = cmd;
                        cmdExecTimer.restart();
                    } else {
                        var cmd = "hyprctl dispatch workspace " + wsId + "; sleep 0.15; hyprctl dispatch focuswindow address:" + a2 + "; sleep 0.15; hyprctl dispatch swapnext; sleep 0.15; hyprctl dispatch workspace " + oldWs;
                        pendingExecCmd = cmd;
                        cmdExecTimer.restart();
                    }
                    
                    refreshTrigger++;
                    forceRefreshTimer.restart();
                }
            }
        } else if (type === "float") {
            if (wins.length >= 1) {
                var a = getToplevelAddr(wins[0]);
                if (a && a !== "0x") {
                    Hyprland.dispatch("togglefloating address:" + a);
                    forceRefreshTimer.restart();
                }
            }
        } else if (type === "fullscreen") {
            if (wins.length >= 1) {
                var a = getToplevelAddr(wins[0]);
                if (a && a !== "0x") {
                    fullscreenWindow(a, wsId);
                }
            }
        } else {
            var oldWs = focusedId;
            if (wsId !== oldWs) {
                layoutCmdState.oldWs = oldWs;
                layoutCmdState.targetWs = wsId;
                layoutCmdState.type = type;
                layoutCmdState.cmd = cmd;
                layoutCmdState.step = "switching";
                Hyprland.dispatch("workspace " + wsId);
                layoutCmdTimer.restart();
            } else {
                if (type === "layoutmsg") Hyprland.dispatch("layoutmsg " + cmd);
                else if (type === "dispatch") Hyprland.dispatch(cmd);
                forceRefreshTimer.restart();
            }
        }
    }

    // Layout Cmd
    property var layoutCmdState: ({ oldWs: 1, targetWs: 1, type: "", cmd: "", step: "idle" })

    Timer {
        id: layoutCmdTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (layoutCmdState.step === "switching") {
                if (layoutCmdState.type === "layoutmsg") Hyprland.dispatch("layoutmsg " + layoutCmdState.cmd);
                else if (layoutCmdState.type === "dispatch") Hyprland.dispatch(layoutCmdState.cmd);
                layoutCmdState.step = "returning";
                Hyprland.dispatch("workspace " + layoutCmdState.oldWs);
                layoutCmdReturnTimer.restart();
            }
        }
    }

    Timer {
        id: layoutCmdReturnTimer
        interval: 150
        repeat: false
        onTriggered: {
            layoutCmdState.step = "idle";
            forceRefreshTimer.restart();
        }
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
            var x = at[0] - monX;
            var y = at[1] - monY;
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x + sz[0] > maxX) maxX = x + sz[0];
            if (y + sz[1] > maxY) maxY = y + sz[1];
        }
        var contentW = Math.max(1, maxX - minX);
        var contentH = Math.max(1, maxY - minY);
        var padding = Theme.dp(10);
        var availableW = Math.max(1, previewW - padding * 2);
        var availableH = Math.max(1, previewH - padding * 2);
        var sc = Math.min(availableW / contentW, availableH / contentH);
        var ox = (previewW - (contentW * sc)) / 2;
        var oy = (previewH - (contentH * sc)) / 2;
        return { scale: sc, offsetX: ox, offsetY: oy, minX: minX, minY: minY };
    }

    // ── Drop Target Detection ──
    function dropWorkspaceAtPopup(x, y, previewsRepeater, popup) {
        if (!previewsRepeater) return -1;
        var cnt = previewsRepeater.count || 0;
        for (var i = 0; i < cnt; i++) {
            var item = previewsRepeater.itemAt(i);
            if (!item) continue;
            var p = item.mapFromItem(popup, x, y);
            if (p.x >= 0 && p.y >= 0 && p.x <= item.width && p.y <= item.height) {
                return item.workspaceId;
            }
        }
        return -1;
    }

    function findWindowAtWithDetails(workspaceId, popupX, popupY, excludeAddress, previewsRepeater, popup) {
        if (!previewsRepeater) return null;
        var formattedExclude = formatAddr(excludeAddress);
        var cnt = previewsRepeater.count || 0;
        for (var i = 0; i < cnt; i++) {
            var previewItem = previewsRepeater.itemAt(i);
            if (!previewItem || previewItem.workspaceId !== workspaceId) continue;
            var localP = previewItem.mapFromItem(popup, popupX, popupY);
            var wins = windowsForWorkspace(workspaceId);
            var fit = getFitParams(workspaceId);
            var closest = null;
            var closestDist = Infinity;
            for (var j = 0; j < wins.length; j++) {
                var tl = wins[j];
                var rawAddr = tl.address || (tl.lastIpcObject ? tl.lastIpcObject.address : "");
                var formattedAddr = formatAddr(rawAddr);
                if (formattedAddr === formattedExclude || !formattedAddr) continue;
                var ipc = tl.lastIpcObject || {};
                var at = ipc.at || [0, 0];
                var sz = ipc.size || [400, 300];
                var relX = (at[0] - monX) - fit.minX;
                var relY = (at[1] - monY) - fit.minY;
                var x = (relX * fit.scale) + fit.offsetX;
                var y = (relY * fit.scale) + fit.offsetY;
                var w = sz[0] * fit.scale;
                var h = sz[1] * fit.scale;
                var cx = x + w / 2;
                var cy = y + h / 2;
                var dist = Math.sqrt(Math.pow(localP.x - cx, 2) + Math.pow(localP.y - cy, 2));
                if (dist < closestDist) {
                    closestDist = dist;
                    closest = { address: formattedAddr, x: x, y: y, w: w, h: h, localX: localP.x, localY: localP.y };
                }
            }
            if (!closest) continue;
            // Normalize cursor position relative to target window [0,1]
            var relX = closest.localX - closest.x;
            var relY = closest.localY - closest.y;
            var nx = relX / closest.w;
            var ny = relY / closest.h;

            // Clamp to window bounds so outside points are treated as edge
            if (nx < 0) nx = 0;
            if (nx > 1) nx = 1;
            if (ny < 0) ny = 0;
            if (ny > 1) ny = 1;

            var edgeThresh = 0.30;
            var side = "center";

            if (nx < edgeThresh && ny >= edgeThresh && ny <= 1 - edgeThresh) side = "left";
            else if (nx > 1 - edgeThresh && ny >= edgeThresh && ny <= 1 - edgeThresh) side = "right";
            else if (ny < edgeThresh && nx >= edgeThresh && nx <= 1 - edgeThresh) side = "top";
            else if (ny > 1 - edgeThresh && nx >= edgeThresh && nx <= 1 - edgeThresh) side = "bottom";
            else {
                // Corner or center: pick nearest edge
                var dl = nx;
                var dr = 1 - nx;
                var dt = ny;
                var db = 1 - ny;
                var md = Math.min(dl, dr, dt, db);
                if (md === dl) side = "left";
                else if (md === dr) side = "right";
                else if (md === dt) side = "top";
                else side = "bottom";
            }
            return { address: closest.address, side: side };
        }
        return null;
    }
}
