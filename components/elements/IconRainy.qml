import QtQuick
import qs.config

// Rainy weather icon drawn with Canvas
Item {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)

    property color iconColor: "#90A4AE"
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
            ctx.arc(width * 0.38, height * 0.38, width * 0.16, Math.PI, 0)
            ctx.arc(width * 0.55, height * 0.32, width * 0.2, Math.PI, 0)
            ctx.arc(width * 0.72, height * 0.42, width * 0.14, Math.PI, 0)
            ctx.closePath()

            ctx.fillRect(width * 0.22, height * 0.38, width * 0.56, height * 0.18)
            ctx.fill()

            ctx.strokeStyle = "#42A5F5"
            ctx.lineWidth = width * 0.05
            ctx.lineCap = "round"

            const drops = [0.35, 0.5, 0.65]

            for (let i = 0; i < drops.length; i++) {
                const x = width * drops[i]

                ctx.beginPath()
                ctx.moveTo(x, height * 0.7)
                ctx.lineTo(x - 4, height * 0.88)
                ctx.stroke()
            }
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    onIconColorChanged: canvas.requestPaint()
}
