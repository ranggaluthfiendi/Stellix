import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.widgets.barpopup
import qs.components.widgets.applauncher
import qs.components.elements

PanelWindow {
    id: root

    property real s: Scales.uiScale
    property real popupW: Theme.dp(560)
    property real popupH: Theme.dp(500)
    property real itemH: Theme.dp(42)
    property int viewMode: 0
    property var contextMenuApp: null
    property bool wallpaperMode: false
    property bool showCommands: false
    property string commandFilter: ""
    property string commandTrigger: ">"
    property bool followCursor: true
    property var wallpaper: null
    property var clipboardService: null

    readonly property var commands: [
        { name: "Stellix Control", desc: "Advanced System Settings", trigger: "", icon: "preferences-system" },
        { name: "/settings", desc: "Open Stellix Control Center", trigger: "/", icon: "preferences-system" },
        { name: "/calc", desc: "Calculator", trigger: "/", icon: "accessories-calculator" },
        { name: "/color", desc: "Color scheme settings", trigger: "/", icon: "preferences-desktop-color" },
        { name: "/currency", desc: "Currency converter", trigger: "/", icon: "accessories-calculator" },
        { name: "/dark", desc: "Switch to dark mode", trigger: "/", icon: "dark-mode" },
        { name: "/light", desc: "Switch to light mode", trigger: "/", icon: "light-mode" },
        { name: "/power", desc: "Power menu", trigger: "/", icon: "system-shutdown" },
        { name: "/record", desc: "Screen recording", trigger: "/", icon: "media-record" },
        { name: "/screenshot", desc: "Take screenshot", trigger: "/", icon: "camera-photo" },
        { name: "/wallpaper", desc: "Switch wallpaper", trigger: "/", icon: "preferences-desktop-wallpaper" },
        { name: "/clipboard", desc: "Clipboard history", trigger: "/", icon: "edit-paste" },
        { name: ">calc", desc: "Calculator", trigger: ">", icon: "accessories-calculator" },
        { name: ">color", desc: "Color scheme settings", trigger: ">", icon: "preferences-desktop-color" },
        { name: ">currency", desc: "Currency converter", trigger: ">", icon: "accessories-calculator" },
        { name: ">power", desc: "Power menu", trigger: ">", icon: "system-shutdown" },
        { name: ">record", desc: "Screen recording", trigger: ">", icon: "media-record" },
        { name: ">screenshot", desc: "Take screenshot", trigger: ">", icon: "camera-photo" },
        { name: ">settings", desc: "System Settings", trigger: ">", icon: "preferences-system" },
        { name: ">wallpaper", desc: "Switch wallpaper", trigger: ">", icon: "preferences-desktop-wallpaper" },
        { name: ">clipboard", desc: "Clipboard history", trigger: ">", icon: "edit-paste" },
        { name: "?calc", desc: "Calculator", trigger: "?", icon: "accessories-calculator" },
        { name: "?color", desc: "Color scheme settings", trigger: "?", icon: "preferences-desktop-color" },
        { name: "?currency", desc: "Currency converter", trigger: "?", icon: "accessories-calculator" },
        { name: "?dark", desc: "Switch to dark mode", trigger: "?", icon: "dark-mode" },
        { name: "?help", desc: "Show commands", trigger: "?", icon: "help-about" },
        { name: "?light", desc: "Switch to light mode", trigger: "?", icon: "light-mode" },
        { name: "?power", desc: "Power menu", trigger: "?", icon: "system-shutdown" },
        { name: "?record", desc: "Screen recording", trigger: "?", icon: "media-record" },
        { name: "?screenshot", desc: "Take screenshot", trigger: "?", icon: "camera-photo" },
        { name: "?wallpaper", desc: "Switch wallpaper", trigger: "?", icon: "preferences-desktop-wallpaper" },
        { name: "?clipboard", desc: "Clipboard history", trigger: "?", icon: "edit-paste" }
    ]

    readonly property var currentModel: root.showCommands
        ? root.filteredCommands
        : (launcher.groupByCategory && launcher.filterMode === 0
            ? launcher.groupedApps
            : launcher.filteredApps)

    readonly property var filteredCommands: {
        if (!root.showCommands) return []
        if (root.commandFilter === "") return root.commands.filter(function(cmd) {
            return cmd.trigger === root.commandTrigger
        })
        return root.commands.filter(function(cmd) {
            return cmd.trigger === root.commandTrigger && cmd.name.toLowerCase().indexOf(root.commandTrigger + root.commandFilter) >= 0
        })
    }

    function findMatchingApp(text) {
        if (!text || text.length === 0) return null
        var lower = text.toLowerCase()
        var apps = launcher.filteredApps || []
        for (var i = 0; i < apps.length; i++) {
            var appName = (apps[i].name || "").toLowerCase()
            if (appName === lower) return apps[i]
        }
        return null
    }

    function autoCompleteApp() {
        var txt = searchInput.text
        if (!txt || txt.length === 0) return false
        var lower = txt.toLowerCase()
        var apps = launcher.filteredApps || []
        for (var i = 0; i < apps.length; i++) {
            var appName = (apps[i].name || "").toLowerCase()
            if (appName.indexOf(lower) === 0) {
                searchInput.text = apps[i].name
                launcher.searchText = apps[i].name
                appList.currentIndex = i
                return true
            }
        }
        return false
    }

    function executeCommand(cmdName) {
        var baseName = cmdName.replace(/^[>/?]/, "")
        searchInput.text = cmdName + " "
        launcher.searchText = cmdName + " "
        
        switch (baseName) {
            case "wallpaper":
                root.wallpaperMode = true
                root.viewMode = 0
                break
            case "settings":
                BarPopupState.closeAll()
                BarPopupState.settingsOpen = true
                closeLauncher()
                break
            case "color":
                root.viewMode = 5
                root.wallpaperMode = false
                break
            case "record":
                recordService.toggleRecording()
                closeLauncher()
                break
            case "screenshot":
                screenshot.screenshotRegion()
                closeLauncher()
                break
            case "power":
                root.viewMode = 3
                root.wallpaperMode = false
                break
            case "calc":
                root.viewMode = 4
                root.wallpaperMode = false
                break
            case "currency":
                root.viewMode = 6
                root.wallpaperMode = false
                break
            case "clipboard":
                root.viewMode = 8
                root.wallpaperMode = false
                break
            case "dark":
                colorService.setMode("dark")
                root.showCommands = false
                root.wallpaperMode = false
                root.viewMode = 0
                searchInput.text = ""
                launcher.searchText = ""
                closeLauncher()
                break
            case "light":
                colorService.setMode("light")
                root.showCommands = false
                root.wallpaperMode = false
                root.viewMode = 0
                searchInput.text = ""
                launcher.searchText = ""
                closeLauncher()
                break
            case "help":
                root.showCommands = true
                root.commandFilter = ""
                break
        }
    }

    visible: BarPopupState.launcherOpen
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: BarPopupState.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    MouseArea {
        anchors.fill: parent
        visible: root.visible
        z: -1
        onClicked: closeLauncher()
    }

    Rectangle {
        id: mainContainer
        
        readonly property point cursor: Quickshell.cursorPosition || Qt.point(root.width / 2, root.height / 2)
        
        x: root.followCursor ? Math.min(Math.max(0, cursor.x - width / 2), root.width - width) : Math.round((root.width - width) / 2)
        y: root.followCursor ? Math.min(Math.max(0, cursor.y - height / 2), root.height - height) : Math.round((root.height - height) / 2)
        width: Math.min(root.width - Theme.dp(40), Math.max(Theme.dp(400), mainLayout.implicitWidth + Theme.dp(24)))
        height: Math.min(root.height - Theme.dp(40), Math.max(Theme.dp(300), mainLayout.implicitHeight + Theme.dp(24)))
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0
        z: 1

        opacity: BarPopupState.launcherOpen ? 1 : 0
        scale: BarPopupState.launcherOpen ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Behavior on x {
            enabled: root.followCursor && BarPopupState.launcherOpen
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Behavior on y {
            enabled: root.followCursor && BarPopupState.launcherOpen
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) { mouse.accepted = true }
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: Theme.dp(12)
            spacing: Theme.dp(8)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(42)
                color: Theme.bgPrimary
                border.width: 1
                border.color: searchInput.activeFocus ? Theme.accent : Theme.border
                radius: 0

                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(10)
                    spacing: Theme.dp(8)

                    StarShape {
                        Layout.preferredWidth: Theme.dp(16)
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.alignment: Qt.AlignVCenter
                        color: Theme.accent
                        animate: true
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        placeholderText: root.showCommands ? "Type command..." : (root.wallpaperMode ? "Switch wallpaper..." : "Search... (>, /, ? for commands)")
                        placeholderTextColor: Theme.textMuted
                        text: launcher.searchText
                        color: Theme.textPrimary
                        selectionColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                        selectedTextColor: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(13 * s)
                        focus: BarPopupState.launcherOpen
                        background: Item {}
                        leftPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            launcher.searchText = text
                            if (text === ">" || text === "/" || text === "?") {
                                root.showCommands = true
                                root.commandTrigger = text
                                root.commandFilter = ""
                                root.wallpaperMode = false
                                root.viewMode = 0
                            } else if (text.length > 1 && (text[0] === ">" || text[0] === "/" || text[0] === "?")) {
                                root.showCommands = true
                                root.commandTrigger = text[0]
                                root.commandFilter = text.substring(1).toLowerCase()
                                root.wallpaperMode = false
                                root.viewMode = 0
                                
                                var cmd = text.toLowerCase().trim()
                                if (cmd === ">wallpaper" || cmd === "/wallpaper" || cmd === "?wallpaper") {
                                    root.showCommands = false
                                    root.wallpaperMode = true
                                    root.viewMode = 0
                                } else if (cmd === ">power" || cmd === "/power" || cmd === "?power") {
                                    root.showCommands = false
                                    root.viewMode = 3
                                } else if (cmd === ">calc" || cmd === "/calc" || cmd === "?calc") {
                                    root.showCommands = false
                                    root.viewMode = 4
                                } else if (cmd === ">currency" || cmd === "/currency" || cmd === "?currency") {
                                    root.showCommands = false
                                    root.viewMode = 6
                                } else if (cmd === ">color" || cmd === "/color" || cmd === "?color") {
                                    root.showCommands = false
                                    root.wallpaperMode = false
                                    root.viewMode = 5
                                    searchInput.text = ""
                                    launcher.searchText = ""
                                } else if (cmd === ">settings" || cmd === "/settings" || cmd === "?settings") {
                                    root.showCommands = false
                                    BarPopupState.closeAll()
                                    BarPopupState.settingsOpen = true
                                    searchInput.text = ""
                                    launcher.searchText = ""
                                    closeLauncher()
                                }
                            } else {
                                root.showCommands = false
                                root.wallpaperMode = false
                                if (root.viewMode >= 3) root.viewMode = 0
                            }
                        }

                        Keys.onPressed: function(event) {
                            // --- Priority 1: Specialized View Key Handling ---
                            if (root.viewMode >= 3 && root.viewMode !== 7) {
                                if (event.key === Qt.Key_Escape) {
                                    root.viewMode = 0
                                    root.showCommands = false
                                    root.wallpaperMode = false
                                    searchInput.text = ""
                                    launcher.searchText = ""
                                    event.accepted = true
                                    return
                                }
                                
                                if (root.viewMode === 8) { // Clipboard Mode
                                    if (event.key === Qt.Key_Delete) {
                                        if (clipboardPopup) {
                                            if (event.modifiers & Qt.AltModifier) {
                                                if (root.clipboardService) root.clipboardService.clearHistory()
                                            } else {
                                                clipboardPopup.deleteCurrent()
                                            }
                                        }
                                        event.accepted = true; return
                                    }
                                    if (event.key === Qt.Key_F && !event.modifiers) {
                                        if (clipboardPopup) clipboardPopup.togglePinCurrent()
                                        event.accepted = true; return
                                    }
                                    if (event.key === Qt.Key_Down) { if (clipboardPopup) clipboardPopup.next(); event.accepted = true; return }
                                    if (event.key === Qt.Key_Up) { if (clipboardPopup) clipboardPopup.prev(); event.accepted = true; return }
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { if (clipboardPopup) clipboardPopup.selectCurrent(); event.accepted = true; return }
                                }
                                // ... other specialized modes will bubble down or return here
                            }

                            // --- Priority 2: Command Clearing ---
                            if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
                                var txt = searchInput.text
                                if (txt.length > 1 && (txt[0] === ">" || txt[0] === "/" || txt[0] === "?")) {
                                    var baseName = txt.substring(1).trim().toLowerCase()
                                    var knownCmds = ["wallpaper", "color", "calc", "currency", "power", "record", "screenshot", "dark", "light", "help", "clipboard"]
                                    if (knownCmds.indexOf(baseName) >= 0) {
                                        searchInput.text = ""
                                        launcher.searchText = ""
                                        root.showCommands = false
                                        root.wallpaperMode = false
                                        root.viewMode = 0
                                        event.accepted = true
                                    }
                                }
                                if (!event.accepted) {
                                    if (root.findMatchingApp(txt)) {
                                        searchInput.text = ""
                                        launcher.searchText = ""
                                        event.accepted = true
                                    }
                                }
                            }
                            if (event.key === Qt.Key_Escape) {
                                if (root.viewMode === 7) {
                                    root.viewMode = 0
                                    root.contextMenuApp = null
                                } else if (deleteConfirmDialog.visible) {
                                    deleteConfirmDialog.hide()
                                } else if (root.wallpaperMode || root.showCommands || root.viewMode >= 3) {
                                    root.wallpaperMode = false
                                    root.showCommands = false
                                    root.viewMode = 0
                                    searchInput.text = ""
                                    launcher.searchText = ""
                                } else {
                                    closeLauncher()
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.viewMode === 7) {
                                    if (root.contextMenuApp) launcher.launchApp(root.contextMenuApp)
                                    root.viewMode = 0
                                } else if (root.showCommands && root.filteredCommands.length > 0 && appList.currentIndex >= 0 && appList.currentIndex < root.filteredCommands.length) {
                                    var cmd = root.filteredCommands[appList.currentIndex].name
                                    root.executeCommand(cmd)
                                    root.showCommands = false
                                    event.accepted = true
                                } else if (root.wallpaperMode) {
                                    wallpaperSwitcher.apply()
                                    event.accepted = true
                                } else if (root.viewMode === 3) {
                                    powerPopup.executeCurrent()
                                    event.accepted = true
                                } else if (root.viewMode === 4) {
                                    if (calcPopup && calcPopup.calcInput) calcPopup.calcInput.forceActiveFocus()
                                    event.accepted = true
                                } else if (root.viewMode === 5) {
                                    if (colorPopup) colorPopup.applyCurrent()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.currencyInput.forceActiveFocus()
                                    event.accepted = true
                                } else if (appList.currentIndex >= 0 && appList.currentIndex < root.currentModel.length) {
                                    launcher.launchApp(root.currentModel[appList.currentIndex])
                                    closeLauncher()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Down) {
                                if (root.showCommands) {
                                    appList.currentIndex = Math.min(appList.currentIndex + 1, root.filteredCommands.length - 1)
                                    event.accepted = true
                                } else if (root.wallpaperMode) {
                                    wallpaperSwitcher.checkKonami(event.key)
                                    wallpaper.next()
                                    event.accepted = true
                                } else if (root.viewMode === 3) {
                                    powerPopup.next()
                                    event.accepted = true
                                } else if (root.viewMode === 5) {
                                    if (colorPopup) colorPopup.next()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.currencyInput.forceActiveFocus()
                                    event.accepted = true
                                } else {
                                    var maxIdx = root.currentModel.length - 1
                                    if (root.viewMode === 1) { // Grid Mode
                                        var nextGridIdx = appList.currentIndex + 6
                                        appList.currentIndex = Math.min(nextGridIdx, maxIdx)
                                    } else {
                                        appList.currentIndex = Math.min(appList.currentIndex + 1, maxIdx)
                                    }
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Up) {
                                if (root.showCommands) {
                                    appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                                    event.accepted = true
                                } else if (root.wallpaperMode) {
                                    wallpaperSwitcher.checkKonami(event.key)
                                    wallpaper.prev()
                                    event.accepted = true
                                } else if (root.viewMode === 3) {
                                    powerPopup.prev()
                                    event.accepted = true
                                } else if (root.viewMode === 5) {
                                    if (colorPopup) colorPopup.prev()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.currencyInput.forceActiveFocus()
                                    event.accepted = true
                                } else {
                                    if (root.viewMode === 1) { // Grid Mode
                                        var prevGridIdx = appList.currentIndex - 6
                                        appList.currentIndex = Math.max(prevGridIdx, 0)
                                    } else {
                                        appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                                    }
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Right) {
                                if (root.wallpaperMode) {
                                    wallpaper.next()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.doSwap()
                                    event.accepted = true
                                } else if (root.viewMode === 1) { // Grid Mode
                                    appList.currentIndex = Math.min(appList.currentIndex + 1, root.currentModel.length - 1)
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Left) {
                                if (root.wallpaperMode) {
                                    wallpaper.prev()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.doSwap()
                                    event.accepted = true
                                } else if (root.viewMode === 1) { // Grid Mode
                                    appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
                                if (root.showCommands && root.filteredCommands.length > 0) {
                                    var selectedCmd = root.filteredCommands[appList.currentIndex >= 0 ? appList.currentIndex : 0]
                                    root.executeCommand(selectedCmd.name)
                                    root.showCommands = false
                                    event.accepted = true
                                } else if (root.wallpaperMode) {
                                    wallpaper.next()
                                    event.accepted = true
                                } else if (root.viewMode === 4) {
                                    if (calcPopup && calcPopup.calcInput) calcPopup.calcInput.forceActiveFocus()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup && currencyPopup.currencyInput) currencyPopup.currencyInput.forceActiveFocus()
                                    event.accepted = true
                                } else if (root.autoCompleteApp()) {
                                    event.accepted = true
                                } else {
                                    appList.forceActiveFocus()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Backtab) {
                                if (root.showCommands && root.filteredCommands.length > 0) {
                                    var prevCmd = root.filteredCommands[appList.currentIndex >= 0 ? appList.currentIndex : 0]
                                    root.executeCommand(prevCmd.name)
                                    root.showCommands = false
                                    event.accepted = true
                                } else if (root.wallpaperMode) {
                                    wallpaper.prev()
                                    event.accepted = true
                                } else {
                                    searchInput.forceActiveFocus()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Control) {
                                if (root.viewMode >= 0 && root.viewMode < 3 && !root.showCommands && !root.wallpaperMode) {
                                    var idx = appList.currentIndex
                                    if (idx >= 0 && idx < root.currentModel.length) {
                                        root.contextMenuApp = root.currentModel[idx]
                                        root.viewMode = 7
                                    }
                                    event.accepted = true
                                } else {
                                    root.viewMode = (root.viewMode + 1) % 2
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Space) {
                                if (root.wallpaperMode) {
                                    wallpaperSwitcher.apply()
                                    event.accepted = true
                                } else if (root.viewMode === 5) {
                                    if (colorPopup) colorPopup.applyCurrent()
                                    event.accepted = true
                                } else if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.closeRequested()
                                    event.accepted = true
                                } else if (root.showCommands && root.filteredCommands.length > 0) {
                                    var selectedCmd = root.filteredCommands[appList.currentIndex >= 0 ? appList.currentIndex : 0]
                                    root.executeCommand(selectedCmd.name)
                                    root.showCommands = false
                                    event.accepted = true
                                } else if (root.autoCompleteApp()) {
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_A) {
                                if (event.modifiers & Qt.ShiftModifier) {
                                    if (root.wallpaperMode || root.showCommands || root.viewMode >= 3) {
                                        root.wallpaperMode = false
                                        root.showCommands = false
                                        root.viewMode = 0
                                        searchInput.text = ""
                                        launcher.searchText = ""
                                        event.accepted = true
                                    }
                                } else if (root.wallpaperMode) {
                                    root.followCursor = !root.followCursor
                                    event.accepted = true
                                } else if (root.viewMode === 5) {
                                    colorService.applyTheme()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_S && !event.modifiers) {
                                if (root.viewMode === 6) {
                                    if (currencyPopup) currencyPopup.doSwap()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_T && !event.modifiers) {
                                if (root.wallpaperMode) {
                                    wallpaperSwitcher.nextAnim()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_M && !event.modifiers) {
                                if (root.viewMode === 5) {
                                    colorService.toggleMode()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_P && (event.modifiers & Qt.AltModifier)) {
                                if (root.viewMode === 8) {
                                    if (clipboardPopup) clipboardPopup.togglePinCurrent()
                                    event.accepted = true
                                }
                            } else if (event.key === Qt.Key_Delete) {
                                if (root.viewMode === 8) {
                                    if (clipboardPopup) {
                                        if (event.modifiers & Qt.AltModifier) {
                                            if (root.clipboardService) root.clipboardService.clearHistory()
                                        } else {
                                            clipboardPopup.deleteCurrent()
                                        }
                                    }
                                    event.accepted = true
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(26)
                spacing: Theme.dp(6)
                visible: !root.wallpaperMode && !root.showCommands && root.viewMode < 3

                Rectangle {
                    Layout.preferredWidth: Theme.dp(28)
                    Layout.preferredHeight: Theme.dp(26)
                    color: viewToggleMouse.containsMouse
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : "transparent"
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.viewMode === 0 ? "☰" : "⊞"
                        color: Theme.accent
                        font.pixelSize: Math.round(13 * s)
                    }

                    MouseArea {
                        id: viewToggleMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.viewMode = (root.viewMode + 1) % 2
                    }
                }

                Rectangle {
                    Layout.preferredWidth: sortText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(26)
                    color: sortMouse.containsMouse
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : "transparent"
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        id: sortText
                        anchors.centerIn: parent
                        text: launcher.sortMode === "az" ? "A-Z" : "Z-A"
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(10 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: sortMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: launcher.sortMode = launcher.sortMode === "az" ? "za" : "az"
                    }
                }

                Rectangle {
                    Layout.preferredWidth: groupText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(26)
                    color: launcher.filterMode === 0 && groupMouse.containsMouse
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : "transparent"
                    border.width: 1
                    border.color: launcher.filterMode === 0 && launcher.groupByCategory ? Theme.accent : Theme.border
                    radius: 0

                    visible: launcher.filterMode === 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        id: groupText
                        anchors.centerIn: parent
                        text: launcher.groupByCategory ? "Grouped" : "Group"
                        color: launcher.groupByCategory ? Theme.accent : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: groupMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: launcher.groupByCategory = !launcher.groupByCategory
                    }
                }

                Rectangle {
                    Layout.preferredWidth: allText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(26)
                    color: launcher.filterMode === 0
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                        : "transparent"
                    border.width: 1
                    border.color: launcher.filterMode === 0 ? Theme.accent : Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: allText
                        anchors.centerIn: parent
                        text: "All"
                        color: launcher.filterMode === 0 ? Theme.accent : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            launcher.filterMode = 0
                            launcher.groupByCategory = false
                        }
                    }
                }

                Flickable {
                    id: categoryFlick
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(26)
                    contentWidth: categoryRow.implicitWidth
                    interactive: contentWidth > width
                    clip: true
                    flickableDirection: Flickable.HorizontalFlick
                    maximumFlickVelocity: 2000

                    Behavior on contentX {
                        enabled: !categoryFlick.moving
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        height: Theme.dp(3)
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y !== 0) {
                                var newX = categoryFlick.contentX - (wheel.angleDelta.y > 0 ? 60 : -60)
                                var maxScroll = Math.max(0, categoryFlick.contentWidth - categoryFlick.width)
                                categoryFlick.contentX = Math.max(0, Math.min(newX, maxScroll))
                            }
                        }
                    }

                    Row {
                        id: categoryRow
                        height: parent.height
                        spacing: Theme.dp(4)

                        Repeater {
                            model: launcher.categoryList.length > 1 ? launcher.categoryList.slice(1) : []

                            delegate: Rectangle {
                                height: Theme.dp(24)
                                width: chipText.width + Theme.dp(14)
                                color: (launcher.filterMode === index + 1)
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                                    : "transparent"
                                border.width: 1
                                border.color: (launcher.filterMode === index + 1) ? Theme.accent : Theme.border
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Behavior on border.color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    id: chipText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: (launcher.filterMode === index + 1) ? Theme.accent : Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(9 * s)
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        launcher.filterMode = index + 1
                                        launcher.groupByCategory = false
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    text: root.currentModel.length + " Apps"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(11 * s)
                    font.weight: Font.Bold
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.wallpaperMode ? 2 : root.viewMode

                Rectangle {
                    color: "transparent"
                    radius: 0
                    clip: true
                    Layout.preferredWidth: Theme.dp(536)
                    Layout.preferredHeight: Theme.dp(360)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton && root.viewMode < 3 && !root.showCommands && !root.wallpaperMode) {
                                var idx = appList.currentIndex
                                if (idx >= 0 && idx < root.currentModel.length) {
                                    root.contextMenuApp = root.currentModel[idx]
                                    root.viewMode = 7
                                }
                            }
                        }
                    }

                    ListView {
                        id: appList
                        anchors.fill: parent
                        model: root.currentModel
                        currentIndex: 0

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                            NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 150 }
                        }

                        remove: Transition {
                            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutCubic }
                        }

                        section.property: "_categoryGroup"
                        section.criteria: ViewSection.FullString
                        section.delegate: Item {
                            width: appList.width
                            height: Theme.dp(28)
                            visible: !root.showCommands && launcher.groupByCategory && launcher.filterMode === 0

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(12)
                                anchors.rightMargin: Theme.dp(12)
                                spacing: Theme.dp(8)

                                Image {
                                    Layout.preferredWidth: Theme.dp(14)
                                    Layout.preferredHeight: Theme.dp(14)
                                    Layout.alignment: Qt.AlignVCenter
                                    source: Quickshell.iconPath(launcher.getCategoryIcon(section), true)
                                    fillMode: Image.PreserveAspectFit
                                    visible: status === Image.Ready
                                }

                                Text {
                                    text: section
                                    color: Theme.accent
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(9 * s)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: Theme.border
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }

                        delegate: Rectangle {
                            width: appList.width
                            height: root.itemH
                            color: appList.currentIndex === index
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                : mouseArea.containsMouse
                                    ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                                    : "transparent"

                            radius: 0

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(8)
                                anchors.leftMargin: Theme.dp(12)
                                anchors.rightMargin: Theme.dp(12)
                                spacing: Theme.dp(10)

                                Item {
                                    Layout.preferredWidth: Theme.dp(28)
                                    Layout.preferredHeight: Theme.dp(28)
                                    Layout.alignment: Qt.AlignVCenter

                                    Image {
                                        anchors.fill: parent
                                        source: root.showCommands ? Quickshell.iconPath(modelData.icon, true) : launcher.getIconPath(modelData)
                                        fillMode: Image.PreserveAspectFit
                                        visible: source !== "" && status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.bgPrimary
                                        border.width: 1
                                        border.color: Theme.border
                                        radius: 0
                                        visible: !parent.children[0].visible

                                        Text {
                                            anchors.centerIn: parent
                                            text: root.showCommands ? modelData.trigger : (modelData.name ? modelData.name.charAt(0).toUpperCase() : "?")
                                            color: Theme.accent
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round(12 * s)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    Text {
                                        text: root.showCommands ? modelData.name : (modelData.name || "Unknown")
                                        color: Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round(11 * s)
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.showCommands ? modelData.desc : (modelData.id || "")
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round(8 * s)
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        opacity: 0.7
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.showCommands) {
                                        var cmd = modelData.name
                                        root.executeCommand(cmd)
                                        root.showCommands = false
                                    } else if (modelData.name === "Stellix Control") {
                                        BarPopupState.closeAll()
                                        BarPopupState.settingsOpen = true
                                        closeLauncher()
                                    } else {
                                        launcher.launchApp(modelData)
                                        closeLauncher()
                                    }
                                }
                                onEntered: appList.currentIndex = index
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: Theme.dp(6)
                        }

                        highlightMoveDuration: 100
                        flickDeceleration: 500
                        maximumFlickVelocity: 5000
                    }
                }

                Rectangle {
                    color: "transparent"
                    radius: 0
                    clip: true
                    Layout.preferredWidth: Theme.dp(504)
                    Layout.preferredHeight: Theme.dp(360)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton && root.viewMode === 1) {
                                var idx = gridView.currentIndex
                                if (idx >= 0 && idx < root.currentModel.length) {
                                    root.contextMenuApp = root.currentModel[idx]
                                    root.viewMode = 7
                                }
                            }
                        }
                    }

                    GridView {
                        id: gridView
                        anchors.fill: parent
                        model: root.currentModel
                        cellWidth: Theme.dp(72)
                        cellHeight: Theme.dp(88)
                        currentIndex: 0
                        flow: GridView.FlowLeftToRight

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                            NumberAnimation { property: "scale"; from: 0.8; to: 1; duration: 150 }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutCubic }
                        }

                        delegate: Item {
                            width: Theme.dp(72)
                            height: Theme.dp(88)

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(2)
                                color: gridView.currentIndex === index
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    : gridMouse.containsMouse
                                        ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                                        : "transparent"
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: Theme.dp(6)

                                Item {
                                    Layout.preferredWidth: Theme.dp(36)
                                    Layout.preferredHeight: Theme.dp(36)
                                    Layout.alignment: Qt.AlignHCenter

                                    Image {
                                        anchors.fill: parent
                                        source: launcher.getIconPath(modelData)
                                        fillMode: Image.PreserveAspectFit
                                        visible: source !== "" && status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.bgPrimary
                                        border.width: 1
                                        border.color: Theme.border
                                        radius: 0
                                        visible: !parent.children[0].visible

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name ? modelData.name.charAt(0).toUpperCase() : "?"
                                            color: Theme.textMuted
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round(14 * s)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                Text {
                                    text: modelData.name || "Unknown"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(9 * s)
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: Theme.dp(64)
                                }
                            }

                            MouseArea {
                                id: gridMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.LeftButton) {
                                        launcher.launchApp(modelData)
                                        closeLauncher()
                                    }
                                }
                                onEntered: gridView.currentIndex = index
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: Theme.dp(6)
                        }

                        highlightMoveDuration: 100
                        flickDeceleration: 500
                        maximumFlickVelocity: 5000
                    }
                }

                WallpaperSwitcher {
                    id: wallpaperSwitcher
                    wallpaper: root.wallpaper
                }

                PowerPopup {
                    id: powerPopup
                    onCloseRequested: {
                        root.viewMode = 0
                        searchInput.text = ""
                        launcher.searchText = ""
                    }
                }

                CalcPopup {
                    id: calcPopup
                    onCloseRequested: {
                        root.viewMode = 0
                        searchInput.text = ""
                        launcher.searchText = ""
                    }
                }

                ColorPopup {
                    id: colorPopup
                    onCloseRequested: {
                        root.viewMode = 0
                        searchInput.text = ""
                        launcher.searchText = ""
                    }
                }

                CurrencyPopup {
                    id: currencyPopup
                    onCloseRequested: {
                        root.viewMode = 0
                        searchInput.text = ""
                        launcher.searchText = ""
                    }
                }

                Rectangle {
                    color: Theme.bgSecondary
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                root.viewMode = 0
                                root.contextMenuApp = null
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(16)
                        spacing: Theme.dp(12)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(60)
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(10)
                                spacing: Theme.dp(12)

                                Item {
                                    Layout.preferredWidth: Theme.dp(40)
                                    Layout.preferredHeight: Theme.dp(40)
                                    Layout.alignment: Qt.AlignVCenter

                                    Image {
                                        anchors.fill: parent
                                        source: root.contextMenuApp ? launcher.getIconPath(root.contextMenuApp) : ""
                                        fillMode: Image.PreserveAspectFit
                                        visible: source !== "" && status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.bgPrimary
                                        border.width: 1
                                        border.color: Theme.border
                                        radius: 0
                                        visible: !parent.children[0].visible

                                        Text {
                                            anchors.centerIn: parent
                                            text: root.contextMenuApp ? (root.contextMenuApp.name ? root.contextMenuApp.name.charAt(0).toUpperCase() : "?") : "?"
                                            color: Theme.accent
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round(16 * s)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    Text {
                                        text: root.contextMenuApp ? (root.contextMenuApp.name || "Unknown") : ""
                                        color: Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round(12 * s)
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.contextMenuApp ? (root.contextMenuApp.id || "") : ""
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round(9 * s)
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        opacity: 0.7
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(36)
                            color: actLaunchMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Behavior on color { ColorAnimation { duration: 80 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(10)
                                spacing: Theme.dp(8)

                                Text { text: "arrow_right"; color: Theme.accent; font.pixelSize: Math.round(14 * s) 
                                font.family: Typography.materialSymbols
                                font.styleName: "Regular"
                                                                       }
                                Text {
                                    Layout.fillWidth: true
                                    text: "Launch"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(11 * s)
                                    font.weight: Font.Medium
                                }
                            }

                            MouseArea {
                                id: actLaunchMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (root.contextMenuApp) launcher.launchApp(root.contextMenuApp)
                                    root.viewMode = 0
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(36)
                            color: actCatMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Behavior on color { ColorAnimation { duration: 80 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(10)
                                spacing: Theme.dp(8)

                                Text { text: "folder"; color: Theme.accent; font.pixelSize: Math.round(14 * s) 
                                font.family: Typography.materialSymbols
                                font.styleName: "Regular"
                                                                       }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.contextMenuApp ? launcher.getAppCategories(root.contextMenuApp) : ""
                                    color: Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(10 * s)
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: actCatMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {}
                            }
                        }

                        Item { Layout.fillHeight: true }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(36)
                            color: actDeleteMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.15) : "transparent"
                            border.width: 1
                            border.color: Theme.danger
                            radius: 0

                            Behavior on color { ColorAnimation { duration: 80 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(10)
                                spacing: Theme.dp(8)

                                Text { text: "delete"; color: Theme.danger; font.pixelSize: Math.round(14 * s) 
                                font.family: Typography.materialSymbols
                                font.styleName: "Regular"
                                                                       }
                                Text {
                                    Layout.fillWidth: true
                                    text: "Delete"
                                    color: Theme.danger
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(11 * s)
                                    font.weight: Font.Medium
                                }
                            }

                            MouseArea {
                                id: actDeleteMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    deleteConfirmDialog.show()
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(36)
                            color: actCancelMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Behavior on color { ColorAnimation { duration: 80 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(10)
                                spacing: Theme.dp(8)

                                Text { text: "close"; color: Theme.textPrimary; font.pixelSize: Math.round(14 * s) 
                                font.family: Typography.materialSymbols
                                font.styleName: "Regular"
                                                                       }
                                Text {
                                    Layout.fillWidth: true
                                    text: "Cancel"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(11 * s)
                                    font.weight: Font.Medium
                                }
                            }

                            MouseArea {
                                id: actCancelMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    root.viewMode = 0
                                    root.contextMenuApp = null
                                }
                            }
                        }
                    }
                }

                ClipboardPopup {
                    id: clipboardPopup
                    service: root.clipboardService
                    onCloseRequested: {
                        root.viewMode = 0
                        searchInput.text = ""
                        launcher.searchText = ""
                        closeLauncher()
                    }
                }
            }

            // --- Footer Navigation Section ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(28)
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                radius: 0
                visible: !root.showCommands && !root.wallpaperMode && root.viewMode !== 5 && root.viewMode !== 6 && root.viewMode !== 7 && root.viewMode !== 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.dp(12)
                    anchors.rightMargin: Theme.dp(12)
                    spacing: Theme.dp(10)

                    FooterHint { label: "Navigate"; keys: "↑/↓" }
                    FooterSeparator {}
                    FooterHint { label: root.viewMode === 4 ? "Copy" : "Launch"; keys: "Enter" }
                    FooterSeparator {}
                    FooterHint { label: "Focus"; keys: "Tab" }
                    FooterSeparator {}
                    FooterHint { label: root.viewMode === 0 ? "Action" : "Back"; keys: root.viewMode === 0 ? "Ctrl" : "Shift+A" }
                    FooterSeparator {}
                    FooterHint { label: "Close"; keys: "Esc" }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "Stellix Launcher"
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(8 * s)
                        font.weight: Font.Bold
                        opacity: 0.6
                    }
                }
            }

            // --- Footer Navigation Section (Context Menu) ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(28)
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                radius: 0
                visible: root.viewMode === 7

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.dp(12)
                    anchors.rightMargin: Theme.dp(12)
                    spacing: Theme.dp(10)

                    FooterHint { label: "Launch"; keys: "Enter" }
                    FooterSeparator {}
                    FooterHint { label: "Cancel"; keys: "Esc" }
                    
                    Item { Layout.fillWidth: true }
                }
            }
        }
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

    Rectangle {
        id: deleteConfirmDialog
        visible: false
        z: 200
        width: Theme.dp(320)
        height: deleteCol.implicitHeight + Theme.dp(24)
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        function show() {
            deletePassword = ""
            deleteError = ""
            visible = true
            Qt.callLater(function() { deletePasswordField.forceActiveFocus() })
        }

        function hide() {
            visible = false
        }

        function doDelete() {
            if (!deleteConfirmDialog.deletePassword || deleteConfirmDialog.deletePassword.length === 0) {
                deleteConfirmDialog.deleteError = "Password is required"
                return
            }
            if (!root.contextMenuApp) return

            var appName = root.contextMenuApp.name || ""
            var appExec = root.contextMenuApp.exec || ""
            var appDesktop = root.contextMenuApp.desktopFilePath || ""

            deleteConfirmDialog.deleteError = ""
            deleteConfirmDialog.visible = false

            Quickshell.execDetached({
                command: ["sh", "-c",
                    "echo '" + deleteConfirmDialog.deletePassword.replace(/'/g, "'\\''") + "' | pkexec --disable-internal-agent sh -c '" +
                    "if command -v flatpak >/dev/null 2>&1 && flatpak list --columns=application | grep -qF \"" + appExec + "\"; then " +
                    "  flatpak uninstall -y \"" + appExec + "\"; " +
                    "elif command -v apt >/dev/null 2>&1 && dpkg -l | grep -qF \"" + appExec + "\"; then " +
                    "  apt remove -y \"" + appExec + "\"; " +
                    "elif [ -f \"" + appDesktop + "\" ]; then " +
                    "  rm -f \"" + appDesktop + "\" && update-desktop-database ~/.local/share/applications/ 2>/dev/null; " +
                    "else " +
                    "  echo \"Could not determine package for " + appName + "\"; " +
                    "fi'"
                ]
            })
        }

        property string deletePassword: ""
        property string deleteError: ""

        MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) { mouse.accepted = true }
        }

        ColumnLayout {
            id: deleteCol
            anchors.fill: parent
            anchors.margins: Theme.dp(12)
            spacing: Theme.dp(10)

            Text {
                Layout.fillWidth: true
                text: "Delete " + (root.contextMenuApp ? root.contextMenuApp.name : "app") + "?"
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(12 * s)
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true
                text: "This will uninstall the application. This action cannot be undone."
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(9 * s)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(32)
                color: Theme.bgPrimary
                border.width: 1
                border.color: deleteConfirmDialog.deleteError.length > 0 ? Theme.danger : Theme.border
                radius: 0

                TextField {
                    id: deletePasswordField
                    anchors.fill: parent
                    anchors.margins: Theme.dp(8)
                    text: deleteConfirmDialog.deletePassword
                    echoMode: TextInput.Password
                    placeholderText: "Password (required)"
                    placeholderTextColor: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(11 * s)
                    color: Theme.textPrimary
                    background: Item {}
                    verticalAlignment: TextInput.AlignVCenter

                    onTextChanged: deleteConfirmDialog.deletePassword = text
                    onAccepted: deleteConfirmDialog.doDelete()
                }
            }

            Text {
                visible: deleteConfirmDialog.deleteError.length > 0
                Layout.fillWidth: true
                text: deleteConfirmDialog.deleteError
                color: Theme.danger
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(9 * s)
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(30)
                    color: deleteCancelMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : "transparent"
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Behavior on color { ColorAnimation { duration: 80 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(10 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: deleteCancelMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: deleteConfirmDialog.hide()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(30)
                    color: deleteConfirmMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.25) : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1)
                    border.width: 1
                    border.color: Theme.danger
                    radius: 0

                    Behavior on color { ColorAnimation { duration: 80 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Delete"
                        color: Theme.danger
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(10 * s)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: deleteConfirmMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: deleteConfirmDialog.doDelete()
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
            // Only handle keys if we are in main views (0, 1) or context menu (7)
            if (root.viewMode >= 3 && root.viewMode !== 7) {
                event.accepted = false;
                return;
            }

            if (event.key === Qt.Key_Escape) {
                if (root.viewMode === 7) {
                    root.viewMode = 0
                    root.contextMenuApp = null
                } else if (deleteConfirmDialog.visible) {
                    deleteConfirmDialog.hide()
                } else {
                    closeLauncher()
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.viewMode === 7) {
                    if (root.contextMenuApp) launcher.launchApp(root.contextMenuApp)
                    root.viewMode = 0
                } else if (appList.currentIndex >= 0 && appList.currentIndex < root.currentModel.length) {
                    launcher.launchApp(root.currentModel[appList.currentIndex])
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                appList.currentIndex = Math.min(appList.currentIndex + 1, root.currentModel.length - 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                event.accepted = true
            } else if (event.key === Qt.Key_Control) {
                if (root.viewMode < 3 && !root.showCommands && !root.wallpaperMode) {
                    var idx = appList.currentIndex
                    if (idx >= 0 && idx < root.currentModel.length) {
                        root.contextMenuApp = root.currentModel[idx]
                        root.viewMode = 7
                    }
                    event.accepted = true
                }
            }
        }
    }

    function closeLauncher() {
        BarPopupState.launcherOpen = false
        launcher.close()
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function() {
                searchInput.forceActiveFocus()
            })
        }
    }
}
