pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {

    // Font
    property string fontFamily: "JetBrainsMono Nerd Font"

    // Size (BASE)
    property int sizeXSBase: 10
    property int sizeSMBase: 12
    property int sizeMDBase: 14
    property int sizeLGBase: 16

    // Computed (scaled)
    readonly property int sizeXS: Math.round(sizeXSBase * Appearance.scaleFactor)
    readonly property int sizeSM: Math.round(sizeSMBase * Appearance.scaleFactor)
    readonly property int sizeMD: Math.round(sizeMDBase * Appearance.scaleFactor)
    readonly property int sizeLG: Math.round(sizeLGBase * Appearance.scaleFactor)

    // Weight
    property int weightNormal: Font.Normal
    property int weightBold: Font.DemiBold
}
