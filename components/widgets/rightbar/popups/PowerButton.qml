import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root
    property real s: 1.0
    property bool danger: false
    property string buttonLabel: ""
    property string buttonIcon: ""
    signal execute()

    readonly property real holdDuration: 3000

    height: Theme.dp(38)
    color: "transparent"
    border.width: 1
    border.color: root.confirming ? Theme.danger : Theme.border
    radius: 0
    clip: true

    property bool confirming: false
    property real holdProgress: 0

    Timer {
        id: holdTimer
        interval: 16
        repeat: true
        onTriggered: {
            root.holdProgress += 16 / root.holdDuration
            if (root.holdProgress >= 1.0) {
                root.holdProgress = 1.0
                holdTimer.stop()
                root.confirming = false
                root.execute()
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * root.holdProgress
        color: root.danger ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.2) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(8)
        spacing: Theme.dp(8)
        z: 1

        Text {
            text: root.buttonIcon
            color: root.confirming ? Theme.danger : Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 13) * root.s)
        }

        Text {
            text: root.confirming ? "Confirm? " + Math.ceil((1 - root.holdProgress) * root.holdDuration / 1000) + "s" : root.buttonLabel
            color: root.confirming ? Theme.danger : Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 10) * root.s)
            font.weight: Typography.weightMedium || Font.Normal
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            root.confirming = true
            root.holdProgress = 0
            holdTimer.start()
        }

        onReleased: {
            root.confirming = false
            root.holdProgress = 0
            holdTimer.stop()
        }

        onExited: {
            if (root.confirming) {
                root.confirming = false
                root.holdProgress = 0
                holdTimer.stop()
            }
        }
    }
}
