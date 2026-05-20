pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config
import qs.services

Singleton {
    id: root

    function dp(x) { return Math.round(x * Scales.uiScale) }

    // Matugen dynamic colors
    property color accent: "#c9c5cc"
    property color accentAlt: "#c9c5c8"

    property color bgPrimary: "#141314"
    property color bgSecondary: "#201f20"
    property color surface: "#47464b"

    property color textPrimary: "#e5e1e2"
    property color textSecondary: "#c9c5cb"
    property color textMuted: "#929095"

    property color border: "#47464b"

    property color accentSoft: "#aaa7ae"

    property color success: "#cec5ba"
    property color warning: "#93000a"
    property color danger: "#ffb4ab"

    property color labelApp: "#c9c5cc"
    property color labelOutput: "#c9c5c8"
    property color labelInput: "#cec5ba"

    property real opacityPanel: 0.9
    property real opacityOverlay: 0.75

    property int radiusSmallBase: 6
    property int radiusMediumBase: 10
    property int radiusLargeBase: 16

    readonly property int radiusSmall: dp(radiusSmallBase)
    readonly property int radiusMedium: dp(radiusMediumBase)
    readonly property int radiusLarge: dp(radiusLargeBase)

    property int borderWidthBase: 1
    readonly property int borderWidth: dp(borderWidthBase)

    // Dark/Light mode - source of truth
    property bool isDark: true
    readonly property string schemeName: isDark ? "dark" : "light"

    // Sync with ColorService on load
    Component.onCompleted: {
        root.isDark = (GlobalState.currentScheme === "dark")
    }

    function setLightMode(light) {
        root.isDark = !light
        GlobalState.currentScheme = root.schemeName
    }

    function toggleMode() {
        root.isDark = !root.isDark
        GlobalState.currentScheme = root.schemeName
    }
}
