import QtQuick
import qs.config

Item {
    id: root

    width: Theme.dp(18)
    height: Theme.dp(18)

    property color iconColor: "#CFD8DC"
    property color snowColor: "#E1F5FE"
    property real iconSize: Math.min(width, height)

    Canvas {
        id: canvas

        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            ctx.fillStyle = root.iconColor

            ctx.beginPath()
            ctx.arc(width * 0.38, height * 0.42, width * 0.16, Math.PI, 0)
            ctx.arc(width * 0.55, height * 0.34, width * 0.2, Math.PI, 0)
            ctx.arc(width * 0.72, height * 0.44, width * 0.14, Math.PI, 0)

            ctx.lineTo(width * 0.78, height * 0.58)
            ctx.lineTo(width * 0.22, height * 0.58)

            ctx.closePath()
            ctx.fill()

            ctx.strokeStyle = root.snowColor
            ctx.lineWidth = width * 0.05
            ctx.lineCap = "round"

            var flakes = [0.35, 0.5, 0.65]

            for (var i = 0; i < flakes.length; i++) {
                var x = width * flakes[i]
                var y = height * 0.80

                ctx.beginPath()

                ctx.moveTo(x - 2, y)
                ctx.lineTo(x + 2, y)

                ctx.moveTo(x, y - 2)
                ctx.lineTo(x, y + 2)

                ctx.stroke()
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onIconColorChanged: canvas.requestPaint()
    onSnowColorChanged: canvas.requestPaint()
}
