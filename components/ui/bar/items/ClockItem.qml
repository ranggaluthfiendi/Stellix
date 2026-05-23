import QtQuick
import Quickshell
import qs.services
import qs.config
import qs.components.widgets.rightbar

Item {
    id: root

    property real s: Scales.uiScale

    readonly property string formattedTime: {
        var fmt = BarLayoutState.clock24Hour ? "HH" : "hh"
        fmt += BarLayoutState.clockShowSeconds ? ":mm:ss" : ":mm"
        if (!BarLayoutState.clock24Hour) fmt += " AP"
        return Qt.formatDateTime(Time.currentDate, fmt)
    }

    readonly property string displayText: {
        var fmt = BarLayoutState.clockFormat
        if (fmt === "time") return formattedTime
        if (fmt === "date") return Time.date
        if (fmt === "time-date") return formattedTime + "  •  " + Time.date
        if (fmt === "date-time") return Time.date + "  •  " + formattedTime
        if (fmt === "time-tz") return formattedTime + " " + Time.timezone
        return formattedTime
    }

    implicitHeight: BarLayoutState.barHeight * s
    implicitWidth: clockText.implicitWidth + Theme.dp(8)

    Text {
        id: clockText
        anchors.centerIn: parent
        text: root.displayText
        color: Theme.textPrimary
        font.family: Typography.fontFamily
        font.pixelSize: Math.round((Typography.sizeMD || 12) * s)
        font.weight: Typography.weightMedium || Font.Normal
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            RightBarState.calendarOpen = !RightBarState.calendarOpen
            RightBarState.calendarMonthOffset = 0
        }
    }
}
