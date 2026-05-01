import QtQuick
import qs.config
import qs.components.elements
import qs.components.widgets.media.nowplaying
import qs.services

Item {
    id: root

    property real scale: Appearance.scaleFactor
    property real s: scale * 0.6

    property real contentOffsetX: 20 * s
    property real rightOffset: 120 * s

    property color primary: Theme.accent
    property color secondary: Theme.surface

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    NowPlayingService {
        id: media
    }

    Item {
        id: container

        width: 700 * s
        height: 97 * s

        property real defaultX: 30 * s
        property real defaultY: screenH - height - 30 * s

        property real mediaOffset: media.hasMedia ? 0 : -(140 * s)

        x: defaultX
        y: defaultY

        layer.enabled: true
        layer.smooth: true

        Behavior on mediaOffset {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        BackgroundBox {
            x: root.contentOffsetX + container.mediaOffset
            s: root.s
            secondary: Theme.surface
            contentWidth: trackInfo.contentWidth
        }

        SeparatorLines {
            x: root.contentOffsetX + container.mediaOffset
            s: root.s
            secondary: Theme.border
            contentWidth: trackInfo.contentWidth
        }

        LeftBars {
            x: root.contentOffsetX + container.mediaOffset
            s: root.s
            primary: Theme.accent
        }

        ArrowShape {
            id: arrow
            x: (145 * s) + root.contentOffsetX + container.mediaOffset
            y: 29 * s
            s: root.s
            primary: Theme.accent
            background: Theme.surface

            opacity: media.hasMedia ? 1 : 0.4

            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation { from: 1; to: 0.4; duration: 900 }
                NumberAnimation { from: 0.4; to: 1; duration: 900 }
            }
        }

        Item {
            x: container.mediaOffset
            width: 140 * s
            height: 97 * s
            clip: true

            Image {
                id: coverArt

                width: (97 * s) * (16 / 9)
                height: 97 * s
                clip: true

                source: media.artUrl
                fillMode: Image.PreserveAspectCrop

                visible: media.hasMedia && media.hasArt
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            Item {
                anchors.centerIn: parent
                width: 40 * s
                height: 40 * s
                visible: media.hasMedia && !media.hasArt

                Row {
                    anchors.centerIn: parent
                    spacing: 4 * s

                    Repeater {
                        model: 12
                        Rectangle {
                            width: 8 * s
                            height: 70 * s
                            color: Theme.accent
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
        }

        TrackInfo {
            id: trackInfo
            s: root.s
            primary: Theme.textPrimary
            player: media.player

            x: (5 * s) + root.contentOffsetX + container.mediaOffset

            opacity: media.hasMedia ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        Draggable {
            anchors.fill: parent
            target: container

            boundWidth: root.screenW
            boundHeight: root.screenH

            defaultX: container.defaultX
            defaultY: container.defaultY
        }
    }
}
