import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.config

Item {
    id: root
    width: Theme.dp(36)
    height: Theme.dp(36)

    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker { objects: [ root.sink ].filter(function(x) { return x }) }

    Text {
        anchors.centerIn: parent
        text: "volume_up"
        font.family: Typography.materialSymbols
        font.styleName: "Regular"
        font.pixelSize: Theme.dp(20)
        color: Theme.textSecondary

        MouseArea {
            id: maVol
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onWheel: (wheel) => {
                if (!root.sink || !root.sink.audio) return
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + delta))
            }
        }
    }
}
