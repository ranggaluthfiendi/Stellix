import QtQuick
import qs.config

Rectangle {
    id: root

    width: Theme.dp(18)
    height: Theme.dp(18)
    color: "transparent"

    property color iconColor: Theme.textPrimary
    property real iconWidth: 2
    property real iconSize: width * 0.82

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

            // Eye outline
            ctx.beginPath()

            ctx.moveTo(w * 0.06, cy)

            ctx.bezierCurveTo(
                w * 0.18, h * 0.18,
                w * 0.38, h * 0.04,
                cx, h * 0.04
            )

            ctx.bezierCurveTo(
                w * 0.62, h * 0.04,
                w * 0.82, h * 0.18,
                w * 0.94, cy
            )

            ctx.bezierCurveTo(
                w * 0.82, h * 0.82,
                w * 0.62, h * 0.96,
                cx, h * 0.96
            )

            ctx.bezierCurveTo(
                w * 0.38, h * 0.96,
                w * 0.18, h * 0.82,
                w * 0.06, cy
            )

            ctx.stroke()

            // Iris
            ctx.beginPath()
            ctx.arc(cx, cy, w * 0.18, 0, Math.PI * 2)
            ctx.stroke()

            // Pupil
            ctx.beginPath()
            ctx.arc(cx, cy, w * 0.07, 0, Math.PI * 2)
            ctx.fill()
        }
    }
}
