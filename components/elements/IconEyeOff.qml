import QtQuick
import qs.config

Rectangle {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)
    color: "transparent"

    property color iconColor: Theme.textPrimary
    property real iconWidth: 2
    property real iconSize: width * 0.85

    Canvas {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")

            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            ctx.strokeStyle = root.iconColor
            ctx.fillStyle = root.iconColor
            ctx.lineWidth = root.iconWidth
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var w = width
            var h = height

            var cx = w / 2
            var cy = h / 2

            // Eye outer shape
            ctx.beginPath()
            ctx.moveTo(w * 0.08, cy)

            ctx.bezierCurveTo(
                w * 0.20, h * 0.18,
                w * 0.40, h * 0.05,
                cx, h * 0.05
            )

            ctx.bezierCurveTo(
                w * 0.60, h * 0.05,
                w * 0.80, h * 0.18,
                w * 0.92, cy
            )

            ctx.bezierCurveTo(
                w * 0.80, h * 0.82,
                w * 0.60, h * 0.95,
                cx, h * 0.95
            )

            ctx.bezierCurveTo(
                w * 0.40, h * 0.95,
                w * 0.20, h * 0.82,
                w * 0.08, cy
            )

            ctx.stroke()

            // Inner pupil shape
            ctx.beginPath()
            ctx.arc(cx, cy, w * 0.12, 0, Math.PI * 2)
            ctx.fill()

            // Small cut effect on pupil
            ctx.clearRect(
                cx - w * 0.03,
                cy - h * 0.12,
                w * 0.06,
                h * 0.08
            )

            // Diagonal slash
            ctx.beginPath()
            ctx.moveTo(w * 0.12, h * 0.10)
            ctx.lineTo(w * 0.88, h * 0.90)
            ctx.stroke()
        }
    }
}
