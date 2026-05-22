import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

ColumnLayout {
    id: root
    property string label: ""
    property real value: 0
    property color barColor: Theme.accent
    
    Layout.fillWidth: true
    spacing: 4
    
    RowLayout {
        Layout.fillWidth: true
        Text { text: root.label; color: Theme.textMuted; font.pixelSize: Theme.dp(8); Layout.preferredWidth: Theme.dp(80) }
        Item { Layout.fillWidth: true }
        Text { 
            text: Math.round(root.value*100) + "%"
            color: Theme.textPrimary; font.pixelSize: Theme.dp(8); font.weight: Font.Bold
            Layout.preferredWidth: Theme.dp(40); horizontalAlignment: Text.AlignRight
        }
    }
    
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.dp(6)
        color: Theme.border
        radius: 0 
        Rectangle {
            width: parent.width * Math.min(1.0, Math.max(0.0, root.value))
            height: parent.height
            color: root.barColor
            radius: 0
        }
    }
}
