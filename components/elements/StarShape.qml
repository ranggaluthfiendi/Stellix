import QtQuick

Item {
    id: root
    width: 16
    height: 16

    property color color: "white"
    property bool animate: true

    transform: [
        Scale {
            id: scaleT
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: 1
            yScale: 1
        }
    ]

    RotationAnimation on rotation {
        running: root.animate
        loops: Animation.Infinite
        from: 0
        to: 180
        duration: 2000
        easing.type: Easing.InOutQuad
    }

    SequentialAnimation {
        running: root.animate
        loops: Animation.Infinite

        NumberAnimation {
            target: scaleT
            property: "xScale"
            to: 1.15
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: scaleT
            property: "yScale"
            to: 1.15
            duration: 1000
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: scaleT
            property: "xScale"
            to: 1
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: scaleT
            property: "yScale"
            to: 1
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }

    Canvas {
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var s = Math.min(width, height) / 60
            ctx.scale(s, s)

            ctx.fillStyle = root.color

            ctx.beginPath()
            ctx.moveTo(30, 5)
            ctx.lineTo(34, 20)
            ctx.lineTo(50, 30)
            ctx.lineTo(34, 40)
            ctx.lineTo(30, 55)
            ctx.lineTo(26, 40)
            ctx.lineTo(10, 30)
            ctx.lineTo(26, 20)
            ctx.closePath()

            ctx.fill()
        }
    }
}
