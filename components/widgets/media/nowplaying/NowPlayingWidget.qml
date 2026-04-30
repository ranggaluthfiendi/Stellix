import QtQuick
import qs.config
import qs.components.elements
import qs.components.widgets.media.nowplaying

Item {
    id: root

    property real scale: Appearance.scaleFactor
    property real s: scale * 0.6

    property color primary: "#d7d1b8"
    property color secondary: "#47443b"

    property string trackTitle: "怪獣の腕のなか - きのこ帝国 Covered by 理芽 / RIM｜from 神椿"
    property string artist: "RIM"

    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    readonly property real screenW: root.window ? root.window.width : width
    readonly property real screenH: root.window ? root.window.height : height

    Item {
        id: container

        width: 813 * s
        height: 97 * s

        // posisi default (bottom-left)
        x: 0
        y: screenH - height

        function resetPosition() {
            x = 0
            y = screenH - height
        }

        BackgroundBox {
            s: root.s
            secondary: root.secondary
        }

        SeparatorLines {
            s: root.s
            secondary: root.secondary
        }

        LeftBars {
            s: root.s
            primary: root.primary
        }

        ArrowShape {
            x: 145 * s
            y: 29 * s
            s: root.s
            primary: root.primary
            background: root.secondary
        }

        Text {
            x: 0
            y: 7 * s

            text: "Now\nPlaying"
            color: root.primary

            font.family: Typography.fontFamily
            font.pixelSize: 30 * s

            horizontalAlignment: Text.AlignRight
        }

        TrackInfo {
            s: root.s
            primary: root.primary
            trackTitle: root.trackTitle
            artist: root.artist
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton

            property real offsetX: 0
            property real offsetY: 0
            property bool dragging: false
            property double lastClickTime: 0

            onPressed: function(mouse) {
                offsetX = mouse.x
                offsetY = mouse.y
                dragging = true
            }

            onReleased: function(mouse) {
                dragging = false

                const now = Date.now()
                if (now - lastClickTime < 300) {
                    container.resetPosition()
                }
                lastClickTime = now
            }

            onPositionChanged: function(mouse) {
                if (!dragging) return

                let newX = container.x + mouse.x - offsetX
                let newY = container.y + mouse.y - offsetY

                const maxX = screenW - container.width
                const maxY = screenH - container.height

                container.x = Math.max(0, Math.min(newX, maxX))
                container.y = Math.max(0, Math.min(newY, maxY))
            }
        }
    }
}
