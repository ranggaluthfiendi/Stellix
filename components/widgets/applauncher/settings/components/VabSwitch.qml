import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: root
    property bool checked: false
    signal toggled()
    Layout.preferredWidth: Theme.dp(50)
    Layout.preferredHeight: Theme.dp(28)
    width: Theme.dp(50)
    height: Theme.dp(28)
    radius: 0
    border.width: 1
    border.color: checked ? Theme.accent : Theme.border
    color: checked ? Theme.accent : "transparent"

    Rectangle {
        x: checked ? parent.width - width - 6 : 6
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.dp(16)
        height: Theme.dp(16)
        color: checked ? Theme.bgPrimary : Theme.textMuted
        radius: 0
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
