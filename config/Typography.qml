pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {

    property string fontFamily: "JetBrainsMono Nerd Font"

    property int sizeXSBase: 10
    property int sizeSMBase: 12
    property int sizeMDBase: 14
    property int sizeLGBase: 16

    readonly property int sizeXS: Math.round(sizeXSBase * Appearance.scaleFactor)
    readonly property int sizeSM: Math.round(sizeSMBase * Appearance.scaleFactor)
    readonly property int sizeMD: Math.round(sizeMDBase * Appearance.scaleFactor)
    readonly property int sizeLG: Math.round(sizeLGBase * Appearance.scaleFactor)

    property int weightNormal: Font.Normal
    property int weightBold: Font.DemiBold
}
