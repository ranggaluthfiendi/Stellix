import QtQuick
import qs.config

// Cloudy weather icon drawn with Canvas
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
            ctx.arc(width * 0.38, height * 0.45, width * 0.16, Math.PI, 0)
            ctx.arc(width * 0.55, height * 0.38, width * 0.2, Math.PI, 0)
            ctx.arc(width * 0.72, height * 0.48, width * 0.14, Math.PI, 0)
            ctx.closePath()

            ctx.fillRect(width * 0.22, height * 0.45, width * 0.56, height * 0.18)
            ctx.fill()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    onIconColorChanged: canvas.requestPaint()
}
