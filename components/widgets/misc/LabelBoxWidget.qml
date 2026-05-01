import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    function dp(x) { return Math.round(x * Appearance.scaleFactor) }

    property string text: "Label"

    property color textColor: Theme.textPrimary
    property color backgroundColor: Theme.bgSecondary

    property real posLeft: NaN
    property real posRight: NaN
    property real posTop: NaN
    property real posBottom: NaN

    property int paddingXBase: 12
    property int paddingYBase: 6

    readonly property int paddingX: dp(paddingXBase)
    readonly property int paddingY: dp(paddingYBase)

    property int radiusBase: Theme.radiusSmallBase
    readonly property int radius: dp(radiusBase)

    width: label.implicitWidth + paddingX * 2
    height: label.implicitHeight + paddingY * 2

    x: !parent ? 0 :
       !isNaN(posLeft) ? posLeft :
       !isNaN(posRight) ? parent.width - width - posRight :
       (parent.width - width) / 2

    y: !parent ? 0 :
       !isNaN(posTop) ? posTop :
       !isNaN(posBottom) ? parent.height - height - posBottom :
       (parent.height - height) / 2

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor

        border.width: Theme.borderWidth
        border.color: Theme.border

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
