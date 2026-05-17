import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root
    property real s: 1.0
    property string buttonLabel: ""
    property bool danger: false
    property bool requireHold: true
    signal execute()

    readonly property real holdDuration: 3000
    readonly property real minWidth: Theme.dp(60)

    implicitWidth: Math.max(lbl.implicitWidth + Theme.dp(16), minWidth)
    implicitHeight: Theme.dp(22)
    color: root.confirming ? (root.danger ? Theme.danger : Theme.accent) : Theme.bgPrimary
    border.width: 1
    border.color: root.confirming ? (root.danger ? Theme.danger : Theme.accent) : Theme.border
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
        color: root.danger ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.3) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
    }

    Text {
        id: lbl
        anchors.centerIn: parent
        text: root.confirming ? Math.ceil((1 - root.holdProgress) * root.holdDuration / 1000) + "s" : root.buttonLabel
        color: root.confirming ? "white" : (root.danger ? Theme.danger : Theme.textMuted)
        font.family: Typography.fontFamily
        font.pixelSize: Math.round((Typography.sizeXXS || 8) * root.s)
        font.weight: root.confirming ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            if (root.requireHold) {
                root.confirming = true
                root.holdProgress = 0
                holdTimer.start()
            } else {
                root.execute()
            }
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
