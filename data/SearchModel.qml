pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var settingsModel: [
        // Category 0: Personalization
        { cat: 0, section: "Personalization", title: "Wallpaper Gallery", desc: "Browse cycle and apply wallpaper backgrounds", type: "action", action: "wallpaper_gallery" },
        { cat: 0, section: "Personalization", title: "Wallpaper Directory", desc: "Change wallpaper folder path directory location", type: "action", action: "wallpaper_dir" },
        { cat: 0, section: "Personalization", title: "Transition Duration", desc: "Wallpaper transition speed animation duration seconds", type: "slider", key: "wp_duration" },
        { cat: 0, section: "Personalization", title: "Transition FPS", desc: "Frames per second wallpaper animation frame rate", type: "slider", key: "wp_fps" },
        { cat: 0, section: "Personalization", title: "Dark Mode", desc: "Toggle light or dark theme color preference", type: "toggle", key: "dark_mode" },
        { cat: 0, section: "Personalization", title: "Matugen Theme", desc: "Color extraction algorithm scheme type color palette", type: "action", action: "matugen" },
        { cat: 0, section: "Personalization", title: "Scheme Type", desc: "Extraction algorithm vibrant expressive tonal color scheme", type: "select", key: "scheme_type" },
        { cat: 0, section: "Personalization", title: "Blur Radius", desc: "Glass effect intensity blur background frosted glass", type: "slider", key: "blur" },
        { cat: 0, section: "Personalization", title: "Transparency", desc: "Panel background opacity transparent clear see-through", type: "slider", key: "transparency" },

        // Category 9: Bar Layout
        { cat: 9, section: "Bar", title: "Bar Position", desc: "Move bar to top or bottom edge of screen", type: "toggle", key: "bar_position" },
        { cat: 9, section: "Bar", title: "Bar Height", desc: "Adjust panel height size in pixels", type: "slider", key: "bar_height" },
        { cat: 9, section: "Bar", title: "Bar Opacity", desc: "Bar background transparency level", type: "slider", key: "bar_opacity" },
        { cat: 9, section: "Bar", title: "Bar Border", desc: "Show border line on bar edge", type: "toggle", key: "bar_border" },
        { cat: 9, section: "Bar", title: "Item Separators", desc: "Show dividers between bar items", type: "toggle", key: "separators" },
        { cat: 9, section: "Bar", title: "Rearrange Items", desc: "Move items between bar sections left center right layout", type: "action", action: "bar_items" },
        { cat: 9, section: "Bar", title: "Hide App Launcher", desc: "Show or hide launcher button on bar", type: "toggle", key: "hide_launcher" },
        { cat: 9, section: "Bar", title: "Hide Workspace", desc: "Show or hide workspace indicator on bar", type: "toggle", key: "hide_workspace" },
        { cat: 9, section: "Bar", title: "Hide Clock", desc: "Show or hide clock display on bar", type: "toggle", key: "hide_clock" },
        { cat: 9, section: "Bar", title: "System Tray", desc: "Show or hide tray icons on bar", type: "toggle", key: "systray" },
        { cat: 9, section: "Bar", title: "System Tray Options", desc: "Show all icons collapse limit arrow tray icons", type: "expand", key: "systray_options" },
        { cat: 9, section: "Bar", title: "Show All Tray Icons", desc: "Display all system tray icons on bar", type: "toggle", key: "systray_show_all" },
        { cat: 9, section: "Bar", title: "Tray Collapse Limit", desc: "Maximum icons before overflow collapse limit", type: "slider", key: "systray_collapse" },
        { cat: 9, section: "Bar", title: "Weather Bar", desc: "Show or hide weather widget in bar", type: "toggle", key: "weather_bar" },
        { cat: 9, section: "Bar", title: "Weather Options", desc: "Customize weather bar icon temp desc layout display", type: "expand", key: "weather_options" },
        { cat: 9, section: "Bar", title: "Weather Show Icon", desc: "Show weather icon in bar", type: "toggle", key: "weather_icon" },
        { cat: 9, section: "Bar", title: "Weather Show Temp", desc: "Show temperature in bar", type: "toggle", key: "weather_temp" },
        { cat: 9, section: "Bar", title: "Weather Show Desc", desc: "Show weather description text in bar", type: "toggle", key: "weather_desc" },
        { cat: 9, section: "Bar", title: "Weather Bar Layout", desc: "Weather display style icon temp desc layout bar", type: "select", key: "weather_layout_bar" },
        { cat: 9, section: "Bar", title: "Widget Slots Info", desc: "How widget slots work positions right bar section", type: "view", action: "slot_info" },
        { cat: 9, section: "Bar", title: "Slot Configuration", desc: "Assign widgets to each position or hide them", type: "expand", key: "slot_config" },
        { cat: 9, section: "Bar", title: "Slot A Position", desc: "First position leftmost widget in right bar", type: "select", key: "slot_a" },
        { cat: 9, section: "Bar", title: "Slot B Position", desc: "Second position middle widget in right bar", type: "select", key: "slot_b" },
        { cat: 9, section: "Bar", title: "Slot C Position", desc: "Third position rightmost widget in right bar", type: "select", key: "slot_c" },
        { cat: 9, section: "Bar", title: "Bar Clock Options", desc: "Clock format 24h seconds date weekday year display", type: "expand", key: "clock_options" },
        { cat: 9, section: "Bar", title: "Bar Clock Format", desc: "Time display format options", type: "select", key: "clock_format" },
        { cat: 9, section: "Bar", title: "Bar 24-Hour Clock", desc: "Use 24-hour time format", type: "toggle", key: "clock_24h" },
        { cat: 9, section: "Bar", title: "Bar Clock Seconds", desc: "Show seconds in clock display", type: "toggle", key: "clock_seconds" },
        { cat: 9, section: "Bar", title: "Battery Options", desc: "Battery style percentage charging warning level", type: "expand", key: "battery_options" },
        { cat: 9, section: "Bar", title: "Battery Style", desc: "Battery indicator style icon display", type: "select", key: "battery_style" },
        { cat: 9, section: "Bar", title: "Battery Charging", desc: "Show charging indicator for battery", type: "toggle", key: "battery_charging" },
        { cat: 9, section: "Bar", title: "Low Battery Threshold", desc: "Warning level for low battery percentage", type: "slider", key: "battery_threshold" },
        { cat: 9, section: "Bar", title: "Workspace Count", desc: "Number of workspace dots displayed on bar", type: "slider", key: "workspace_count" },
        { cat: 9, section: "Bar", title: "Layout Presets", desc: "Quick apply predefined bar layout presets", type: "action", action: "bar_presets" },
        { cat: 9, section: "Bar", title: "Calendar Opacity", desc: "Calendar popup transparency level", type: "slider", key: "calendar_opacity" },
        { cat: 9, section: "Bar", title: "Notification Opacity", desc: "Notification panel transparency level", type: "slider", key: "notif_opacity" },
        { cat: 9, section: "Bar", title: "System Tray Opacity", desc: "Tray menu transparency level", type: "slider", key: "systray_opacity" },
        { cat: 9, section: "Bar", title: "Reset Bar Settings", desc: "Restore all bar settings to default values", type: "action", action: "reset_bar" },

        // Category 10: Screen Widgets
        { cat: 10, section: "Desktop", title: "Desktop Clock", desc: "Show clock widget on desktop screen", type: "toggle", key: "screen_clock" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Size", desc: "Scale of desktop clock widget size", type: "slider", key: "clock_scale" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Position", desc: "X Y coordinates location reset clock position", type: "action", action: "clock_pos" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Color", desc: "Accent white black text color mode", type: "select", key: "clock_color" },
        { cat: 10, section: "Desktop", title: "Desktop Clock 24-Hour", desc: "Use 24-hour format on desktop clock", type: "toggle", key: "clock_24h_desktop" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Seconds", desc: "Show seconds on desktop clock", type: "toggle", key: "clock_seconds_desktop" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Date", desc: "Show date on desktop clock", type: "toggle", key: "clock_date" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Weekday", desc: "Show weekday on desktop clock", type: "toggle", key: "clock_weekday" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Year", desc: "Show year on desktop clock", type: "toggle", key: "clock_year" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Alignment", desc: "Left center right text alignment position", type: "select", key: "clock_alignment" },
        { cat: 10, section: "Desktop", title: "Desktop Clock Opacity", desc: "Desktop clock transparency level", type: "slider", key: "clock_opacity" },
        { cat: 10, section: "Desktop", title: "System Stats", desc: "CPU RAM Memory Network usage statistics", type: "toggle", key: "screen_stats" },
        { cat: 10, section: "Desktop", title: "Stats Layout", desc: "Default inline compact layout mode", type: "select", key: "stats_layout" },
        { cat: 10, section: "Desktop", title: "Stats Color Mode", desc: "Accent white black text color mode", type: "select", key: "stats_color" },
        { cat: 10, section: "Desktop", title: "Show CPU", desc: "Display CPU usage in stats widget", type: "toggle", key: "stats_cpu" },
        { cat: 10, section: "Desktop", title: "Show GPU", desc: "Display GPU usage in stats widget", type: "toggle", key: "stats_gpu" },
        { cat: 10, section: "Desktop", title: "Show Memory", desc: "Display RAM usage in stats widget", type: "toggle", key: "stats_memory" },
        { cat: 10, section: "Desktop", title: "Show Network", desc: "Display network speed in stats widget", type: "toggle", key: "stats_network" },
        { cat: 10, section: "Desktop", title: "Stats Size", desc: "Scale of system stats widget size", type: "slider", key: "stats_scale" },
        { cat: 10, section: "Desktop", title: "Stats Position", desc: "Reset system stats widget position", type: "action", action: "stats_pos" },
        { cat: 10, section: "Desktop", title: "Stats Opacity", desc: "System stats transparency level", type: "slider", key: "stats_opacity" },
        { cat: 10, section: "Desktop", title: "Desktop Weather", desc: "Show current weather temperature widget", type: "toggle", key: "screen_weather" },
        { cat: 10, section: "Desktop", title: "Desktop Weather Layout", desc: "Default compact inline vertical weather layout", type: "select", key: "weather_layout" },
        { cat: 10, section: "Desktop", title: "Desktop Weather City", desc: "Change city location search weather area", type: "text", key: "weather_city" },
        { cat: 10, section: "Desktop", title: "Desktop Weather Size", desc: "Scale of weather widget size", type: "slider", key: "weather_scale" },
        { cat: 10, section: "Desktop", title: "Desktop Weather Position", desc: "Reset weather widget position", type: "action", action: "weather_pos" },
        { cat: 10, section: "Desktop", title: "Desktop Weather Opacity", desc: "Weather widget transparency level", type: "slider", key: "weather_opacity" },
        { cat: 10, section: "Desktop", title: "Quick Actions", desc: "Power utility shortcuts buttons", type: "toggle", key: "screen_qa" },
        { cat: 10, section: "Desktop", title: "Quick Actions Pinned", desc: "Keep quick actions always visible sticky", type: "toggle", key: "qa_pinned" },
        { cat: 10, section: "Desktop", title: "Quick Actions Radius", desc: "Roundness of quick action buttons corners", type: "slider", key: "qa_radius" },
        { cat: 10, section: "Desktop", title: "Quick Actions Size", desc: "Scale of quick action buttons size", type: "slider", key: "qa_scale" },
        { cat: 10, section: "Desktop", title: "Quick Actions Position", desc: "Reset quick actions position", type: "action", action: "qa_pos" },
        { cat: 10, section: "Desktop", title: "Quick Actions Opacity", desc: "Quick actions transparency level", type: "slider", key: "qa_opacity" },
        { cat: 10, section: "Desktop", title: "Now Playing", desc: "Music player widget desktop multimedia", type: "toggle", key: "screen_np" },
        { cat: 10, section: "Desktop", title: "Now Playing Size", desc: "Scale of now playing widget size", type: "slider", key: "np_scale" },
        { cat: 10, section: "Desktop", title: "Now Playing Position", desc: "Reset now playing widget position", type: "action", action: "np_pos" },
        { cat: 10, section: "Desktop", title: "Now Playing Opacity", desc: "Now playing transparency level", type: "slider", key: "np_opacity" },
        { cat: 10, section: "Desktop", title: "Standalone Equalizer", desc: "Independent audio visualizer wave visual", type: "toggle", key: "screen_eq" },
        { cat: 10, section: "Desktop", title: "Equalizer Style", desc: "Wave bars bars-fill dots visualizer style", type: "select", key: "eq_style" },
        { cat: 10, section: "Desktop", title: "Equalizer Color Mode", desc: "Accent white black custom visualizer color", type: "select", key: "eq_color" },
        { cat: 10, section: "Desktop", title: "Equalizer Custom Color", desc: "Custom hex color for equalizer visualizer", type: "text", key: "eq_custom_color" },
        { cat: 10, section: "Desktop", title: "Equalizer Double Wave", desc: "Double wave effect for wave style", type: "toggle", key: "eq_double_wave" },
        { cat: 10, section: "Desktop", title: "Equalizer Mirror", desc: "Mirror mode for equalizer visualizer", type: "toggle", key: "eq_mirror" },
        { cat: 10, section: "Desktop", title: "Equalizer Fill", desc: "Line fill transparency for equalizer", type: "slider", key: "eq_fill" },
        { cat: 10, section: "Desktop", title: "Equalizer Size", desc: "Scale of equalizer widget size", type: "slider", key: "eq_scale" },
        { cat: 10, section: "Desktop", title: "Equalizer Position", desc: "Reset equalizer widget position", type: "action", action: "eq_pos" },
        { cat: 10, section: "Desktop", title: "Equalizer Opacity", desc: "Equalizer transparency level", type: "slider", key: "eq_opacity" },
        { cat: 10, section: "Desktop", title: "Widget Opacity", desc: "Global transparency for all desktop widgets", type: "slider", key: "widgets_opacity" },
        { cat: 10, section: "Desktop", title: "System Indicators", desc: "Show volume brightness pin overlay indicators", type: "toggle", key: "indicators" },

        // Category 2: Audio
        { cat: 2, section: "Audio", title: "Master Volume", desc: "Main system output level sound volume speaker", type: "slider", key: "master_vol" },
        { cat: 2, section: "Audio", title: "Microphone", desc: "Input sensitivity level mic sound recording", type: "slider", key: "mic_vol" },
        { cat: 2, section: "Audio", title: "Audio Mixer", desc: "Volume control per application volume mixer per-app", type: "view", action: "audio_mixer" },

        // Category 3: Wi-Fi
        { cat: 3, section: "Wi-Fi", title: "Wi-Fi Status", desc: "Wireless network toggle internet wifi ssid signal", type: "toggle", key: "wifi" },
        { cat: 3, section: "Wi-Fi", title: "Network Info", desc: "IP address interface details connection network", type: "view", action: "net_info" },
        { cat: 3, section: "Wi-Fi", title: "Connect to Network", desc: "Join saved or new wifi network connection", type: "action", action: "wifi_connect" },
        { cat: 3, section: "Wi-Fi", title: "Saved Networks", desc: "View managed saved wifi networks list", type: "view", action: "wifi_saved" },

        // Category 8: Bluetooth
        { cat: 8, section: "Bluetooth", title: "Bluetooth", desc: "Bluetooth power pairing wireless device", type: "toggle", key: "bluetooth" },
        { cat: 8, section: "Bluetooth", title: "Bluetooth Devices", desc: "Paired and available bluetooth devices list", type: "view", action: "bt_devices" },
        { cat: 8, section: "Bluetooth", title: "Pair Device", desc: "Search and pair new bluetooth device", type: "action", action: "bt_pair" },

        // Category 4: Keybindings
        { cat: 4, section: "Keybinds", title: "Terminal Bind", desc: "Shortcut for kitty terminal quick access", type: "keybind", key: "terminal" },
        { cat: 4, section: "Keybinds", title: "Launcher Bind", desc: "Shortcut for app launcher quick open", type: "keybind", key: "launcher" },
        { cat: 4, section: "Keybinds", title: "Clipboard Bind", desc: "Shortcut for clipboard manager quick access", type: "keybind", key: "clipboard" },
        { cat: 4, section: "Keybinds", title: "Settings Bind", desc: "Shortcut for system settings quick open", type: "keybind", key: "settings" },
        { cat: 4, section: "Keybinds", title: "Guide Bind", desc: "Shortcut for shortcut guide quick help", type: "keybind", key: "guide" },
        { cat: 4, section: "Keybinds", title: "Files Bind", desc: "Shortcut for file manager quick open", type: "keybind", key: "files" },
        { cat: 4, section: "Keybinds", title: "Browser Bind", desc: "Shortcut for web browser quick open", type: "keybind", key: "browser" },
        { cat: 4, section: "Keybinds", title: "VS Code Bind", desc: "Shortcut for VS Code editor quick open", type: "keybind", key: "code" },
        { cat: 4, section: "Keybinds", title: "Discord Bind", desc: "Shortcut for Discord chat quick open", type: "keybind", key: "discord" },
        { cat: 4, section: "Keybinds", title: "Steam Bind", desc: "Shortcut for Steam gaming quick open", type: "keybind", key: "steam" },
        { cat: 4, section: "Keybinds", title: "OBS Bind", desc: "Shortcut for OBS Studio record stream", type: "keybind", key: "obs" },
        { cat: 4, section: "Keybinds", title: "Kill Window Bind", desc: "Shortcut to kill active window force close", type: "keybind", key: "kill" },
        { cat: 4, section: "Keybinds", title: "Screenshot Bind", desc: "Shortcut for screenshot screen capture", type: "keybind", key: "screenshot" },
        { cat: 4, section: "Keybinds", title: "Workspace Switcher Bind", desc: "Shortcut for workspace switcher quick change", type: "keybind", key: "ws_tab" },
        { cat: 4, section: "Keybinds", title: "Fullscreen Bind", desc: "Shortcut to toggle fullscreen mode", type: "keybind", key: "fullscreen" },
        { cat: 4, section: "Keybinds", title: "Floating Bind", desc: "Shortcut to toggle floating window mode", type: "keybind", key: "floating" },

        // Category 5: System
        { cat: 5, section: "System", title: "Shell Reload", desc: "Hot-reload Quickshell refresh restart shell", type: "action", action: "restart_shell" },
        { cat: 5, section: "System", title: "Power Menu", desc: "Shutdown Restart Logout power options", type: "action", action: "power_menu" },
        { cat: 5, section: "System", title: "System Info", desc: "Kernel CPU RAM Uptime hardware information", type: "view", action: "sys_info" },
        { cat: 5, section: "System", title: "Show Welcome Screen", desc: "Toggle welcome screen on startup display", type: "toggle", key: "welcome_screen" },
        { cat: 5, section: "System", title: "Floating Settings", desc: "Open settings as floating window mode", type: "toggle", key: "settings_floating" },

        // Category 6: About
        { cat: 6, section: "About", title: "About Stellix", desc: "Version info credits about stellix shell", type: "view", action: "about" }
    ]

    function search(query) {
        if (!query || query.trim() === "") return []
        var results = []
        var qRaw = query.toLowerCase().trim()
        var qParts = qRaw.split(/\s+/)

        if (qRaw === "") return []

        for (var i = 0; i < root.settingsModel.length; i++) {
            var item = root.settingsModel[i]
            var title = item.title.toLowerCase()
            var desc = item.desc.toLowerCase()
            var allMatch = true
            for (var j = 0; j < qParts.length; j++) {
                var p = qParts[j]
                if (title.indexOf(p) === -1 && desc.indexOf(p) === -1) {
                    allMatch = false
                    break
                }
            }
            if (allMatch) results.push(item)
        }

        results.sort(function(a, b) {
            var aTitle = a.title.toLowerCase()
            var bTitle = b.title.toLowerCase()
            if (aTitle === qRaw) return -1
            if (bTitle === qRaw) return 1
            if (aTitle.indexOf(qRaw) === 0 && bTitle.indexOf(qRaw) !== 0) return -1
            if (bTitle.indexOf(qRaw) === 0 && aTitle.indexOf(qRaw) !== 0) return 1
            if (a.section !== b.section) return a.section.localeCompare(b.section)
            return 0
        })

        return results
    }
}
