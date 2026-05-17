import QtQuick
import qs.config

// Bell icon drawn with Canvas (pure SVG-style, no emoji/text)
// Shape: dome top, flared skirt at bottom, small clapper circle
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

            var w = width
            var h = height
            var cx = w * 0.5

            ctx.fillStyle = root.iconColor

            // Bell body: dome (top arc) + straight sides + flared base
            var domeR  = w * 0.30          // dome radius
            var domeY  = h * 0.32          // center of dome arc
            var bodyW  = w * 0.62          // width at base of dome
            var flareW = w * 0.78          // width at bottom flare
            var bodyBot= h * 0.72          // y where body ends / flare starts
            var flareH = h * 0.10          // height of flare zone

            ctx.beginPath()
            // Start at left edge of dome center
            ctx.arc(cx, domeY, domeR, Math.PI, 0, false)         // dome semicircle
            // Right side going down
            ctx.lineTo(cx + bodyW / 2, bodyBot)
            // Right flare
            ctx.lineTo(cx + flareW / 2, bodyBot + flareH)
            // Bottom flat edge
            ctx.lineTo(cx - flareW / 2, bodyBot + flareH)
            // Left flare
            ctx.lineTo(cx - bodyW / 2, bodyBot)
            ctx.closePath()
            ctx.fill()

            // Clapper: small filled circle at very bottom
            var clapperY = bodyBot + flareH + h * 0.07
            var clapperR = w * 0.08
            ctx.beginPath()
            ctx.arc(cx, clapperY, clapperR, 0, Math.PI * 2)
            ctx.fill()

            // Stem: small rectangle at top of dome (bell hanger)
            ctx.fillRect(cx - w * 0.05, h * 0.03, w * 0.10, h * 0.06)
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
