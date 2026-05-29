import QtQuick
import qs.config

Rectangle {
    id: root
    width: Theme.dp(32)
    height: Theme.dp(32)
    radius: width / 2
    color: ma.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : "transparent"

    property string icon: ""
    property color iconColor: Theme.textPrimary
    property real iconSize: Theme.dp(18)
    signal clicked()

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Typography.materialSymbols
        font.styleName: "Regular"
        font.pixelSize: root.iconSize
        color: root.iconColor
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
