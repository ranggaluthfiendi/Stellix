import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config

SpinBox {
    id: control
    editable: true
    
    Layout.preferredWidth: Theme.dp(110)
    Layout.preferredHeight: Theme.dp(34)

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        font: control.font
        color: Theme.textPrimary
        selectionColor: Theme.accent
        selectedTextColor: Theme.bgPrimary
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        width: Theme.dp(30)
        color: control.up.pressed ? Theme.accent : (control.up.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent")
        border.width: 1
        border.color: Theme.accent
        radius: 0
        Text {
            text: "+"
            font.pixelSize: Theme.dp(14)
            color: control.up.pressed ? Theme.bgPrimary : Theme.accent
            anchors.centerIn: parent
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        width: Theme.dp(30)
        color: control.down.pressed ? Theme.accent : (control.down.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent")
        border.width: 1
        border.color: Theme.accent
        radius: 0
        Text {
            text: "-"
            font.pixelSize: Theme.dp(14)
            color: control.down.pressed ? Theme.bgPrimary : Theme.accent
            anchors.centerIn: parent
        }
    }

    background: Rectangle {
        implicitWidth: Theme.dp(110)
        border.width: 1
        border.color: Theme.border
        color: Theme.bgSecondary
        radius: 0
    }
}
