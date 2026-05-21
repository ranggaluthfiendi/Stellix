pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services

Singleton {
    id: root

    function dp(x) { return Math.round(x * Scales.uiScale) }

    // Dark/Light mode - source of truth
    property bool isDark: true
    readonly property string schemeName: isDark ? "dark" : "light"

    // Read matugen colors using Process
    readonly property string colorsFilePath: "/home/rang/.config/quickshell/savedata/matugen-colors.json"

    StdioCollector {
        id: colorsCollector
        onStreamFinished: {
            try {
                if (this.text && this.text.length > 10) {
                    var parsed = JSON.parse(this.text)
                    root.colorsJson = parsed
                }
            } catch (e) {
                console.warn("[Theme] Failed to parse colors JSON:", e)
            }
        }
    }

    Process {
        id: colorsProcess
        stdout: colorsCollector
        stderr: colorsCollector
    }

    property var colorsJson: null

    function loadColors() {
        colorsProcess.exec(["sh", "-c", "cat '" + colorsFilePath + "' 2>/dev/null"])
    }

    // Watch for file changes using FileView (just for trigger, not for reading)
    FileView {
        id: colorsFileWatcher
        path: colorsFilePath
        watchChanges: true
        blockLoading: false
        onFileChanged: {
            Qt.callLater(loadColors)
        }
    }

    // Get color from JSON based on current mode
    function getMatugenColor(name, fallback) {
        if (!colorsJson) return fallback
        const mode = isDark ? "dark" : "light"
        try {
            if (colorsJson[mode] && colorsJson[mode][name]) {
                return colorsJson[mode][name]
            }
        } catch (e) {}
        return fallback
    }

    // Default fallback colors (dark mode)
    readonly property var defaultDarkColors: ({
        "primary": "#c9c5cc",
        "onPrimary": "#322f35",
        "primaryContainer": "#4b474e",
        "onPrimaryContainer": "#e6e1e8",
        "secondary": "#c9c5c8",
        "onSecondary": "#322f32",
        "secondaryContainer": "#4a4749",
        "onSecondaryContainer": "#e5e1e3",
        "tertiary": "#cec5ba",
        "onTertiary": "#342f28",
        "tertiaryContainer": "#4c463e",
        "onTertiaryContainer": "#eae1d5",
        "error": "#ffb4ab",
        "onError": "#690005",
        "errorContainer": "#93000a",
        "onErrorContainer": "#ffb4ab",
        "background": "#141314",
        "onBackground": "#e5e1e2",
        "surface": "#141314",
        "onSurface": "#e5e1e2",
        "surfaceContainer": "#201f20",
        "surfaceContainerHigh": "#2a292a",
        "surfaceContainerHighest": "#353435",
        "surfaceContainerLow": "#1b1a1b",
        "surfaceContainerLowest": "#0f0e0f",
        "surfaceVariant": "#47464b",
        "onSurfaceVariant": "#c9c5cb",
        "outline": "#929095",
        "outlineVariant": "#47464b",
        "inverseSurface": "#e5e1e2",
        "inverseOnSurface": "#322f30",
        "inversePrimary": "#615d64",
        "shadow": "#000000",
        "scrim": "#000000",
        "surfaceTint": "#c9c5cc",
        "surfaceBright": "#3a393a",
        "surfaceDim": "#141314"
    })

    // Default fallback colors (light mode)
    readonly property var defaultLightColors: ({
        "primary": "#615d64",
        "onPrimary": "#ffffff",
        "primaryContainer": "#e8e0e9",
        "onPrimaryContainer": "#4b474e",
        "secondary": "#605d60",
        "onSecondary": "#ffffff",
        "secondaryContainer": "#e9e1e4",
        "onSecondaryContainer": "#4a4749",
        "tertiary": "#665d51",
        "onTertiary": "#ffffff",
        "tertiaryContainer": "#ede1d4",
        "onTertiaryContainer": "#4c463e",
        "error": "#ba1a1a",
        "onError": "#ffffff",
        "errorContainer": "#ffdad6",
        "onErrorContainer": "#93000a",
        "background": "#faf8f9",
        "onBackground": "#1c1b1c",
        "surface": "#faf8f9",
        "onSurface": "#1c1b1c",
        "surfaceContainer": "#efecee",
        "surfaceContainerHigh": "#e9e7e8",
        "surfaceContainerHighest": "#e3e1e2",
        "surfaceContainerLow": "#f4f1f3",
        "surfaceContainerLowest": "#ffffff",
        "surfaceVariant": "#e4e1e6",
        "onSurfaceVariant": "#47464b",
        "outline": "#77767b",
        "outlineVariant": "#c7c5cb",
        "inverseSurface": "#313030",
        "inverseOnSurface": "#f4f0f1",
        "inversePrimary": "#c9c5cc",
        "shadow": "#000000",
        "scrim": "#000000",
        "surfaceTint": "#615d64",
        "surfaceBright": "#faf8f9",
        "surfaceDim": "#dad7d8"
    })

    // Primary theme colors - reactive to isDark and matugen JSON
    readonly property color accent: colorsJson ? getMatugenColor("primary", isDark ? defaultDarkColors.primary : defaultLightColors.primary) : (isDark ? defaultDarkColors.primary : defaultLightColors.primary)
    readonly property color accentAlt: colorsJson ? getMatugenColor("secondary", isDark ? defaultDarkColors.secondary : defaultLightColors.secondary) : (isDark ? defaultDarkColors.secondary : defaultLightColors.secondary)

    readonly property color bgPrimary: colorsJson ? getMatugenColor("surface", isDark ? defaultDarkColors.surface : defaultLightColors.surface) : (isDark ? defaultDarkColors.surface : defaultLightColors.surface)
    readonly property color bgSecondary: colorsJson ? getMatugenColor("surfaceContainer", isDark ? defaultDarkColors.surfaceContainer : defaultLightColors.surfaceContainer) : (isDark ? defaultDarkColors.surfaceContainer : defaultLightColors.surfaceContainer)
    readonly property color surface: colorsJson ? getMatugenColor("surfaceVariant", isDark ? defaultDarkColors.surfaceVariant : defaultLightColors.surfaceVariant) : (isDark ? defaultDarkColors.surfaceVariant : defaultLightColors.surfaceVariant)

    readonly property color textPrimary: colorsJson ? getMatugenColor("onSurface", isDark ? defaultDarkColors.onSurface : defaultLightColors.onSurface) : (isDark ? defaultDarkColors.onSurface : defaultLightColors.onSurface)
    readonly property color textSecondary: colorsJson ? getMatugenColor("onSurfaceVariant", isDark ? defaultDarkColors.onSurfaceVariant : defaultLightColors.onSurfaceVariant) : (isDark ? defaultDarkColors.onSurfaceVariant : defaultLightColors.onSurfaceVariant)
    readonly property color textMuted: colorsJson ? getMatugenColor("outline", isDark ? defaultDarkColors.outline : defaultLightColors.outline) : (isDark ? defaultDarkColors.outline : defaultLightColors.outline)

    readonly property color border: colorsJson ? getMatugenColor("outlineVariant", isDark ? defaultDarkColors.outlineVariant : defaultLightColors.outlineVariant) : (isDark ? defaultDarkColors.outlineVariant : defaultLightColors.outlineVariant)
    readonly property color accentSoft: colorsJson ? getMatugenColor("primaryContainer", isDark ? defaultDarkColors.primaryContainer : defaultLightColors.primaryContainer) : (isDark ? defaultDarkColors.primaryContainer : defaultLightColors.primaryContainer)

    readonly property color success: colorsJson ? getMatugenColor("tertiary", isDark ? defaultDarkColors.tertiary : defaultLightColors.tertiary) : (isDark ? defaultDarkColors.tertiary : defaultLightColors.tertiary)
    readonly property color warning: colorsJson ? getMatugenColor("errorContainer", isDark ? defaultDarkColors.errorContainer : defaultLightColors.errorContainer) : (isDark ? defaultDarkColors.errorContainer : defaultLightColors.errorContainer)
    readonly property color danger: colorsJson ? getMatugenColor("error", isDark ? defaultDarkColors.error : defaultLightColors.error) : (isDark ? defaultDarkColors.error : defaultLightColors.error)

    readonly property color labelApp: colorsJson ? getMatugenColor("primary", isDark ? defaultDarkColors.primary : defaultLightColors.primary) : (isDark ? defaultDarkColors.primary : defaultLightColors.primary)
    readonly property color labelOutput: colorsJson ? getMatugenColor("secondary", isDark ? defaultDarkColors.secondary : defaultLightColors.secondary) : (isDark ? defaultDarkColors.secondary : defaultLightColors.secondary)
    readonly property color labelInput: colorsJson ? getMatugenColor("tertiary", isDark ? defaultDarkColors.tertiary : defaultLightColors.tertiary) : (isDark ? defaultDarkColors.tertiary : defaultLightColors.tertiary)

    // Derived colors with alpha
    property color accentHover: Qt.rgba(accent.r, accent.g, accent.b, 0.12)
    property color accentPressed: Qt.rgba(accent.r, accent.g, accent.b, 0.24)
    property color surfaceHover: Qt.rgba(surface.r, surface.g, surface.b, 0.08)

    // Opacity
    property real opacityPanel: 0.9
    property real opacityOverlay: 0.75

    // Border radius
    property int radiusSmallBase: 6
    property int radiusMediumBase: 10
    property int radiusLargeBase: 16

    readonly property int radiusSmall: dp(radiusSmallBase)
    readonly property int radiusMedium: dp(radiusMediumBase)
    readonly property int radiusLarge: dp(radiusLargeBase)

    property int borderWidthBase: 1
    readonly property int borderWidth: dp(borderWidthBase)

    // Wallpaper path (managed by WallpaperService)
    property string wallpaperPath: ""

    // Sync with GlobalState on load
    Component.onCompleted: {
        root.isDark = (GlobalState.currentScheme === "dark")
        root.loadColors()
    }

    // Functions for dark/light mode switching
    function setLightMode(light) {
        root.isDark = !light
        GlobalState.currentScheme = root.schemeName
    }

    function toggleMode() {
        root.isDark = !root.isDark
        GlobalState.currentScheme = root.schemeName
    }

    // Check if matugen colors are loaded
    readonly property bool hasMatugenColors: colorsJson !== null
}
