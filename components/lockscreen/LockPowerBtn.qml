import QtQuick
import qs.config

Rectangle {
    id: root
    width: size
    height: size
    radius: Theme.radiusSmall
    color: ma.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
    border.width: Theme.borderWidth
    border.color: Theme.border

    property real size: Theme.dp(36)
    property string icon: ""
    property string label: ""

    signal clicked()

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Typography.materialSymbols
        font.styleName: "Regular"
        font.pixelSize: Theme.dp(18)
        color: Theme.textSecondary
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
