import QtQuick
import qs.config

Rectangle {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)
    color: "transparent"
    border.width: 0

    property color iconColor: Theme.textPrimary
    property real iconWidth: 2
    property real iconSize: width * 0.55

    Canvas {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = root.iconWidth
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var w = width
            var h = height

            ctx.beginPath()
            ctx.moveTo(w, 0)
            ctx.lineTo(w * 0.3, h / 2)
            ctx.lineTo(w, h)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(w * 0.55, 0)
            ctx.lineTo(w * 0.05, h / 2)
            ctx.lineTo(w * 0.55, h)
            ctx.stroke()
        }
    }
}
