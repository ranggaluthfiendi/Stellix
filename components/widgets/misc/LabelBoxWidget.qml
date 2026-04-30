import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    // Helper
    function dp(x) { return Math.round(x * Appearance.scaleFactor) }

    // Content
    property string text: "Label"

    // Color (editable)
    property color textColor: Theme.textPrimary
    property color backgroundColor: Theme.bgSecondary

    // Position 
    property real posLeft: NaN
    property real posRight: NaN
    property real posTop: NaN
    property real posBottom: NaN

    // Padding
    property int paddingXBase: 12
    property int paddingYBase: 6

    // Computed (scaled)
    readonly property int paddingX: dp(paddingXBase)
    readonly property int paddingY: dp(paddingYBase)

    // Radius
    property int radiusBase: Theme.radiusSmallBase
    readonly property int radius: dp(radiusBase)

    // Size
    width: label.implicitWidth + paddingX * 2
    height: label.implicitHeight + paddingY * 2

    // Positioning logic
    x: !parent ? 0 :
       !isNaN(posLeft) ? posLeft :
       !isNaN(posRight) ? parent.width - width - posRight :
       (parent.width - width) / 2

    y: !parent ? 0 :
       !isNaN(posTop) ? posTop :
       !isNaN(posBottom) ? parent.height - height - posBottom :
       (parent.height - height) / 2

    // Background
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor

        border.width: Theme.borderWidth
        border.color: Theme.border

        // Text
        Text {
            id: label
            text: root.text
            color: root.textColor

            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeSM

            anchors.centerIn: parent
        }
    }
}
