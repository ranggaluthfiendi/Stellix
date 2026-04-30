import QtQuick

Item {
    property real s
    property color secondary

    Rectangle {
        x: 197 * s
        y: 21 * s
        width: 581 * s
        height: 55 * s
        color: secondary
    }
}
