import QtQuick
import QtQuick.Shapes
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    property color waveColor: Theme.accent
    property real lineThickness: 2 * Scales.uiScale
    property real fillOpacity: 0.15
    property string style: "wave"
    property bool mirrored: true
    property bool doubleWave: true
    property bool filled: false
    property real s: Scales.uiScale
    property var bars: CavaService.bars
    property bool active: true

    implicitWidth: 100
    implicitHeight: 40

    readonly property var processedBars: {
        if (!mirrored) return bars;
        
        var list = [];
        for (var i = 7; i >= 0; i--) list.push(bars[i] || 0);
        for (var j = 0; j < 8; j++) list.push(bars[j] || 0);
        
        return list;
    }

    readonly property int pointCount: processedBars.length

    // --- Secondary Wave Style (Double Effect) ---
    Shape {
        visible: root.active && root.style === "wave" && root.doubleWave
        anchors.fill: parent
        opacity: 0.4
        layer.enabled: true; layer.samples: 4; layer.smooth: true

        ShapePath {
            strokeWidth: root.lineThickness * 0.75
            strokeColor: root.waveColor
            fillColor: root.filled ? root.waveColor : Qt.rgba(root.waveColor.r, root.waveColor.g, root.waveColor.b, root.fillOpacity * 0.5)
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            startX: 0
            startY: root.height / 2

            PathCurve { x: root.width * 0.05; y: root.height / 2 + (root.processedBars[0] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.15; y: root.height / 2 - (root.processedBars[1] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.25; y: root.height / 2 + (root.processedBars[2] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.35; y: root.height / 2 - (root.processedBars[3] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.45; y: root.height / 2 + (root.processedBars[4] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.55; y: root.height / 2 - (root.processedBars[5] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.65; y: root.height / 2 + (root.processedBars[6] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.75; y: root.height / 2 - (root.processedBars[7] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.85; y: root.height / 2 + (root.processedBars[8] || 0) * (root.height / 3) }
            PathCurve { x: root.width * 0.95; y: root.height / 2 - (root.processedBars[9] || 0) * (root.height / 3) }
            
            PathLine { x: root.width; y: root.height / 2 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: root.height / 2 }
        }
    }

    // --- Main Wave Style ---
    Shape {
        visible: root.active && root.style === "wave"
        anchors.fill: parent
        opacity: 1.0
        layer.enabled: true; layer.samples: 4; layer.smooth: true

        ShapePath {
            strokeWidth: root.lineThickness
            strokeColor: root.waveColor
            fillColor: root.filled ? root.waveColor : Qt.rgba(root.waveColor.r, root.waveColor.g, root.waveColor.b, root.fillOpacity)
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            startX: 0
            startY: root.height / 2

            // Generate PathCurves based on pointCount
            PathCurve { x: root.width * 0.05; y: root.height / 2 - (root.processedBars[0] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.15; y: root.height / 2 + (root.processedBars[1] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.25; y: root.height / 2 - (root.processedBars[2] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.35; y: root.height / 2 + (root.processedBars[3] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.45; y: root.height / 2 - (root.processedBars[4] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.55; y: root.height / 2 + (root.processedBars[5] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.65; y: root.height / 2 - (root.processedBars[6] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.75; y: root.height / 2 + (root.processedBars[7] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.85; y: root.height / 2 - (root.processedBars[8] || 0) * (root.height / 2) }
            PathCurve { x: root.width * 0.95; y: root.height / 2 + (root.processedBars[9] || 0) * (root.height / 2) }
            
            PathLine { x: root.width; y: root.height / 2 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: root.height / 2 }
        }
    }

    // --- Bars Style ---
    Row {
        visible: root.active && (root.style === "bars" || root.style === "bars-fill")
        anchors.fill: parent
        spacing: Math.max(1, (width - (pointCount * 4 * s)) / (pointCount - 1))
        
        Repeater {
            model: root.pointCount
            Rectangle {
                width: root.style === "bars-fill" ? (root.width / root.pointCount) : 4 * s
                height: Math.max(2 * s, root.height * (root.processedBars[index] || 0))
                anchors.bottom: parent.bottom
                color: root.waveColor
                opacity: 0.6 + (root.processedBars[index] * 0.4)
                radius: root.style === "bars-fill" ? 0 : width / 2
                
                Behavior on height { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            }
        }
    }

    // --- Dots Style ---
    Row {
        visible: root.active && root.style === "dots"
        anchors.fill: parent
        spacing: Math.max(2, (width - (pointCount * 6 * s)) / (pointCount - 1))
        
        Repeater {
            model: root.pointCount
            Rectangle {
                width: 6 * s
                height: width
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -(root.height / 2) * (root.processedBars[index] || 0)
                color: root.waveColor
                opacity: 0.5 + (root.processedBars[index] * 0.5)
                
                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
            }
        }
    }
}
