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
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = width * 0.08
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var w = width
            var h = height

            ctx.beginPath()
            ctx.moveTo(w * 0.5, h * 0.15)
            ctx.lineTo(w * 0.5, h * 0.85)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(w * 0.2, h * 0.5)
            ctx.lineTo(w * 0.8, h * 0.5)
            ctx.stroke()
        }
    }
}
