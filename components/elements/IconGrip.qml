import QtQuick

Item {
    id: root

    property color color: Theme.textMuted

    width: 20
    height: 20

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            ctx.fillStyle = root.color
            ctx.lineCap = "round"

            function drawLine(y, leftWidth, rightStart) {
                const h = height * 0.07
                const radius = h / 2

                const leftX = 0
                const leftY = y - h / 2
                const leftW = width * leftWidth

                roundedRect(leftX, leftY, leftW, h, radius)

                const rightX = width * rightStart
                const rightY = y - h / 2
                const rightW = width - rightX

                roundedRect(rightX, rightY, rightW, h, radius)
            }

            function roundedRect(x, y, w, h, r) {
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

            drawLine(height * 0.2, 0.21, 0.28)
            drawLine(height * 0.5, 0.21, 0.28)
            drawLine(height * 0.8, 0.21, 0.28)
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onColorChanged: canvas.requestPaint()
}
