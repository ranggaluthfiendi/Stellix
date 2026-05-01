import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real s: 0.6
    property color primary: "#d7d1b8"
    property color background: "#47443b"

    width: 42 * s
    height: 37 * s

    Shape {
        anchors.fill: parent

        ShapePath {
            fillColor: root.primary
            strokeColor: "transparent"

            startX: 0 * s
            startY: 18.5 * s

            PathLine { x: 10.5 * s; y: 7.675 * s }
            PathLine { x: 10.5 * s; y: 29.325 * s }
            PathLine { x: 0 * s; y: 18.5 * s }
        }
    }

    Shape {
        anchors.fill: parent

        ShapePath {
            fillColor: root.primary
            strokeColor: "transparent"

            startX: 41.25 * s
            startY: 18.5 * s

            PathLine { x: 10.5 * s; y: 29.325 * s }
            PathLine { x: 10.5 * s; y: 7.675 * s }
            PathLine { x: 41.25 * s; y: 18.5 * s }
        }
    }

    Rectangle {
        width: 4 * s
        height: 4 * s
        radius: 2 * s

        x: (8 - 2) * s
        y: (19 - 2) * s

        color: root.background
    }

    Rectangle {
        x: 36 * s
        y: 0
        width: 5 * s
        height: 5 * s
        color: root.primary
    }

    Rectangle {
        x: 36 * s
        y: 32 * s
        width: 5 * s
        height: 5 * s
        color: root.primary
    }
}
