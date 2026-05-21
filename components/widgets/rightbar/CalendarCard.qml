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

    readonly property real headerH: Theme.dp(56)
    readonly property real weekdayH: Theme.dp(18)
    readonly property real gridH: Theme.dp(168)
    readonly property real footerH: Theme.dp(28)
    readonly property real navH: Theme.dp(32)
    readonly property real totalH: headerH + weekdayH + gridH + footerH + navH

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

            // ── Header: Day number + time ──
            Item {
                width: parent.width
                height: root.headerH

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(10)
                    spacing: Theme.dp(10)

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(42)
                        Layout.preferredHeight: Theme.dp(42)
                        color: Theme.accent
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: root.now.getDate()
                            color: Theme.bgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(18 * s)
                            font.weight: Font.Bold
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.dp(2)

                        Item { Layout.fillHeight: true }

                        Text {
                            text: {
                                var h = root.now.getHours()
                                var m = root.now.getMinutes()
                                return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
                            }
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(14 * s)
                            font.weight: Font.Bold
                        }

                        Text {
                            text: root.dayName + ", " + root.now.getDate() + " " + root.monthNameFull + " " + root.now.getFullYear()
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(9 * s)
                        }

                        Item { Layout.fillHeight: true }
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
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(8 * s)
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
                                if (!inMonth) return Theme.textMuted
                                if (isToday) return Theme.bgPrimary
                                if (pinned) return Theme.accent
                                return Theme.textPrimary
                            }
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(10 * s)
                            font.weight: isToday ? Font.Bold : Font.Normal
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
                height: root.footerH

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Theme.dp(4)
                    spacing: Theme.dp(4)

                    Text {
                        text: root.pinnedCountInShownMonth() > 0 ? (root.pinnedCountInShownMonth() + " pinned") : "Click a date to pin"
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(8 * s)
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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Theme.dp(4)
                    spacing: 0

                    // Left side: prev controls
                    RowLayout {
                        spacing: Theme.dp(2)
                        Layout.alignment: Qt.AlignLeft

                        NavButton {
                            iconSource: chevronsLeftComp
                            onClicked: RightBarState.calendarMonthOffset -= 12
                        }

                        NavButton {
                            iconSource: chevronLeftComp
                            onClicked: RightBarState.prevMonth()
                        }
                    }

                    // Center: month label
                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(78)
                        Layout.preferredHeight: Theme.dp(20)
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
                            anchors.centerIn: parent
                            text: root.monthNameShort(root.shownMonth) + " " + root.shownYear
                            color: root.shownMonth === (root.now.getMonth() + 1) && root.shownYear === root.now.getFullYear() ? Theme.accent : Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(8 * s)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: monthMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: RightBarState.calendarMonthOffset = 0
                        }
                    }

                    // Right side: next controls
                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: Theme.dp(2)
                        Layout.alignment: Qt.AlignRight

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
        }
    }

    component NavButton: Rectangle {
        property var iconSource
        signal clicked
        Layout.preferredWidth: Theme.dp(22)
        Layout.preferredHeight: Theme.dp(22)
        color: navMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
        border.width: 1
        border.color: navMouse.containsMouse ? Theme.textPrimary : Theme.border
        radius: 0

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

    Component { id: chevronsLeftComp; IconChevronsLeft { iconSize: Theme.dp(12); iconColor: Theme.textPrimary } }
    Component { id: chevronLeftComp; IconChevronLeft { iconSize: Theme.dp(12); iconColor: Theme.textPrimary } }
    Component { id: chevronRightComp; IconChevronRight { iconSize: Theme.dp(12); iconColor: Theme.textPrimary } }
    Component { id: chevronsRightComp; IconChevronsRight { iconSize: Theme.dp(12); iconColor: Theme.textPrimary } }
}
