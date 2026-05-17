import QtQuick
import qs.config

Rectangle {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)
    color: "transparent"
    border.width: 0

    property color iconColor: Theme.textPrimary
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
            var barW = w * 0.15

            ctx.beginPath()
            ctx.moveTo(barW, 0)
            ctx.lineTo(w - barW * 0.3, h / 2)
            ctx.lineTo(barW, h)
            ctx.closePath()
            ctx.fill()

            ctx.fillRect(w - barW * 0.8, 0, barW * 0.8, h)
        }
    }
}
