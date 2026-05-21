import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root
    color: "transparent"

    property string indicatorType: "volume"
    property real indicatorValue: 0
    property bool indicatorMuted: false

    readonly property real indicatorW: Theme.dp(220)
    readonly property real indicatorH: Theme.dp(40)

    implicitWidth: indicatorW
    implicitHeight: indicatorH

    property bool animating: false
    property real slideY: 0
    property real slideOpacity: 1

    onAnimatingChanged: {
        if (animating) {
            slideY = -Theme.dp(15)
            slideOpacity = 0
            Qt.callLater(function() {
                slideY = 0
                slideOpacity = 1
            })
        } else {
            slideY = -Theme.dp(15)
            slideOpacity = 0
        }
    }

    Behavior on slideY {
        NumberAnimation { duration: animating ? 180 : 140; easing.type: animating ? Easing.OutCubic : Easing.InCubic }
    }
    Behavior on slideOpacity {
        NumberAnimation { duration: animating ? 160 : 120; easing.type: animating ? Easing.OutCubic : Easing.InCubic }
    }

    y: slideY
    opacity: slideOpacity

    RowLayout {
        anchors.centerIn: parent
        spacing: Theme.dp(6)

        Text {
            text: (root.indicatorType === "volume" ? "Volume" : "Brightness") + ": " + Math.round(root.indicatorValue * 100) + "%" + (root.indicatorMuted ? " | Muted" : "")
            color: root.indicatorMuted ? Theme.danger : Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 13) * Scales.uiScale)
            font.weight: Typography.weightBold || Font.Bold
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
