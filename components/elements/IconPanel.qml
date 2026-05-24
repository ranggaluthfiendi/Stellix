import QtQuick
import qs.config

// Panel/sidebar icon drawn with Canvas (represents rightbar)
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
            var r = w * 0.08

            // Rounded rectangle (panel shape)
            var x = w * 0.15
            var y = h * 0.12
            var pw = w * 0.70
            var ph = h * 0.76

            ctx.beginPath()
            ctx.moveTo(x + r, y)
            ctx.lineTo(x + pw - r, y)
            ctx.arcTo(x + pw, y, x + pw, y + r, r)
            ctx.lineTo(x + pw, y + ph - r)
            ctx.arcTo(x + pw, y + ph, x + pw - r, y + ph, r)
            ctx.lineTo(x + r, y + ph)
            ctx.arcTo(x, y + ph, x, y + ph - r, r)
            ctx.lineTo(x, y + r)
            ctx.arcTo(x, y, x + r, y, r)
            ctx.closePath()
            ctx.fill()

            // Divider line (right panel indicator)
            ctx.fillStyle = Theme.bgSecondary
            var divX = x + pw * 0.65
            ctx.fillRect(divX, y + h * 0.08, w * 0.02, ph - h * 0.16)
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
