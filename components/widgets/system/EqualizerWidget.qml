import qs.components.utils
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.elements

Item {
    id: root

    property real baseS: 1.0
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopEqualizerScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    NowPlayingService {
        id: media
    }

    Item {
        id: container
        width: 240 * s
        height: 80 * s

        x: BarLayoutState.desktopEqualizerX
        y: BarLayoutState.desktopEqualizerY
        rotation: BarLayoutState.desktopEqualizerRotation

        opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopEqualizerOpacity

        // Standalone Custom Visualizer
        WaveVisualizer {
            id: standaloneWave
            anchors.fill: parent
            active: media.player && media.player.isPlaying
            
            style: BarLayoutState.desktopEqualizerStyle
            mirrored: BarLayoutState.desktopEqualizerMirrored
            doubleWave: BarLayoutState.desktopEqualizerDoubleWave
            filled: BarLayoutState.desktopEqualizerFilled
            lineThickness: BarLayoutState.desktopEqualizerLineThickness * s
            fillOpacity: BarLayoutState.desktopEqualizerFillOpacity
            
            waveColor: {
                var mode = BarLayoutState.desktopEqualizerColorMode
                if (mode === "white") return "#FFFFFF"
                if (mode === "black") return "#000000"
                if (mode === "custom") return BarLayoutState.desktopEqualizerCustomColor
                return Theme.accent
            }
            
            opacity: 0.8
        }

        Draggable {
            id: drag
            anchors.fill: parent
            target: container
            boundWidth: root.screenW
            boundHeight: root.screenH
            defaultX: (screenW - width) / 2
            defaultY: (screenH - height) / 2
            currentX: BarLayoutState.desktopEqualizerX
            currentY: BarLayoutState.desktopEqualizerY
            onDragPositionChanged: (x, y) => {
                BarLayoutState.desktopEqualizerX = x
                BarLayoutState.desktopEqualizerY = y
            }
            onRotateAction: (r) => {
                BarLayoutState.desktopEqualizerRotation = r
            }
        }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopEqualizerDrag", drag)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopEqualizerDrag")
    }
}
