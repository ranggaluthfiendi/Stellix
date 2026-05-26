import QtQuick
import QtQuick.Layouts
import qs.config
import qs.core.state
import qs.core.settings
import qs.components.utils

Item {
    id: root

    property real s: 1.0
    property var rootItem: null

    height: Theme.dp(32)
    width: contentRow.implicitWidth + Theme.dp(8)

    readonly property bool isPlaying: rootItem ? rootItem.isPlaying : false
    readonly property bool hasMedia: rootItem ? rootItem.hasMedia : false
    readonly property string title: rootItem ? rootItem.title : ""
    readonly property string artist: rootItem ? rootItem.artist : ""
    readonly property bool isExpanded: rootItem ? rootItem.expanded : false
    readonly property bool expandRight: BarLayoutState.barMediaExpandDirection === "right"

    RowLayout {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.dp(4)
        anchors.rightMargin: Theme.dp(4)
        spacing: root.isExpanded ? Theme.dp(6) : 0

        Behavior on spacing {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        layoutDirection: root.expandRight ? Qt.LeftToRight : Qt.RightToLeft

        Item {
            id: rotatingIcon
            Layout.preferredWidth: Theme.dp(18)
            Layout.preferredHeight: Theme.dp(18)
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

            transform: Scale {
                id: scaleTransform
                origin.x: rotatingIcon.width / 2
                origin.y: rotatingIcon.height / 2
                xScale: 1.0
                yScale: 1.0
            }

            SequentialAnimation {
                id: pressEffect
                running: false
                NumberAnimation {
                    target: scaleTransform
                    property: "xScale"
                    to: 0.85
                    duration: 60
                }
                NumberAnimation {
                    target: scaleTransform
                    property: "xScale"
                    to: 1.0
                    duration: 80
                }
                NumberAnimation {
                    target: scaleTransform
                    property: "yScale"
                    to: 0.85
                    duration: 60
                }
                NumberAnimation {
                    target: scaleTransform
                    property: "yScale"
                    to: 1.0
                    duration: 80
                }
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
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pressEffect.restart()

                    if (rootItem && rootItem.expanded) {
                        rootItem.expanded = false
                        if (BarPopupState.mediaPopupOpen) {
                            BarPopupState.mediaPopupOpen = false
                        }
                    } else if (rootItem) {
                        rootItem.expanded = true
                    }
                }
            }
        }

        Item {
            id: textContainer
            Layout.preferredWidth: root.isExpanded ? textCol.implicitWidth : 0
            Layout.preferredHeight: textCol.implicitHeight

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            clip: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                visible: root.isExpanded
                onClicked: {
                    BarPopupState.mediaPopupOpen = !BarPopupState.mediaPopupOpen
                }
            }

            Column {
                id: textCol
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                MarqueeText {
                    width: Theme.dp(100)
                    height: Theme.dp(12)
                    text: root.hasMedia ? root.title : "No media"
                    textColor: Theme.textPrimary
                    fontSize: 9
                    fontScale: root.s
                    scrolling: true
                    textPadding: 0
                }

                Text {
                    width: Theme.dp(100)
                    text: root.hasMedia ? root.artist : ""
                    color: Theme.textMuted
                    font.pixelSize: Math.round(7 * root.s)
                    elide: Text.ElideRight
                    visible: root.hasMedia
                }
            }
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
