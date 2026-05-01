import QtQuick
import qs.config
import qs.components.elements
import qs.components.widgets.media.nowplaying
import Quickshell.Services.Mpris

Item {
    id: root

    property real scale: Appearance.scaleFactor
    property real s: scale * 0.6
    property real coverMarginRight: 8 * s

    property real rightOffset: 120 * s

    property color primary: "#d7d1b8"
    property color secondary: "#47443b"

    property var player: null

    property string currentTitle: ""
    property string currentArt: ""

    property bool hasMedia: currentTitle.length > 0
    property bool hasArt: currentArt !== ""

    function pickPlayer() {
        let found = null
        for (let p of Mpris.players.values) {
            if (p.isPlaying) {
                found = p
                break
            }
        }
        if (!found && Mpris.players.values.length > 0) {
            found = Mpris.players.values[0]
        }
        player = found
    }

    function updateState() {
        if (!player) {
            currentTitle = ""
            currentArt = ""
            return
        }

        let newTitle = player.trackTitle || ""
        let newArt = player.trackArtUrl || ""

        if (currentTitle !== newTitle)
            currentTitle = newTitle

        if (currentArt !== newArt)
            currentArt = newArt
    }

    Timer {
        interval: root.player && root.player.isPlaying ? 250 : 1000
        running: true
        repeat: true
        onTriggered: {
            root.pickPlayer()
            root.updateState()
        }
    }

    Connections {
        target: root.player ? root.player : null
        function onTrackChanged() { root.updateState() }
        function onPostTrackChanged() { root.updateState() }
        function onTrackArtUrlChanged() { root.updateState() }
        function onPlaybackStateChanged() { root.pickPlayer() }
    }

    Component.onCompleted: {
        pickPlayer()
        updateState()
    }

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    Item {
        id: container

        width: 813 * s
        height: 97 * s

        property real defaultX: 30 * s
        property real defaultY: screenH - height - 30 * s

        x: defaultX
        y: defaultY

        BackgroundBox {
            s: root.s
            secondary: root.secondary
            contentWidth: trackInfo.contentWidth
        }

        SeparatorLines {
            s: root.s
            secondary: root.secondary
            contentWidth: trackInfo.contentWidth
        }

        LeftBars {
            s: root.s
            primary: root.primary
        }

        ArrowShape {
            id: arrow
            x: 145 * s
            y: 29 * s
            s: root.s
            primary: root.primary
            background: root.secondary

            opacity: root.hasMedia ? 1 : 0.4

            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation { from: 1; to: 0.4; duration: 900 }
                NumberAnimation { from: 0.4; to: 1; duration: 900 }
            }
        }

        Item {
            width: 140 * s
            height: 97 * s
            clip: true

            Image {
                x: -coverMarginRight / 2
                width: 136 * s
                height: 97 * s
                source: root.currentArt
                fillMode: Image.PreserveAspectCrop

                visible: root.hasMedia && root.hasArt
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            Item {
                anchors.centerIn: parent
                width: 40 * s
                height: 40 * s
                visible: root.hasMedia && !root.hasArt

                Row {
                    anchors.centerIn: parent
                    spacing: 4 * s

                    Repeater {
                        model: 4
                        Rectangle {
                            width: 8 * s
                            height: 70 * s
                            color: root.primary
                            opacity: 0.6

                            anchors.verticalCenter: parent.verticalCenter

                            transform: Scale {
                                id: scaleTransform
                                origin.y: height / 2
                            }

                            SequentialAnimation {
                                running: true
                                loops: Animation.Infinite

                                NumberAnimation {
                                    target: scaleTransform
                                    property: "yScale"
                                    from: 0.4
                                    to: 1.4
                                    duration: 300 + index * 120
                                }

                                NumberAnimation {
                                    target: scaleTransform
                                    property: "yScale"
                                    from: 1.4
                                    to: 0.4
                                    duration: 300 + index * 120
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: "No\nMedia"
                anchors.centerIn: parent
                color: root.primary

                visible: !root.hasMedia
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }

        TrackInfo {
            id: trackInfo
            s: root.s
            primary: root.primary
            player: root.player

            opacity: root.hasMedia ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        MouseArea {
            anchors.fill: parent
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

                let now = Date.now()

                if (now - lastClickTime < 300) {
                    container.x = container.defaultX
                    container.y = container.defaultY
                }

                lastClickTime = now
            }

            onPositionChanged: function(mouse) {
                if (!dragging) return

                let newX = container.x + mouse.x - offsetX
                let newY = container.y + mouse.y - offsetY

                const maxX = screenW - container.width + root.rightOffset
                const maxY = screenH - container.height

                container.x = Math.max(0, Math.min(newX, maxX))
                container.y = Math.max(0, Math.min(newY, maxY))
            }
        }
    }
}
