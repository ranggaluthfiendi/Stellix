pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root
    width: 0; height: 0
    visible: false

    property bool open: false
    onOpenChanged: {
        if (open) {
            calendarOpen = false
            weatherDetailOpen = false
            workspaceSwitcherOpen = false
            mediaPopupOpen = false
            notifPopupOpen = false
            SysTrayState._closeTrayItems()
        }
    }

    property bool calendarOpen: false
    onCalendarOpenChanged: {
        if (calendarOpen) {
            open = false
            weatherDetailOpen = false
            workspaceSwitcherOpen = false
            mediaPopupOpen = false
            notifPopupOpen = false
            SysTrayState._closeTrayItems()
        }
    }
    property bool workspaceSwitcherOpen: false
    onWorkspaceSwitcherOpenChanged: {
        if (workspaceSwitcherOpen) {
            open = false
            calendarOpen = false
            weatherDetailOpen = false
            mediaPopupOpen = false
            notifPopupOpen = false
            SysTrayState._closeTrayItems()
        }
    }
    property bool launcherOpen: false
    property bool settingsOpen: false
    property bool guideOpen: false
    property bool weatherDetailOpen: false
    onWeatherDetailOpenChanged: {
        if (weatherDetailOpen) {
            open = false
            calendarOpen = false
            workspaceSwitcherOpen = false
            mediaPopupOpen = false
            notifPopupOpen = false
            SysTrayState._closeTrayItems()
        }
    }
    property bool mediaPopupOpen: false
    onMediaPopupOpenChanged: {
        if (mediaPopupOpen) {
            open = false
            calendarOpen = false
            weatherDetailOpen = false
            workspaceSwitcherOpen = false
            notifPopupOpen = false
            SysTrayState._closeTrayItems()
        }
    }

    property bool notifPopupOpen: false
    onNotifPopupOpenChanged: {
        if (notifPopupOpen) {
            open = false
            calendarOpen = false
            weatherDetailOpen = false
            workspaceSwitcherOpen = false
            mediaPopupOpen = false
            SysTrayState._closeTrayItems()
        }
    }
    property bool dndEnabled: false
    property int calendarMonthOffset: 0
    property bool notifPanelRequested: false
    // Updated by BatteryBarPopup's NotificationServer
    property int notifCount: 0

    signal launcherToggleRequested()
    signal welcomeRequested()

    // Volume/Brightness indicator
    property bool indicatorVisible: false
    property string indicatorType: "volume"
    property real indicatorValue: 0
    property bool indicatorMuted: false

    Timer {
        id: indicatorHideTimer
        interval: BarLayoutState.indicatorTimeout
        repeat: false
        onTriggered: {
            root.indicatorVisible = false
        }
    }

    function showIndicator(type, value, muted) {
        root.indicatorType = type
        root.indicatorValue = value
        root.indicatorMuted = muted || false
        root.indicatorVisible = true
        indicatorHideTimer.restart()
        // Close calendar when indicator shows
        root.calendarOpen = false
    }

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
        launcherOpen = false
        settingsOpen = false
        guideOpen = false
        weatherDetailOpen = false
        mediaPopupOpen = false
        notifPopupOpen = false
        SysTrayState.forceCloseAll()
    }

    function closeWeatherDetail() {
        weatherDetailOpen = false
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
