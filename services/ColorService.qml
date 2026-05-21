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
    property var allSchemesData: ({})

    readonly property string matugenConf: Quickshell.env("HOME") + "/.config/matugen/matugen.toml"
    readonly property string savedataPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/color-state.json"
    readonly property string allSchemesPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/all-schemes.json"

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

    // FileView to watch all-schemes.json
    FileView {
        id: allSchemesFile
        path: "file://" + root.allSchemesPath
        watchChanges: true
        blockLoading: false
        onFileChanged: {
            try {
                if (allSchemesFile.text && allSchemesFile.text.length > 10) {
                    root.allSchemesData = JSON.parse(allSchemesFile.text)
                }
            } catch (e) {
                console.warn("[ColorService] Failed to parse all-schemes.json:", e)
            }
        }
    }

    function getSchemeColor(schemeValue, colorName, fallback) {
        var key = schemeValue.replace("scheme-", "")
        if (root.allSchemesData[key] && root.allSchemesData[key][colorName]) {
            var mode = Theme.schemeName
            if (root.allSchemesData[key][colorName][mode] && root.allSchemesData[key][colorName][mode].color) {
                return root.allSchemesData[key][colorName][mode].color
            }
        }
        return fallback
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

        // Run matugen on startup if wallpaper exists
        if (wallpaper.currentWallpaperPath && wallpaper.currentWallpaperPath !== "") {
            root.extractFromWallpaper(wallpaper.currentWallpaperPath)
        }
    }

    onCurrentSchemeChanged: {
        root.saveState()
    }

    onCurrentTypeChanged: {
        root.saveState()
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
                // Theme.qml will auto-reload via FileView when colors.json changes
            } else {
                console.warn("[ColorService] Matugen failed:", output)
            }
        }
    }

    function runMatugen(targetPath, mode) {
        var now = new Date().getTime()
        if (root.isGenerating || (now - root.lastMatugenRun < 1500)) return
        root.lastMatugenRun = now

        if (!targetPath) {
            console.warn("[ColorService] No wallpaper path available")
            return
        }

        root.isGenerating = true
        root.lastWallpaper = targetPath

        // Matugen will generate both dark and light variants
        matugenProcess.exec(["sh", "-c",
            "matugen image '" + targetPath + "' " +
            "-m " + mode + " " +
            "-t " + root.currentType + " " +
            "-c " + root.matugenConf + " " +
            "--prefer=darkness 2>&1"
        ])
    }

    function extractFromWallpaper(path) {
        var targetPath = path || root.lastWallpaper
        if (!targetPath) {
            if (wallpaper.currentWallpaperPath && wallpaper.currentWallpaperPath !== "") {
                targetPath = wallpaper.currentWallpaperPath
            } else if (wallpaper.wallpapers.length > 0 && wallpaper.currentIndex >= 0) {
                targetPath = wallpaper.wallpapers[wallpaper.currentIndex]
            }
        }
        if (!targetPath) {
            console.warn("[ColorService] No wallpaper found for extraction")
            return
        }

        var mode = Theme.schemeName
        root.runMatugen(targetPath, mode)

        // Also generate all schemes for preview
        root.generateAllSchemes(targetPath, mode)
    }

    function generateAllSchemes(wallpaperPath, mode) {
        if (!wallpaperPath) return
        Quickshell.execDetached({
            command: ["sh", "-c",
                "~/.config/matugen/generate-all-schemes.sh '" + wallpaperPath + "' '" + mode + "' &"
            ]
        })
    }

    function toggleMode() {
        Theme.toggleMode()
        // Matugen will be triggered via Theme.isDark change if needed
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
}
