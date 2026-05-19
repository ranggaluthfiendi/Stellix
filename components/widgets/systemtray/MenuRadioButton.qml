import QtQuick
import qs.config

Rectangle {
    property var checkState: Qt.Unchecked

    width: Theme.dp(12)
    height: Theme.dp(12)
    radius: width / 2

    color: Qt.rgba(
        Theme.textMuted.r,
        Theme.textMuted.g,
        Theme.textMuted.b,
        0.3
    )

    Rectangle {
        anchors.centerIn: parent
        width: Theme.dp(5)
        height: Theme.dp(5)
        radius: width / 2

        visible: checkState === Qt.Checked

        color: Theme.textPrimary
    }
}
