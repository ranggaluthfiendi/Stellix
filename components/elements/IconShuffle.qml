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
            ctx.lineJoin = "round"

            var w = width
            var h = height
            var pad = w * 0.15
            var midY = h * 0.5

            // Crossed arrows (shuffle)
            ctx.beginPath()
            ctx.moveTo(pad, pad)
            ctx.lineTo(w - pad, h - pad)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(pad, h - pad)
            ctx.lineTo(w - pad, pad)
            ctx.stroke()

            // Arrowheads
            var head = w * 0.18
            ctx.fillStyle = root.iconColor

            // Top-right arrowhead
            ctx.beginPath()
            ctx.moveTo(w - pad, h - pad)
            ctx.lineTo(w - pad - head, h - pad)
            ctx.lineTo(w - pad, h - pad - head)
            ctx.closePath()
            ctx.fill()

            // Bottom-right arrowhead
            ctx.beginPath()
            ctx.moveTo(w - pad, pad)
            ctx.lineTo(w - pad - head, pad)
            ctx.lineTo(w - pad, pad + head)
            ctx.closePath()
            ctx.fill()
        }
    }
}
