import QtQuick
import QtQuick.Shapes
import qs.config

Item {
    id: root

    property real s: Scales.uiScale
    property color color: Theme.warning

    width: 14 * s
    height: 14 * s

    Shape {
        anchors.fill: parent

        ShapePath {
            strokeWidth: 0
            fillColor: root.color

            startX: 0.45 * root.width
            startY: 0.05 * root.height

            PathLine { x: 0.75 * root.width; y: 0.05 * root.height }
            PathLine { x: 0.55 * root.width; y: 0.45 * root.height }
            PathLine { x: 0.80 * root.width; y: 0.45 * root.height }
            PathLine { x: 0.30 * root.width; y: 0.95 * root.height }
            PathLine { x: 0.45 * root.width; y: 0.60 * root.height }
            PathLine { x: 0.20 * root.width; y: 0.60 * root.height }
            PathLine { x: 0.45 * root.width; y: 0.05 * root.height }
        }
    }
}
