import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.config
import qs.components.widgets.rightbar

Item {
    id: root

    property real s: Scales.uiScale

    readonly property string clockSection: BarLayoutState.findItemSection("clock")
    readonly property bool isCenterClock: clockSection === "center"
    readonly property bool isLeftClock: clockSection === "left"
    readonly property bool isRightClock: clockSection === "right"
    readonly property real popupW: Theme.dp(372)
    readonly property real screenW: BarLayoutState.barScreenWidth > 0 ? BarLayoutState.barScreenWidth : Screen.width
    readonly property real centerMargin: Math.max(0, (screenW - popupW) / 2)

    readonly property real popupRadius: BarLayoutState.calendarPopupRounded ? Theme.radiusMedium : 0

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
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            RightBarState.calendarOpen = !RightBarState.calendarOpen
            RightBarState.calendarMonthOffset = 0
        }
    }

    PanelWindow {
        id: calendarPanel
        visible: RightBarState.calendarOpen
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: !BarLayoutState.isBottom
            bottom: BarLayoutState.isBottom
            left: true
            right: true
        }

        implicitWidth: root.popupW
        implicitHeight: calendarCard.implicitHeight

        margins.left: root.isCenterClock ? root.centerMargin : (root.isLeftClock ? Theme.dp(5) : root.screenW - root.popupW - Theme.dp(5))
        margins.right: root.isCenterClock ? root.centerMargin : (root.isRightClock ? Theme.dp(5) : root.screenW - root.popupW - Theme.dp(5))
        margins.top: !BarLayoutState.isBottom ? (BarLayoutState.barHeight * s + Theme.dp(4)) : 0
        margins.bottom: BarLayoutState.isBottom ? (BarLayoutState.barHeight * s + Theme.dp(4)) : 0

        Rectangle {
            id: calendarBg
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: root.popupRadius

            property real animOpacity: 0
            opacity: animOpacity

            states: State {
                name: "visible"
                when: calendarPanel.visible
                PropertyChanges { target: calendarBg; animOpacity: 1 }
            }

            transitions: [
                Transition {
                    from: ""
                    to: "visible"
                    NumberAnimation { target: calendarBg; property: "animOpacity"; duration: 180; easing.type: Easing.OutCubic }
                },
                Transition {
                    from: "visible"
                    to: ""
                    NumberAnimation { target: calendarBg; property: "animOpacity"; duration: 140; easing.type: Easing.InCubic }
                }
            ]

            CalendarCard {
                id: calendarCard
                anchors.fill: parent
            }
        }
    }
}
