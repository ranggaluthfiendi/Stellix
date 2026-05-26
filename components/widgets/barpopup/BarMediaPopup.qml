import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.core.state
import qs.components.utils
import qs.components.elements

Rectangle {
    id: root

    color: "transparent"

    property var mprisService: null
    property real s: Scales.uiScale

    readonly property var activePlayer: mprisService ? mprisService.activePlayer : null
    readonly property bool hasMedia: mprisService ? mprisService.hasPlayer : false
    readonly property string displayArtUrl: {
        if (mprisService && mprisService.artUrl && mprisService.artUrl !== "") return mprisService.artUrl
        return mprisService ? mprisService.persistentArtUrl : ""
    }

    readonly property int artSize: Theme.dp(80)
    readonly property int pad: Theme.dp(12)
    readonly property int gap: Theme.dp(10)
    readonly property int rightX: pad + artSize + gap
    readonly property int rightW: width - rightX - pad
    readonly property int rowH: Theme.dp(20)
    readonly property int btnSz: Theme.dp(28)
    readonly property int iconSz: Math.round(btnSz * 0.5)

    implicitHeight: pad + artSize + pad

    property string artKey: ""
    property string failedArtKey: ""

    onDisplayArtUrlChanged: {
        root.artKey = root.displayArtUrl
        root.failedArtKey = ""
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: BarLayoutState.barPopupRounded ? Theme.radiusMedium : 0
    }

    Rectangle {
        id: artBox
        x: root.pad; y: root.pad; width: root.artSize; height: root.artSize
        color: Theme.bgPrimary
        border.width: 1
        border.color: Theme.border
        radius: 0
        clip: true

        Image {
            id: art
            anchors.fill: parent
            source: (root.displayArtUrl && root.displayArtUrl !== root.failedArtKey) ? root.displayArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            cache: false
            asynchronous: true
            sourceSize.width: root.artSize
            sourceSize.height: root.artSize

            onStatusChanged: if (status === Image.Error) { root.failedArtKey = root.displayArtUrl; source = "" }
        }

        Text {
            anchors.centerIn: parent
            visible: !art.visible
            text: "♪"
            color: Theme.textMuted
            font.pixelSize: Math.round(24 * s)
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.activePlayer != null ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (root.activePlayer && root.activePlayer.canRaise) root.activePlayer.raise()
        }
    }

    ColumnLayout {
        x: root.rightX
        y: root.pad
        width: root.rightW
        spacing: Theme.dp(4)

        MarqueeText {
            Layout.fillWidth: true
            height: Theme.dp(16)
            text: root.hasMedia ? (mprisService ? mprisService.title : "") : "No media playing"
            textColor: Theme.textPrimary
            fontSize: 10
            fontScale: s
            scrolling: true
            textPadding: 0
        }

        MarqueeText {
            Layout.fillWidth: true
            height: Theme.dp(14)
            text: root.hasMedia ? (mprisService ? mprisService.artist : "") : ""
            textColor: Theme.textMuted
            fontSize: 9
            fontScale: s
            scrolling: true
            textPadding: 0
            visible: root.hasMedia
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(4)
            color: Theme.bgPrimary
            border.width: 1
            border.color: Theme.border

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: (mprisService && mprisService.length > 0) ? (mprisService.position / mprisService.length) * parent.width : 0
                color: Theme.accentSoft
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                enabled: root.activePlayer && root.activePlayer.canSeek
                onPressed: (mouse) => {
                    if (root.activePlayer && mprisService.length > 0)
                        root.activePlayer.position = (mouse.x / width) * mprisService.length
                }
            }
        }

        Row {
            spacing: Theme.dp(4)
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: 5
                delegate: Rectangle {
                    width: root.btnSz
                    height: root.btnSz
                    color: mouse.containsMouse ? Theme.border : Theme.bgPrimary
                    radius: Theme.dp(4)
                    border.width: 1
                    border.color: mouse.containsMouse ? Theme.textPrimary : Theme.border

                    Loader {
                        anchors.centerIn: parent
                        sourceComponent: index === 0 ? shuffleI : index === 1 ? prevI : index === 2 ? playI : index === 3 ? nextI : loopI
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!root.activePlayer) return
                            if (index === 0) root.activePlayer.shuffle = !root.activePlayer.shuffle
                            else if (index === 1) root.activePlayer.previous()
                            else if (index === 2) root.activePlayer.togglePlaying()
                            else if (index === 3) root.activePlayer.next()
                            else if (index === 4) {
                                if (root.activePlayer.loopState === MprisLoopState.None) root.activePlayer.loopState = MprisLoopState.Playlist
                                else if (root.activePlayer.loopState === MprisLoopState.Playlist) root.activePlayer.loopState = MprisLoopState.Track
                                else root.activePlayer.loopState = MprisLoopState.None
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: shuffleI
        IconShuffle {
            iconSize: root.iconSz
            iconColor: (root.activePlayer && root.activePlayer.shuffle) ? Theme.accent : Theme.textPrimary
        }
    }

    Component {
        id: prevI
        IconSkipPrev {
            iconSize: root.iconSz
            iconColor: Theme.textPrimary
        }
    }

    Component {
        id: playI
        Item {
            width: root.iconSz
            height: root.iconSz
            IconPlay {
                anchors.fill: parent
                iconColor: Theme.textPrimary
                visible: !root.activePlayer || !root.activePlayer.isPlaying
            }
            IconPause {
                anchors.fill: parent
                iconColor: Theme.textPrimary
                visible: root.activePlayer && root.activePlayer.isPlaying
            }
        }
    }

    Component {
        id: nextI
        IconSkipNext {
            iconSize: root.iconSz
            iconColor: Theme.textPrimary
        }
    }

    Component {
        id: loopI
        IconLoop {
            iconSize: root.iconSz
            iconColor: (root.activePlayer && root.activePlayer.loopState !== MprisLoopState.None) ? Theme.accent : Theme.textPrimary
        }
    }
}
