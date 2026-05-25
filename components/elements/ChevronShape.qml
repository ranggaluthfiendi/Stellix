import QtQuick

Item {
    id: root

    property string direction: "down"
    property color color: "#e3e3e3"

    width: 24
    height: 24

    property real animProgress: 1.0

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = root.color

            ctx.beginPath()

            if (root.direction === "left") {
                ctx.moveTo(width * 0.7, height * 0.2)
                ctx.lineTo(width * 0.35, height * 0.5)
                ctx.lineTo(width * 0.7, height * 0.8)
            } else if (root.direction === "right") {
                ctx.moveTo(width * 0.3, height * 0.2)
                ctx.lineTo(width * 0.65, height * 0.5)
                ctx.lineTo(width * 0.3, height * 0.8)
            } else {
                ctx.moveTo(width * 0.2, height * 0.35)
                ctx.lineTo(width * 0.5, height * 0.7)
                ctx.lineTo(width * 0.8, height * 0.35)
            }

            ctx.closePath()
            ctx.fill()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onDirectionChanged: {
        canvas.requestPaint()
        anim.restart()
    }
    onColorChanged: canvas.requestPaint()

    SequentialAnimation on animProgress {
        id: anim
        running: false
        NumberAnimation { from: 1.0; to: 0.5; duration: 100 }
        NumberAnimation { from: 0.5; to: 1.0; duration: 100 }
    }
}
