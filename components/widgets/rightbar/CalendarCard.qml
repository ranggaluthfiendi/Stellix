import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components.widgets.rightbar
import qs.components.elements

Item {
    id: root
    property real s: Scales.uiScale

    property date now: new Date()
    readonly property date shownDate: new Date(now.getFullYear(), now.getMonth() + RightBarState.calendarMonthOffset, 1)
    readonly property int shownYear: shownDate.getFullYear()
    readonly property int shownMonth: shownDate.getMonth() + 1
    readonly property int daysInMonth: new Date(shownYear, shownMonth, 0).getDate()
    readonly property int firstWeekday: {
        var d = new Date(shownYear, shownMonth - 1, 1).getDay()
        return (d + 6) % 7
    }
    readonly property int prevMonthDays: new Date(shownYear, shownMonth - 1, 0).getDate()
    readonly property string monthPrefix: String(shownYear) + "-" + (shownMonth < 10 ? ("0" + shownMonth) : String(shownMonth))

    readonly property string dayName: {
        var names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return names[now.getDay()]
    }
    readonly property string monthNameFull: {
        var names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return names[now.getMonth()]
    }

    readonly property real headerH: Theme.dp(64)
    readonly property real weekdayH: Theme.dp(24)
    readonly property real gridH: Theme.dp(210)
    readonly property real footerH: Theme.dp(36)
    readonly property real totalH: headerH + weekdayH + gridH + footerH

    implicitHeight: totalH

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    function monthNameShort(m) {
        var names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return names[m - 1]
    }

    function gridCellDate(row, col) {
        var index = row * 7 + col
        var dayNum = index - firstWeekday + 1
        var y = shownYear
        var m = shownMonth
        var d = dayNum

        if (dayNum < 1) {
            m = shownMonth - 1
            if (m < 1) { m = 12; y = shownYear - 1 }
            d = prevMonthDays + dayNum
        } else if (dayNum > daysInMonth) {
            m = shownMonth + 1
            if (m > 12) { m = 1; y = shownYear + 1 }
            d = dayNum - daysInMonth
        }

        return { y: y, m: m, d: d, inMonth: (m === shownMonth && y === shownYear) }
    }

    function pinnedCountInShownMonth() {
        var count = 0
        for (var i = 0; i < RightBarState.pinnedDates.length; i++) {
            var key = RightBarState.pinnedDates[i]
            if (typeof key === "string" && key.indexOf(monthPrefix + "-") === 0) count++
        }
        return count
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        Column {
            anchors.fill: parent
            spacing: 0

            // ── Header: Month/Year + Nav ──
            Item {
                width: parent.width
                height: root.headerH

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(12)
                    spacing: Theme.dp(8)

                    // Month/Year
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(2)

                        Text {
                            text: root.monthNameFull + " " + root.now.getFullYear()
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(16 * s)
                            font.weight: Font.Bold
                        }

                        Text {
                            text: root.dayName + ", " + root.now.getDate() + " " + root.monthNameFull
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(9 * s)
                        }
                    }

                    // Time
                    Text {
                        text: {
                            var h = root.now.getHours()
                            var m = root.now.getMinutes()
                            return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
                        }
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(22 * s)
                        font.weight: Font.Bold
                    }

                    // Nav buttons
                    RowLayout {
                        spacing: Theme.dp(4)

                        NavButton {
                            iconSource: chevronsLeftComp
                            onClicked: RightBarState.calendarMonthOffset -= 12
                        }

                        NavButton {
                            iconSource: chevronLeftComp
                            onClicked: RightBarState.prevMonth()
                        }

                        NavButton {
                            iconSource: chevronRightComp
                            onClicked: RightBarState.nextMonth()
                        }

                        NavButton {
                            iconSource: chevronsRightComp
                            onClicked: RightBarState.calendarMonthOffset += 12
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.dp(1)
                color: Theme.border
            }

            // ── Weekday headers ──
            Item {
                width: parent.width
                height: root.weekdayH

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    delegate: Text {
                        required property var modelData
                        required property int index
                        x: index * (parent.width / 7)
                        width: parent.width / 7
                        height: parent.height
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: index >= 5 ? Theme.danger : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Medium
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.dp(1)
                color: Theme.border
            }

            // ── Calendar grid ──
            Item {
                width: parent.width
                height: root.gridH

                readonly property real cellW: width / 7
                readonly property real cellH: height / 6

                Repeater {
                    model: 42
                    delegate: Rectangle {
                        required property int index
                        readonly property int row: Math.floor(index / 7)
                        readonly property int col: index % 7
                        readonly property var info: root.gridCellDate(row, col)
                        readonly property bool inMonth: info.inMonth
                        readonly property string key: RightBarState.dateKey(info.y, info.m, info.d)
                        readonly property bool pinned: RightBarState.isPinned(key)
                        readonly property bool isToday:
                            info.y === root.now.getFullYear() &&
                            info.m === (root.now.getMonth() + 1) &&
                            info.d === root.now.getDate()

                        x: col * parent.cellW
                        y: row * parent.cellH
                        width: parent.cellW
                        height: parent.cellH
                        color: {
                            if (isToday) return Theme.accent
                            if (cellMouse.containsMouse && inMonth) return Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            if (pinned) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                            return "transparent"
                        }
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: info.d
                            color: {
                                if (!inMonth) return Qt.rgba(Theme.textMuted.r, Theme.textMuted.g, Theme.textMuted.b, 0.4)
                                if (isToday) return Theme.bgPrimary
                                if (pinned) return Theme.accent
                                return Theme.textPrimary
                            }
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(11 * s)
                            font.weight: isToday ? Font.Bold : Font.Normal
                        }

                        // Pin indicator
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: Theme.dp(2)
                            width: Theme.dp(4)
                            height: Theme.dp(4)
                            radius: width / 2
                            color: Theme.warning
                            visible: pinned && !isToday
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.togglePinnedDate(parent.key)
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.dp(1)
                color: Theme.border
            }

            // ── Footer ──
            Item {
                width: parent.width
                height: root.footerH

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Theme.dp(10)
                    spacing: Theme.dp(8)

                    Text {
                        text: root.pinnedCountInShownMonth() > 0 ? (root.pinnedCountInShownMonth() + " pinned this month") : "Click a date to pin/unpin"
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    HoldButton {
                        visible: root.pinnedCountInShownMonth() > 0
                        s: root.s
                        buttonLabel: "Clear Month"
                        requireHold: false
                        onExecute: RightBarState.clearPinnedDatesInMonth(root.shownYear, root.shownMonth)
                    }

                    HoldButton {
                        visible: RightBarState.pinnedDates.length > root.pinnedCountInShownMonth()
                        s: root.s
                        buttonLabel: "Clear All"
                        danger: true
                        requireHold: false
                        onExecute: RightBarState.clearAllPinnedDates()
                    }
                }
            }
        }
    }

    component NavButton: Rectangle {
        property var iconSource
        signal clicked
        Layout.preferredWidth: Theme.dp(26)
        Layout.preferredHeight: Theme.dp(26)
        color: navMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
        border.width: 1
        border.color: navMouse.containsMouse ? Theme.accent : Theme.border
        radius: Theme.dp(4)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Loader {
            anchors.centerIn: parent
            sourceComponent: iconSource
        }

        MouseArea {
            id: navMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }

    Component { id: chevronsLeftComp; IconChevronsLeft { iconSize: Theme.dp(14); iconColor: Theme.textPrimary } }
    Component { id: chevronLeftComp; IconChevronLeft { iconSize: Theme.dp(14); iconColor: Theme.textPrimary } }
    Component { id: chevronRightComp; IconChevronRight { iconSize: Theme.dp(14); iconColor: Theme.textPrimary } }
    Component { id: chevronsRightComp; IconChevronsRight { iconSize: Theme.dp(14); iconColor: Theme.textPrimary } }
}
