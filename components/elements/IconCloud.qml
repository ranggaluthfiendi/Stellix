import QtQuick
import qs.config

// Cloud icon drawn with Canvas
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
            ctx.fillStyle = root.iconColor

            var w = width
            var h = height
            var cx = w * 0.5
            var cy = h * 0.5

            // Cloud shape: multiple overlapping arcs
            ctx.beginPath()
            // Bottom flat-ish area
            ctx.arc(cx - w * 0.15, cy + h * 0.08, w * 0.18, Math.PI * 0.5, Math.PI * 1.5, false)
            // Left bump
            ctx.arc(cx - w * 0.22, cy - h * 0.05, w * 0.20, Math.PI * 0.8, Math.PI * 0.1, false)
            // Top bump
            ctx.arc(cx + w * 0.02, cy - h * 0.18, w * 0.22, Math.PI * 1.1, Math.PI * 1.9, false)
            // Right bump
            ctx.arc(cx + w * 0.22, cy - h * 0.02, w * 0.18, Math.PI * 1.4, Math.PI * 0.6, false)
            // Bottom right
            ctx.arc(cx + w * 0.12, cy + h * 0.10, w * 0.15, Math.PI * 0.3, Math.PI * 0.8, false)
            ctx.closePath()
            ctx.fill()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
