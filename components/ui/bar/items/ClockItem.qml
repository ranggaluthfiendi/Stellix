import QtQuick
import Quickshell
import qs.services
import qs.config

Text {
    verticalAlignment: Text.AlignVCenter
    color: Theme.textPrimary
    font.family: Typography.fontFamily
    font.pixelSize: Typography.sizeMD

    text: Time.time
}
