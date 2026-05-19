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
            ctx.lineWidth = width * 0.12
            ctx.lineCap = "round"

            var w = width
            var h = height
            var pad = w * 0.15
            var r = (w - pad * 2) * 0.5
            var cx = w * 0.5
            var cy = h * 0.55

            // Open circular arrow (loop)
            ctx.beginPath()
            ctx.arc(cx, cy, r, Math.PI * 0.15, Math.PI * 1.75, false)
            ctx.stroke()

            // Arrowhead
            ctx.fillStyle = root.iconColor
            var headX = cx + r * Math.cos(Math.PI * 0.15)
            var headY = cy + r * Math.sin(Math.PI * 0.15)
            var head = w * 0.18

            ctx.beginPath()
            ctx.moveTo(headX, headY)
            ctx.lineTo(headX - head * 0.8, headY - head * 0.5)
            ctx.lineTo(headX - head * 0.3, headY + head * 0.6)
            ctx.closePath()
            ctx.fill()
        }
    }
}
