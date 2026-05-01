pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {

    function dp(x) { return Math.round(x * Appearance.scaleFactor) }

    property color accent: "#d7d1b8"
    property color accentAlt: "#cfc8ad"

    property color bgPrimary: "#1c1b18"
    property color bgSecondary: "#26241f"
    property color surface: "#34322c"

    property color textPrimary: "#e8e4d6"
    property color textSecondary: "#d7d1b8"
    property color textMuted: "#8e8a7a"

    property color border: "#4f4b42"

    property color accentSoft: "#bdb79f"

    property color success: "#9fd19a"
    property color warning: "#e6c97a"
    property color danger: "#d98c8c"

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
}
