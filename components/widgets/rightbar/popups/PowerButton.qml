import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root
    property real s: 1.0
    property string colorType: "default"
    property string buttonLabel: ""
    property string buttonIcon: ""
    signal execute()

    readonly property real holdDuration: 3000

    readonly property color activeColor: {
        if (root.colorType === "danger") return Theme.danger
        if (root.colorType === "warning") return Theme.warning
        if (root.colorType === "info") return Theme.accent
        return Theme.accent
    }

    height: Theme.dp(38)
    color: mouseArea.containsMouse && !root.confirming
        ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.08)
        : "transparent"
    border.width: 1
    border.color: root.confirming ? root.activeColor : (mouseArea.containsMouse ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.5) : Theme.border)
    radius: 0
    clip: true

    Behavior on color {
        ColorAnimation { duration: 120 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

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
        color: Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.2)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(8)
        spacing: Theme.dp(8)
        z: 1

        Text {
            text: root.buttonIcon
            color: root.confirming ? root.activeColor : (mouseArea.containsMouse ? root.activeColor : Theme.textPrimary)
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 13) * root.s)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        Text {
            text: root.confirming ? "Confirm to " + root.buttonLabel + "?" : root.buttonLabel
            color: root.confirming ? root.activeColor : (mouseArea.containsMouse ? root.activeColor : Theme.textPrimary)
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 10) * root.s)
            font.weight: root.confirming ? Font.Bold : Font.Normal
            Layout.fillWidth: true

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        Text {
            visible: root.confirming
            text: Math.ceil((1 - root.holdProgress) * root.holdDuration / 1000) + "s"
            color: root.activeColor
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 10) * root.s)
            font.weight: Font.Bold
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
