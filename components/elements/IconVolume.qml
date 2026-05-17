import QtQuick
import qs.config

Item {
    id: root
    width: Theme.dp(18)
    height: Theme.dp(18)

    property color iconColor: Theme.textPrimary
    property real iconSize: Math.min(width, height)

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.iconColor
            ctx.strokeStyle = root.iconColor

            var w = width
            var h = height

            // Speaker body (trapezoid facing right)
            // Rectangle part (left)
            var bx = w * 0.08   // body left
            var bt = h * 0.35   // body top
            var bb = h * 0.65   // body bottom
            var bw = w * 0.25   // body width

            // Triangle cone (right side pointing left)
            var cx2 = bx + bw   // cone base x
            var ct = h * 0.18   // cone tip top
            var cbm = h * 0.82  // cone tip bottom
            var ctr = h * 0.5 - h * 0.06  // center top
            var cbr = h * 0.5 + h * 0.06  // center bottom

            ctx.beginPath()
            // Rectangle speaker body
            ctx.moveTo(bx, bt)
            ctx.lineTo(bx + bw, bt)
            ctx.lineTo(bx + bw, bb)
            ctx.lineTo(bx, bb)
            ctx.closePath()
            ctx.fill()

            // Cone triangle
            ctx.beginPath()
            ctx.moveTo(cx2, bt)
            ctx.lineTo(w * 0.52, ct)
            ctx.lineTo(w * 0.52, cbm)
            ctx.lineTo(cx2, bb)
            ctx.closePath()
            ctx.fill()

            // Sound waves (arcs on the right)
            ctx.lineWidth = w * 0.09
            ctx.lineCap = "round"

            // Small wave
            ctx.beginPath()
            ctx.arc(w * 0.52, h * 0.5, w * 0.15, -Math.PI * 0.4, Math.PI * 0.4)
            ctx.stroke()

            // Medium wave
            ctx.beginPath()
            ctx.arc(w * 0.52, h * 0.5, w * 0.28, -Math.PI * 0.42, Math.PI * 0.42)
            ctx.stroke()
        }

        Connections {
            target: root
            function onIconColorChanged() { canvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
