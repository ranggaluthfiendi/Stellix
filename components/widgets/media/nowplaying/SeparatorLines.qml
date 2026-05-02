import QtQuick
import qs.config

Item {
    id: root

    property real s: Scales.uiScale
    property color secondary

    property real contentWidth: 300 * s
    property real maxWidth: 500 * s

    readonly property real boxWidth: Math.min(contentWidth, maxWidth)

    Rectangle {
        x: 197 * s
        y: 16 * s
        width: boxWidth
        height: 1.33 * s
        color: secondary
    }

    Rectangle {
        x: 197 * s
        y: 80 * s
        width: boxWidth
        height: 1.33 * s
        color: secondary
    }
}
