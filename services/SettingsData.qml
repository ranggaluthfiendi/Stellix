import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: root

    readonly property string savePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/settings-state.json"

    // Sidebar state
    property bool appearanceExp: true
    property bool connectivityExp: true
    property bool workspaceExp: true
    property bool systemExp: true

    property bool showWelcomeScreen: true
    property bool settingsFloating: false

    onAppearanceExpChanged: save()
    onConnectivityExpChanged: save()
    onWorkspaceExpChanged: save()
    onSystemExpChanged: save()
    onShowWelcomeScreenChanged: save()
    onSettingsFloatingChanged: save()

    function save() {
        var data = {
            appearanceExp: root.appearanceExp,
            connectivityExp: root.connectivityExp,
            workspaceExp: root.workspaceExp,
            systemExp: root.systemExp,
            showWelcomeScreen: root.showWelcomeScreen,
            settingsFloating: root.settingsFloating
        }
        var json = JSON.stringify(data)
        writeProcess.exec(["sh", "-c", "mkdir -p $(dirname '" + root.savePath + "') && echo '" + json + "' > '" + root.savePath + "'"])
    }

    function load() {
        readProcess.exec(["cat", root.savePath])
    }

    Process {
        id: writeProcess
    }

    Process {
        id: readProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim())
                    if (data.hasOwnProperty("appearanceExp")) root.appearanceExp = data.appearanceExp
                    if (data.hasOwnProperty("connectivityExp")) root.connectivityExp = data.connectivityExp
                    if (data.hasOwnProperty("workspaceExp")) root.workspaceExp = data.workspaceExp
                    if (data.hasOwnProperty("systemExp")) root.systemExp = data.systemExp
                    if (data.hasOwnProperty("showWelcomeScreen")) root.showWelcomeScreen = data.showWelcomeScreen
                    if (data.hasOwnProperty("settingsFloating")) root.settingsFloating = data.settingsFloating
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: load()

    readonly property var settingsModel: [
        // Category 0: Appearance
        { cat: 0, title: "Dark Mode", desc: "Toggle between light and dark themes", type: "toggle", key: "dark_mode" },
        { cat: 0, title: "Material Colors", desc: "Regenerate colors from current wallpaper", type: "action", action: "matugen" },
        { cat: 0, title: "Scheme Type", desc: "Extraction algorithm (Vibrant, Expressive, etc)", type: "select", key: "scheme_type" },
        { cat: 0, title: "Blur Intensity", desc: "Transparency effects depth", type: "slider", key: "blur" },
        { cat: 0, title: "Wallpaper Transition", desc: "Animation effect for wallpapers", type: "select", key: "wp_transition" },
        { cat: 0, title: "Transition Duration", desc: "Speed of wallpaper fade/swipe", type: "number", key: "wp_duration" },
        { cat: 0, title: "Glass Opacity", desc: "Transparency of shell panels", type: "slider", key: "opacity" },
        
        // Category 1: Workspaces
        { cat: 1, title: "Animations", desc: "Global system animation toggle", type: "toggle", key: "animations" },
        { cat: 1, title: "Corner Rounding", desc: "Window corner radius", type: "number", key: "rounding" },
        { cat: 1, title: "Window Shadows", desc: "Drop shadows for all windows", type: "toggle", key: "shadows" },
        { cat: 1, title: "Gaps In", desc: "Inner spacing between windows", type: "number", key: "gaps_in" },
        { cat: 1, title: "Gaps Out", desc: "Outer spacing from screen edges", type: "number", key: "gaps_out" },
        { cat: 1, title: "Border Width", desc: "Thickness of window borders", type: "number", key: "border_size" },
        { cat: 1, title: "Active Border", desc: "Color of focused window border", type: "action", action: "border_color" },
        
        // Category 2: Audio
        { cat: 2, title: "Master Volume", desc: "Main system output level", type: "slider", key: "master_vol" },
        { cat: 2, title: "Microphone", desc: "Input sensitivity level", type: "slider", key: "mic_vol" },
        { cat: 2, title: "Mute System", desc: "Silence all system sounds", type: "toggle", key: "mute_all" },
        { cat: 2, title: "App Streams", desc: "Volume control per application", type: "view", action: "audio_mixer" },
        
        // Category 3: Wi-Fi
        { cat: 3, title: "Wi-Fi Status", desc: "Wireless network connection toggle wifi ssid signal internet connectivity", type: "toggle", key: "wifi" },
        { cat: 3, title: "Wi-Fi Security", desc: "View or change network credentials password security key pass", type: "view", action: "wifi_security" },
        { cat: 3, title: "Network Info", desc: "IP address and interface details wifi ethernet connection", type: "view", action: "net_info" },

        // Category 8: Bluetooth
        { cat: 8, title: "Bluetooth", desc: "Bluetooth adapter power and devices pairing wireless", type: "toggle", key: "bluetooth" },
        { cat: 8, title: "Bluetooth Status", desc: "Check adapter and connected devices pairing", type: "view", action: "bluetooth_status" },

        // Category 4: Keybindings
        { cat: 4, title: "Terminal Bind", desc: "Shortcut for kitty terminal", type: "keybind", key: "terminal" },
        { cat: 4, title: "Launcher Bind", desc: "Shortcut for app launcher", type: "keybind", key: "launcher" },
        { cat: 4, title: "Settings Bind", desc: "Shortcut for this application", type: "keybind", key: "settings" },
        { cat: 4, title: "File Manager Bind", desc: "Shortcut for nautilus", type: "keybind", key: "files" },
        { cat: 4, title: "Kill Window", desc: "Shortcut to close active window", type: "keybind", key: "kill" },
        { cat: 4, title: "Screenshot", desc: "Shortcut for hyprshot", type: "keybind", key: "screenshot" },
        { cat: 4, title: "Workspace Tab", desc: "Shortcut for switcher", type: "keybind", key: "ws_tab" },
        
        // Category 9: Bar Layout
        { cat: 9, title: "Bar Position", desc: "Move bar to top or bottom of screen panel location", type: "toggle", key: "bar_position" },
        { cat: 9, title: "Bar Items", desc: "Rearrange items between left center right bar sections layout order", type: "action", action: "bar_items" },
        { cat: 9, title: "Hide Launcher", desc: "Show or hide app launcher button in bar", type: "toggle", key: "hide_launcher" },
        { cat: 9, title: "Hide Workspace", desc: "Show or hide workspace indicator in bar", type: "toggle", key: "hide_workspace" },
        { cat: 9, title: "Hide System Tray", desc: "Show or hide system tray icons in bar", type: "toggle", key: "hide_systray" },
        { cat: 9, title: "Hide Clock", desc: "Show or hide clock display in bar", type: "toggle", key: "hide_clock" },
        { cat: 9, title: "Clock Format", desc: "Choose time date display format", type: "select", key: "clock_format" },
        { cat: 9, title: "24 Hour Format", desc: "Use 24-hour or 12-hour time display", type: "toggle", key: "clock_24h" },
        { cat: 9, title: "Show Seconds", desc: "Display seconds in clock time", type: "toggle", key: "clock_seconds" },
        { cat: 9, title: "Battery Style", desc: "Choose battery icon percentage display style", type: "select", key: "battery_style" },
        { cat: 9, title: "Charging Indicator", desc: "Show lightning bolt when battery charging", type: "toggle", key: "battery_charging" },
        { cat: 9, title: "Low Battery Threshold", desc: "Percentage warning level for low battery", type: "slider", key: "battery_threshold" },
        { cat: 9, title: "Bar Height", desc: "Adjust bar panel height pixels size", type: "slider", key: "bar_height" },
        { cat: 9, title: "Bar Opacity", desc: "Adjust bar background transparency opacity", type: "slider", key: "bar_opacity" },
        { cat: 9, title: "Bar Border", desc: "Show border line on bar edge top bottom", type: "toggle", key: "bar_border" },
        { cat: 9, title: "Item Separators", desc: "Show dividers between bar items", type: "toggle", key: "bar_separators" },
        { cat: 9, title: "Workspace Count", desc: "Number of workspace dots to display", type: "slider", key: "workspace_count" },
        { cat: 9, title: "Reset All", desc: "Restore all bar settings to defaults", type: "action", action: "reset_all" },

        // Category 5: System
        { cat: 5, title: "Shell Restart", desc: "Hot-reload Quickshell process", type: "action", action: "restart_shell" },
        { cat: 5, title: "Hyprland Reload", desc: "Force reload compositor config", type: "action", action: "hypr_reload" },
        { cat: 5, title: "Power State", desc: "Shutdown, Restart, Logout", type: "action", action: "power_menu" },
        { cat: 5, title: "Kernel Info", desc: "Linux kernel version and build", type: "view", action: "kernel" },
        { cat: 5, title: "CPU Threads", desc: "Processor core information", type: "view", action: "cpu" },
        { cat: 5, title: "Memory Status", desc: "RAM usage and availability", type: "view", action: "ram" },
        { cat: 5, title: "Uptime", desc: "Time since last system boot", type: "view", action: "uptime" }
    ]

    function search(query) {
        if (!query || query.trim() === "") return []
        var results = []
        var qRaw = query.toLowerCase().trim()
        var qNorm = qRaw.replace(/[^a-z0-9]/g, "")
        if (qNorm === "" && qRaw === "") return []

        for (var i = 0; i < settingsModel.length; i++) {
            var item = settingsModel[i]
            var titleRaw = item.title.toLowerCase()
            var descRaw = item.desc.toLowerCase()
            
            var titleNorm = titleRaw.replace(/[^a-z0-9]/g, "")
            var descNorm = descRaw.replace(/[^a-z0-9]/g, "")
            
            // Match against normalized strings (fuzzy) OR raw strings (for single letters)
            if (titleNorm.indexOf(qNorm) !== -1 || descNorm.indexOf(qNorm) !== -1 ||
                titleRaw.indexOf(qRaw) !== -1 || descRaw.indexOf(qRaw) !== -1) {
                results.push(item)
            }
        }
        return results
    }
}
