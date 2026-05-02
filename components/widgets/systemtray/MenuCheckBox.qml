import QtQuick
import qs.config

Rectangle {
    property var checkState: Qt.Unchecked

    width: Theme.dp(14)
    height: Theme.dp(14)
    radius: Theme.dp(2)

    color: Qt.rgba(
        Theme.textMuted.r,
        Theme.textMuted.g,
        Theme.textMuted.b,
        0.3
    )

    Rectangle {
        anchors.centerIn: parent
        width: Theme.dp(8)
        height: Theme.dp(8)

        visible: checkState === Qt.Checked

        color: Theme.textPrimary
    }
}
