import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Text {
    property string title: ""
    text: title
    color: Theme.accent
    font.pixelSize: Theme.dp(10)
    font.weight: Font.Bold
    Layout.topMargin: Theme.dp(12)
    Layout.bottomMargin: Theme.dp(4)
    Layout.leftMargin: Theme.dp(4)
}
