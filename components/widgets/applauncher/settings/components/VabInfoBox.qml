import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    Layout.fillWidth: true
    Layout.preferredHeight: Theme.dp(70)
    color: Theme.bgSecondary
    border.width: 1
    border.color: Theme.border
    radius: 0 
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.dp(4)
        Text { text: root.label; color: Theme.textMuted; font.pixelSize: Theme.dp(9); Layout.alignment: Qt.AlignHCenter }
        Text { text: root.value; color: Theme.textPrimary; font.bold: true; font.pixelSize: Theme.dp(11); Layout.alignment: Qt.AlignHCenter }
    }
}
