import QtQuick
import qs.config

Item {
    property bool expanded: false

    width: Theme.dp(12)
    height: Theme.dp(12)

    rotation: expanded ? 90 : 0

    RotationAnimator on rotation {
        duration: 150
    }

    Canvas {
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            ctx.strokeStyle = Qt.rgba(
                Theme.textMuted.r,
                Theme.textMuted.g,
                Theme.textMuted.b,
                1
            )

            ctx.lineWidth = Theme.dp(1.5)

            ctx.beginPath()
            ctx.moveTo(Theme.dp(3), Theme.dp(2))
            ctx.lineTo(Theme.dp(9), Theme.dp(6))
            ctx.lineTo(Theme.dp(3), Theme.dp(10))
            ctx.stroke()
        }
    }
}
