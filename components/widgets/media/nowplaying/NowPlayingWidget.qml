import qs.components.utils
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.components.elements
import qs.components.widgets.media.nowplaying
import qs.core.state

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopNowPlayingScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    // ── Bind directly to MprisService instance ──
    readonly property var mprisSvc: BarLayoutState.getItem("mprisService")

    Item {
        id: container

        width: styleLoader.item ? styleLoader.item.implicitWidth : 200 * s
        height: styleLoader.item ? styleLoader.item.implicitHeight : 100 * s

        property real defaultX: 30 * s
        property real defaultY: screenH - height - 30 * s

        x: BarLayoutState.desktopNowPlayingX
        y: BarLayoutState.desktopNowPlayingY
        rotation: BarLayoutState.desktopNowPlayingRotation

        opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopNowPlayingOpacity
        visible: true 

        layer.enabled: true
        layer.smooth: true

        Loader {
            id: styleLoader
            anchors.fill: parent
            source: {
                switch (BarLayoutState.desktopNowPlayingStyle) {
                    case "nier": return Qt.resolvedUrl("NierStyle.qml")
                    case "card": return Qt.resolvedUrl("CardStyle.qml")
                    case "minimal": return Qt.resolvedUrl("MinimalStyle.qml")
                    case "glass": return Qt.resolvedUrl("GlassStyle.qml")
                    case "retro": return Qt.resolvedUrl("RetroStyle.qml")
                    default: return Qt.resolvedUrl("NierStyle.qml")
                }
            }

            onLoaded: {
                item.s = root.s
            }

            // Sync properties to the loaded item
            Binding { target: styleLoader.item; property: "s"; value: root.s }
        }

        Draggable {
            id: draggable
            anchors.fill: parent
            target: container

            boundWidth: root.screenW
            boundHeight: root.screenH

            defaultX: container.defaultX
            defaultY: container.defaultY

            currentX: BarLayoutState.desktopNowPlayingX
            currentY: BarLayoutState.desktopNowPlayingY
            onDragPositionChanged: (x, y) => {
                BarLayoutState.desktopNowPlayingX = x
                BarLayoutState.desktopNowPlayingY = y
            }
            onRotateAction: (r) => {
                BarLayoutState.desktopNowPlayingRotation = r
            }
        }
    }
}
