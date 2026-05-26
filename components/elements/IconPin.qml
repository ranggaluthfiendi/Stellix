import QtQuick
import qs.config

Item {
    id: root
    width: Theme.dp(16)
    height: Theme.dp(16)

    property color iconColor: Theme.textPrimary
    property real iconSize: Math.min(width, height)
    property bool isPinned: true

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.iconColor
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = width * 0.1
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var w = width
            var h = height

            // Always use Vertical Pin shape
            // Head
            ctx.beginPath()
            ctx.rect(w * 0.2, h * 0.1, w * 0.6, h * 0.25)
            ctx.fill()
            
            // Body
            ctx.beginPath()
            ctx.rect(w * 0.35, h * 0.35, w * 0.3, h * 0.15)
            ctx.fill()
            
            // Needle
            ctx.beginPath()
            ctx.moveTo(w * 0.5, h * 0.5)
            ctx.lineTo(w * 0.5, h * 0.9)
            ctx.stroke()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
            function onIsPinnedChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
