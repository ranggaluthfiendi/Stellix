import QtQuick

Item {
    id: timeFloating

    property string time: "00:00"
    property string date: ""

    function updateTime() {
        const now = new Date()
        time = Qt.formatTime(now, "hh:mm")
        date = Qt.formatDate(now, "ddd dd • MMMM • yyyy").toUpperCase()
    }

    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
    }
}
