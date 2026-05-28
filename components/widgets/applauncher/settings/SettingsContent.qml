import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.widgets.barpopup
import qs.core.services
import qs.components.elements

// Import modular pages and components
import "./pages"
import "./components"

Item {
    id: root

    property real s: Scales.uiScale
    
    // Services (Passed from shell.qml)
    property var pwService: null
    property var systemInfo: null
    property var wallpaper: null
    property var colorService: null
    property var settingsData: null

    property string highlightTitle: ""
    property bool isFloating: false
    property var parentWindow: null

    // State
    property int currentCategory: 0
    property string searchQuery: ""
    property bool isSearching: searchQuery.length > 0
    property int focusedNavItem: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    property bool subFocusActive: false

    // Keybind recording state
    property string recordingTarget: ""
    property bool isRecording: false

    // Hyprland keybind management
    property var keybindMap: ({
        "terminal": { linePattern: "bind = $win, return", action: "exec", target: "$terminal", display: "SUPER + RETURN" },
        "launcher": { linePattern: "bind = ALT, space", action: "global", target: "quickshell:app-launcher", display: "ALT + SPACE" },
        "clipboard": { linePattern: "bind = $win, V", action: "global", target: "quickshell:clipboard", display: "SUPER + V" },
        "settings": { linePattern: "bind = $win, I", action: "global", target: "quickshell:system-settings", display: "SUPER + I" },
        "guide": { linePattern: "bind = $win, slash", action: "global", target: "quickshell:guide-popup", display: "SUPER + /" },
        "files": { linePattern: "bind = $win, E", action: "exec", target: "$fileManager", display: "SUPER + E" },
        "browser": { linePattern: "bind = $win, W", action: "exec", target: "$brave", display: "SUPER + W" },
        "code": { label: "VS Code", linePattern: "bind = $win, C", action: "exec", target: "$code", display: "SUPER + C" },
        "discord": { linePattern: "bind = $win, D", action: "exec", target: "$discord", display: "SUPER + D" },
        "steam": { linePattern: "bind = $win, G", action: "exec", target: "$steam", display: "SUPER + G" },
        "obs": { linePattern: "bind = $win, O", action: "exec", target: "$obs", display: "SUPER + O" },
        "kill": { linePattern: "bind = $win, Q", action: "killactive", target: "", display: "SUPER + Q" },
        "screenshot": { linePattern: "bind = $win, S", action: "exec", target: "hyprshot -m window", display: "SUPER + S" },
        "ws_tab": { linePattern: "bind = $win, Tab", action: "global", target: "quickshell:workspace-switcher", display: "SUPER + TAB" },
        "fullscreen": { linePattern: "bind = $win, F", action: "fullscreen", target: "toggle", display: "SUPER + F" },
        "floating": { linePattern: "bind = $win SHIFT, F", action: "togglefloating", target: "", display: "SUPER + SHIFT + F" }
    })

    readonly property string keybindsPath: "/home/rang/.config/hypr/hyprland/keybinds.conf"

    StdioCollector {
        id: keybindReadCollector
        onStreamFinished: { try { parseCurrentKeybinds(this.text) } catch (e) { console.warn("[Settings] Failed to parse keybinds:", e) } }
    }

    Process { id: keybindReadProc; stdout: keybindReadCollector; stderr: keybindReadCollector }
    Process { id: hyprctlProc }
    Process { id: confWriteProc }

    function loadCurrentKeybinds() { keybindReadProc.exec(["sh", "-c", "cat '" + keybindsPath + "' 2>/dev/null"]) }

    function parseCurrentKeybinds(content) {
        var lines = content.split("\n")
        var updatedMap = {}
        for (var key in keybindMap) { updatedMap[key] = keybindMap[key] }
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.indexOf("#") === 0 || line.length === 0) continue
            for (var key in updatedMap) {
                var pattern = updatedMap[key].linePattern
                if (line.indexOf(pattern) === 0 || line.indexOf(pattern.replace("bind = ", "")) === 0) {
                    var parts = line.split(",")
                    if (parts.length >= 2) {
                        var mod = parts[0].replace("bind", "").trim()
                        var key_part = parts[1].trim()
                        var display = ""
                        if (mod.indexOf("$win") !== -1) display = "SUPER"
                        if (mod.indexOf("ALT") !== -1) { if (display.length > 0) display += " + "; display += "ALT" }
                        if (mod.indexOf("SHIFT") !== -1) { if (display.length > 0) display += " + "; display += "SHIFT" }
                        if (mod.indexOf("CTRL") !== -1) { if (display.length > 0) display += " + "; display += "CTRL" }
                        if (key_part.length > 0) {
                            if (display.length > 0) display += " + "
                            var keyDisplay = key_part.toUpperCase()
                            if (keyDisplay === "RETURN") keyDisplay = "ENTER"
                            if (keyDisplay === "ESCAPE") keyDisplay = "ESC"
                            display += keyDisplay
                        }
                        var updated = {}; for (var k in updatedMap[key]) { updated[k] = updatedMap[key][k] }
                        updated.display = display; updatedMap[key] = updated
                    }
                }
            }
        }
        keybindMap = updatedMap
    }

    function updateKeybind(target, newMod, newKey) {
        var kb = keybindMap[target]; if (!kb) return
        var newBind = "bind = " + newMod + ", " + newKey
        
        // Find KeybindsPage to show messages
        function getKbPage() {
            for (var i = 0; i < stack.children.length; i++) {
                if (stack.children[i] && stack.children[i].hasOwnProperty("uiMessage")) return stack.children[i]
            }
            return null
        }
        var kbPage = getKbPage()

        // Check for duplicate keybindings
        for (var k in keybindMap) {
            if (k !== target && keybindMap[k].linePattern.indexOf(newBind) === 0) {
                if (kbPage) kbPage.showMessage("DUPLICATE: This key combo is already in use!", true)
                return
            }
        }

        if (kb.action === "exec") newBind += ", exec, " + kb.target
        else if (kb.action === "global") newBind += ", global, " + kb.target
        else if (kb.action === "killactive") newBind += ", killactive,"
        else if (kb.action === "fullscreen") newBind += ", fullscreen, " + kb.target
        else if (kb.action === "togglefloating") newBind += ", togglefloating,"
        
        hyprctlProc.exec(["sh", "-c", "hyprctl keyword " + newBind.replace(/,/g, " ,")])
        
        var updated = {}; for (var key_item in kb) { updated[key_item] = kb[key_item] }
        var modDisplay = newMod.replace("$win", "SUPER"); var keyDisplay = newKey.toUpperCase()
        if (keyDisplay === "RETURN") keyDisplay = "ENTER"; if (keyDisplay === "ESCAPE") keyDisplay = "ESC"
        updated.display = modDisplay + " + " + keyDisplay; updated.linePattern = newBind
        var newMap = {}; for (var key_name in keybindMap) { if (key_name === target) newMap[key_name] = updated; else newMap[key_name] = keybindMap[key_name] }
        keybindMap = newMap

        // Notify user via UI
        if (kbPage) kbPage.showMessage("SAVED: Restart Hyprland or Quickshell to apply changes.", false)
    }

    function keyToString(key) {
        var keyMap = { 0x01000000: "ESC", 0x01000001: "TAB", 0x01000003: "ENTER", 0x01000005: "SHIFT", 0x01000020: "CTRL", 0x01000023: "ALT", 0x20: "SPACE", 0x54: "T" }
        if (keyMap[key]) return keyMap[key]
        if (key >= 0x30 && key <= 0x39) return String.fromCharCode(key)
        if (key >= 0x41 && key <= 0x5A) return String.fromCharCode(key)
        return "KEY_" + key
    }

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: root.isFloating ? Theme.bgPrimary : "transparent"
        
        RowLayout {
            anchors.fill: parent; spacing: 0

            // --- Sidebar ---
            Rectangle {
                id: sidebar
                Layout.fillHeight: true
                Layout.minimumWidth: Theme.dp(200)
                Layout.preferredWidth: Theme.dp(240)
                color: Theme.bgSecondary
                
                // Add system move for floating window
                MouseArea {
                    anchors.fill: parent
                    enabled: root.isFloating
                    onPressed: (mouse) => {
                        if (root.parentWindow) root.parentWindow.startSystemMove()
                    }
                }

                ScrollView {
                    anchors.fill: parent
                    clip: true
                    
                    ScrollBar.vertical: ScrollBar {
                        id: sidebarScroll
                        width: Theme.dp(4)
                        policy: ScrollBar.AsNeeded
                        background: Rectangle { color: "transparent" }
                        contentItem: Rectangle {
                            color: sidebarScroll.pressed ? Theme.accent : (sidebarScroll.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.6) : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3))
                            radius: 0
                        }
                    }

                    ColumnLayout {
                        width: sidebar.width
                        anchors.margins: Theme.dp(16)
                        spacing: Theme.dp(6)
                        
                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.dp(10); Layout.bottomMargin: Theme.dp(16)
                            Layout.leftMargin: Theme.dp(16); Layout.rightMargin: Theme.dp(16); Layout.topMargin: Theme.dp(16)
                            StarShape { Layout.preferredWidth: Theme.dp(32); Layout.preferredHeight: Theme.dp(32); color: Theme.accent }
                            Column {
                                Text { text: "Stellix Control"; color: Theme.textPrimary; font.pixelSize: Theme.dp(12); font.weight: Font.Bold }
                                Text { text: "System Center"; color: Theme.textMuted; font.pixelSize: Theme.dp(7) }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: Theme.dp(16); Layout.rightMargin: Theme.dp(16)
                            spacing: Theme.dp(6)

                            // --- Appearance ---
                            VabSidebarHeader { title: "Appearance"; expanded: settingsData.appearanceExp; onToggled: settingsData.appearanceExp = !settingsData.appearanceExp }
                            VabNavItem { label: "Personalization"; index: 0; active: !root.isSearching && root.currentCategory === 0; visible: settingsData.appearanceExp }
                            VabNavItem { label: "Bar Layout"; index: 9; active: !root.isSearching && root.currentCategory === 9; visible: settingsData.appearanceExp }
                            VabNavItem { label: "Screen Widgets"; index: 10; active: !root.isSearching && root.currentCategory === 10; visible: settingsData.appearanceExp }
                            VabNavItem { label: "Weather"; index: 11; active: !root.isSearching && root.currentCategory === 11; visible: settingsData.appearanceExp }
                            VabNavItem { label: "Clock"; index: 12; active: !root.isSearching && root.currentCategory === 12; visible: settingsData.appearanceExp }
                            
                            // --- Metrics ---
                            VabSidebarHeader { title: "Metric Widgets"; expanded: settingsData.metricsExp; onToggled: settingsData.metricsExp = !settingsData.metricsExp; Layout.topMargin: Theme.dp(8) }
                            VabNavItem { label: "CPU"; index: 13; active: !root.isSearching && root.currentCategory === 13; visible: settingsData.metricsExp }
                            VabNavItem { label: "GPU"; index: 14; active: !root.isSearching && root.currentCategory === 14; visible: settingsData.metricsExp }
                            VabNavItem { label: "RAM"; index: 15; active: !root.isSearching && root.currentCategory === 15; visible: settingsData.metricsExp }
                            VabNavItem { label: "Disk"; index: 16; active: !root.isSearching && root.currentCategory === 16; visible: settingsData.metricsExp }
                            VabNavItem { label: "Uptime"; index: 17; active: !root.isSearching && root.currentCategory === 17; visible: settingsData.metricsExp }
                            VabNavItem { label: "Temp"; index: 18; active: !root.isSearching && root.currentCategory === 18; visible: settingsData.metricsExp }
                            VabNavItem { label: "Net Down"; index: 19; active: !root.isSearching && root.currentCategory === 19; visible: settingsData.metricsExp }
                            VabNavItem { label: "Net Up"; index: 20; active: !root.isSearching && root.currentCategory === 20; visible: settingsData.metricsExp }
                            VabNavItem { label: "Battery"; index: 21; active: !root.isSearching && root.currentCategory === 21; visible: settingsData.metricsExp }
                            VabNavItem { label: "Swap"; index: 22; active: !root.isSearching && root.currentCategory === 22; visible: settingsData.metricsExp }
                            VabNavItem { label: "GPU Mem"; index: 23; active: !root.isSearching && root.currentCategory === 23; visible: settingsData.metricsExp }
                            VabNavItem { label: "Load"; index: 24; active: !root.isSearching && root.currentCategory === 24; visible: settingsData.metricsExp }
                            VabNavItem { label: "Process"; index: 25; active: !root.isSearching && root.currentCategory === 25; visible: settingsData.metricsExp }
                            VabNavItem { label: "Fan"; index: 26; active: !root.isSearching && root.currentCategory === 26; visible: settingsData.metricsExp }
                            VabNavItem { label: "IP"; index: 27; active: !root.isSearching && root.currentCategory === 27; visible: settingsData.metricsExp }

                            // --- Connectivity ---
                            VabSidebarHeader { title: "Connectivity"; expanded: settingsData.connectivityExp; onToggled: settingsData.connectivityExp = !settingsData.connectivityExp; Layout.topMargin: Theme.dp(8) }
                            VabNavItem { label: "Wi-Fi"; index: 3; active: !root.isSearching && root.currentCategory === 3; visible: settingsData.connectivityExp }
                            VabNavItem { label: "Bluetooth"; index: 8; active: !root.isSearching && root.currentCategory === 8; visible: settingsData.connectivityExp }
                            VabNavItem { label: "Audio Mixer"; index: 2; active: !root.isSearching && root.currentCategory === 2; visible: settingsData.connectivityExp }

                            // --- Workspace ---
                            VabSidebarHeader { title: "Workspace"; expanded: settingsData.workspaceExp; onToggled: settingsData.workspaceExp = !settingsData.workspaceExp; Layout.topMargin: Theme.dp(8) }
                            VabNavItem { label: "General"; index: 1; active: !root.isSearching && root.currentCategory === 1; visible: settingsData.workspaceExp }
                            VabNavItem { label: "Keybindings"; index: 4; active: !root.isSearching && root.currentCategory === 4; visible: settingsData.workspaceExp }
                            
                            // --- System ---
                            VabSidebarHeader { title: "System"; expanded: settingsData.systemExp; onToggled: settingsData.systemExp = !settingsData.systemExp; Layout.topMargin: Theme.dp(8) }
                            VabNavItem { label: "System Status"; index: 5; active: !root.isSearching && root.currentCategory === 5; visible: settingsData.systemExp }
                            VabNavItem { label: "About Stellix"; index: 6; active: !root.isSearching && root.currentCategory === 6; visible: settingsData.systemExp }

                            Item { Layout.preferredHeight: Theme.dp(20) }
                        }
                    }
                }
            }

            // --- Content ---
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0
                
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(64); color: "transparent"
                    
                    // Add system move for floating window
                    MouseArea {
                        anchors.fill: parent
                        enabled: root.isFloating
                        onPressed: (mouse) => {
                            if (root.parentWindow) root.parentWindow.startSystemMove()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: Theme.dp(20); anchors.rightMargin: Theme.dp(20); spacing: Theme.dp(16)
                        Text {
                            text: root.isSearching ? "Search Results" : ["Personalization", "Workspaces", "Audio", "Wi-Fi", "Keybindings", "System", "About", "Search", "Bluetooth", "Bar Layout", "Screen Widgets", "Weather", "Clock", "CPU", "GPU", "RAM", "Disk", "Uptime", "Temp", "Net Down", "Net Up"][root.currentCategory]
                            color: Theme.textPrimary; font.pixelSize: Theme.dp(16); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(140)
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(36); color: Theme.bgSecondary; border.width: 1; border.color: searchInput.activeFocus ? Theme.accent : Theme.border; radius: 0 
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: Theme.dp(16); anchors.rightMargin: Theme.dp(10); spacing: Theme.dp(8)
                                TextField {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    placeholderText: "Search settings..."
                                    color: Theme.textPrimary
                                    placeholderTextColor: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                                    background: Item {}
                                    font.pixelSize: Theme.dp(11)
                                    font.family: Typography.fontFamily
                                    text: root.searchQuery
                                    onTextChanged: if (text !== root.searchQuery) root.searchQuery = text
                                    onAccepted: {
                                        if (text !== "" && root.settingsData) root.settingsData.addRecentSearch(text)
                                    }
                                    Keys.onPressed: function(event) {
                                        if (event.key === Qt.Key_Escape) { 
                                            if (text !== "") { text = ""; root.searchQuery = "" } 
                                            else { BarPopupState.settingsOpen = false }
                                            event.accepted = true 
                                        }
                                    }
                                }
                                Text { text: "✕"; visible: searchInput.text !== ""; color: Theme.textMuted; font.pixelSize: Theme.dp(10); MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { searchInput.text = ""; root.searchQuery = "" } } }
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: Theme.dp(32); Layout.preferredHeight: Theme.dp(32); color: closeMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1) : "transparent"; radius: 0
                            Text { anchors.centerIn: parent; text: "✕"; color: closeMouse.containsMouse ? Theme.danger : Theme.textMuted; font.pixelSize: Theme.dp(12) }
                            MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: BarPopupState.settingsOpen = false }
                        }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border; opacity: 0.5 }
                }

                StackLayout {
                    id: stack
                    Layout.fillWidth: true; Layout.fillHeight: true; currentIndex: root.isSearching ? 7 : root.currentCategory

                    AppearancePage { colorService: root.colorService; wallpaper: root.wallpaper; systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; subFocusActive: root.subFocusActive; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    WorkspacePage { systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    AudioPage { pwService: root.pwService; systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    WifiPage { systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    KeybindsPage { 
                        systemInfo: root.systemInfo; currentCategory: root.currentCategory; keybindMap: root.keybindMap; isRecording: root.isRecording; recordingTarget: root.recordingTarget
                        focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex
                        onRecordClicked: function(target){ root.recordingTarget = target; root.isRecording = true }
                        onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" }
                    }
                    SystemPage { settingsData: root.settingsData; systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    AboutPage { systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex }
                    SearchResultsPage { 
                        searchQuery: root.searchQuery; settingsData: root.settingsData; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; 
                        onGoToCategory: function(cat, title){ 
                            var prevCat = root.currentCategory;
                            root.highlightTitle = title;
                            root.searchQuery = ""; 
                            root.currentCategory = cat; 
                            root.focusedNavItem = cat;
                            root.focusInContent = true;

                            if (prevCat === cat) {
                                // Manual trigger if page didn't change
                                var page = stack.children[cat];
                                if (page && typeof page.triggerHighlight === "function") {
                                    page.triggerHighlight(title);
                                    root.highlightTitle = "";
                                }
                            }
                        } 
                    }
                    BluetoothPage { systemInfo: root.systemInfo; currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    BarLayoutPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; subFocusActive: root.subFocusActive; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    ScreenPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    WeatherPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    ClockPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    CpuMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    GpuMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    MemMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    DiskMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    UptimeMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    TempMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    NetDownMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    NetUpMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    BatteryMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    SwapMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    GpuMemMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    LoadMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    ProcessMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    FanMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                    IpMetricPage { currentCategory: root.currentCategory; focusInContent: root.focusInContent; contentFocusIndex: root.contentFocusIndex; onActiveChanged: if(active && root.highlightTitle !== "") { triggerHighlight(root.highlightTitle); root.highlightTitle = "" } }
                }

                Rectangle { // Hint bar
                    Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(32); color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: Theme.dp(16); anchors.rightMargin: Theme.dp(16); spacing: Theme.dp(10)
                        
                        FooterHint { label: "Navigate"; keys: "↑/↓" }
                        FooterSeparator {}
                        FooterHint { label: "Switch Area"; keys: "←/→" }
                        FooterSeparator {}
                        FooterHint { label: "Back/Close"; keys: "Esc" }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "Stellix Control"
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(8 * s)
                            font.weight: Font.Bold
                            opacity: 0.6
                        }
                    }
                }
            }
        }
    }

    Item {
        focus: BarPopupState.settingsOpen
        Keys.onPressed: function(event) {
            if (root.isRecording) {
                if (event.key === Qt.Key_Escape) { root.isRecording = false; root.recordingTarget = ""; event.accepted = true; return }
                var mod = "SUPER"; var keyStr = root.keyToString(event.key)
                if (event.modifiers & Qt.AltModifier) mod = "ALT"; if (event.modifiers & Qt.ControlModifier) mod = "CTRL"
                if (event.modifiers & Qt.ShiftModifier) mod += " SHIFT"
                root.updateKeybind(root.recordingTarget, mod, keyStr); root.isRecording = false; event.accepted = true; return
            }
            if (event.key === Qt.Key_Escape) {
                if (root.subFocusActive) root.subFocusActive = false; else if (root.focusInContent) root.focusInContent = false; else BarPopupState.settingsOpen = false
                event.accepted = true; return
            }
            var navOrder = [0, 9, 10, 11, 12, 3, 8, 2, 1, 4, 5, 6, 13, 14, 15, 16, 17, 18, 19, 20]; var currentIdx = navOrder.indexOf(root.focusedNavItem)
            if (event.key === Qt.Key_Right && !root.focusInContent) { root.focusInContent = true; root.contentFocusIndex = 0; event.accepted = true; return }
            if (event.key === Qt.Key_Left && root.focusInContent && !root.subFocusActive) { root.focusInContent = false; event.accepted = true; return }
            if (event.key === Qt.Key_Up) {
                if (!root.focusInContent) {
                    root.focusedNavItem = navOrder[(currentIdx - 1 + navOrder.length) % navOrder.length];
                    root.currentCategory = root.focusedNavItem;
                } else if (!root.subFocusActive) {
                    root.contentFocusIndex = (root.contentFocusIndex - 1 + 30) % 30
                }
                event.accepted = true; return
            }
            if (event.key === Qt.Key_Down) {
                if (!root.focusInContent) {
                    root.focusedNavItem = navOrder[(currentIdx + 1) % navOrder.length];
                    root.currentCategory = root.focusedNavItem;
                } else if (!root.subFocusActive) {
                    root.contentFocusIndex = (root.contentFocusIndex + 1) % 30
                }
                event.accepted = true; return
            }
            if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && root.focusInContent) { root.subFocusActive = !root.subFocusActive; event.accepted = true; return }
        }
    }
    Connections { target: BarPopupState; function onSettingsOpenChanged() { if (BarPopupState.settingsOpen) loadCurrentKeybinds() } }

    component VabSidebarHeader: Rectangle {
        property string title: ""
        property bool expanded: true
        signal toggled()
        Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(36); color: "transparent"
        RowLayout {
            anchors.fill: parent; spacing: Theme.dp(10)
            Text {
                text: expanded ? "▾" : "▸"
                color: Theme.accent; font.pixelSize: Theme.dp(22); font.weight: Font.Bold
                Layout.preferredWidth: Theme.dp(26); Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: title
                color: Theme.accent; font.pixelSize: Theme.dp(11); font.weight: Font.Bold
                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
            }
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.toggled() }
    }

    component VabNavItem: Rectangle {
        property string label: ""; property int index: 0; property bool active: false
        property bool isFocused: !root.focusInContent && root.focusedNavItem === index
        Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(42); radius: 0
        color: active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (isFocused ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.1) : "transparent")
        border.width: isFocused ? 1 : 0; border.color: Theme.accent
        Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: active ? Theme.dp(4) : 0; color: Theme.accent; radius: 0; Behavior on width { NumberAnimation { duration: 120 } } }
        Text { anchors.left: parent.left; anchors.leftMargin: active || isFocused ? Theme.dp(16) : Theme.dp(12); anchors.verticalCenter: parent.verticalCenter; text: label; color: active || isFocused ? Theme.textPrimary : Theme.textMuted; font.pixelSize: Theme.dp(12); font.weight: active || isFocused ? Font.Bold : Font.Normal }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: function(){ root.searchQuery = ""; searchInput.text = ""; root.currentCategory = index; root.focusedNavItem = index; root.focusInContent = false } }
    }

    component FooterHint: RowLayout {
        property string label: ""
        property string keys: ""
        spacing: Theme.dp(4)
        
        Text {
            text: keys
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
            font.weight: Font.Bold
        }
        Text {
            text: label
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
        }
    }

    component FooterSeparator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(12)
        color: Theme.border
        opacity: 0.5
    }
}
