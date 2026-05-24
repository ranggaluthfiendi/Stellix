import QtQuick
import Quickshell
import qs.services

Item {
    id: timeFloating

    property string time: "00:00"
    property string date: ""

    SystemClock {
        id: clock
        precision: BarLayoutState.desktopClockShowSeconds ? SystemClock.Seconds : SystemClock.Minutes
        
        onDateChanged: {
            var timeFmt = BarLayoutState.desktopClock24Hour ? "HH:mm" : "hh:mm"
            if (BarLayoutState.desktopClockShowSeconds) timeFmt += ":ss"
            if (!BarLayoutState.desktopClock24Hour) timeFmt += " AP"
            
            timeFloating.time = Qt.formatDateTime(clock.date, timeFmt)
            
            var dateParts = []
            if (BarLayoutState.desktopClockShowWeekday) dateParts.push("ddd")
            if (BarLayoutState.desktopClockShowDate) dateParts.push("dd MMMM")
            if (BarLayoutState.desktopClockShowYear) dateParts.push("yyyy")
            
            var dateFmt = dateParts.join(" ' • ' ")
            if (dateFmt === "") dateFmt = " " // Non-empty to trigger binding
            
            timeFloating.date = Qt.formatDateTime(clock.date, dateFmt).toUpperCase()
        }
    }

    Component.onCompleted: {
        var timeFmt = BarLayoutState.desktopClock24Hour ? "HH:mm" : "hh:mm"
        if (BarLayoutState.desktopClockShowSeconds) timeFmt += ":ss"
        if (!BarLayoutState.desktopClock24Hour) timeFmt += " AP"
        
        time = Qt.formatDateTime(clock.date, timeFmt)
        
        var dateParts = []
        if (BarLayoutState.desktopClockShowWeekday) dateParts.push("ddd")
        if (BarLayoutState.desktopClockShowDate) dateParts.push("dd MMMM")
        if (BarLayoutState.desktopClockShowYear) dateParts.push("yyyy")
        
        var dateFmt = dateParts.join(" ' • ' ")
        if (dateFmt === "") dateFmt = " "
        
        date = Qt.formatDateTime(clock.date, dateFmt).toUpperCase()
    }
}


