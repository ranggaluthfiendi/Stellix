import QtQuick
import qs.config

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
            var ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            ctx.fillStyle = root.iconColor

            ctx.beginPath()
            ctx.arc(width * 0.38, height * 0.52, width * 0.16, Math.PI, 0)
            ctx.arc(width * 0.55, height * 0.44, width * 0.2, Math.PI, 0)
            ctx.arc(width * 0.72, height * 0.54, width * 0.14, Math.PI, 0)

            ctx.lineTo(width * 0.78, height * 0.68)
            ctx.lineTo(width * 0.22, height * 0.68)

            ctx.closePath()
            ctx.fill()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onIconColorChanged: canvas.requestPaint()
}
