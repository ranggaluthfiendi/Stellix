import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real s: Scales.uiScale

    property real level: 1.0

    property color fillColor: "#00ff00"
    property color strokeColor: "#ffffff"
    property color backgroundColor: "transparent"

    readonly property real padding: 1.5 * s

    width: 16 * s
    height: 16 * s

    Rectangle {
        x: 1 * s + root.padding
        y: 5 * s + root.padding
        width: 12 * s - (root.padding * 2)
        height: 6 * s - (root.padding * 2)
        color: root.backgroundColor
    }

    Rectangle {
        x: 1 * s + root.padding
        y: 5 * s + root.padding
        height: 6 * s - (root.padding * 2)
        width: (12 * s - (root.padding * 2)) * root.level
        color: root.fillColor
    }

    Shape {
        anchors.fill: parent

        ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2 * root.s
            fillColor: "transparent"

            startX: 1 * root.s
            startY: 5 * root.s

            PathLine { x: 13 * root.s; y: 5 * root.s }
            PathLine { x: 13 * root.s; y: 11 * root.s }
            PathLine { x: 1 * root.s; y: 11 * root.s }
            PathLine { x: 1 * root.s; y: 5 * root.s }
        }

        ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2 * root.s
            fillColor: root.strokeColor

            startX: 13 * root.s
            startY: 7 * root.s

            PathLine { x: 15 * root.s; y: 7 * root.s }
            PathLine { x: 15 * root.s; y: 9 * root.s }
            PathLine { x: 13 * root.s; y: 9 * root.s }
            PathLine { x: 13 * root.s; y: 7 * root.s }
        }
    }
}
