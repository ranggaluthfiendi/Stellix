import QtQuick

Item {
    id: root
    property color color: "#e3e3e3"
    width: 24
    height: 24

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = root.color
            ctx.beginPath()
            ctx.moveTo(width * 0.2, height * 0.35)
            ctx.lineTo(width * 0.5, height * 0.7)
            ctx.lineTo(width * 0.8, height * 0.35)
            ctx.closePath()
            ctx.fill()
        }
    }
}
