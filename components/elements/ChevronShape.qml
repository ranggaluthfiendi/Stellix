import QtQuick

Item {
    id: root

    property string direction: "up"
    property color color: "#e3e3e3"

    width: 24
    height: 24

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = root.color

            ctx.beginPath()

            if (root.direction === "up") {
                ctx.moveTo(width * 0.2, height * 0.35)
                ctx.lineTo(width * 0.5, height * 0.7)
                ctx.lineTo(width * 0.8, height * 0.35)
            } else {
                ctx.moveTo(width * 0.35, height * 0.2)
                ctx.lineTo(width * 0.7, height * 0.5)
                ctx.lineTo(width * 0.35, height * 0.8)
            }

            ctx.closePath()
            ctx.fill()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onDirectionChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
}
