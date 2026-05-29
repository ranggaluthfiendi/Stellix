import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.config
import qs.core.state
import qs.components.utils

Rectangle {
    id: root
    width: Theme.dp(280)
    height: root.targetHeight
    radius: BarLayoutState.lockscreenMediaRadius
    color: root.styleBg
    border.width: Theme.borderWidth
    border.color: root.styleBorder
    visible: Mpris.players.values.length > 0
    clip: true

    property bool expanded: false
    property var mprisService: null
    property var currentPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property real targetHeight: Theme.dp(64)

    readonly property string artUrl: mprisService ? mprisService.artUrl : (currentPlayer ? currentPlayer.trackArtUrl : "")
    readonly property string title: mprisService ? mprisService.title : (currentPlayer ? currentPlayer.trackTitle : "")
    readonly property string artist: mprisService ? mprisService.artist : (currentPlayer ? currentPlayer.trackArtist : "")
    readonly property bool isPlaying: currentPlayer ? currentPlayer.isPlaying : false

    readonly property color styleBg: {
        switch (BarLayoutState.lockscreenMediaStyle) {
            case "card": return "transparent"
            case "minimal": return "transparent"
            case "full": return Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0.85)
            default: return Theme.bgSecondary
        }
    }

    readonly property color styleBorder: {
        switch (BarLayoutState.lockscreenMediaStyle) {
            case "card": return "transparent"
            case "minimal": return "transparent"
            default: return Theme.border
        }
    }

    readonly property color styleText: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : Theme.textPrimary
    readonly property color styleMuted: BarLayoutState.lockscreenMediaStyle === "card" ? Qt.rgba(255, 255, 255, 0.7) : Theme.textMuted
    readonly property color styleAccent: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : Theme.accent

    readonly property real expandedHeight: {
        switch (BarLayoutState.lockscreenMediaStyle) {
            case "card": return Theme.dp(180)
            case "minimal": return Theme.dp(140)
            case "full": return Theme.dp(200)
            default: return Theme.dp(140)
        }
    }

    readonly property real collapsedHeight: {
        switch (BarLayoutState.lockscreenMediaStyle) {
            case "card": return Theme.dp(64)
            case "minimal": return Theme.dp(56)
            case "full": return Theme.dp(64)
            default: return Theme.dp(64)
        }
    }

    Behavior on targetHeight {
        enabled: !expandAnim.running && !collapseAnim.running
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: expandAnim
        NumberAnimation {
            target: root
            property: "targetHeight"
            to: root.expandedHeight
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: collapseAnim
        NumberAnimation {
            target: root
            property: "targetHeight"
            to: root.collapsedHeight
            duration: 250
            easing.type: Easing.InCubic
        }
    }

    onExpandedChanged: {
        if (root.expanded) {
            collapseAnim.stop()
            expandAnim.restart()
        } else {
            expandAnim.stop()
            collapseAnim.restart()
        }
    }

    // CARD STYLE: Full art background
    Loader {
        anchors.fill: parent
        active: BarLayoutState.lockscreenMediaStyle === "card"
        sourceComponent: Item {
            Image {
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                opacity: 0.6
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.4)
            }

            WaveVisualizer {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.dp(4)
                height: Theme.dp(30)
                active: root.isPlaying
                waveColor: "#ffffff"
                opacity: 0.3
            }
        }
    }

    // FULL STYLE: Large art background blur
    Image {
        anchors.fill: parent
        source: root.artUrl
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        opacity: BarLayoutState.lockscreenMediaStyle === "full" ? 0.2 : 0
        visible: opacity > 0
    }

    // COMPACT / DEFAULT: Header row
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(32) : Theme.dp(48)
        color: "transparent"
        visible: !root.expanded && BarLayoutState.lockscreenMediaStyle !== "card"

        RowLayout {
            anchors.fill: parent
            anchors.margins: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(4) : Theme.dp(8)
            spacing: Theme.dp(8)

            ClippingWrapperRectangle {
                Layout.preferredWidth: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(24) : Theme.dp(32)
                Layout.preferredHeight: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(24) : Theme.dp(32)
                Layout.alignment: Qt.AlignVCenter
                radius: Theme.radiusSmall
                color: Theme.bgPrimary
                visible: BarLayoutState.lockscreenMediaShowAlbumArt && BarLayoutState.lockscreenMediaStyle !== "minimal"

                Image {
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.bgPrimary
                        visible: parent.status !== Image.Ready
                        Text {
                            anchors.centerIn: parent
                            text: "music_note"
                            font.family: Typography.materialSymbols
                            font.styleName: "Regular"
                            font.pixelSize: Theme.dp(16)
                            color: Theme.textMuted
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Theme.dp(2)

                MarqueeText {
                    Layout.fillWidth: true
                    height: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(14) : Theme.dp(16)
                    text: root.title
                    textColor: root.styleText
                    fontSize: BarLayoutState.lockscreenMediaStyle === "minimal" ? Typography.sizeXS : Typography.sizeSM
                    fontWeight: Typography.weightMedium
                    fontScale: 1
                    scrolling: true
                }

                MarqueeText {
                    Layout.fillWidth: true
                    height: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(12) : Theme.dp(14)
                    text: root.artist
                    textColor: root.styleMuted
                    fontSize: BarLayoutState.lockscreenMediaStyle === "minimal" ? Typography.sizeXXS : Typography.sizeXS
                    fontScale: 1
                    scrolling: true
                    visible: BarLayoutState.lockscreenMediaStyle !== "minimal"
                }
            }

            Row {
                id: controlsRow
                Layout.alignment: Qt.AlignVCenter
                spacing: Theme.dp(2)
                visible: BarLayoutState.lockscreenMediaShowControls

                LockMediaBtn {
                    icon: "skip_previous"
                    iconSize: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(14) : Theme.dp(16)
                    iconColor: root.styleText
                    onClicked: { if (root.currentPlayer && root.currentPlayer.canGoPrevious) root.currentPlayer.previous() }
                }
                LockMediaBtn {
                    icon: root.isPlaying ? "pause" : "play_arrow"
                    iconSize: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(14) : Theme.dp(16)
                    iconColor: root.styleAccent
                    onClicked: { if (root.currentPlayer && root.currentPlayer.canTogglePlaying) root.currentPlayer.togglePlaying() }
                }
                LockMediaBtn {
                    icon: "skip_next"
                    iconSize: BarLayoutState.lockscreenMediaStyle === "minimal" ? Theme.dp(14) : Theme.dp(16)
                    iconColor: root.styleText
                    onClicked: { if (root.currentPlayer && root.currentPlayer.canGoNext) root.currentPlayer.next() }
                }
            }
        }
    }

    // CARD STYLE: Compact header
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.dp(48)
        color: "transparent"
        visible: !root.expanded && BarLayoutState.lockscreenMediaStyle === "card"

        Row {
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(8)

            ClippingWrapperRectangle {
                width: Theme.dp(32)
                height: Theme.dp(32)
                anchors.verticalCenter: parent.verticalCenter
                radius: Theme.radiusSmall
                color: Qt.rgba(255, 255, 255, 0.15)

                Image {
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0.5)
                        visible: parent.status !== Image.Ready
                        Text {
                            anchors.centerIn: parent
                            text: "music_note"
                            font.family: Typography.materialSymbols
                            font.styleName: "Regular"
                            font.pixelSize: Theme.dp(16)
                            color: "#ffffff"
                        }
                    }
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.dp(32) - Theme.dp(8) - cardControlsRow.implicitWidth
                spacing: Theme.dp(2)

                MarqueeText {
                    width: parent.width
                    height: Theme.dp(16)
                    text: root.title
                    textColor: "#ffffff"
                    fontSize: Typography.sizeSM
                    fontWeight: Typography.weightMedium
                    fontScale: 1
                    scrolling: true
                }

                MarqueeText {
                    width: parent.width
                    height: Theme.dp(14)
                    text: root.artist
                    textColor: Qt.rgba(255, 255, 255, 0.7)
                    fontSize: Typography.sizeXS
                    fontScale: 1
                    scrolling: true
                }
            }

            Row {
                id: cardControlsRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.dp(2)

                LockMediaBtn {
                    icon: "skip_previous"
                    iconSize: Theme.dp(16)
                    iconColor: "#ffffff"
                    onClicked: { if (root.currentPlayer && root.currentPlayer.canGoPrevious) root.currentPlayer.previous() }
                }
                LockMediaBtn {
                    icon: root.isPlaying ? "pause" : "play_arrow"
                    iconSize: Theme.dp(16)
                    iconColor: "#ffffff"
                    onClicked: { if (root.currentPlayer && root.currentPlayer.canTogglePlaying) root.currentPlayer.togglePlaying() }
                }
                LockMediaBtn {
                    icon: "skip_next"
                    iconSize: Theme.dp(16)
                    iconColor: "#ffffff"
                    onClicked: { if (root.currentPlayer && root.currentPlayer.canGoNext) root.currentPlayer.next() }
                }
            }
        }
    }

    // EXPANDED CONTENT
    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.dp(8)
        anchors.bottomMargin: Theme.dp(30)
        spacing: Theme.dp(6)
        visible: root.expanded

        // FULL STYLE: Large art
        ClippingWrapperRectangle {
            width: Theme.dp(80)
            height: Theme.dp(80)
            radius: Theme.radiusMedium
            color: Theme.bgPrimary
            anchors.horizontalCenter: parent.horizontalCenter
            visible: BarLayoutState.lockscreenMediaStyle === "full" && BarLayoutState.lockscreenMediaShowAlbumArt

            Image {
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true

                Rectangle {
                    anchors.fill: parent
                    color: Theme.bgPrimary
                    visible: parent.status !== Image.Ready
                    Text {
                        anchors.centerIn: parent
                        text: "music_note"
                        font.family: Typography.materialSymbols
                        font.styleName: "Regular"
                        font.pixelSize: Theme.dp(32)
                        color: Theme.textMuted
                    }
                }
            }
        }

        // Title & Artist
        Column {
            width: parent.width
            spacing: Theme.dp(2)
            anchors.horizontalCenter: parent.horizontalCenter
            visible: BarLayoutState.lockscreenMediaStyle !== "minimal"

            MarqueeText {
                width: parent.width
                height: BarLayoutState.lockscreenMediaStyle === "full" ? Theme.dp(22) : Theme.dp(18)
                text: root.title
                textColor: root.styleText
                fontSize: BarLayoutState.lockscreenMediaStyle === "full" ? Typography.sizeMD : Typography.sizeSM
                fontWeight: Typography.weightBold
                fontScale: 1
                scrolling: true
            }

            MarqueeText {
                width: parent.width
                height: BarLayoutState.lockscreenMediaStyle === "full" ? Theme.dp(16) : Theme.dp(14)
                text: root.artist
                textColor: root.styleMuted
                fontSize: BarLayoutState.lockscreenMediaStyle === "full" ? Typography.sizeSM : Typography.sizeXS
                fontScale: 1
                scrolling: true
            }
        }

        // Progress bar
        Column {
            width: parent.width
            spacing: Theme.dp(4)
            visible: BarLayoutState.lockscreenMediaShowProgress

            Rectangle {
                width: parent.width
                height: Theme.dp(4)
                radius: Theme.dp(2)
                color: BarLayoutState.lockscreenMediaStyle === "card" ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(root.styleText.r, root.styleText.g, root.styleText.b, 0.15)

                Rectangle {
                    width: {
                        var pos = mprisService ? mprisService.position : (root.currentPlayer ? root.currentPlayer.position : 0)
                        var len = mprisService ? mprisService.length : (root.currentPlayer ? root.currentPlayer.length : 0)
                        return len > 0 ? (pos / len) * parent.width : 0
                    }
                    height: parent.height
                    radius: Theme.dp(2)
                    color: root.styleAccent
                    Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -Theme.dp(4)
                    onClicked: (mouse) => {
                        var len = mprisService ? mprisService.length : (root.currentPlayer ? root.currentPlayer.length : 0)
                        if (root.currentPlayer && len > 0) {
                            root.currentPlayer.position = (mouse.x / width) * len
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: Theme.dp(4)
                Text {
                    id: timeLeft
                    text: formatTime(mprisService ? mprisService.position : (root.currentPlayer ? root.currentPlayer.position : 0))
                    font.family: Typography.fontFamily
                    font.pixelSize: Typography.sizeXXS
                    color: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleMuted
                }
                Item { width: parent.width - timeLeft.implicitWidth - timeRight.implicitWidth - Theme.dp(4); height: 1 }
                Text {
                    id: timeRight
                    text: formatTime(mprisService ? mprisService.length : (root.currentPlayer ? root.currentPlayer.length : 0))
                    font.family: Typography.fontFamily
                    font.pixelSize: Typography.sizeXXS
                    color: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleMuted
                }
            }
        }

        // Controls
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.dp(4)
            visible: BarLayoutState.lockscreenMediaShowControls

            LockMediaBtn {
                icon: "shuffle"
                iconSize: Theme.dp(18)
                iconColor: root.currentPlayer && root.currentPlayer.shuffle ? root.styleAccent : (BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleMuted)
                onClicked: { if (root.currentPlayer) root.currentPlayer.shuffle = !root.currentPlayer.shuffle }
            }

            LockMediaBtn {
                icon: "skip_previous"
                iconSize: Theme.dp(18)
                iconColor: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleText
                onClicked: { if (root.currentPlayer && root.currentPlayer.canGoPrevious) root.currentPlayer.previous() }
            }

            LockMediaBtn {
                icon: root.isPlaying ? "pause" : "play_arrow"
                iconSize: Theme.dp(18)
                iconColor: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleAccent
                onClicked: { if (root.currentPlayer && root.currentPlayer.canTogglePlaying) root.currentPlayer.togglePlaying() }
            }

            LockMediaBtn {
                icon: "skip_next"
                iconSize: Theme.dp(18)
                iconColor: BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleText
                onClicked: { if (root.currentPlayer && root.currentPlayer.canGoNext) root.currentPlayer.next() }
            }

            LockMediaBtn {
                icon: {
                    if (!root.currentPlayer) return "repeat"
                    if (root.currentPlayer.loopState === MprisLoopState.None) return "repeat"
                    if (root.currentPlayer.loopState === MprisLoopState.Playlist) return "repeat"
                    return "repeat_one"
                }
                iconSize: Theme.dp(18)
                iconColor: root.currentPlayer && root.currentPlayer.loopState !== MprisLoopState.None ? root.styleAccent : (BarLayoutState.lockscreenMediaStyle === "card" ? "#ffffff" : root.styleMuted)
                onClicked: {
                    if (!root.currentPlayer) return
                    if (root.currentPlayer.loopState === MprisLoopState.None) root.currentPlayer.loopState = MprisLoopState.Playlist
                    else if (root.currentPlayer.loopState === MprisLoopState.Playlist) root.currentPlayer.loopState = MprisLoopState.Track
                    else root.currentPlayer.loopState = MprisLoopState.None
                }
            }
        }
    }

    // Expand button
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.dp(4)
        width: Theme.dp(20)
        height: Theme.dp(20)
        radius: Theme.radiusSmall
        color: expandMouse.containsMouse ? root.styleAccent : "transparent"
        z: 10
        visible: BarLayoutState.lockscreenMediaStyle !== "minimal"

        Text {
            anchors.centerIn: parent
            text: root.expanded ? "arrow_drop_up" : "arrow_drop_down"
            font.family: Typography.materialSymbols
            font.styleName: "Regular"
            font.pixelSize: Theme.dp(14)
            color: expandMouse.containsMouse ? (BarLayoutState.lockscreenMediaStyle === "card" ? "#000000" : root.styleBg) : root.styleMuted
        }

        MouseArea {
            id: expandMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    function formatTime(sec) {
        if (!sec || sec <= 0) return "0:00"
        var totalSec = Math.floor(sec)
        var min = Math.floor(totalSec / 60)
        var s = totalSec % 60
        return min + ":" + (s < 10 ? "0" : "") + s
    }
}
