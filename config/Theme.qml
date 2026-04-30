pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {

    // Helper
    function dp(x) { return Math.round(x * Appearance.scaleFactor) }

    // Base Colors (editable)
    property color bgPrimary: "#1e1e2e"
    property color bgSecondary: "#313244"
    property color surface: "#45475a"

    // Text Colors
    property color textPrimary: "#cdd6f4"
    property color textSecondary: "#bac2de"
    property color textMuted: "#6c7086"

    // Accent
    property color accent: "#89b4fa"
    property color accentAlt: "#f5c2e7"

    // Status Colors
    property color success: "#a6e3a1"
    property color warning: "#f9e2af"
    property color danger: "#f38ba8"

    // Transparency
    property real opacityPanel: 0.9
    property real opacityOverlay: 0.75

    // Radius (BASE editable)
    property int radiusSmallBase: 6
    property int radiusMediumBase: 10
    property int radiusLargeBase: 16

    // Radius (COMPUTED scaled)
    readonly property int radiusSmall: dp(radiusSmallBase)
    readonly property int radiusMedium: dp(radiusMediumBase)
    readonly property int radiusLarge: dp(radiusLargeBase)

    // Border
    property int borderWidthBase: 1
    readonly property int borderWidth: dp(borderWidthBase)

    property color border: "#585b70"
}
