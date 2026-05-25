import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components.widgets.barpopup
import qs.components.elements

Item {
    id: root
    property real s: Scales.uiScale

    property date now: new Date()
    readonly property date shownDate: new Date(now.getFullYear(), now.getMonth() + BarPopupState.calendarMonthOffset, 1)
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

    readonly property real headerH: Theme.dp(48)
    readonly property real navH: Theme.dp(30)
    readonly property real weekdayH: Theme.dp(22)
    readonly property real gridH: Theme.dp(156)
    readonly property real footerH: Theme.dp(44)
    readonly property real totalH: headerH + navH + weekdayH + gridH + footerH + Theme.dp(3) // 3 separators

    implicitHeight: totalH
    implicitWidth: Theme.dp(360)

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
        for (var i = 0; i < BarPopupState.pinnedDates.length; i++) {
            var key = BarPopupState.pinnedDates[i]
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

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header: Month/Year + Nav ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.headerH
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(12)
                    spacing: Theme.dp(12)

                    // Time on the Left
                    Text {
                        text: {
                            var h = root.now.getHours()
                            var m = root.now.getMinutes()
                            return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
                        }
                        color: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(20 * s)
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Consolidated Date on the Right
                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                        Text {
                            text: root.dayName + ", " + root.now.getDate() + " " + root.monthNameFull + " " + root.now.getFullYear()
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(11 * s)
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            // Navigation Controls Row
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.navH
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.04)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.dp(10)
                    anchors.rightMargin: Theme.dp(10)
                    spacing: Theme.dp(4)

                    NavButton {
                        iconSource: chevronsLeftComp
                        onClicked: BarPopupState.calendarMonthOffset -= 12
                    }

                    NavButton {
                        iconSource: chevronLeftComp
                        onClicked: BarPopupState.prevMonth()
                    }

                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        Layout.preferredHeight: Theme.dp(22)
                        Layout.preferredWidth: Theme.dp(64)
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                        radius: 0
                        visible: BarPopupState.calendarMonthOffset !== 0
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Today"
                            color: Theme.accent
                            font.pixelSize: Theme.dp(9)
                            font.weight: Font.Bold
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: BarPopupState.calendarMonthOffset = 0
                        }
                    }

                    Item { Layout.fillWidth: true }

                    NavButton {
                        iconSource: chevronRightComp
                        onClicked: BarPopupState.nextMonth()
                    }

                    NavButton {
                        iconSource: chevronsRightComp
                        onClicked: BarPopupState.calendarMonthOffset += 12
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
                opacity: 0.5
            }

            // ── Weekday headers ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.weekdayH
                color: "transparent"

                Row {
                    anchors.fill: parent
                    Repeater {
                        model: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
                        delegate: Text {
                            required property var modelData
                            required property int index
                            width: parent.width / 7
                            height: parent.height
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            color: index >= 5 ? Theme.danger : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(9 * s)
                            font.weight: Font.Bold
                            opacity: 0.8
                        }
                    }
                }
            }

            // ── Calendar grid ──
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.gridH

                readonly property real cellW: width / 7
                readonly property real cellH: height / 6

                Repeater {
                    model: 42
                    delegate: Item {
                        required property int index
                        readonly property int row: Math.floor(index / 7)
                        readonly property int col: index % 7
                        readonly property var info: root.gridCellDate(row, col)
                        readonly property bool inMonth: info.inMonth
                        readonly property string key: BarPopupState.dateKey(info.y, info.m, info.d)
                        readonly property bool pinned: BarPopupState.isPinned(key)
                        readonly property bool isToday:
                            info.y === root.now.getFullYear() &&
                            info.m === (root.now.getMonth() + 1) &&
                            info.d === root.now.getDate()

                        x: col * parent.cellW
                        y: row * parent.cellH
                        width: parent.cellW
                        height: parent.cellH

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) - Theme.dp(4)
                            height: width
                            radius: 0
                            color: {
                                if (isToday) return Theme.accent
                                if (cellMouse.containsMouse && inMonth) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                                if (pinned) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                return "transparent"
                            }
                            
                            border.width: pinned && !isToday ? 1 : 0
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)

                            Behavior on color { ColorAnimation { duration: 120 } }

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
                                font.weight: (isToday || pinned) ? Font.Bold : Font.Normal
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: Theme.dp(4)
                                width: Theme.dp(3)
                                height: Theme.dp(3)
                                radius: 0
                                color: isToday ? Theme.bgPrimary : Theme.accent
                                visible: pinned
                            }
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: BarPopupState.togglePinnedDate(key)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
                opacity: 0.5
            }

            // ── Footer ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.footerH
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.dp(12)
                    anchors.rightMargin: Theme.dp(12)
                    spacing: Theme.dp(8)

                    Text {
                        text: root.pinnedCountInShownMonth() > 0 ? (root.pinnedCountInShownMonth() + " pinned this month") : "Click a date to pin"
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
                        onExecute: BarPopupState.clearPinnedDatesInMonth(root.shownYear, root.shownMonth)
                    }

                    HoldButton {
                        visible: BarPopupState.pinnedDates.length > 0
                        s: root.s
                        buttonLabel: "Clear All"
                        danger: true
                        requireHold: true
                        onExecute: BarPopupState.clearAllPinnedDates()
                    }
                }
            }
        }
    }

    component NavButton: Rectangle {
        property var iconSource
        property string tooltip: ""
        signal clicked
        Layout.preferredWidth: Theme.dp(28)
        Layout.preferredHeight: Theme.dp(28)
        color: navMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12) : "transparent"
        radius: 0

        Behavior on color { ColorAnimation { duration: 120 } }

        Loader {
            anchors.centerIn: parent
            sourceComponent: iconSource
            opacity: navMouse.containsMouse ? 1.0 : 0.7
            Behavior on opacity { NumberAnimation { duration: 120 } }
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
