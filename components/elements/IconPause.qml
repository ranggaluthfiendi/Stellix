import QtQuick
import qs.config

Rectangle {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)
    color: "transparent"
    border.width: 0

    property color iconColor: Theme.textPrimary
    property real iconWidth: 2
    property real iconSize: width * 0.6

    Canvas {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.iconColor

            var w = width
            var h = height
            var margin = w * 0.12
            var barW = w * 0.28
            var gap = w * 0.2

            ctx.fillRect(margin, 0, barW, h)
            ctx.fillRect(margin + barW + gap, 0, barW, h)
        }
    }
}
