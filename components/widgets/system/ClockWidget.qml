import QtQuick
import qs.config
import qs.services

Item {
    id: root

    property real s: Scales.uiScale * 0.6

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    TimeFloating {
        id: timeService
    }

    ClockPosition {
        id: pos
        defaultX: container.defaultX
        defaultY: container.defaultY
    }

    Component.onCompleted: {
        pos.loadPosition()
        container.safeTime = "00:00"
        container.safeDate = ""
    }

    Connections {
        target: pos

        function onPositionLoaded(x, y) {
            container.x = x
            container.y = y
        }

        function onAlignLoaded(a) {
            container.alignMode = a
        }
    }

    Connections {
        target: timeService

        function onTimeChanged() {
            container.safeTime = timeService.time ? timeService.time : "00:00"
        }

        function onDateChanged() {
            container.safeDate = timeService.date ? timeService.date : ""
        }
    }

    Item {
        id: container

        width: 320 * s
        height: 140 * s

        property real defaultX: 40 * s
        property real defaultY: 40 * s

        x: defaultX
        y: defaultY

        property int alignMode: 1

        property string safeTime: "00:00"
        property string safeDate: ""

        property bool savePending: false

        function nextAlign() {
            alignMode = (alignMode + 1) % 3
            pos.applyPosition(container.x, container.y, container, alignMode)
        }

        function alignment() {
            if (alignMode === 0) return Text.AlignLeft
            if (alignMode === 1) return Text.AlignHCenter
            return Text.AlignRight
        }

        function scheduleSave() {
            if (savePending) return
            savePending = true

            Qt.callLater(function() {
                savePending = false
                pos.applyPosition(container.x, container.y, container, alignMode)
            })
        }

        onXChanged: scheduleSave()
        onYChanged: scheduleSave()

        Column {
            anchors.fill: parent
            anchors.margins: 10 * s
            spacing: 4 * s

            Text {
                text: container.safeTime
                font.pixelSize: Typography.sp(86)
                color: Theme.textPrimary
                horizontalAlignment: container.alignment()
                width: parent.width
            }

            Text {
                text: container.safeDate
                font.pixelSize: Typography.sp(22)
                color: Theme.textSecondary
                horizontalAlignment: container.alignment()
                width: parent.width
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    container.nextAlign()
                }
            }
        }

        Draggable {
            anchors.fill: parent
            target: container

            boundWidth: root.screenW
            boundHeight: root.screenH

            defaultX: container.defaultX
            defaultY: container.defaultY
        }
    }
}
