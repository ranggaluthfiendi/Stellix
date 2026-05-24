import QtQuick
import qs.config

// Power button icon drawn with Canvas
Item {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)

    property color iconColor: Theme.textPrimary
    property real iconSize: Math.min(width, height)

    Canvas {
        id: canvas
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
            var cx = w * 0.5
            var cy = h * 0.5
            var r = w * 0.32

            // Arc (top open circle)
            ctx.beginPath()
            ctx.arc(cx, cy, r, -Math.PI * 0.75, Math.PI * 0.25, false)
            ctx.stroke()

            // Vertical line through center
            ctx.beginPath()
            ctx.moveTo(cx, h * 0.12)
            ctx.lineTo(cx, cy + h * 0.08)
            ctx.stroke()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
