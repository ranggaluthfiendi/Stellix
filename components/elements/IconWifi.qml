import QtQuick
import qs.config

Rectangle {
    id: root
    implicitWidth: Theme.dp(18)
    implicitHeight: Theme.dp(18)
    width: implicitWidth
    height: implicitHeight
    color: "transparent"
    border.width: 0

    property color iconColor: Theme.textPrimary
    property real iconSize: width * 0.6

    Canvas {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        anchors.verticalCenter: parent.verticalCenter

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = width * 0.1
            ctx.lineCap = "round"

            var w = width
            var h = height
            var cx = w / 2

            ctx.beginPath()
            ctx.arc(cx, h * 0.85, w * 0.12, 0, Math.PI * 2)
            ctx.fillStyle = root.iconColor
            ctx.fill()

            ctx.beginPath()
            ctx.arc(cx, h * 0.85, w * 0.35, -Math.PI * 0.75, -Math.PI * 0.25)
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(cx, h * 0.85, w * 0.6, -Math.PI * 0.85, -Math.PI * 0.15)
            ctx.stroke()
        }
    }
}
