pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    function dp(x) { return Math.round(x * Scales.uiScale) }

    // Matugen dynamic colors
    property color accent: "#c4c0ff"
    property color accentAlt: "#c7c4dc"

    property color bgPrimary: "#131318"
    property color bgSecondary: "#201f25"
    property color surface: "#47464f"

    property color textPrimary: "#e5e1e9"
    property color textSecondary: "#c8c5d0"
    property color textMuted: "#928f99"

    property color border: "#47464f"

    property color accentSoft: "#434078"

    property color success: "#ebb9d0"
    property color warning: "#93000a"
    property color danger: "#ffb4ab"

    property color labelApp: "#c4c0ff"
    property color labelOutput: "#c7c4dc"
    property color labelInput: "#ebb9d0"

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

    // Dark/Light mode detection (based on matugen mode)
    readonly property bool isDark: "dark" === "dark"
    readonly property string schemeName: "dark"
}
