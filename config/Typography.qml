pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    property string fontFamily: "JetBrainsMono Nerd Font"

    // Material Symbols icon font (like Clairova-Shell Appearance.qml)
    readonly property string materialSymbols: "Material Symbols Rounded"
    readonly property string materialSymbolsOutlined: "Material Symbols Outlined"
    readonly property string materialSymbolsSharp: "Material Symbols Sharp"

    property int sizeXXSBase: 7
    property int sizeXSBase: 10
    property int sizeSMBase: 12
    property int sizeMDBase: 14
    property int sizeLGBase: 16

    function sp(x) { return Math.round(x * Scales.uiScale) }

    readonly property int sizeXXS: sp(sizeXXSBase)
    readonly property int sizeXS: sp(sizeXSBase)
    readonly property int sizeSM: sp(sizeSMBase)
    readonly property int sizeMD: sp(sizeMDBase)
    readonly property int sizeLG: sp(sizeLGBase)

    property int weightNormal: Font.Normal
    property int weightMedium: Font.Medium
    property int weightBold: Font.DemiBold
}
