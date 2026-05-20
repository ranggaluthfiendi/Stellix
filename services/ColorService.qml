import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config
import qs.services

Item {
    id: root

    property string currentScheme: "dark"
    property string currentType: "scheme-tonal-spot"
    property bool isGenerating: false
    property string lastWallpaper: ""
    property bool initDone: false
    property int lastMatugenRun: 0

    readonly property string matugenConf: Quickshell.env("HOME") + "/.config/matugen/matugen.toml"
    readonly property string themeOutput: Quickshell.env("HOME") + "/.config/quickshell/config/Theme.qml"
    readonly property string savedataPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/color-state.json"

    readonly property var schemeTypes: [
        { name: "Tonal Spot", value: "scheme-tonal-spot", desc: "Balanced, natural tones" },
        { name: "Content", value: "scheme-content", desc: "Based on image content" },
        { name: "Expressive", value: "scheme-expressive", desc: "Bold, vibrant colors" },
        { name: "Fidelity", value: "scheme-fidelity", desc: "True to original colors" },
        { name: "Fruit Salad", value: "scheme-fruit-salad", desc: "Playful, mixed colors" },
        { name: "Monochrome", value: "scheme-monochrome", desc: "Single color variations" },
        { name: "Neutral", value: "scheme-neutral", desc: "Subtle, muted tones" },
        { name: "Vibrant", value: "scheme-vibrant", desc: "High saturation colors" }
    ]

    readonly property string currentTypeName: {
        for (var i = 0; i < schemeTypes.length; i++) {
            if (schemeTypes[i].value === root.currentType) {
                return schemeTypes[i].name
            }
        }
        return "Unknown"
    }

    StdioCollector { id: readCollector }
    StdioCollector { id: writeCollector }

    Process {
        id: readProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim())
                    if (data.scheme) root.currentScheme = data.scheme
                    if (data.type) root.currentType = data.type
                } catch (e) {}
                root.initDone = true
            }
        }
    }

    Process {
        id: writeProcess
        stdout: writeCollector
        stderr: writeCollector
    }

    function saveState() {
        if (!root.initDone) return

        var json = JSON.stringify({
            scheme: root.currentScheme,
            type: root.currentType
        }).replace(/'/g, "'\\''")

        writeProcess.exec(["sh", "-c",
            "mkdir -p '" + root.savedataPath.replace(/\/[^\/]+$/, "") + "' && echo '" + json + "' > '" + root.savedataPath + "'"
        ])
    }

    function loadState() {
        var fallback = JSON.stringify({
            scheme: "dark",
            type: "scheme-tonal-spot"
        }).replace(/'/g, "'\\''")

        readProcess.exec(["sh", "-c",
            "cat '" + root.savedataPath + "' 2>/dev/null || echo '" + fallback + "'"
        ])
    }

    Component.onCompleted: {
        root.initDone = true
        root.loadState()

        // Sync Theme.isDark with loaded state
        Theme.isDark = (root.currentScheme === "dark")
        GlobalState.currentScheme = root.currentScheme
    }

    onCurrentSchemeChanged: {
        root.saveState()
    }

    onCurrentTypeChanged: {
        root.saveState()
    }

    // Listen to Theme.isDark changes and run matugen + reload
    Connections {
        target: Theme
        function onIsDarkChanged() {
            if (!root.initDone) return
            var newScheme = Theme.schemeName
            if (newScheme !== root.currentScheme) {
                root.currentScheme = newScheme
                root.runMatugenAndReload()
            }
        }
    }

    StdioCollector { id: matugenCollector }

    Process {
        id: matugenProcess
        stdout: matugenCollector
        stderr: matugenCollector
        onExited: function(exitCode, exitStatus) {
            var output = matugenCollector.text.trim()
            root.isGenerating = false

            if (exitCode === 0) {
                Quickshell.reload(false)
            } else {
                // Matugen failed, silently reload anyway
            }
        }
    }

    function runMatugenAndReload() {
        var now = new Date().getTime()
        if (root.isGenerating || (now - root.lastMatugenRun < 1500)) return
        root.lastMatugenRun = now

        var targetPath = root.lastWallpaper
        if (!targetPath) {
            if (wallpaper.currentWallpaperPath && wallpaper.currentWallpaperPath !== "") {
                targetPath = wallpaper.currentWallpaperPath
            } else if (wallpaper.wallpapers.length > 0 && wallpaper.currentIndex >= 0) {
                targetPath = wallpaper.wallpapers[wallpaper.currentIndex]
            }
        }
        if (!targetPath) {
            Quickshell.reload(false)
            return
        }

        root.isGenerating = true
        root.lastWallpaper = targetPath

        var mode = Theme.schemeName

        matugenProcess.exec(["sh", "-c",
            "matugen image '" + targetPath + "' " +
            "-m " + mode + " " +
            "-t " + root.currentType + " " +
            "-c " + root.matugenConf + " " +
            "--prefer=darkness 2>&1"
        ])
    }

    function extractFromWallpaper(path) {
        var now = new Date().getTime()
        if (root.isGenerating || (now - root.lastMatugenRun < 1500)) return
        root.lastMatugenRun = now

        var targetPath = path || root.lastWallpaper
        if (!targetPath) {
            if (wallpaper.currentWallpaperPath && wallpaper.currentWallpaperPath !== "") {
                targetPath = wallpaper.currentWallpaperPath
            } else if (wallpaper.wallpapers.length > 0 && wallpaper.currentIndex >= 0) {
                targetPath = wallpaper.wallpapers[wallpaper.currentIndex]
            }
        }
        if (!targetPath) {
            return
        }

        root.isGenerating = true
        root.lastWallpaper = targetPath

        var mode = Theme.schemeName

        matugenProcess.exec(["sh", "-c",
            "matugen image '" + targetPath + "' " +
            "-m " + mode + " " +
            "-t " + root.currentType + " " +
            "-c " + root.matugenConf + " " +
            "--prefer=darkness 2>&1"
        ])
    }

    function toggleMode() {
        Theme.toggleMode()
    }

    function setMode(mode) {
        if (mode === "dark" || mode === "light") {
            Theme.setLightMode(mode === "light")
        }
    }

    function cycleType() {
        var idx = -1
        for (var i = 0; i < schemeTypes.length; i++) {
            if (schemeTypes[i].value === root.currentType) {
                idx = i
                break
            }
        }
        root.currentType = schemeTypes[(idx + 1) % schemeTypes.length].value
        extractFromWallpaper("")
    }

    function setType(type) {
        root.currentType = type
        extractFromWallpaper("")
    }

    function applyTheme() {
        extractFromWallpaper("")
    }

    function applySystemTheme() {
        applyProcess.exec(["sh", "-c",
            "bash " + Quickshell.env("HOME") + "/.config/matugen/apply-theme.sh " + root.currentScheme + " " + root.lastWallpaper + " 2>&1"
        ])
    }

    StdioCollector { id: applyCollector }

    Process {
        id: applyProcess
        stdout: applyCollector
        stderr: applyCollector
        onExited: function(exitCode, exitStatus) {
            var output = applyCollector.text.trim()
            if (exitCode === 0) {
            } else {
            }
        }
    }
}
