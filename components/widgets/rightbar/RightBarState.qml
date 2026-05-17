pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: root
    width: 0; height: 0
    visible: false

    property bool open: false
    property bool calendarOpen: false
    property bool workspaceSwitcherOpen: false
    property bool dndEnabled: false
    property int calendarMonthOffset: 0
    property bool notifPanelRequested: false
    // Updated by BatteryRightBar's NotificationServer
    property int notifCount: 0

    readonly property string dndPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/dnd-state.json"

    StdioCollector { id: dndReadOut }
    StdioCollector { id: dndWriteOut }

    Process {
        id: dndRead
        stdout: dndReadOut
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                try {
                    var data = JSON.parse(dndReadOut.text.trim())
                    root.dndEnabled = data.dnd === true
                } catch (e) {
                    root.dndEnabled = false
                }
            }
        }
    }

    Process {
        id: dndWrite
        stdout: dndWriteOut
    }

    function saveDnd() {
        var json = JSON.stringify({ dnd: root.dndEnabled })
        var dir = root.dndPath.replace(/\/[^\/]+$/, "")
        dndWrite.exec(["sh", "-c", "mkdir -p '" + dir + "' && echo '" + json + "' > '" + root.dndPath + "'"])
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled
        saveDnd()
    }

    function toggle() {
        open = !open
    }

    function closeAll() {
        open = false
        calendarOpen = false
        workspaceSwitcherOpen = false
    }

    function prevMonth() {
        calendarMonthOffset = calendarMonthOffset - 1
    }

    function nextMonth() {
        calendarMonthOffset = calendarMonthOffset + 1
    }

    function dateKey(year, month, day) {
        var y = String(year)
        var m = month < 10 ? ("0" + month) : String(month)
        var d = day < 10 ? ("0" + day) : String(day)
        return y + "-" + m + "-" + d
    }

    property var pinnedDates: []

    function isPinned(key) {
        return pinnedDates.indexOf(key) !== -1
    }

    function togglePinnedDate(key) {
        var idx = pinnedDates.indexOf(key)
        if (idx === -1) {
            pinnedDates = pinnedDates.concat([key])
        } else {
            var copy = pinnedDates.slice()
            copy.splice(idx, 1)
            pinnedDates = copy
        }
    }

    function clearPinnedDates() {
        pinnedDates = []
    }

    function clearPinnedDatesInMonth(year, month) {
        var prefix = String(year) + "-" + (month < 10 ? ("0" + month) : String(month)) + "-"
        var copy = pinnedDates.slice()
        var filtered = []
        for (var i = 0; i < copy.length; i++) {
            if (copy[i].indexOf(prefix) !== 0) filtered.push(copy[i])
        }
        pinnedDates = filtered
    }

    function clearAllPinnedDates() {
        pinnedDates = []
    }

    Component.onCompleted: {
        dndRead.exec(["sh", "-c", "cat '" + root.dndPath + "' 2>/dev/null || echo '{\"dnd\":false}'"])
    }
}
