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
            var cx = w / 2
            var cy = h / 2
            var r = w * 0.2

            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.fill()

            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = w * 0.08
            ctx.lineCap = "round"

            for (var i = 0; i < 8; i++) {
                var angle = (i * Math.PI * 2) / 8
                var x1 = cx + Math.cos(angle) * (r + w * 0.05)
                var y1 = cy + Math.sin(angle) * (r + w * 0.05)
                var x2 = cx + Math.cos(angle) * (r + w * 0.2)
                var y2 = cy + Math.sin(angle) * (r + w * 0.2)
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()
            }
        }
    }
}
