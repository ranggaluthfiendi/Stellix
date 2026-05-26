import QtQuick
import qs.config
import qs.core.state

Item {
    id: root

    property real s: 1.0
    property var rootItem: null

    height: Theme.dp(32)
    width: Theme.dp(24)

    readonly property var mprisService: rootItem ? rootItem.mprisService : null
    readonly property bool hasMedia: rootItem ? rootItem.hasMedia : false
    readonly property bool isPlaying: rootItem ? rootItem.isPlaying : false

    Item {
        id: rotatingIcon
        anchors.centerIn: parent
        width: Theme.dp(18)
        height: Theme.dp(18)
        transformOrigin: Item.Center

        property real currentRotation: 0
        rotation: currentRotation

        Timer {
            id: loopTimer
            interval: 16
            repeat: true
            running: root.isPlaying
            onTriggered: {
                rotatingIcon.currentRotation += 1
                if (rotatingIcon.currentRotation >= 360)
                    rotatingIcon.currentRotation = 0
            }
        }

        NumberAnimation {
            id: returnToZero
            target: rotatingIcon
            property: "currentRotation"
            easing.type: Easing.InOutQuad
        }

        SequentialAnimation {
            id: pressEffect
            running: false
            NumberAnimation {
                target: scaleTransform
                property: "xScale"
                to: 1.2
                duration: 60
            }
            NumberAnimation {
                target: scaleTransform
                property: "xScale"
                to: 1.0
                duration: 80
            }
            ParallelAnimation {
                NumberAnimation {
                    target: scaleTransform
                    property: "yScale"
                    to: 1.2
                    duration: 60
                }
                NumberAnimation {
                    target: scaleTransform
                    property: "yScale"
                    to: 1.0
                    duration: 80
                }
            }
        }

        transform: Scale {
            id: scaleTransform
            origin.x: rotatingIcon.width / 2
            origin.y: rotatingIcon.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        Text {
            anchors.centerIn: parent
            text: "♪"
            color: Theme.accent
            font.pixelSize: Math.round(14 * root.s)
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
            hoverEnabled: true
            onClicked: pressEffect.restart()
        }
    }

    onIsPlayingChanged: {
        if (root.isPlaying) {
            returnToZero.stop()
            loopTimer.running = true
        } else {
            loopTimer.running = false
            let angle = rotatingIcon.currentRotation
            let remaining = (360 - (angle % 360)) % 360

            returnToZero.from = angle
            returnToZero.to = angle + remaining
            returnToZero.duration = 1200
            returnToZero.restart()
        }
    }
}
