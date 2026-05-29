import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root
    width: size
    height: size + labelText.implicitHeight + Theme.dp(4)
    radius: Theme.radiusMedium
    color: ma.containsMouse
        ? (active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08))
        : (active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : Theme.bgSecondary)
    border.width: Theme.borderWidth
    border.color: active ? Theme.accent : Theme.border

    property real size: Theme.dp(40)
    property string icon: ""
    property string label: ""
    property bool active: false

    signal toggled()

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.dp(4)

        Text {
            text: root.icon
            font.family: Typography.materialSymbols
            font.styleName: "Regular"
            font.pixelSize: Theme.dp(18)
            color: root.active ? Theme.accent : Theme.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: labelText
            text: root.label
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeXXS
            color: root.active ? Theme.accent : Theme.textMuted
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
