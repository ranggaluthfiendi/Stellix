pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm")
    }

    readonly property string timezone: "WIB"

    readonly property string fullTime: {
        Qt.formatDateTime(clock.date, "HH:mm")
    }

    readonly property string date: {
        Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
    }

    readonly property date currentDate: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
