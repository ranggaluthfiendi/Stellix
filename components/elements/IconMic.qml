import QtQuick
import qs.config

// Clean microphone icon based on tetrisly SVG
Item {
    id: root
    width: Theme.dp(16)
    height: Theme.dp(16)

    property color iconColor: Theme.textPrimary
    property real iconSize: Math.min(width, height)
    property bool muted: false

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var s = width / 24

            ctx.fillStyle = root.iconColor
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = 1.5 * s
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            // Full SVG path converted to Canvas
            ctx.beginPath()
            // U-bracket / stand
            ctx.moveTo(19 * s, 11 * s)
            ctx.bezierCurveTo(19.552 * s, 11 * s, 20 * s, 11.448 * s, 20 * s, 12 * s)
            ctx.bezierCurveTo(20 * s, 16.079 * s, 16.947 * s, 19.445 * s, 13.001 * s, 19.938 * s)
            ctx.lineTo(13 * s, 21 * s)
            ctx.bezierCurveTo(13 * s, 21.552 * s, 12.552 * s, 22 * s, 12 * s, 22 * s)
            ctx.bezierCurveTo(11.448 * s, 22 * s, 11 * s, 21.552 * s, 11 * s, 21 * s)
            ctx.lineTo(11.000 * s, 19.938 * s)
            ctx.bezierCurveTo(7.054 * s, 19.446 * s, 4 * s, 16.080 * s, 4 * s, 12 * s)
            ctx.bezierCurveTo(4 * s, 11.448 * s, 4.448 * s, 11 * s, 5 * s, 11 * s)
            ctx.bezierCurveTo(5.552 * s, 11 * s, 6 * s, 11.448 * s, 6 * s, 12 * s)
            ctx.bezierCurveTo(6 * s, 15.314 * s, 8.686 * s, 18 * s, 12 * s, 18 * s)
            ctx.bezierCurveTo(15.314 * s, 18 * s, 18 * s, 15.314 * s, 18 * s, 12 * s)
            ctx.bezierCurveTo(18 * s, 11.448 * s, 18.448 * s, 11 * s, 19 * s, 11 * s)
            ctx.closePath()

            // Outer capsule
            ctx.moveTo(12 * s, 2 * s)
            ctx.bezierCurveTo(14.209 * s, 2 * s, 16 * s, 3.791 * s, 16 * s, 6 * s)
            ctx.lineTo(16 * s, 12 * s)
            ctx.bezierCurveTo(16 * s, 14.209 * s, 14.209 * s, 16 * s, 12 * s, 16 * s)
            ctx.bezierCurveTo(9.791 * s, 16 * s, 8 * s, 14.209 * s, 8 * s, 12 * s)
            ctx.lineTo(8 * s, 6 * s)
            ctx.bezierCurveTo(8 * s, 3.791 * s, 9.791 * s, 2 * s, 12 * s, 2 * s)
            ctx.closePath()

            // Inner hole (evenodd)
            ctx.moveTo(12 * s, 4 * s)
            ctx.bezierCurveTo(10.895 * s, 4 * s, 10 * s, 4.895 * s, 10 * s, 6 * s)
            ctx.lineTo(10 * s, 12 * s)
            ctx.bezierCurveTo(10 * s, 13.105 * s, 10.895 * s, 14 * s, 12 * s, 14 * s)
            ctx.bezierCurveTo(13.105 * s, 14 * s, 14 * s, 13.105 * s, 14 * s, 12 * s)
            ctx.lineTo(14 * s, 6 * s)
            ctx.bezierCurveTo(14 * s, 4.895 * s, 13.105 * s, 4 * s, 12 * s, 4 * s)
            ctx.closePath()

            ctx.fill("evenodd")

            // Mute slash
            if (root.muted) {
                ctx.lineWidth = 2 * s
                ctx.beginPath()
                ctx.moveTo(17 * s, 3 * s)
                ctx.lineTo(5 * s, 21 * s)
                ctx.stroke()
            }
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
            function onMutedChanged() { canvas.requestPaint() }
            function onIconSizeChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
