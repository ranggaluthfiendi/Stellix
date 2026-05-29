import QtQuick
import qs.config

Column {
    id: root
    spacing: Theme.dp(4)

    property var currentDate: new Date()

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: root.currentDate = new Date()
    }

    Text {
        text: {
            const h = root.currentDate.getHours().toString().padStart(2, "0")
            const m = root.currentDate.getMinutes().toString().padStart(2, "0")
            return h + ":" + m
        }
        color: Theme.textPrimary
        font.family: Typography.fontFamily
        font.pixelSize: Theme.dp(48)
        font.weight: Typography.weightBold
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: Qt.formatDate(root.currentDate, "dddd, dd MMMM yyyy")
        color: Theme.textMuted
        font.family: Typography.fontFamily
        font.pixelSize: Typography.sizeSM
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
