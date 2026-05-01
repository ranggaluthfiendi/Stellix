pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {

    function dp(x) { return Math.round(x * Appearance.scaleFactor) }

    readonly property int barHeight: dp(32)
    readonly property int barPadding: dp(10)

    readonly property int spacingXS: dp(4)
    readonly property int spacingSM: dp(8)
    readonly property int spacingMD: dp(12)
    readonly property int spacingLG: dp(16)

    readonly property int marginScreen: dp(8)

    readonly property int iconXS: dp(12)
    readonly property int iconSM: dp(16)
    readonly property int iconMD: dp(20)
    readonly property int iconLG: dp(24)

    readonly property int widgetHeight: dp(26)
    readonly property int widgetMinWidth: dp(40)
}
