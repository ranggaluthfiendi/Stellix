import qs.components.utils
import QtQuick
import QtQuick.Shapes
import qs.config
import qs.components.elements
import qs.core.state
import Quickshell.Services.Mpris

Item {
    id: root

    property real s: Scales.uiScale * 0.6
    property color primary
    required property var player

    readonly property var mprisSvc: BarLayoutState.getItem("mprisService")

    function syncPlayback() {
        if (!root.player || !root.player.canControl) return
        root.player.togglePlaying()
    }

    Item {
        id: controlBox

        x: 212 * s
        y: 38 * s

        width: 20 * s
        height: 20 * s

        Rectangle {
            anchors.fill: parent
            color: ctrlMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent"
            radius: 4 * s

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        MouseArea {
            id: ctrlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: root.syncPlayback()
        }

        Item {
            width: 12 * s
            height: 12 * s

            x: (controlBox.width - width) / 2
            y: (controlBox.height - height) / 2

            Canvas {
                id: playCanvas
                anchors.fill: parent
                visible: !mprisSvc || !mprisSvc.isPlaying

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.fillStyle = ctrlMouse.containsMouse ? Theme.accent : root.primary
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, height / 2)
                    ctx.lineTo(0, height)
                    ctx.closePath()
                    ctx.fill()
                }

                Connections {
                    target: mprisSvc
                    function onIsPlayingChanged() { playCanvas.requestPaint() }
                }
            }

            Row {
                anchors.fill: parent
                spacing: width * 0.2
                visible: mprisSvc && mprisSvc.isPlaying

                Rectangle {
                    width: parent.width * 0.35
                    height: parent.height
                    color: ctrlMouse.containsMouse ? Theme.accent : root.primary
                    radius: 1 * s
                }

                Rectangle {
                    width: parent.width * 0.35
                    height: parent.height
                    color: ctrlMouse.containsMouse ? Theme.accent : root.primary
                    radius: 1 * s
                }
            }
        }
    }

    MarqueeText {
        id: titleMarquee
        x: 245 * s
        y: 24 * s
        width: 300 * s
        height: 28 * s
        text: mprisSvc ? mprisSvc.title : ""
        textColor: root.primary
        fontSize: 12
        fontScale: Scales.uiScale
        fontWeight: Font.Normal
        scrolling: true
        textPadding: 0
    }

    MarqueeText {
        id: artistMarquee
        x: 245 * s
        y: 52 * s
        width: 300 * s
        height: 24 * s
        text: mprisSvc ? mprisSvc.artist : ""
        textColor: root.primary
        fontSize: 10
        fontScale: Scales.uiScale
        fontWeight: Font.Bold
        scrolling: true
        textPadding: 0
    }

    property real contentWidth: {
        let w = Math.max(titleMarquee.textWidth, artistMarquee.textWidth)
        let minW = 300 * s
        return (w > minW ? w : minW) + 140 * s
    }
}
