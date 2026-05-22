import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: root
    property string label: ""
    property string target: ""
    property var keybindMap: null
    property string recordingTarget: ""
    property bool isRecording: false
    
    property int itemIndex: -1
    property bool isFocused: false
    
    signal recordClicked()

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.dp(44)
    color: isFocused ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : (kbMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05) : "transparent")
    border.width: isFocused ? 1 : 0
    border.color: Theme.accent
    radius: 0 

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.dp(16)
        anchors.rightMargin: Theme.dp(16)
        spacing: Theme.dp(12)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: root.label
                color: Theme.textPrimary
                font.pixelSize: Theme.dp(11)
                font.weight: Font.Medium
            }
            Text {
                text: "Click to change keybinding"
                color: Theme.textMuted
                font.pixelSize: Theme.dp(8)
            }
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.preferredHeight: Theme.dp(26)
            Layout.preferredWidth: Math.max(keyText.implicitWidth + Theme.dp(24), Theme.dp(90))
            color: root.recordingTarget === root.target ? Theme.accent : (kbMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : Theme.bgSecondary)
            border.width: 1
            border.color: root.recordingTarget === root.target ? Theme.accent : Theme.border
            radius: 0 

            Text {
                id: keyText
                anchors.centerIn: parent
                text: root.recordingTarget === root.target ? "PRESS KEY..." : (root.keybindMap[root.target] ? root.keybindMap[root.target].display : "NONE")
                color: root.recordingTarget === root.target ? Theme.bgPrimary : Theme.accent
                font.pixelSize: Theme.dp(9)
                font.weight: Font.Bold
            }

            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }
    }

    MouseArea {
        id: kbMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.recordClicked()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.border
        opacity: 0.1
    }
}
