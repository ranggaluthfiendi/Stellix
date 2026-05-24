import QtQuick
import qs.config

// Foggy weather icon drawn with Canvas
Item {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)

    property color iconColor: "#B0BEC5"
    property real iconSize: Math.min(width, height)

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            ctx.fillStyle = root.iconColor

            ctx.beginPath()
            ctx.arc(width * 0.38, height * 0.32, width * 0.16, Math.PI, 0)
            ctx.arc(width * 0.55, height * 0.26, width * 0.2, Math.PI, 0)
            ctx.arc(width * 0.72, height * 0.36, width * 0.14, Math.PI, 0)
            ctx.closePath()

            ctx.fillRect(width * 0.22, height * 0.32, width * 0.56, height * 0.18)
            ctx.fill()

            ctx.strokeStyle = "#CFD8DC"
            ctx.lineWidth = width * 0.05
            ctx.lineCap = "round"

            ctx.beginPath()
            ctx.moveTo(width * 0.18, height * 0.72)
            ctx.lineTo(width * 0.82, height * 0.72)

            ctx.moveTo(width * 0.24, height * 0.84)
            ctx.lineTo(width * 0.76, height * 0.84)

            ctx.stroke()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    onIconColorChanged: canvas.requestPaint()
}
