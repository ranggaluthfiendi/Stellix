import QtQuick
import QtQuick.Layouts
import qs.components.elements
import qs.config

RowLayout {
    spacing: 6

    Text {
        text: "Menu"
        color: Theme.textPrimary
        font.family: Typography.fontFamily
        font.pixelSize: Typography.sizeMD
    }

    StarShape {
        width: 16
        height: 16
        color: Theme.textPrimary
    }
}
