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

    property int instanceIndex: 0

    property bool _updatingConfig: false

    readonly property var cfg: BarLayoutState.getQuickActionsConfig(instanceIndex)
    readonly property real s: Scales.uiScale * 0.6 * (cfg ? cfg.scale : 1.0)

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    function resolveColor(mode, fallback) {
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
            case "default": return fallback
            case "custom": return cfg ? cfg.customBgColor : "#ffffff"
            default: return fallback
        }
    }

    function resolveIconColor(mode) {
        switch (mode) {
            case "accent": return Theme.accent
            case "text_primary": return Theme.textPrimary
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "default": return Theme.textPrimary
            case "custom": return cfg ? cfg.customBgColor : "#ffffff"
            default: return Theme.textPrimary
        }
    }

    function resolveLabelColor(mode) {
        switch (mode) {
            case "accent": return Theme.accent
            case "text_muted": return Theme.textMuted
            case "text_primary": return Theme.textPrimary
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "default": return Theme.textMuted
            default: return Theme.textMuted
        }
    }

    visible: cfg ? cfg.enabled : false

    Item {
        id: container
        width: {
            if (!cfg) return 120 * s
            var count = cfg.model ? cfg.model.length : 0
            var btnW = (56 + (cfg.buttonPadding || 0) * 2) * s
            var spacing = (cfg.buttonSpacing || 0) * s
            var pad = 12 * s
            if (cfg.layoutDirection === "vertical") {
                return Math.max(80 * s, btnW + pad * 2)
            }
            return Math.max(120 * s, count * btnW + (count - 1) * spacing + pad * 2)
        }
        height: {
            if (!cfg) return 58 * s
            var count = cfg.model ? cfg.model.length : 0
            var btnH = 58 * s
            var spacing = (cfg.buttonSpacing || 0) * s
            var pad = 12 * s
            if (cfg.layoutDirection === "vertical") {
                return Math.max(80 * s, count * btnH + (count - 1) * spacing + pad * 2)
            }
            return 58 * s + pad * 2
        }

        x: cfg ? cfg.x : 800
        y: cfg ? cfg.y : 900
        rotation: cfg ? cfg.rotation : 0

        opacity: BarLayoutState.desktopWidgetsOpacity * (cfg ? cfg.opacity : 1.0) * (cfg && (!cfg.autoHide || cfg.visible) ? 1.0 : 0.0)
        scale: cfg && (!cfg.autoHide || cfg.visible) ? 1.0 : 0.9

        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

        Timer {
            id: autohideTimer
            interval: 3000
            onTriggered: {
                if (cfg && cfg.autoHide && !mouseArea.containsMouse && !root._updatingConfig) {
                    root._updatingConfig = true
                    var c = JSON.parse(JSON.stringify(cfg))
                    c.visible = false
                    BarLayoutState.updateQuickActionsConfig(root.instanceIndex, c)
                    root._updatingConfig = false
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -40 * s
            hoverEnabled: true
            onEntered: {
                if (cfg && cfg.autoHide && !root._updatingConfig) {
                    root._updatingConfig = true
                    var c = JSON.parse(JSON.stringify(cfg))
                    c.visible = true
                    BarLayoutState.updateQuickActionsConfig(root.instanceIndex, c)
                    root._updatingConfig = false
                    autohideTimer.stop()
                }
            }
            onExited: {
                if (cfg && cfg.autoHide) {
                    autohideTimer.restart()
                } else if (cfg && !cfg.autoHide) {
                    autohideTimer.stop()
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onEntered: {
                if (cfg && cfg.autoHide && !root._updatingConfig) {
                    root._updatingConfig = true
                    var c = JSON.parse(JSON.stringify(cfg))
                    c.visible = true
                    BarLayoutState.updateQuickActionsConfig(root.instanceIndex, c)
                    root._updatingConfig = false
                    autohideTimer.stop()
                }
            }
            onExited: {
                if (cfg && cfg.autoHide) {
                    autohideTimer.restart()
                } else if (cfg && !cfg.autoHide) {
                    autohideTimer.stop()
                }
            }
        }

        Connections {
            target: BarLayoutState
            function onDesktopQuickActionsInstancesChanged() {
                if (root._updatingConfig) return
                if (!cfg) return
                if (!cfg.autoHide && !cfg.visible) {
                    root._updatingConfig = true
                    var c = JSON.parse(JSON.stringify(cfg))
                    c.visible = true
                    BarLayoutState.updateQuickActionsConfig(root.instanceIndex, c)
                    root._updatingConfig = false
                    autohideTimer.stop()
                } else if (cfg.autoHide && !cfg.visible) {
                    autohideTimer.restart()
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: cfg && cfg.containerBgEnabled ? resolveColor(cfg.containerBgColorMode, Theme.bgSecondary) : "transparent"
            border.width: cfg && cfg.containerBorderEnabled ? 1 : 0
            border.color: cfg && cfg.containerBorderEnabled ? resolveColor(cfg.containerBorderColorMode || "border", Theme.border) : "transparent"
            radius: (cfg ? cfg.radius : 12) >= 100 ? 1000 * s : (cfg ? cfg.radius : 12) * s

            Loader {
                anchors.fill: parent
                anchors.margins: (cfg && cfg.containerBorderEnabled ? Theme.dp(12) : Theme.dp(6)) * s
                sourceComponent: cfg && cfg.layoutDirection === "vertical" ? columnLayoutComp : rowLayoutComp
            }

            Component {
                id: rowLayoutComp
                RowLayout {
                    anchors.fill: parent
                    spacing: cfg ? cfg.buttonSpacing * s : 2 * s
                    Repeater { model: cfg ? cfg.model : []; delegate: buttonDelegate }
                }
            }

            Component {
                id: columnLayoutComp
                ColumnLayout {
                    anchors.fill: parent
                    spacing: cfg ? cfg.buttonSpacing * s : 2 * s
                    Repeater { model: cfg ? cfg.model : []; delegate: buttonDelegate }
                }
            }

            Component {
                id: buttonDelegate
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: cfg && cfg.layoutDirection === "vertical"
                    Layout.preferredHeight: 58 * s
                    color: (cfg && cfg.hoverEnabled && actMouse.containsMouse) ? resolveColor(cfg.hoverColorMode, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)) : resolveColor(cfg ? cfg.bgColorMode : "bg_secondary", "transparent")
                    border.width: cfg && cfg.borderEnabled ? 1 : 0
                    border.color: (cfg && cfg.borderEnabled && actMouse.containsMouse) ? resolveColor(cfg.borderColorMode, Theme.accent) : (cfg && cfg.borderEnabled ? resolveColor(cfg.borderColorMode, "transparent") : "transparent")
                    radius: (cfg ? cfg.radius : 12) >= 100 ? 1000 * s : Math.max(0, (cfg ? cfg.radius : 12) - 4) * s

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4 * s

                        Item {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.preferredWidth: cfg ? cfg.iconSize * s : 16 * s
                            Layout.preferredHeight: cfg ? cfg.iconSize * s : 16 * s

                            Loader {
                                anchors.fill: parent
                                sourceComponent: {
                                    if (modelData.textIcon) return textIconComp
                                    if (modelData.type === "app") return appIconComp
                                    if (modelData.iconComp === "StarShape") return starComp
                                    if (modelData.iconComp === "IconEye") return eyeComp
                                    if (modelData.iconComp === "IconPause") return pauseComp
                                    if (modelData.iconComp === "IconLoop") return loopComp
                                    if (modelData.iconComp === "IconClose") return closeComp
                                    if (modelData.iconComp === "IconPower") return powerComp
                                    if (modelData.iconComp === "IconShuffle") return shuffleComp
                                    if (modelData.iconComp === "IconPlay") return playComp
                                    if (modelData.iconComp === "IconPanel") return panelComp
                                    return null
                                }
                            }
                        }

                        Text {
                            text: (modelData.label || "").toUpperCase()
                            color: actMouse.containsMouse ? resolveIconColor(cfg ? cfg.iconColorMode : "text_primary") : resolveLabelColor(cfg ? cfg.labelColorMode : "text_muted")
                            font.pixelSize: 8 * s
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                            visible: cfg && cfg.showLabels && text !== ""
                        }
                    }

                    MouseArea {
                        id: actMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.type === "app") {
                                if (modelData.command) {
                                    if (Array.isArray(modelData.command)) {
                                        Quickshell.execDetached({command: modelData.command})
                                    } else {
                                        Quickshell.execDetached({command: ["sh", "-c", modelData.command]})
                                    }
                                }
                            } else {
                                if (modelData.action === "screenshot") {
                                    Quickshell.execDetached({command: ["sh", "-c", "mkdir -p ~/Pictures/Screenshots && (hyprshot -m region -o ~/Pictures/Screenshots || grimblast --notify copy area || grim $(slurp) - | wl-copy)"]})
                                } else if (modelData.action === "lock") {
                                    Quickshell.execDetached({command: ["hyprlock"]})
                                } else if (modelData.action === "sleep") {
                                    Quickshell.execDetached({command: ["systemctl", "suspend"]})
                                } else if (modelData.action === "restart") {
                                    Quickshell.execDetached({command: ["systemctl", "reboot"]})
                                } else if (modelData.action === "power") {
                                    Quickshell.execDetached({command: ["systemctl", "poweroff"]})
                                } else if (modelData.command) {
                                    Quickshell.execDetached({command: ["sh", "-c", modelData.command]})
                                }
                            }
                        }
                    }

                    Component {
                        id: textIconComp
                        Text {
                            text: modelData.textIcon
                            anchors.centerIn: parent
                            font.pixelSize: cfg ? cfg.iconSize * s : 16 * s
                            color: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary")
                        }
                    }

                    Component {
                        id: appIconComp
                        Image {
                            source: modelData.icon ? (modelData.icon.startsWith("/") ? "file://" + modelData.icon : "image://icon/" + modelData.icon) : ""
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                        }
                    }
                }
            }
        }

        Component { id: starComp; StarShape { color: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent; animate: false } }
        Component { id: eyeComp; IconEye { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: pauseComp; IconPause { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: loopComp; IconLoop { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: closeComp; IconClose { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: powerComp; IconPower { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: shuffleComp; IconShuffle { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: playComp; IconPlay { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }
        Component { id: panelComp; IconPanel { iconColor: resolveIconColor(cfg ? cfg.iconColorMode : "text_primary"); anchors.fill: parent } }

        Draggable {
            id: drag
            anchors.fill: parent
            target: container
            boundWidth: root.screenW
            boundHeight: root.screenH
            defaultX: (screenW - container.width) / 2
            defaultY: screenH - container.height - 40 * Scales.uiScale
            enabled: true
            currentX: cfg ? cfg.x : 800
            currentY: cfg ? cfg.y : 900
            onDragPositionChanged: (x, y) => {
                if (cfg && !root._updatingConfig) {
                    root._updatingConfig = true
                    var c = JSON.parse(JSON.stringify(cfg))
                    c.x = x
                    c.y = y
                    BarLayoutState.updateQuickActionsConfig(root.instanceIndex, c)
                    root._updatingConfig = false
                }
            }
            onRotateAction: (r) => {
                container.rotation = r
                rotationSaveTimer.restart()
            }
        }

        Timer {
            id: rotationSaveTimer
            interval: 800
            repeat: false
            onTriggered: {
                if (cfg && !root._updatingConfig) {
                    root._updatingConfig = true
                    var c = JSON.parse(JSON.stringify(cfg))
                    c.rotation = container.rotation
                    BarLayoutState.updateQuickActionsConfig(root.instanceIndex, c)
                    root._updatingConfig = false
                }
            }
        }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopQuickActionsDrag_" + instanceIndex, drag)
        if (cfg && cfg.autoHide) {
            autohideTimer.start()
        } else if (cfg) {
            autohideTimer.stop()
        }
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopQuickActionsDrag_" + instanceIndex)
    }
}
