import QtQuick
import qs.config

// Clean bell notification icon
Item {
    id: root
    width: Theme.dp(32)
    height: Theme.dp(32)

    property color iconColor: Theme.textMuted
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

            ctx.fillStyle = root.iconColor
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = 1.5 * s
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            // Bell dome
            ctx.beginPath()
            ctx.moveTo(17 * s, 8 * s)
            ctx.quadraticCurveTo(17 * s, 3 * s, 12 * s, 3 * s)
            ctx.quadraticCurveTo(7 * s, 3 * s, 7 * s, 8 * s)
            ctx.lineTo(5 * s, 15 * s)
            ctx.lineTo(19 * s, 15 * s)
            ctx.closePath()
            ctx.fill()

            // Bell bottom rim
            ctx.beginPath()
            ctx.moveTo(4 * s, 15 * s)
            ctx.lineTo(20 * s, 15 * s)
            ctx.lineTo(18 * s, 17 * s)
            ctx.lineTo(6 * s, 17 * s)
            ctx.closePath()
            ctx.fill()

            // Bell clapper (bottom bump)
            ctx.beginPath()
            ctx.moveTo(10 * s, 17 * s)
            ctx.arc(12 * s, 17 * s, 2 * s, Math.PI, 0, false)
            ctx.closePath()
            ctx.fill()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
            function onIconSizeChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
