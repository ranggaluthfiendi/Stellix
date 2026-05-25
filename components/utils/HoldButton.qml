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

    readonly property real holdDuration: root.requireHold ? 1000 : 0
    readonly property real minWidth: Theme.dp(64)

    implicitWidth: Math.max(lbl.implicitWidth + Theme.dp(20), minWidth)
    implicitHeight: Theme.dp(26)
    
    color: {
        if (root.confirming) return root.danger ? Theme.danger : Theme.accent
        if (mouseArea.containsMouse) return root.danger ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.2) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
        return Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.04)
    }
    
    border.width: 1
    border.color: {
        if (root.confirming) return "transparent"
        if (mouseArea.containsMouse) return root.danger ? Theme.danger : Theme.accent
        return Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
    }
    
    radius: 0
    clip: true

    property bool confirming: false
    property real holdProgress: 0

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

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
        color: root.danger ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.4) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
        visible: root.confirming
    }

    Text {
        id: lbl
        anchors.centerIn: parent
        text: root.confirming ? Math.ceil((1 - root.holdProgress) * root.holdDuration / 1000).toString() : root.buttonLabel
        color: root.confirming ? "white" : (mouseArea.containsMouse ? (root.danger ? Theme.danger : Theme.accent) : Theme.textSecondary)
        font.family: Typography.fontFamily
        font.pixelSize: Math.round(9 * root.s)
        font.weight: (root.confirming || mouseArea.containsMouse) ? Font.Bold : Font.Normal
    }

    MouseArea {
        id: mouseArea
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
