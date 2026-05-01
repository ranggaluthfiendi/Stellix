import QtQuick

Item {
    id: root

    property real s
    property color secondary

    property real contentWidth: 300 * s
    property real maxWidth: 500 * s

    readonly property real boxWidth: Math.min(contentWidth, maxWidth)

    Rectangle {
        x: 197 * s
        y: 21 * s
        width: boxWidth
        height: 55 * s
        color: secondary
    }
}
