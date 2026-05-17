import QtQuick
import qs.config

// Simple power button icon
Item {
    id: root
    width: Theme.dp(16)
    height: Theme.dp(16)

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

            var s = width / 24

            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = 2.5 * s
            ctx.lineCap = "round"

            // Arc (top part)
            ctx.beginPath()
            ctx.arc(12 * s, 13 * s, 8 * s, Math.PI * 0.85, Math.PI * 0.15, false)
            ctx.stroke()

            // Vertical line
            ctx.beginPath()
            ctx.moveTo(12 * s, 3 * s)
            ctx.lineTo(12 * s, 13 * s)
            ctx.stroke()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
            function onIconSizeChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
