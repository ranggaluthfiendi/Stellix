import QtQuick
import QtQuick.Layouts
import qs.config
import qs.core.state

Item {
    id: root

    required property Item target
    required property real boundWidth
    required property real boundHeight

    property real defaultX: 0
    property real defaultY: 0

    property real currentX: defaultX
    property real currentY: defaultY

    onCurrentXChanged: if (!dragging) target.x = currentX
    onCurrentYChanged: if (!dragging) target.y = currentY

    signal dragPositionChanged(real x, real y)
    signal rotateAction(real newRotation)

    property real startMouseX: 0
    property real startMouseY: 0
    property real startItemX: 0
    property real startItemY: 0

    property bool dragging: false
    property bool rotating: false
    property bool moved: false
    property double lastClickTime: 0

    property real currentRotation: target.rotation

    onCurrentRotationChanged: target.rotation = currentRotation

    function toGlobal(mouse) {
        return mapToItem(null, mouse.x, mouse.y)
    }

    // Rotation indicator
    Rectangle {
        id: rotationIndicator
        visible: root.rotating
        z: 999
        anchors.centerIn: parent
        width: Theme !== undefined ? Theme.dp(48) : 48
        height: Theme !== undefined ? Theme.dp(48) : 48
        color: Theme !== undefined ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.9) : "#dac49c"
        radius: width / 2
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            
            Text {
                text: "↻"
                color: Theme !== undefined ? Theme.bgPrimary : "#151310"
                font.pixelSize: 16
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: Math.round(root.currentRotation) + "°"
                color: Theme !== undefined ? Theme.bgPrimary : "#151310"
                font.pixelSize: 9
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }
        }

        SequentialAnimation on opacity {
            id: fadeRotateIn
            running: root.rotating
            NumberAnimation { from: 0; to: 1; duration: 100 }
        }

        SequentialAnimation on opacity {
            id: fadeRotateOut
            running: !root.rotating
            NumberAnimation { from: 1; to: 0; duration: 200 }
        }
    }

    MouseArea {
        anchors.fill: parent    
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        propagateComposedEvents: true

        onWheel: function(wheel) {
            if (!root.dragging) return;
            
            if (wheel.angleDelta.y > 0) {
                root.currentRotation = (root.currentRotation - 1 + 360) % 360
                root.rotateAction(root.currentRotation)
            } else if (wheel.angleDelta.y < 0) {
                root.currentRotation = (root.currentRotation + 1) % 360
                root.rotateAction(root.currentRotation)
            }
            root.rotating = true
            rotateTimer.restart()
        }

        onPressed: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
                root.currentRotation = 0
                root.rotateAction(0)
                root.rotating = true
                rotateTimer.restart()
                return
            }

            if (mouse.button !== Qt.RightButton)
                return

            let p = root.toGlobal(mouse)

            root.startMouseX = p.x
            root.startMouseY = p.y
            root.startItemX = root.target.x
            root.startItemY = root.target.y

            root.dragging = true
            root.moved = false
        }

        onPositionChanged: function(mouse) {
            if (!root.dragging)
                return

            let p = root.toGlobal(mouse)

            let dx = p.x - root.startMouseX
            let dy = p.y - root.startMouseY

            if (!root.moved && Math.abs(dx) < 5 && Math.abs(dy) < 5)
                return

            root.moved = true

            let newX = root.startItemX + dx
            let newY = root.startItemY + dy

            const snapThreshold = 12
            const overflow = 20
            const maxX = root.boundWidth - root.target.width
            const maxY = root.boundHeight - root.target.height
            const centerX = root.boundWidth / 2
            const centerY = root.boundHeight / 2
            
            let snappedX = false
            if (Math.abs((newX + root.target.width / 2) - centerX) < snapThreshold) {
                newX = centerX - root.target.width / 2
                BarLayoutState.snapLineXVisible = true
                BarLayoutState.snapLineXPos = centerX
                snappedX = true
            }
            else if (Math.abs(newX) < snapThreshold) {
                newX = 0
                BarLayoutState.snapLineXVisible = true
                BarLayoutState.snapLineXPos = 0
                snappedX = true
            }
            else if (Math.abs(newX - maxX) < snapThreshold) {
                newX = maxX
                BarLayoutState.snapLineXVisible = true
                BarLayoutState.snapLineXPos = root.boundWidth
                snappedX = true
            }
            
            if (!snappedX) BarLayoutState.snapLineXVisible = false
            
            let snappedY = false
            if (Math.abs((newY + root.target.height / 2) - centerY) < snapThreshold) {
                newY = centerY - root.target.height / 2
                BarLayoutState.snapLineYVisible = true
                BarLayoutState.snapLineYPos = centerY
                snappedY = true
            }
            else if (Math.abs(newY) < snapThreshold) {
                newY = 0
                BarLayoutState.snapLineYVisible = true
                BarLayoutState.snapLineYPos = 0
                snappedY = true
            }
            else if (Math.abs(newY - maxY) < snapThreshold) {
                newY = maxY
                BarLayoutState.snapLineYVisible = true
                BarLayoutState.snapLineYPos = root.boundHeight
                snappedY = true
            }

            if (!snappedY) BarLayoutState.snapLineYVisible = false

            root.target.x = Math.max(-overflow, Math.min(newX, maxX + overflow))
            root.target.y = Math.max(-overflow, Math.min(newY, maxY + overflow))
        }

        onReleased: function(mouse) {
            if (mouse.button !== Qt.RightButton)
                return

            root.dragging = false
            BarLayoutState.snapLineXVisible = false
            BarLayoutState.snapLineYVisible = false

            let now = Date.now()
            let isDoubleClick = (now - root.lastClickTime) < 300

            if (isDoubleClick) {
                root.target.x = root.defaultX
                root.target.y = root.defaultY
            }

            root.currentX = root.target.x
            root.currentY = root.target.y
            root.dragPositionChanged(root.currentX, root.currentY)

            if (!root.moved) {
                mouse.accepted = false
            }

            root.lastClickTime = now
        }
    }

    Timer {
        id: rotateTimer
        interval: 800
        repeat: false
        onTriggered: root.rotating = false
    }

    function reset() {
        root.target.x = root.defaultX
        root.target.y = root.defaultY
    }
}
