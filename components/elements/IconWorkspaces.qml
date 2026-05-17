import QtQuick
import qs.config

Rectangle {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)
    color: "transparent"
    border.width: 0

    property color iconColor: Theme.textPrimary
    property real iconSize: width * 0.6

    Canvas {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.iconColor

            var gap = width * 0.15
            var boxW = (width - gap * 3) / 2
            var boxH = (height - gap * 3) / 2
            var r = boxW * 0.2

            function drawRoundRect(x, y, w, h, r) {
                ctx.beginPath()
                ctx.moveTo(x + r, y)
                ctx.lineTo(x + w - r, y)
                ctx.quadraticCurveTo(x + w, y, x + w, y + r)
                ctx.lineTo(x + w, y + h - r)
                ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
                ctx.lineTo(x + r, y + h)
                ctx.quadraticCurveTo(x, y + h, x, y + h - r)
                ctx.lineTo(x, y + r)
                ctx.quadraticCurveTo(x, y, x + r, y)
                ctx.closePath()
                ctx.fill()
            }

            drawRoundRect(gap, gap, boxW, boxH, r)
            drawRoundRect(gap * 2 + boxW, gap, boxW, boxH, r)
            drawRoundRect(gap, gap * 2 + boxH, boxW, boxH, r)
            drawRoundRect(gap * 2 + boxW, gap * 2 + boxH, boxW, boxH, r)
        }
    }
}
