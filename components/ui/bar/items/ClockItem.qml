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

    PopupWindow {
        id: calendarPopup
        visible: RightBarState.calendarOpen
        color: "transparent"
        grabFocus: false

        anchor.item: root
        anchor.rect: BarLayoutState.isBottom
            ? Qt.rect(0, -(implicitHeight + Theme.dp(4)), 0, 0)
            : Qt.rect(0, root.height + Theme.dp(4), 0, 0)

        implicitWidth: Theme.dp(244)
        implicitHeight: calendarCard.implicitHeight

        Rectangle {
            id: calendarBg
            anchors.fill: parent
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.calendarOpacity)
            border.width: 1
            border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, BarLayoutState.calendarOpacity)
            radius: 0

            property real animOpacity: 0
            opacity: animOpacity
            y: BarLayoutState.isBottom ? Theme.dp(8) : -Theme.dp(8)

            states: State {
                name: "visible"
                when: calendarPopup.visible
                PropertyChanges { target: calendarBg; animOpacity: 1; y: 0 }
            }

            transitions: [
                Transition {
                    from: ""
                    to: "visible"
                    NumberAnimation { target: calendarBg; property: "animOpacity"; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { target: calendarBg; property: "y"; duration: 200; easing.type: Easing.OutCubic }
                },
                Transition {
                    from: "visible"
                    to: ""
                    NumberAnimation { target: calendarBg; property: "animOpacity"; duration: 140; easing.type: Easing.InCubic }
                    NumberAnimation { target: calendarBg; property: "y"; duration: 140; easing.type: Easing.InCubic }
                }
            ]

            CalendarCard {
                id: calendarCard
                anchors.fill: parent
            }
        }
    }
}
