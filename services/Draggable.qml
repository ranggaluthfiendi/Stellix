import QtQuick

Item {
    id: root

    required property Item target
    required property real boundWidth
    required property real boundHeight

    property real defaultX: 0
    property real defaultY: 0

    property real startMouseX: 0
    property real startMouseY: 0
    property real startItemX: 0
    property real startItemY: 0

    property bool dragging: false
    property bool moved: false
    property double lastClickTime: 0

    function toGlobal(mouse) {
        return mapToItem(null, mouse.x, mouse.y)
    }

    MouseArea {
        anchors.fill: parent    
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true

        onPressed: function(mouse) {
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

            const maxX = root.boundWidth - root.target.width
            const maxY = root.boundHeight - root.target.height

            root.target.x = Math.max(0, Math.min(newX, maxX))
            root.target.y = Math.max(0, Math.min(newY, maxY))
        }

        onReleased: function(mouse) {
            if (mouse.button !== Qt.RightButton)
                return

            root.dragging = false

            let now = Date.now()
            let isDoubleClick = (now - root.lastClickTime) < 300

            if (isDoubleClick) {
                root.target.x = root.defaultX
                root.target.y = root.defaultY
            }

            if (!root.moved) {
                mouse.accepted = false
            }

            root.lastClickTime = now
        }
    }
}
