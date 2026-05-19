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
    readonly property string dateTimeStr: {
        var h = now.getHours()
        var m = now.getMinutes()
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m + ", " + dayName + " " + now.getDate() + " " + monthNameFull + " " + now.getFullYear()
    }

    readonly property real headerH: Theme.dp(28)
    readonly property real dividerH: Theme.dp(1)
    readonly property real weekdayH: Theme.dp(14)
    readonly property real gridH: Theme.dp(150)
    readonly property real footerH: Theme.dp(28)
    readonly property real navH: Theme.dp(26)
    readonly property real totalH: headerH + dividerH + weekdayH + gridH + dividerH + footerH + dividerH + navH

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

            // ── Top: datetime ──
            Item {
                width: parent.width
                height: Theme.dp(28)

                Text {
                    anchors.centerIn: parent
                    text: root.dateTimeStr
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                    font.weight: Typography.weightMedium || Font.Normal
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
                height: Theme.dp(14)

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
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                    }
                }
            }

            // ── Calendar grid ──
            Item {
                width: parent.width
                height: Theme.dp(150)

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
                            if (cellMouse.containsMouse && !isToday) return Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            if (isToday) return Theme.accent
                            if (pinned) return Qt.rgba(1, 1, 1, 0.06)
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
                                if (!inMonth) return Theme.textMuted
                                if (isToday) return Theme.bgPrimary
                                return Theme.textPrimary
                            }
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                            font.weight: isToday ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
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

            // ── Footer: pinned count + clear ──
            Item {
                width: parent.width
                height: Theme.dp(28)

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Theme.dp(6)
                    spacing: Theme.dp(4)

                    Text {
                        text: root.pinnedCountInShownMonth() > 0 ? (root.pinnedCountInShownMonth() + " pinned") : "Click a date to pin"
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    HoldButton {
                        visible: root.pinnedCountInShownMonth() > 0
                        s: root.s
                        buttonLabel: "Clear"
                        requireHold: false
                        onExecute: RightBarState.clearPinnedDatesInMonth(root.shownYear, root.shownMonth)
                    }

                    HoldButton {
                        visible: RightBarState.pinnedDates.length > root.pinnedCountInShownMonth()
                        s: root.s
                        buttonLabel: "All"
                        danger: true
                        requireHold: false
                        onExecute: RightBarState.clearAllPinnedDates()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: Theme.dp(1)
                color: Theme.border
            }

            // ── Bottom nav: year/month controls ──
            Item {
                width: parent.width
                height: root.navH

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.dp(4)

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(22)
                        Layout.preferredHeight: Theme.dp(22)
                        color: chevronsLeftMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                        border.width: 1
                        border.color: chevronsLeftMouse.containsMouse ? Theme.textPrimary : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Loader {
                            anchors.centerIn: parent
                            sourceComponent: chevronsLeftComp
                        }
                        Component { id: chevronsLeftComp; IconChevronsLeft { iconSize: Theme.dp(12); iconColor: chevronsLeftMouse.containsMouse ? Theme.textPrimary : Theme.textPrimary } }

                        MouseArea {
                            id: chevronsLeftMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.calendarMonthOffset -= 12
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(22)
                        Layout.preferredHeight: Theme.dp(22)
                        color: chevronLeftMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                        border.width: 1
                        border.color: chevronLeftMouse.containsMouse ? Theme.textPrimary : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Loader {
                            anchors.centerIn: parent
                            sourceComponent: chevronLeftComp
                        }
                        Component { id: chevronLeftComp; IconChevronLeft { iconSize: Theme.dp(12); iconColor: chevronLeftMouse.containsMouse ? Theme.textPrimary : Theme.textPrimary } }

                        MouseArea {
                            id: chevronLeftMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.prevMonth()
                        }
                    }

                    // ── Month label (tengah) ──
                    Rectangle {
                        Layout.preferredWidth: Theme.dp(86)
                        Layout.preferredHeight: Theme.dp(22)
                        color: monthMouse.containsMouse
                            ? (root.shownMonth === (root.now.getMonth() + 1) && root.shownYear === root.now.getFullYear() ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                            : (root.shownMonth === (root.now.getMonth() + 1) && root.shownYear === root.now.getFullYear() ? Theme.bgSecondary : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.shownMonth === (root.now.getMonth() + 1) && root.shownYear === root.now.getFullYear() ? Theme.accent : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            id: monthLabel
                            anchors.centerIn: parent
                            text: root.monthNameShort(root.shownMonth) + " " + root.shownYear
                            color: root.shownMonth === (root.now.getMonth() + 1) && root.shownYear === root.now.getFullYear() ? Theme.accent : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        MouseArea {
                            id: monthMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.calendarMonthOffset = 0
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(22)
                        Layout.preferredHeight: Theme.dp(22)
                        color: chevronRightMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                        border.width: 1
                        border.color: chevronRightMouse.containsMouse ? Theme.textPrimary : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Loader {
                            anchors.centerIn: parent
                            sourceComponent: chevronRightComp
                        }
                        Component { id: chevronRightComp; IconChevronRight { iconSize: Theme.dp(12); iconColor: chevronRightMouse.containsMouse ? Theme.textPrimary : Theme.textPrimary } }

                        MouseArea {
                            id: chevronRightMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.nextMonth()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(22)
                        Layout.preferredHeight: Theme.dp(22)
                        color: chevronsRightMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                        border.width: 1
                        border.color: chevronsRightMouse.containsMouse ? Theme.textPrimary : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Loader {
                            anchors.centerIn: parent
                            sourceComponent: chevronsRightComp
                        }
                        Component { id: chevronsRightComp; IconChevronsRight { iconSize: Theme.dp(12); iconColor: chevronsRightMouse.containsMouse ? Theme.textPrimary : Theme.textPrimary } }

                        MouseArea {
                            id: chevronsRightMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.calendarMonthOffset += 12
                        }
                    }
                }
            }
        }
    }
}
