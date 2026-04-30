import QtQuick

Item {
    property real s
    property color primary

    Rectangle {
        x: 136 * s
        width: 16 * s
        height: 97 * s
        color: primary
        opacity: 0.42
    }

    Rectangle {
        x: 160 * s
        width: 3.44 * s
        height: 97 * s
        color: primary
        opacity: 0.42
    }
}
