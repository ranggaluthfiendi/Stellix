import QtQuick
import qs.config

// Sunny weather icon drawn with Canvas
Item {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)

    property color iconColor: "#FDB813"
    property real iconSize: Math.min(width, height)

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const cx = width / 2
            const cy = height / 2
            const r = width * 0.18

            ctx.strokeStyle = root.iconColor
            ctx.fillStyle = root.iconColor
            ctx.lineWidth = width * 0.05
            ctx.lineCap = "round"

            for (let i = 0; i < 8; i++) {
                const angle = (Math.PI / 4) * i
                const x1 = cx + Math.cos(angle) * (r + 8)
                const y1 = cy + Math.sin(angle) * (r + 8)
                const x2 = cx + Math.cos(angle) * (r + 18)
                const y2 = cy + Math.sin(angle) * (r + 18)

                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()
            }

            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.fill()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    onIconColorChanged: canvas.requestPaint()
}
