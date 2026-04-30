import QtQuick
import qs.config

Item {
    property real s
    property color primary
    property string trackTitle
    property string artist

    // cover
    Rectangle {
        x: 206 * s
        y: 33 * s
        width: 30 * s
        height: 30 * s
        color: primary
    }

    // title
    Text {
        x: 245 * s
        y: 28 * s
        width: 500 * s
        text: trackTitle
        color: primary
        font.family: Typography.fontFamily
        font.pixelSize: 14 * s
        elide: Text.ElideRight
    }

    // artist
    Text {
        x: 245 * s
        y: 48 * s
        text: artist
        color: primary
        font.family: Typography.fontFamily
        font.pixelSize: 20 * s
        font.weight: Typography.weightBold
    }
}
