import qs.components.utils
import QtQuick
import Quickshell
import qs.config
import qs.components.elements
import qs.components.widgets.media.nowplaying
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopNowPlayingScale

    property real contentOffsetX: 20 * s
    property real rightOffset: 120 * s

    property color primary: Theme.accent
    property color secondary: Theme.surface

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    readonly property var pwService: BarLayoutState.getItem("pwService")
    readonly property real audioPeak: (media.player && media.player.isPlaying) ? (pwService ? pwService.audioPeak : 0) : 0
    readonly property var cavaBars: media.hasMedia ? CavaService.bars : []

    NowPlayingService {
        id: media
    }

    Item {
        id: container

        width: trackInfo.x + trackInfo.contentWidth + 20 * s
        height: 97 * s

        property real defaultX: 30 * s
        property real defaultY: screenH - height - 30 * s

        property real mediaOffset: media.hasMedia ? 0 : -(140 * s)

        x: BarLayoutState.desktopNowPlayingX
        y: BarLayoutState.desktopNowPlayingY
        rotation: BarLayoutState.desktopNowPlayingRotation

        opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopNowPlayingOpacity

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

            opacity: media.hasMedia ? (0.4 + root.audioPeak * 0.6) : 0.4

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        Item {
            x: container.mediaOffset
            width: 140 * s
            height: 97 * s
            clip: true

            property bool artHovered: false

            MouseArea {
                anchors.fill: parent
                hoverEnabled: media.hasMedia
                cursorShape: media.hasMedia && media.targetWorkspace > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                onEntered: parent.artHovered = true
                onExited: parent.artHovered = false
                onClicked: {
                    if (media.targetWorkspace > 0) {
                        media.goToMediaWorkspace()
                    }
                }
            }

            Image {
                id: coverArt

                anchors.fill: parent
                clip: true
                asynchronous: true

                source: media.hasMedia && media.localArtPath !== ""
                    ? "file://" + media.localArtPath
                    : (media.hasMedia && media.artUrl !== "" ? media.artUrl : "")
                fillMode: Image.PreserveAspectCrop

                visible: media.hasMedia && (media.localArtPath !== "" || media.artUrl !== "") && status !== Image.Error
                opacity: visible ? (parent.artHovered ? 0.35 : 1.0) : 0

                Behavior on source {
                    SequentialAnimation {
                        NumberAnimation { target: coverArt; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutCubic }
                        PropertyAction { target: coverArt; property: "source" }
                        NumberAnimation { target: coverArt; property: "opacity"; to: 1; duration: 250; easing.type: Easing.InCubic }
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                onStatusChanged: if (status === Image.Error) source = ""
            }

            // Blurred background for better contrast and "smart" look
            Image {
                id: blurredBg
                anchors.fill: parent
                z: -1
                source: coverArt.source
                fillMode: Image.PreserveAspectCrop
                visible: coverArt.visible
                opacity: 0.4
            }

            // --- Smooth Wave Visualizer Overlay ---
            // Only visible if there is NO cover art
            WaveVisualizer {
                id: smoothWave
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8 * s
                anchors.leftMargin: 10 * s
                anchors.rightMargin: 10 * s
                height: 40 * s
                z: 6
                active: media.hasMedia && media.player && media.player.isPlaying && !parent.artHovered && !media.hasArt
                waveColor: Theme.accent
                opacity: 0.8
            }

            Item {
                anchors.centerIn: parent
                width: 40 * s
                height: 40 * s
                visible: media.hasMedia && media.localArtPath === "" && media.artUrl === "" && !parent.artHovered
                // Wave already shown above
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.35)
                opacity: parent.artHovered ? 1 : 0
                visible: opacity > 0 && media.hasMedia
                z: 5

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 8 * s
                opacity: parent.artHovered ? 1 : 0
                visible: opacity > 0 && media.hasMedia
                z: 10

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                Image {
                    id: appIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 32 * s
                    height: 32 * s
                    source: {
                        var de = media.player ? media.player.desktopEntry : ""
                        if (de) {
                            var entry = DesktopEntries.byId(de)
                            if (entry && entry.icon) {
                                var p = Quickshell.iconPath(entry.icon, true)
                                if (p !== "") return p
                            }
                        }
                        return ""
                    }
                    visible: source !== "" && status === Image.Ready
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: !appIcon.visible
                    text: "♪"
                    color: Theme.textPrimary
                    font.pixelSize: 24 * s
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: media.identity || ""
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: 9 * s
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    width: 120 * s
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: wsIndicatorRow.implicitWidth + Theme.dp(8)
                    height: Theme.dp(16)
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                    border.width: 1
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
                    radius: Theme.dp(4)
                    visible: media.targetWorkspace > 0

                    Row {
                        id: wsIndicatorRow
                        anchors.centerIn: parent
                        spacing: 4 * s

                        IconWorkspaces {
                            iconSize: 10 * s
                            iconColor: Theme.accent
                        }

                        Text {
                            text: "WS " + media.targetWorkspace
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: 8 * s
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: media.goToMediaWorkspace()
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
            id: draggable
            anchors.fill: parent
            target: container

            boundWidth: root.screenW
            boundHeight: root.screenH

            defaultX: container.defaultX
            defaultY: container.defaultY

            currentX: BarLayoutState.desktopNowPlayingX
            currentY: BarLayoutState.desktopNowPlayingY
            onDragPositionChanged: (x, y) => {
                BarLayoutState.desktopNowPlayingX = x
                BarLayoutState.desktopNowPlayingY = y
            }
            onRotateAction: (r) => {
                BarLayoutState.desktopNowPlayingRotation = r
            }
        }
    }
}
