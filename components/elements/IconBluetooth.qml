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
            ctx.lineJoin = "round"

            var w = width
            var h = height
            var cx = w / 2

            ctx.beginPath()
            ctx.moveTo(w * 0.35, 0)
            ctx.lineTo(w * 0.65, h * 0.3)
            ctx.lineTo(w * 0.35, h * 0.6)
            ctx.lineTo(w * 0.65, h * 0.9)
            ctx.lineTo(w * 0.35, h * 0.6)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(w * 0.35, h * 0.3)
            ctx.lineTo(w * 0.65, h * 0.6)
            ctx.stroke()
        }
    }
}
