import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: root
    property string text: ""
    signal clicked()
    Layout.preferredHeight: Theme.dp(34)
    Layout.preferredWidth: Math.max(bt.implicitWidth + Theme.dp(24), Theme.dp(80))
    radius: 0
    color: btnMouse.pressed ? Theme.accent : (btnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12) : "transparent")
    border.width: 1
    border.color: Theme.accent

    Text {
        id: bt
        anchors.centerIn: parent
        text: root.text
        color: btnMouse.pressed ? Theme.bgPrimary : Theme.accent
        font.pixelSize: Theme.dp(10)
        font.weight: Font.Bold
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
