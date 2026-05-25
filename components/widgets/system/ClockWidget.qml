import qs.components.utils
import QtQuick
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopClockScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    readonly property string formattedTime: {
        var fmt = BarLayoutState.desktopClock24Hour ? "HH" : "hh"
        fmt += BarLayoutState.desktopClockShowSeconds ? ":mm:ss" : ":mm"
        if (!BarLayoutState.desktopClock24Hour) fmt += " AP"
        return Qt.formatDateTime(Time.currentDate, fmt)
    }

    readonly property string formattedDay: {
        if (BarLayoutState.desktopClockShowWeekday) return Qt.formatDateTime(Time.currentDate, "dddd").toUpperCase()
        return ""
    }

    readonly property string formattedDate: {
        var parts = []
        if (BarLayoutState.desktopClockShowDate) parts.push(Qt.formatDateTime(Time.currentDate, "dd MMMM"))
        if (BarLayoutState.desktopClockShowYear) parts.push(Qt.formatDateTime(Time.currentDate, "yyyy"))
        return parts.join("  •  ").toUpperCase()
    }

    Item {
        id: container

        width: 480 * s
        height: 180 * s

        property real defaultX: 40 * Scales.uiScale
        property real defaultY: 40 * Scales.uiScale

        x: BarLayoutState.desktopClockX
        y: BarLayoutState.desktopClockY
        rotation: BarLayoutState.desktopClockRotation

        property int alignMode: BarLayoutState.desktopClockAlignment

        opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopClockOpacity

        readonly property color clockColor: {
            if (BarLayoutState.desktopClockColorMode === "white") return "#FFFFFF"
            if (BarLayoutState.desktopClockColorMode === "black") return "#000000"
            return Theme.accent
        }

        readonly property color dateColor: {
            if (BarLayoutState.desktopClockColorMode === "white") return Qt.rgba(1, 1, 1, 0.7)
            if (BarLayoutState.desktopClockColorMode === "black") return Qt.rgba(0, 0, 0, 0.7)
            return Theme.textSecondary
        }

        function alignment() {
            if (BarLayoutState.desktopClockAlignment === 0) return Text.AlignLeft
            if (BarLayoutState.desktopClockAlignment === 1) return Text.AlignHCenter
            return Text.AlignRight
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10 * s
            spacing: 0

            Text {
                text: root.formattedTime
                font.pixelSize: Typography.sp(86) * BarLayoutState.desktopClockScale
                color: container.clockColor
                horizontalAlignment: container.alignment()
                width: parent.width
                font.weight: Font.Bold
                lineHeight: 0.8
            }

            Text {
                visible: text !== ""
                text: root.formattedDay
                font.pixelSize: Typography.sp(22) * BarLayoutState.desktopClockScale
                color: container.clockColor
                horizontalAlignment: container.alignment()
                width: parent.width
                font.weight: Font.Bold
                opacity: 0.9
            }

            Text {
                visible: text !== ""
                text: root.formattedDate
                font.pixelSize: Typography.sp(14) * BarLayoutState.desktopClockScale
                color: container.dateColor
                horizontalAlignment: container.alignment()
                width: parent.width
                font.weight: Font.Medium
            }
        }

        Draggable {
            id: drag
            anchors.fill: parent
            target: container

            boundWidth: root.screenW
            boundHeight: root.screenH

            defaultX: container.defaultX
            defaultY: container.defaultY
            
            currentX: BarLayoutState.desktopClockX
            currentY: BarLayoutState.desktopClockY
            onDragPositionChanged: (x, y) => {
                BarLayoutState.desktopClockX = x
                BarLayoutState.desktopClockY = y
            }
            onRotateAction: (r) => {
                BarLayoutState.desktopClockRotation = r
            }
        }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopClockPos", drag)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopClockPos")
    }
}
