import QtQuick
import QtQuick.Layouts
import qs.config
import qs.core.state
import qs.core.settings
import qs.components.elements

Rectangle {
    id: root
    color: "transparent"

    property string indicatorType: "volume"
    property real indicatorValue: 0
    property bool indicatorMuted: false

    property real measuredLabelWidth: Theme.dp(60) * BarLayoutState.indicatorScale
    property real measuredValueWidth: Theme.dp(40) * BarLayoutState.indicatorScale

    function updateMeasuredWidth(type, w) {
        if (type === "label") measuredLabelWidth = w
        if (type === "value") measuredValueWidth = w
    }

    readonly property real contentWidth: {
        var w = 0
        var spacing = Theme.dp(12) * BarLayoutState.indicatorScale
        var visibleElements = 0

        for (var i = 0; i < BarLayoutState.indicatorElementOrder.length; i++) {
            var modelData = BarLayoutState.indicatorElementOrder[i]
            var visible = false
            var itemW = 0

            if (modelData === "icon" && BarLayoutState.indicatorShowIcon) {
                visible = true
                itemW = Theme.dp(20) * BarLayoutState.indicatorScale
            } else if (modelData === "label" && BarLayoutState.indicatorShowLabel) {
                visible = true
                itemW = measuredLabelWidth
            } else if (modelData === "progress" && BarLayoutState.indicatorShowProgress) {
                // Don't count progress width for pinned indicator
                if (root.indicatorType !== "pinned") {
                    visible = true
                    itemW = Theme.dp(BarLayoutState.indicatorProgressWidth) * BarLayoutState.indicatorScale
                }
            } else if (modelData === "value" && BarLayoutState.indicatorShowValue) {
                visible = true
                itemW = measuredValueWidth
            }

            if (visible) {
                w += itemW
                visibleElements++
            }
        }

        if (visibleElements > 0) {
            w += (visibleElements - 1) * spacing
        }
        
        return w + (Theme.dp(32) * BarLayoutState.indicatorScale)
    }

    // Definitions for sizing
    readonly property real indicatorW: Math.max(Theme.dp(120), contentWidth)
    readonly property real indicatorH: Theme.dp(BarLayoutState.indicatorHeight) * BarLayoutState.indicatorScale

    implicitWidth: indicatorW
    implicitHeight: indicatorH

    property bool animating: false
    property real slideY: 0
    property real slideOpacity: 1

    readonly property color progressColor: {
        if (root.indicatorMuted) {
            switch (BarLayoutState.indicatorProgressColorMode) {
                case "accent": return Theme.accent
                case "accent_soft": return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                case "bg_secondary": return Theme.bgSecondary
                case "bg_primary": return Theme.bgPrimary
                case "text_primary": return Theme.textPrimary
                case "text_muted": return Theme.textMuted
                case "border": return Theme.border
                case "white": return "#ffffff"
                case "black": return "#000000"
                case "transparent": return "transparent"
                case "success": return "#4CAF50"
                case "danger": return Theme.danger
                case "custom": return BarLayoutState.indicatorCustomProgressColor
                default: return Theme.danger
            }
        }
        switch (BarLayoutState.indicatorProgressColorMode) {
            case "accent": return Theme.accent
            case "accent_soft": return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            case "bg_secondary": return Theme.bgSecondary
            case "bg_primary": return Theme.bgPrimary
            case "text_primary": return Theme.textPrimary
            case "text_muted": return Theme.textMuted
            case "border": return Theme.border
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "transparent": return "transparent"
            case "success": return "#4CAF50"
            case "danger": return Theme.danger
            case "custom": return BarLayoutState.indicatorCustomProgressColor
            default: return Theme.accent
        }
    }

    readonly property color trackColor: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15)

    function resolveTextColor(mode, fallback) {
        switch (mode) {
            case "accent": return Theme.accent
            case "accent_soft": return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            case "bg_secondary": return Theme.bgSecondary
            case "bg_primary": return Theme.bgPrimary
            case "text_primary": return Theme.textPrimary
            case "text_muted": return Theme.textMuted
            case "border": return Theme.border
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "transparent": return "transparent"
            case "success": return "#4CAF50"
            case "danger": return Theme.danger
            case "custom": return BarLayoutState.indicatorCustomBgColor
            default: return fallback
        }
    }

    function resolveBgColor(mode, fallback) {
        switch (mode) {
            case "accent": return Theme.accent
            case "accent_soft": return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            case "bg_secondary": return Theme.bgSecondary
            case "bg_primary": return Theme.bgPrimary
            case "text_primary": return Theme.textPrimary
            case "text_muted": return Theme.textMuted
            case "border": return Theme.border
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "transparent": return "transparent"
            case "success": return "#4CAF50"
            case "danger": return Theme.danger
            case "custom": return BarLayoutState.indicatorCustomBgColor
            default: return fallback
        }
    }

    function resolveBorderColor(mode, fallback) {
        switch (mode) {
            case "accent": return Theme.accent
            case "accent_soft": return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            case "bg_secondary": return Theme.bgSecondary
            case "bg_primary": return Theme.bgPrimary
            case "text_primary": return Theme.textPrimary
            case "text_muted": return Theme.textMuted
            case "border": return Theme.border
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "transparent": return "transparent"
            case "success": return "#4CAF50"
            case "danger": return Theme.danger
            case "custom": return BarLayoutState.indicatorCustomBgColor
            default: return fallback
        }
    }

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
        NumberAnimation { duration: animating ? BarLayoutState.indicatorAnimationDuration : Math.max(50, BarLayoutState.indicatorAnimationDuration * 0.7); easing.type: animating ? Easing.OutCubic : Easing.InCubic }
    }
    Behavior on slideOpacity {
        NumberAnimation { duration: animating ? Math.max(50, BarLayoutState.indicatorAnimationDuration * 0.8) : Math.max(50, BarLayoutState.indicatorAnimationDuration * 0.6); easing.type: animating ? Easing.OutCubic : Easing.InCubic }
    }

    y: slideY
    opacity: slideOpacity * BarLayoutState.indicatorOpacity

    // --- Component definitions OUTSIDE Repeater ---
    Component {
        id: iconComp
        Item {
            implicitWidth: Theme.dp(16) * BarLayoutState.indicatorScale
            implicitHeight: Theme.dp(16) * BarLayoutState.indicatorScale

            IconVolume {
                anchors.fill: parent
                iconColor: root.indicatorMuted ? Theme.danger : Theme.textPrimary
                iconSize: Theme.dp(12) * BarLayoutState.indicatorScale
                visible: root.indicatorType === "volume"
            }

            IconBrightness {
                anchors.fill: parent
                iconColor: Theme.textPrimary
                iconSize: Theme.dp(12) * BarLayoutState.indicatorScale
                visible: root.indicatorType === "brightness"
            }

            IconPin {
                anchors.fill: parent
                iconColor: root.indicatorValue > 0.5 ? Theme.accent : Qt.rgba(Theme.textMuted.r, Theme.textMuted.g, Theme.textMuted.b, 0.4)
                iconSize: Theme.dp(12) * BarLayoutState.indicatorScale
                isPinned: root.indicatorValue > 0.5
                visible: root.indicatorType === "pinned"
            }
        }
    }

    Component {
        id: labelComp
        Text {
            id: labelText
            text: {
                if (root.indicatorType === "volume") return "Volume"
                if (root.indicatorType === "brightness") return "Brightness"
                if (root.indicatorType === "pinned") return "Bar"
                return ""
            }
            color: resolveTextColor(BarLayoutState.indicatorTextColorMode, Theme.textPrimary)
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 13) * Scales.uiScale * BarLayoutState.indicatorScale)
            font.weight: Typography.weightBold || Font.Bold
            
            onImplicitWidthChanged: {
                root.updateMeasuredWidth("label", implicitWidth)
            }
            Component.onCompleted: {
                root.updateMeasuredWidth("label", implicitWidth)
            }
        }
    }

    Component {
        id: progressComp
        Item {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                visible: BarLayoutState.indicatorProgressStyle === "fill"
                color: root.trackColor
                radius: height / 2

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * root.indicatorValue
                    color: root.progressColor
                    radius: height / 2
                    
                    Behavior on width { NumberAnimation { duration: Math.max(50, BarLayoutState.indicatorAnimationDuration * 0.75); easing.type: Easing.OutCubic } }
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: BarLayoutState.indicatorProgressStyle === "outline"
                color: "transparent"
                border.width: Theme.dp(1.5) * BarLayoutState.indicatorScale
                border.color: root.trackColor
                radius: height / 2

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: Theme.dp(0.5) * BarLayoutState.indicatorScale
                    width: Math.max(0, parent.width * root.indicatorValue - Theme.dp(1) * BarLayoutState.indicatorScale)
                    color: root.progressColor
                    radius: height / 2
                    
                    Behavior on width { NumberAnimation { duration: Math.max(50, BarLayoutState.indicatorAnimationDuration * 0.75); easing.type: Easing.OutCubic } }
                }
            }

            Row {
                id: dotsRow
                anchors.centerIn: parent
                visible: BarLayoutState.indicatorProgressStyle === "dots"
                spacing: Theme.dp(BarLayoutState.indicatorProgressWidth / 30) * BarLayoutState.indicatorScale
                layoutDirection: Qt.LeftToRight

                readonly property int dotCount: 10
                readonly property real dotSize: Math.min(parent.height, (parent.width - (spacing * (dotCount - 1))) / dotCount)

                Repeater {
                    model: parent.dotCount
                    delegate: Rectangle {
                        width: dotsRow.dotSize
                        height: width
                        radius: width / 2
                        color: index / dotsRow.dotCount < root.indicatorValue ? root.progressColor : root.trackColor
                        
                        Behavior on color { ColorAnimation { duration: Math.max(50, BarLayoutState.indicatorAnimationDuration * 0.75) } }
                    }
                }
            }

            Item {
                anchors.fill: parent
                visible: BarLayoutState.indicatorProgressStyle === "wave"

                Rectangle {
                    anchors.fill: parent
                    color: root.trackColor
                    radius: height / 2
                }
                
                Item {
                    anchors.fill: parent
                    clip: true
                    
                    Item {
                        width: parent.width * root.indicatorValue
                        height: parent.height
                        clip: true
                        
                        Behavior on width { NumberAnimation { duration: Math.max(50, BarLayoutState.indicatorAnimationDuration * 1.25); easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent
                            color: root.progressColor
                            radius: height / 2
                        }

                        // Improved Wave effect overlay
                        Canvas {
                            anchors.fill: parent
                            property real phase: 0
                            
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                
                                var amplitude = height * 0.15;
                                var frequency = 0.035;
                                
                                // First wave layer (background)
                                ctx.fillStyle = Qt.rgba(1, 1, 1, 0.15);
                                ctx.beginPath();
                                ctx.moveTo(0, height);
                                for (var x = 0; x <= width; x += 3) {
                                    var y = height * 0.55 + Math.sin(x * frequency + phase) * amplitude;
                                    ctx.lineTo(x, y);
                                }
                                ctx.lineTo(width, height);
                                ctx.closePath();
                                ctx.fill();

                                // Second wave layer (foreground)
                                ctx.fillStyle = Qt.rgba(1, 1, 1, 0.25);
                                ctx.beginPath();
                                ctx.moveTo(0, height);
                                for (var x2 = 0; x2 <= width; x2 += 3) {
                                    var y2 = height * 0.45 + Math.cos(x2 * frequency * 0.8 + phase * 1.5) * amplitude * 1.2;
                                    ctx.lineTo(x2, y2);
                                }
                                ctx.lineTo(width, height);
                                ctx.closePath();
                                ctx.fill();
                            }
                            
                            Timer {
                                running: true
                                repeat: true
                                interval: 20
                                onTriggered: {
                                    parent.phase += 0.06;
                                    parent.requestPaint();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: valueComp
        Text {
            text: {
                if (root.indicatorType === "pinned") return root.indicatorValue > 0.5 ? "Pinned" : "Unpinned"
                return Math.round(root.indicatorValue * 100) + "%" + (root.indicatorMuted ? " | Muted" : "")
            }
            color: {
                if (root.indicatorMuted) return Theme.danger
                if (root.indicatorType === "pinned" && root.indicatorValue < 0.5) return Theme.textSecondary
                return resolveTextColor(BarLayoutState.indicatorTextColorMode, Theme.accent)
            }
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 13) * Scales.uiScale * BarLayoutState.indicatorScale)
            font.weight: Typography.weightBold || Font.Bold
            
            onImplicitWidthChanged: {
                root.updateMeasuredWidth("value", implicitWidth)
            }
            Component.onCompleted: {
                root.updateMeasuredWidth("value", implicitWidth)
            }
        }
    }

    // Background and Container
    Rectangle {
        id: bgRect
        width: root.indicatorW
        height: root.indicatorH
        anchors.centerIn: parent
        color: resolveBgColor(BarLayoutState.indicatorBgColorMode, Theme.bgSecondary)
        border.width: BarLayoutState.indicatorBorderWidth
        border.color: resolveBorderColor(BarLayoutState.indicatorBorderColorMode, Theme.border)
        radius: {
            switch (BarLayoutState.indicatorStyle) {
                case "pill": return height / 2
                case "square": return 0
                case "minimal": return Theme.dp(4) * BarLayoutState.indicatorScale
                default: return BarLayoutState.indicatorRadius * BarLayoutState.indicatorScale
            }
        }
        clip: true 

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.dp(12) * BarLayoutState.indicatorScale

            Repeater {
                model: BarLayoutState.indicatorElementOrder

                Loader {
                    id: elemLoader
                    required property string modelData

                    sourceComponent: modelData === "icon" ? iconComp :
                                     modelData === "label" ? labelComp :
                                     modelData === "progress" ? progressComp :
                                     modelData === "value" ? valueComp : null

                    visible: {
                        if (modelData === "icon") return BarLayoutState.indicatorShowIcon
                        if (modelData === "label") return BarLayoutState.indicatorShowLabel
                        if (modelData === "progress") {
                            // Don't show progress for pinned indicator as it's binary
                            if (root.indicatorType === "pinned") return false
                            return BarLayoutState.indicatorShowProgress
                        }
                        if (modelData === "value") return BarLayoutState.indicatorShowValue
                        return false
                    }

                    Layout.preferredWidth: {
                        if (!visible) return 0
                        if (modelData === "icon") return Theme.dp(20) * BarLayoutState.indicatorScale
                        if (modelData === "progress") return Theme.dp(BarLayoutState.indicatorProgressWidth) * BarLayoutState.indicatorScale
                        return -1
                    }
                    Layout.preferredHeight: {
                        if (modelData === "progress") {
                            switch (BarLayoutState.indicatorProgressStyle) {
                                case "dots": return Theme.dp(14) * BarLayoutState.indicatorScale
                                case "wave": return Theme.dp(22) * BarLayoutState.indicatorScale
                                default: return Theme.dp(8) * BarLayoutState.indicatorScale
                            }
                        }
                        return -1
                    }
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
