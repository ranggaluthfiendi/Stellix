import QtQuick

Item {
    property real s
    property color secondary

    Rectangle {
        x: 197 * s
        y: 16 * s
        width: 581 * s
        height: 1.33 * s
        color: secondary
    }

    Rectangle {
        x: 197 * s
        y: 80 * s
        width: 581 * s
        height: 1.33 * s
        color: secondary
    }
}
