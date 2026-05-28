import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.elements
import "../components"

VabContentPage {
    id: screenPageRoot

    property int editingIndex: -1
    property bool showingAppPicker: false
    property bool showingActionPicker: false
    property bool showingIconPicker: false
    property int targetIndex: -1

    property int qaEditingInstance: 0

    // Cached config values to avoid binding loops
    property real _qaScale: 1.0
    property real _qaRadius: 12
    property real _qaOpacity: 1.0
    property int _qaButtonSpacing: 2
    property int _qaButtonPadding: 6
    property int _qaIconSize: 16
    property string _qaBgColorMode: "bg_secondary"
    property string _qaHoverColorMode: "accent_soft"
    property string _qaBorderColorMode: "border"
    property string _qaIconColorMode: "text_primary"
    property string _qaLabelColorMode: "text_muted"
    property string _qaLayoutDirection: "horizontal"
    property bool _qaShowLabels: true
    property bool _qaHoverEnabled: true
    property bool _qaBorderEnabled: true
    property bool _qaContainerBgEnabled: true
    property string _qaContainerBgColorMode: "bg_secondary"
    property bool _qaContainerBorderEnabled: true
    property string _qaContainerBorderColorMode: "border"
    property bool _qaAutoHide: true
    property bool _qaEnabled: true
    property string _qaName: "Quick Actions"

    function getQaCfg() {
        if (qaEditingInstance >= 0 && qaEditingInstance < BarLayoutState.desktopQuickActionsInstances.length) {
            return BarLayoutState.desktopQuickActionsInstances[qaEditingInstance]
        }
        return null
    }

    function refreshQaCache() {
        var cfg = getQaCfg()
        if (cfg) {
            _qaScale = cfg.scale !== undefined ? cfg.scale : 1.0
            _qaRadius = cfg.radius !== undefined ? cfg.radius : 12
            _qaOpacity = cfg.opacity !== undefined ? cfg.opacity : 1.0
            _qaButtonSpacing = cfg.buttonSpacing !== undefined ? cfg.buttonSpacing : 2
            _qaButtonPadding = cfg.buttonPadding !== undefined ? cfg.buttonPadding : 6
            _qaIconSize = cfg.iconSize !== undefined ? cfg.iconSize : 16
            _qaBgColorMode = cfg.bgColorMode || "bg_secondary"
            _qaHoverColorMode = cfg.hoverColorMode || "accent_soft"
            _qaBorderColorMode = cfg.borderColorMode || "border"
            _qaIconColorMode = cfg.iconColorMode || "text_primary"
            _qaLabelColorMode = cfg.labelColorMode || "text_muted"
            _qaLayoutDirection = cfg.layoutDirection || "horizontal"
            _qaShowLabels = cfg.showLabels !== undefined ? cfg.showLabels : true
            _qaHoverEnabled = cfg.hoverEnabled !== undefined ? cfg.hoverEnabled : true
            _qaBorderEnabled = cfg.borderEnabled !== undefined ? cfg.borderEnabled : true
            _qaContainerBgEnabled = cfg.containerBgEnabled !== undefined ? cfg.containerBgEnabled : true
            _qaContainerBgColorMode = cfg.containerBgColorMode || "bg_secondary"
            _qaContainerBorderEnabled = cfg.containerBorderEnabled !== undefined ? cfg.containerBorderEnabled : true
            _qaContainerBorderColorMode = cfg.containerBorderColorMode || "border"
            _qaAutoHide = cfg.autoHide !== undefined ? cfg.autoHide : true
            _qaEnabled = cfg.enabled !== undefined ? cfg.enabled : true
            _qaName = cfg.name || "Quick Actions"
        }
    }

    function updateQaProp(key, value) {
        var cfg = getQaCfg()
        if (cfg) {
            var c = JSON.parse(JSON.stringify(cfg))
            c[key] = value
            BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
        }
    }

    onQaEditingInstanceChanged: refreshQaCache()

    Connections {
        target: BarLayoutState
        function onDesktopQuickActionsInstancesChanged() {
            screenPageRoot.refreshQaCache()
        }
    }

    property int currentCategory: 10
    property bool focusInContent: false
    property int contentFocusIndex: 0

    active: screenPageRoot.focusInContent && screenPageRoot.currentCategory === 10
    focusIndex: screenPageRoot.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader {
            title: "Desktop Widgets"
        }

        // --- Clock ---
        VabSettingsCard {
            id: clockCard
            property bool expanded: false
            itemIndex: 0
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 0
            title: "Desktop Clock Widget"
            desc: "Toggle and customize the desktop clock"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: clockCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: clockCard.expanded = !clockCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenClock
                    onToggled: BarLayoutState.showScreenClock = !BarLayoutState.showScreenClock
                }
            }

            ColumnLayout {
                visible: clockCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                VabSectionHeader { title: "Colors" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Text Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "TEXT_PRIMARY", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopClockTextColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopClockTextColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Date Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "TEXT_MUTED", "TEXT_PRIMARY", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopClockDateColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopClockDateColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TRANSPARENT", "BG_SECONDARY", "ACCENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopClockBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopClockBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Border Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TRANSPARENT", "BORDER", "ACCENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopClockBorderColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopClockBorderColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Widget Position"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabButton { text: "Reset Position"; onClicked: { BarLayoutState.desktopClockX = 624; BarLayoutState.desktopClockY = 278 } }
                }
            }
        }

        // --- System Stats ---
        VabSettingsCard {
            id: statsCard
            property bool expanded: false
            itemIndex: 1
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 1
            title: "System Stats Widget"
            desc: "Toggle CPU, RAM, Network, and other system metrics"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: statsCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: statsCard.expanded = !statsCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenSystemStats
                    onToggled: BarLayoutState.showScreenSystemStats = !BarLayoutState.showScreenSystemStats
                }
            }

            ColumnLayout {
                visible: statsCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                // Display Mode Toggle
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Display Mode"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["COMBINED", "INDIVIDUAL"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.statsDisplayMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.statsDisplayMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                // --- Combined Mode Settings ---
                ColumnLayout {
                    visible: BarLayoutState.statsDisplayMode === "combined"
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Layout Mode"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["DEFAULT", "INLINE", "COMPACT"]
                                delegate: VabButton {
                                    text: modelData
                                    active: BarLayoutState.desktopStatsLayout === modelData.toLowerCase()
                                    onClicked: BarLayoutState.desktopStatsLayout = modelData.toLowerCase()
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Color Mode"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["ACCENT", "WHITE", "BLACK"]
                                delegate: VabButton {
                                    text: modelData
                                    active: BarLayoutState.desktopStatsColorMode === modelData.toLowerCase()
                                    onClicked: BarLayoutState.desktopStatsColorMode = modelData.toLowerCase()
                                }
                            }
                        }
                    }

                    VabSectionHeader { title: "Widget Colors" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["BG_SECONDARY", "BG_PRIMARY", "TRANSPARENT"]
                                delegate: VabButton {
                                    text: modelData
                                    active: BarLayoutState.desktopStatsBgColorMode === modelData.toLowerCase()
                                    onClicked: BarLayoutState.desktopStatsBgColorMode = modelData.toLowerCase()
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Border Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["BORDER", "ACCENT", "TRANSPARENT"]
                                delegate: VabButton {
                                    text: modelData
                                    active: BarLayoutState.desktopStatsBorderColorMode === modelData.toLowerCase()
                                    onClicked: BarLayoutState.desktopStatsBorderColorMode = modelData.toLowerCase()
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "CPU Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: Theme.bgSecondary
                            border.width: 1
                            border.color: Theme.border
                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(8)
                                verticalAlignment: TextInput.AlignVCenter
                                text: BarLayoutState.desktopStatsCpuColor
                                color: Theme.textPrimary
                                font.pixelSize: Theme.dp(10)
                                onAccepted: { BarLayoutState.desktopStatsCpuColor = text; BarLayoutState.save() }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "GPU Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: Theme.bgSecondary
                            border.width: 1
                            border.color: Theme.border
                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(8)
                                verticalAlignment: TextInput.AlignVCenter
                                text: BarLayoutState.desktopStatsGpuColor
                                color: Theme.textPrimary
                                font.pixelSize: Theme.dp(10)
                                onAccepted: { BarLayoutState.desktopStatsGpuColor = text; BarLayoutState.save() }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "MEM Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: Theme.bgSecondary
                            border.width: 1
                            border.color: Theme.border
                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(8)
                                verticalAlignment: TextInput.AlignVCenter
                                text: BarLayoutState.desktopStatsMemColor
                                color: Theme.textPrimary
                                font.pixelSize: Theme.dp(10)
                                onAccepted: { BarLayoutState.desktopStatsMemColor = text; BarLayoutState.save() }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Net Down Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: Theme.bgSecondary
                            border.width: 1
                            border.color: Theme.border
                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(8)
                                verticalAlignment: TextInput.AlignVCenter
                                text: BarLayoutState.desktopStatsNetDownColor
                                color: Theme.textPrimary
                                font.pixelSize: Theme.dp(10)
                                onAccepted: { BarLayoutState.desktopStatsNetDownColor = text; BarLayoutState.save() }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Net Up Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: Theme.bgSecondary
                            border.width: 1
                            border.color: Theme.border
                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(8)
                                verticalAlignment: TextInput.AlignVCenter
                                text: BarLayoutState.desktopStatsNetUpColor
                                color: Theme.textPrimary
                                font.pixelSize: Theme.dp(10)
                                onAccepted: { BarLayoutState.desktopStatsNetUpColor = text; BarLayoutState.save() }
                            }
                        }
                    }

                    VabSectionHeader { title: "Visible Metrics" }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: Theme.dp(20)
                        rowSpacing: Theme.dp(8)

                        Repeater {
                            model: [
                                { key: "Cpu", label: "Show CPU" },
                                { key: "Gpu", label: "Show GPU" },
                                { key: "Mem", label: "Show Memory" },
                                { key: "Net", label: "Show Network" },
                                { key: "Disk", label: "Show Disk" },
                                { key: "Uptime", label: "Show Uptime" },
                                { key: "Temp", label: "Show Temperature" },
                                { key: "Battery", label: "Show Battery" },
                                { key: "Swap", label: "Show Swap" },
                                { key: "GpuMem", label: "Show GPU Memory" },
                                { key: "Load", label: "Show Load Avg" },
                                { key: "Process", label: "Show Process" },
                                { key: "Fan", label: "Show Fan" },
                                { key: "Ip", label: "Show IP" }
                            ]
                            delegate: RowLayout {
                                spacing: Theme.dp(8)
                                Layout.fillWidth: true
                                Text { text: modelData.label; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                                VabSwitch {
                                    checked: BarLayoutState["desktopStatsShow" + modelData.key]
                                    onToggled: BarLayoutState["desktopStatsShow" + modelData.key] = !BarLayoutState["desktopStatsShow" + modelData.key]
                                }
                            }
                        }
                    }

                    VabSectionHeader { title: "Network Labels"; Layout.topMargin: Theme.dp(8) }

                    Rectangle {
                        id: netLabelContainer
                        Layout.fillWidth: true
                        height: netLabelColumn.implicitHeight
                        color: "transparent"

                        property int _netLabelKey: 0

                        Connections {
                            target: BarLayoutState
                            function onDesktopStatsNetDownLabelChanged() { netLabelContainer._netLabelKey++ }
                            function onDesktopStatsNetUpLabelChanged() { netLabelContainer._netLabelKey++ }
                        }

                        ColumnLayout {
                            id: netLabelColumn
                            anchors.fill: parent
                            spacing: Theme.dp(8)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(8)
                                Text {
                                    text: "Down"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.dp(9)
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: Theme.dp(50)
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(28)
                                    color: Theme.bgSecondary
                                    border.width: 1
                                    border.color: netDownInput.activeFocus ? Theme.accent : Theme.border
                                    TextInput {
                                        id: netDownInput
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.dp(8)
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: BarLayoutState.desktopStatsNetDownLabel || "DOWN"
                                        color: Theme.textPrimary
                                        font.pixelSize: Theme.dp(9)
                                        selectByMouse: true
                                    }
                                }
                                VabButton {
                                    text: "Apply"
                                    onClicked: {
                                        BarLayoutState.desktopStatsNetDownLabel = netDownInput.text
                                        BarLayoutState.save()
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(8)
                                Text {
                                    text: "Up"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.dp(9)
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: Theme.dp(50)
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Theme.dp(28)
                                    color: Theme.bgSecondary
                                    border.width: 1
                                    border.color: netUpInput.activeFocus ? Theme.accent : Theme.border
                                    TextInput {
                                        id: netUpInput
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.dp(8)
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: BarLayoutState.desktopStatsNetUpLabel || "UP"
                                        color: Theme.textPrimary
                                        font.pixelSize: Theme.dp(9)
                                        selectByMouse: true
                                    }
                                }
                                VabButton {
                                    text: "Apply"
                                    onClicked: {
                                        BarLayoutState.desktopStatsNetUpLabel = netUpInput.text
                                        BarLayoutState.save()
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(8)
                                Text {
                                    text: "Presets"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.dp(9)
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: Theme.dp(50)
                                }
                                RowLayout {
                                    spacing: Theme.dp(4)
                                    Repeater {
                                        model: netLabelContainer._netLabelKey > 0 ? ["DOWN/UP", "DOWNLOAD/UPLOAD", "RX/TX", "IN/OUT", "▼/▲", "↓/↑"] : []
                                        delegate: VabButton {
                                            required property string modelData
                                            text: modelData
                                            active: {
                                                var preset = modelData
                                                var down = preset.split("/")[0]
                                                var up = preset.split("/")[1]
                                                return BarLayoutState.desktopStatsNetDownLabel === down && BarLayoutState.desktopStatsNetUpLabel === up
                                            }
                                            onClicked: {
                                                var preset = modelData
                                                var parts = preset.split("/")
                                                BarLayoutState.desktopStatsNetDownLabel = parts[0]
                                                BarLayoutState.desktopStatsNetUpLabel = parts[1]
                                                BarLayoutState.save()
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(8)
                                Text {
                                    text: "Down Color"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.dp(9)
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: Theme.dp(50)
                                }
                                RowLayout {
                                    spacing: Theme.dp(4)
                                    Repeater {
                                        model: ["ACCENT", "SUCCESS", "DANGER", "WHITE", "BLACK"]
                                        delegate: VabButton {
                                            required property string modelData
                                            text: modelData
                                            active: BarLayoutState.desktopStatsNetDownLabelColorMode === modelData.toLowerCase()
                                            onClicked: {
                                                BarLayoutState.desktopStatsNetDownLabelColorMode = modelData.toLowerCase()
                                                BarLayoutState.save()
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.dp(8)
                                Text {
                                    text: "Up Color"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.dp(9)
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: Theme.dp(50)
                                }
                                RowLayout {
                                    spacing: Theme.dp(4)
                                    Repeater {
                                        model: ["ACCENT", "SUCCESS", "DANGER", "WHITE", "BLACK"]
                                        delegate: VabButton {
                                            required property string modelData
                                            text: modelData
                                            active: BarLayoutState.desktopStatsNetUpLabelColorMode === modelData.toLowerCase()
                                            onClicked: {
                                                BarLayoutState.desktopStatsNetUpLabelColorMode = modelData.toLowerCase()
                                                BarLayoutState.save()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    VabSectionHeader { title: "Widget Size & Position"; Layout.topMargin: Theme.dp(24) }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Widget Size"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        VabSlider {
                            Layout.fillWidth: true
                            from: 0.5; to: 2.0; value: BarLayoutState.desktopStatsScale
                            onValueChanged: BarLayoutState.desktopStatsScale = value
                        }
                        Text { text: Math.round(BarLayoutState.desktopStatsScale * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                        VabButton { text: "Reset"; onClicked: BarLayoutState.desktopStatsScale = 1.0 }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Widget Position"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabButton { text: "Reset Position"; onClicked: { BarLayoutState.desktopStatsX = 40; BarLayoutState.desktopStatsY = 800 } }
                    }
                }

                // --- Individual Mode Settings ---
                ColumnLayout {
                    visible: BarLayoutState.statsDisplayMode === "individual"
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Layout Preset"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["ROW", "GRID", "SCATTERED"]
                                delegate: VabButton {
                                    text: modelData
                                    active: BarLayoutState.individualStatsLayout === modelData.toLowerCase()
                                    onClicked: BarLayoutState.individualStatsLayout = modelData.toLowerCase()
                                }
                            }
                        }
                    }

                    VabSectionHeader { title: "Individual Metric Pages" }

                    Text {
                        text: "Each metric has its own dedicated settings page with controls for visibility, color, size, and position. Navigate to individual metric pages from the settings sidebar."
                        color: Theme.textMuted
                        font.pixelSize: Theme.dp(9)
                        font.italic: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // --- Weather ---
        VabSettingsCard {
            id: weatherCard
            property bool expanded: false
            itemIndex: 2
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 2
            title: "Weather Widget"
            desc: "Toggle current weather and temperature"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: weatherCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: weatherCard.expanded = !weatherCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenWeather
                    onToggled: BarLayoutState.showScreenWeather = !BarLayoutState.showScreenWeather
                }
            }

            ColumnLayout {
                visible: weatherCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Layout Mode"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["DEFAULT", "COMPACT", "INLINE", "VERTICAL", "MINIMAL"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherLayout === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopWeatherLayout = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Widget Size"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.5
                        to: 2.0
                        value: BarLayoutState.desktopWeatherScale
                        onValueChanged: BarLayoutState.desktopWeatherScale = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopWeatherScale * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                    VabButton {
                        text: "Reset"
                        onClicked: BarLayoutState.desktopWeatherScale = 1.0
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Widget Position"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.fillWidth: true
                    }
                    VabButton {
                        text: "Reset Position"
                        onClicked: {
                            BarLayoutState.desktopWeatherX = 40
                            BarLayoutState.desktopWeatherY = 600
                        }
                    }
                }

                VabSectionHeader { title: "Colors" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BG_SECONDARY", "BG_PRIMARY", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopWeatherBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Text Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TEXT_PRIMARY", "ACCENT", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherTextColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopWeatherTextColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Temp Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "TEXT_PRIMARY", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherTempColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopWeatherTempColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Desc Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TEXT_MUTED", "TEXT_PRIMARY", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherDescColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopWeatherDescColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Border Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BORDER", "ACCENT", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherBorderColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopWeatherBorderColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }
            }
        }

        // --- Quick Actions ---
        VabSettingsCard {
            id: qaCard
            property bool expanded: false
            itemIndex: 3
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 3
            title: "Quick Action Buttons"
            desc: "Toggle power and utility shortcuts"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: qaCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: qaCard.expanded = !qaCard.expanded
                }
                VabSwitch {
                    checked: _qaEnabled
                    onToggled: updateQaProp("enabled", !checked)
                }
            }

            ColumnLayout {
                visible: qaCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                // Instance Manager
                VabSectionHeader { title: "Instances" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(6)

                    Repeater {
                        model: BarLayoutState.desktopQuickActionsInstances.length
                        delegate: RowLayout {
                            spacing: Theme.dp(6)
                            Layout.fillWidth: true

                            VabButton {
                                text: BarLayoutState.desktopQuickActionsInstances[index].name || ("QA " + (index + 1))
                                active: qaEditingInstance === index
                                Layout.fillWidth: true
                                onClicked: {
                                    screenPageRoot.qaEditingInstance = index
                                    editingIndex = -1
                                }
                            }

                            Rectangle {
                                width: Theme.dp(28); height: Theme.dp(28)
                                color: Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1)
                                border.width: 1; border.color: Theme.danger; radius: Theme.dp(4)
                                visible: BarLayoutState.desktopQuickActionsInstances.length > 1
                                Text { anchors.centerIn: parent; text: "✕"; color: Theme.danger; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var currentIdx = qaEditingInstance
                                        BarLayoutState.removeQuickActionsInstance(index)
                                        if (currentIdx >= BarLayoutState.desktopQuickActionsInstances.length) {
                                            screenPageRoot.qaEditingInstance = Math.max(0, BarLayoutState.desktopQuickActionsInstances.length - 1)
                                        }
                                        editingIndex = -1
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(6)
                        VabButton { text: "+ ADD"; Layout.fillWidth: true; onClicked: { BarLayoutState.addQuickActionsInstance(); screenPageRoot.qaEditingInstance = BarLayoutState.desktopQuickActionsInstances.length - 1; editingIndex = -1 } }
                        VabButton {
                            text: "DUPLICATE"
                            Layout.fillWidth: true
                            enabled: BarLayoutState.desktopQuickActionsInstances.length > 0
                            onClicked: {
                                BarLayoutState.duplicateQuickActionsInstance(qaEditingInstance)
                                screenPageRoot.qaEditingInstance = qaEditingInstance + 1
                                editingIndex = -1
                            }
                        }
                    }
                }

                // Instance Name
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Name"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    Rectangle {
                        Layout.fillWidth: true; height: Theme.dp(28); color: Theme.bgSecondary; border.width: 1; border.color: qaNameInput.activeFocus ? Theme.accent : Theme.border; radius: Theme.dp(6)
                        TextInput {
                            id: qaNameInput
                            anchors.fill: parent; anchors.leftMargin: Theme.dp(8); anchors.rightMargin: Theme.dp(8); verticalAlignment: TextInput.AlignVCenter
                            text: _qaName
                            color: Theme.textPrimary; font.pixelSize: Theme.dp(10)
                            selectByMouse: true
                            onAccepted: {
                                _qaName = text
                                updateQaProp("name", text)
                            }
                        }
                        }
                    }

                // Enabled toggle
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Enabled"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: _qaEnabled
                        onToggled: {
                            _qaEnabled = !_qaEnabled
                            updateQaProp("enabled", _qaEnabled)
                        }
                    }
                }

                // --- Behavior ---
                VabSectionHeader { title: "Behavior" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "AutoHide (Hover to show)"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: _qaAutoHide
                        onToggled: {
                            _qaAutoHide = !_qaAutoHide
                            updateQaProp("autoHide", _qaAutoHide)
                            if (!_qaAutoHide) {
                                var cfg = getQaCfg()
                                if (cfg && !cfg.visible) {
                                    var c = JSON.parse(JSON.stringify(cfg))
                                    c.visible = true
                                    BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                }
                            }
                        }
                    }
                }

                // --- Button Editor ---
                VabSectionHeader { title: "Buttons" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(8)

                    Repeater {
                        model: getQaCfg() ? getQaCfg().model : []
                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(6)

                            Rectangle {
                                Layout.fillWidth: true
                                height: Theme.dp(54)
                                color: Theme.bgSecondary
                                border.width: 1
                                border.color: screenPageRoot.editingIndex === index ? Theme.accent : Theme.border
                                radius: Theme.dp(8)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.dp(10)
                                    spacing: Theme.dp(14)

                                    Rectangle {
                                        width: Theme.dp(34); height: Theme.dp(34)
                                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                                        radius: Theme.dp(6)
                                        Loader {
                                            anchors.centerIn: parent
                                            width: Theme.dp(20); height: Theme.dp(20)
                                            sourceComponent: {
                                                if (modelData.textIcon) return textIconComp_settings
                                                if (modelData.type === "app") return appIconComp_settings
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

                                    ColumnLayout {
                                        spacing: 0
                                        Layout.fillWidth: true
                                        Text { text: modelData.label; color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                                        Text { text: modelData.type === "app" ? (modelData.command || "No App Selected") : (modelData.action || "Action"); color: Theme.textMuted; font.pixelSize: Theme.dp(9); elide: Text.ElideRight; Layout.fillWidth: true }
                                    }

                                    RowLayout {
                                        spacing: Theme.dp(4)
                                        VabButton {
                                            text: screenPageRoot.editingIndex === index ? "DONE" : "EDIT"
                                            Layout.preferredHeight: Theme.dp(30)
                                            onClicked: screenPageRoot.editingIndex = (screenPageRoot.editingIndex === index ? -1 : index)
                                        }

                                        RowLayout {
                                            spacing: Theme.dp(2)
                                            Rectangle {
                                                width: Theme.dp(30); height: Theme.dp(30); color: Theme.bgPrimary; border.width: 1; border.color: Theme.border; radius: Theme.dp(4); opacity: index > 0 ? 1 : 0.4
                                                Text { anchors.centerIn: parent; text: "↑"; color: Theme.textPrimary; font.pixelSize: Theme.dp(12); font.weight: Font.Bold }
                                                MouseArea {
                                                    anchors.fill: parent; enabled: index > 0; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (getQaCfg()) {
                                                            var c = JSON.parse(JSON.stringify(getQaCfg()))
                                                            var m = c.model.slice()
                                                            var item = m.splice(index, 1)[0]
                                                            m.splice(index - 1, 0, item)
                                                            c.model = m
                                                            BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                                            if (screenPageRoot.editingIndex === index) screenPageRoot.editingIndex = index - 1
                                                            else if (screenPageRoot.editingIndex === index - 1) screenPageRoot.editingIndex = index
                                                        }
                                                    }
                                                }
                                            }
                                            Rectangle {
                                                width: Theme.dp(30); height: Theme.dp(30); color: Theme.bgPrimary; border.width: 1; border.color: Theme.border; radius: Theme.dp(4); opacity: index < (getQaCfg() ? getQaCfg().model.length : 0) - 1 ? 1 : 0.4
                                                Text { anchors.centerIn: parent; text: "↓"; color: Theme.textPrimary; font.pixelSize: Theme.dp(12); font.weight: Font.Bold }
                                                MouseArea {
                                                    anchors.fill: parent; enabled: index < (getQaCfg() ? getQaCfg().model.length : 0) - 1; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (getQaCfg()) {
                                                            var c = JSON.parse(JSON.stringify(getQaCfg()))
                                                            var m = c.model.slice()
                                                            var item = m.splice(index, 1)[0]
                                                            m.splice(index + 1, 0, item)
                                                            c.model = m
                                                            BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                                            if (screenPageRoot.editingIndex === index) screenPageRoot.editingIndex = index + 1
                                                            else if (screenPageRoot.editingIndex === index + 1) screenPageRoot.editingIndex = index
                                                        }
                                                    }
                                                }
                                            }
                                            Rectangle {
                                                width: Theme.dp(30); height: Theme.dp(30); color: Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1); border.width: 1; border.color: Theme.danger; radius: Theme.dp(4)
                                                Text { anchors.centerIn: parent; text: "✕"; color: Theme.danger; font.pixelSize: Theme.dp(12); font.weight: Font.Bold }
                                                MouseArea {
                                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (getQaCfg()) {
                                                            var c = JSON.parse(JSON.stringify(getQaCfg()))
                                                            var m = c.model.slice()
                                                            m.splice(index, 1)
                                                            c.model = m
                                                            BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                                            screenPageRoot.editingIndex = -1
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: screenPageRoot.editingIndex === index
                                Layout.fillWidth: true
                                implicitHeight: editCol.implicitHeight + Theme.dp(20)
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                                border.width: 1
                                border.color: Theme.accent
                                radius: Theme.dp(8)

                                ColumnLayout {
                                    id: editCol
                                    anchors.fill: parent
                                    anchors.margins: Theme.dp(10)
                                    spacing: Theme.dp(10)

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Type"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); Layout.preferredWidth: Theme.dp(60) }
                                        RowLayout {
                                            spacing: Theme.dp(6)
                                            VabButton {
                                                text: "ACTION"
                                                active: getQaCfg().model[index].type === "action"
                                                Layout.preferredHeight: Theme.dp(28)
                                                onClicked: {
                                                    var c = JSON.parse(JSON.stringify(getQaCfg()))
                                                    c.model[index].type = "action"
                                                    c.model[index].action = "power"
                                                    c.model[index].textIcon = "⏻"
                                                    c.model[index].iconComp = ""
                                                    BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                                }
                                            }
                                            VabButton {
                                                text: "APP"
                                                active: getQaCfg().model[index].type === "app"
                                                Layout.preferredHeight: Theme.dp(28)
                                                onClicked: {
                                                    screenPageRoot.targetIndex = index
                                                    screenPageRoot.showingAppPicker = true
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Label"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); Layout.preferredWidth: Theme.dp(60) }
                                        Rectangle {
                                            Layout.fillWidth: true; height: Theme.dp(28); color: Theme.bgSecondary; border.width: 1; border.color: labelInput.activeFocus ? Theme.accent : Theme.border; radius: Theme.dp(6)
                                            TextInput {
                                                id: labelInput
                                                anchors.fill: parent; anchors.leftMargin: Theme.dp(8); anchors.rightMargin: Theme.dp(8); verticalAlignment: TextInput.AlignVCenter
                                                text: modelData.label; color: Theme.textPrimary; font.pixelSize: Theme.dp(10)
                                                selectByMouse: true
                                                onAccepted: {
                                                    var c = JSON.parse(JSON.stringify(getQaCfg()))
                                                    c.model[index].label = text
                                                    BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: modelData.type === "app" ? "App" : "Action"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); Layout.preferredWidth: Theme.dp(60) }
                                        VabButton {
                                            visible: modelData.type === "action"
                                            text: modelData.action ? "Select: " + modelData.action : "Select Action"
                                            Layout.fillWidth: true
                                            onClicked: {
                                                screenPageRoot.targetIndex = index
                                                screenPageRoot.showingActionPicker = true
                                            }
                                        }
                                        VabButton {
                                            visible: modelData.type === "app"
                                            text: modelData.command ? "Change: " + modelData.command : "Select App"
                                            Layout.fillWidth: true
                                            onClicked: {
                                                screenPageRoot.targetIndex = index
                                                screenPageRoot.showingAppPicker = true
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Icon"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); Layout.preferredWidth: Theme.dp(60) }
                                        Rectangle {
                                            Layout.fillWidth: true; height: Theme.dp(28); color: Theme.bgSecondary; border.width: 1; border.color: iconInput.activeFocus ? Theme.accent : Theme.border; radius: Theme.dp(6)
                                            TextInput {
                                                id: iconInput
                                                anchors.fill: parent; anchors.leftMargin: Theme.dp(8); anchors.rightMargin: Theme.dp(8); verticalAlignment: TextInput.AlignVCenter
                                                text: modelData.textIcon || (modelData.type === "app" ? (modelData.icon || "") : (modelData.iconComp || ""))
                                                color: Theme.textPrimary; font.pixelSize: Theme.dp(10)
                                                focus: true
                                                selectByMouse: true
                                                Keys.onPressed: (event) => { if (event.key === Qt.Key_Space) event.accepted = true }
                                                onTextEdited: {
                                                    var c = JSON.parse(JSON.stringify(getQaCfg()))
                                                    if (modelData.type === "app") { c.model[index].icon = text; c.model[index].textIcon = "" }
                                                    else { if (text.length > 0 && text.length <= 2) { c.model[index].textIcon = text; c.model[index].iconComp = "" } else { c.model[index].iconComp = text; c.model[index].textIcon = "" } }
                                                    BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                                }
                                            }
                                        }
                                        VabButton {
                                            text: "🎨"
                                            Layout.preferredHeight: Theme.dp(28)
                                            Layout.preferredWidth: Theme.dp(28)
                                            onClicked: {
                                                screenPageRoot.targetIndex = index
                                                screenPageRoot.showingIconPicker = true
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.type === "app" ? "Icon is set automatically from app selection." : "Icon can be Unicode (emoji) or component name (e.g. IconPower)."
                                        color: Theme.textMuted; font.pixelSize: Theme.dp(7); font.italic: true
                                        wrapMode: Text.WordWrap; Layout.fillWidth: true
                                    }
                                }
                            }

                            Component { id: appIconComp_settings; Image { source: modelData.icon ? (modelData.icon.startsWith("/") ? "file://" + modelData.icon : "image://icon/" + modelData.icon) : ""; fillMode: Image.PreserveAspectFit; anchors.fill: parent } }
                            Component { id: textIconComp_settings; Text { text: modelData.textIcon; anchors.centerIn: parent; font.pixelSize: Theme.dp(14); color: Theme.textPrimary } }
                            Component { id: starComp; StarShape { color: Theme.textPrimary; anchors.fill: parent; animate: false } }
                            Component { id: eyeComp; IconEye { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: pauseComp; IconPause { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: loopComp; IconLoop { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: closeComp; IconClose { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: powerComp; IconPower { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: shuffleComp; IconShuffle { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: playComp; IconPlay { iconColor: Theme.textPrimary; anchors.fill: parent } }
                            Component { id: panelComp; IconPanel { iconColor: Theme.textPrimary; anchors.fill: parent } }
                        }
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: Theme.dp(8)
                        VabButton {
                            text: "ADD ACTION"
                            Layout.fillWidth: true
                            onClicked: {
                                if (getQaCfg()) {
                                    var c = JSON.parse(JSON.stringify(getQaCfg()))
                                    c.model.push({ textIcon: "⏻", action: "power", label: "Power", type: "action" })
                                    BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                }
                            }
                        }
                        VabButton {
                            text: "ADD APP"
                            Layout.fillWidth: true
                            onClicked: {
                                screenPageRoot.targetIndex = -1
                                screenPageRoot.showingAppPicker = true
                            }
                        }
                        VabButton {
                            text: "RESET TO DEFAULT"
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            onClicked: {
                                if (getQaCfg()) {
                                    var c = JSON.parse(JSON.stringify(getQaCfg()))
                                    c.model = [
                                        { textIcon: "📸", action: "screenshot", label: "Shot", type: "action" },
                                        { textIcon: "🔒", action: "lock", label: "Lock", type: "action" },
                                        { textIcon: "☾", action: "sleep", label: "Sleep", type: "action" },
                                        { textIcon: "↻", action: "restart", label: "Reboot", type: "action" },
                                        { textIcon: "⏻", action: "power", label: "Off", type: "action" }
                                    ]
                                    BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                }
                            }
                        }
                    }
                }

                // --- Appearance ---
                VabSectionHeader { title: "Appearance" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Widget Size"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        id: qaScaleSlider
                        Layout.fillWidth: true
                        from: 0.5; to: 2.0
                        value: _qaScale
                        onValueChanged: {
                            if (Math.abs(_qaScale - value) > 0.001) {
                                _qaScale = value
                                updateQaProp("scale", value)
                            }
                        }
                    }
                    Text { text: Math.round(_qaScale * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                    VabButton { text: "Reset"; onClicked: { _qaScale = 1.0; updateQaProp("scale", 1.0) } }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Corner Radius"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: _qaRadius
                        onValueChanged: {
                            if (Math.round(value) !== _qaRadius) {
                                _qaRadius = Math.round(value)
                                updateQaProp("radius", Math.round(value))
                            }
                        }
                    }
                    Text { text: Math.round(_qaRadius) + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Opacity"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.1; to: 1.0
                        value: _qaOpacity
                        onValueChanged: {
                            if (Math.abs(_qaOpacity - value) > 0.01) {
                                _qaOpacity = value
                                updateQaProp("opacity", value)
                            }
                        }
                    }
                    Text { text: Math.round(_qaOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                // Colors
                VabSectionHeader { title: "Colors" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(8)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["ACCENT", "BG_SECONDARY", "TRANSPARENT"]
                                delegate: VabButton {
                                    text: modelData
                                    active: _qaBgColorMode === modelData.toLowerCase()
                                    onClicked: { _qaBgColorMode = modelData.toLowerCase(); updateQaProp("bgColorMode", modelData.toLowerCase()) }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Hover"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["ACCENT_SOFT", "BG_SECONDARY", "TRANSPARENT"]
                                delegate: VabButton {
                                    text: modelData
                                    active: _qaHoverColorMode === modelData.toLowerCase()
                                    onClicked: { _qaHoverColorMode = modelData.toLowerCase(); updateQaProp("hoverColorMode", modelData.toLowerCase()) }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Border"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["BORDER", "ACCENT", "TRANSPARENT"]
                                delegate: VabButton {
                                    text: modelData
                                    active: _qaBorderColorMode === modelData.toLowerCase()
                                    onClicked: { _qaBorderColorMode = modelData.toLowerCase(); updateQaProp("borderColorMode", modelData.toLowerCase()) }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Label"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["ACCENT", "TEXT_MUTED", "TEXT_PRIMARY", "WHITE", "BLACK"]
                                delegate: VabButton {
                                    text: modelData
                                    active: _qaLabelColorMode === modelData.toLowerCase()
                                    onClicked: { _qaLabelColorMode = modelData.toLowerCase(); updateQaProp("labelColorMode", modelData.toLowerCase()) }
                                }
                            }
                        }
                    }
                }

                // Toggles
                VabSectionHeader { title: "Toggles" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(8)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Hover Effect"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: _qaHoverEnabled
                            onToggled: { _qaHoverEnabled = !_qaHoverEnabled; updateQaProp("hoverEnabled", _qaHoverEnabled) }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Border"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: _qaBorderEnabled
                            onToggled: { _qaBorderEnabled = !_qaBorderEnabled; updateQaProp("borderEnabled", _qaBorderEnabled) }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)
                        Text { text: "Show Labels"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: _qaShowLabels
                            onToggled: { _qaShowLabels = !_qaShowLabels; updateQaProp("showLabels", _qaShowLabels) }
                        }
                    }
                }

                // Layout
                VabSectionHeader { title: "Layout" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Direction"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["HORIZONTAL", "VERTICAL"]
                            delegate: VabButton {
                                text: modelData
                                active: _qaLayoutDirection === modelData.toLowerCase()
                                onClicked: { _qaLayoutDirection = modelData.toLowerCase(); updateQaProp("layoutDirection", modelData.toLowerCase()) }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Spacing"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0; to: 20
                        value: _qaButtonSpacing
                        onValueChanged: {
                            if (Math.round(value) !== _qaButtonSpacing) {
                                _qaButtonSpacing = Math.round(value)
                                updateQaProp("buttonSpacing", Math.round(value))
                            }
                        }
                    }
                    Text { text: Math.round(_qaButtonSpacing) + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Padding"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0; to: 20
                        value: _qaButtonPadding
                        onValueChanged: {
                            if (Math.round(value) !== _qaButtonPadding) {
                                _qaButtonPadding = Math.round(value)
                                updateQaProp("buttonPadding", Math.round(value))
                            }
                        }
                    }
                    Text { text: Math.round(_qaButtonPadding) + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Icon Size"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 12; to: 32
                        value: _qaIconSize
                        onValueChanged: {
                            if (Math.round(value) !== _qaIconSize) {
                                _qaIconSize = Math.round(value)
                                updateQaProp("iconSize", Math.round(value))
                            }
                        }
                    }
                    Text { text: Math.round(_qaIconSize) + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                // Container
                VabSectionHeader { title: "Container" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: _qaContainerBgEnabled
                        onToggled: { _qaContainerBgEnabled = !_qaContainerBgEnabled; updateQaProp("containerBgEnabled", _qaContainerBgEnabled) }
                    }
                }

                RowLayout {
                    visible: _qaContainerBgEnabled
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Container BG"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BG_SECONDARY", "BG_PRIMARY", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: _qaContainerBgColorMode === modelData.toLowerCase()
                                onClicked: { _qaContainerBgColorMode = modelData.toLowerCase(); updateQaProp("containerBgColorMode", modelData.toLowerCase()) }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Container Border"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: _qaContainerBorderEnabled
                        onToggled: { _qaContainerBorderEnabled = !_qaContainerBorderEnabled; updateQaProp("containerBorderEnabled", _qaContainerBorderEnabled) }
                    }
                }

                RowLayout {
                    visible: _qaContainerBorderEnabled
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Container Border Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BORDER", "ACCENT", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: _qaContainerBorderColorMode === modelData.toLowerCase()
                                onClicked: { _qaContainerBorderColorMode = modelData.toLowerCase(); updateQaProp("containerBorderColorMode", modelData.toLowerCase()) }
                            }
                        }
                    }
                }

                // Position
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Position"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabButton {
                        text: "Reset Position"
                        onClicked: {
                            var cfg = getQaCfg()
                            if (cfg) {
                                var c = JSON.parse(JSON.stringify(cfg))
                                c.x = 960
                                c.y = 900
                                BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                            }
                        }
                    }
                }
            }
        }

        // --- System Indicator ---
        VabSettingsCard {
            id: sysIndicatorCard
            property bool expanded: false
            itemIndex: 4
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 4
            title: "System Indicator"
            desc: "Volume and brightness indicator popup"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: sysIndicatorCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: sysIndicatorCard.expanded = !sysIndicatorCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showIndicators
                    onToggled: BarLayoutState.showIndicators = !BarLayoutState.showIndicators
                }
            }

            ColumnLayout {
                visible: sysIndicatorCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                // Visibility Toggles
                VabSectionHeader { title: "Visibility" }
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: Theme.dp(20)
                    rowSpacing: Theme.dp(8)
                    Repeater {
                        model: [
                            { key: "showVolumeIndicator", label: "Show Volume Indicator" },
                            { key: "showBrightnessIndicator", label: "Show Brightness Indicator" },
                            { key: "showPinnedIndicator", label: "Show Pinned Indicator" }
                        ]
                        delegate: RowLayout {
                            spacing: Theme.dp(8)
                            Layout.fillWidth: true
                            Text { text: modelData.label; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                            VabSwitch {
                                checked: BarLayoutState[modelData.key]
                                onToggled: BarLayoutState[modelData.key] = !BarLayoutState[modelData.key]
                            }
                        }
                    }
                }

                // Position & Size
                VabSectionHeader { title: "Position & Size" }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Position"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        Repeater {
                            model: ["CENTER", "TOP-LEFT", "TOP-RIGHT", "BOTTOM-LEFT", "BOTTOM-RIGHT", "TOP-CENTER", "BOTTOM-CENTER"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorPosition === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorPosition = modelData.toLowerCase()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Scale"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.5; to: 2.0; value: BarLayoutState.indicatorScale
                        onValueChanged: BarLayoutState.indicatorScale = value
                    }
                    Text { text: Math.round(BarLayoutState.indicatorScale * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                // Appearance
                VabSectionHeader { title: "Appearance" }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Bg Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["SECONDARY", "PRIMARY", "TRANSPARENT", "ACCENT", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Progress"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "SUCCESS", "DANGER", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorProgressColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorProgressColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Text Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TEXT_PRIMARY", "ACCENT", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorTextColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorTextColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Border"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BORDER", "ACCENT", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorBorderColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorBorderColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Radius"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0; to: 24; value: BarLayoutState.indicatorRadius
                        onValueChanged: BarLayoutState.indicatorRadius = value
                    }
                    Text { text: Math.round(BarLayoutState.indicatorRadius) + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Opacity"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.5; to: 1.0; value: BarLayoutState.indicatorOpacity
                        onValueChanged: BarLayoutState.indicatorOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.indicatorOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight }
                }

                // Behavior
                VabSectionHeader { title: "Behavior" }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Timeout"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 500; to: 5000; stepSize: 100; value: BarLayoutState.indicatorTimeout
                        onValueChanged: BarLayoutState.indicatorTimeout = value
                    }
                    Text { text: Math.round(BarLayoutState.indicatorTimeout) + "ms"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(50); horizontalAlignment: Text.AlignRight }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Animation"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 50; to: 500; stepSize: 10; value: BarLayoutState.indicatorAnimationDuration
                        onValueChanged: BarLayoutState.indicatorAnimationDuration = value
                    }
                    Text { text: Math.round(BarLayoutState.indicatorAnimationDuration) + "ms"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(50); horizontalAlignment: Text.AlignRight }
                }
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: Theme.dp(20)
                    rowSpacing: Theme.dp(8)
                    Repeater {
                        model: [
                            { key: "indicatorShowValue", label: "Show Value" },
                            { key: "indicatorShowProgress", label: "Show Progress" },
                            { key: "indicatorShowIcon", label: "Show Icon" },
                            { key: "indicatorShowLabel", label: "Show Label" }
                        ]
                        delegate: RowLayout {
                            spacing: Theme.dp(8)
                            Layout.fillWidth: true
                            Text { text: modelData.label; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                            VabSwitch {
                                checked: BarLayoutState[modelData.key]
                                onToggled: BarLayoutState[modelData.key] = !BarLayoutState[modelData.key]
                            }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(6)
                    RowLayout {
                        spacing: Theme.dp(12)
                        Text { text: "Element Order"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        Text { text: '(Reorder indicator elements)'; color: Theme.textSecondary; font.pixelSize: Theme.dp(9); font.italic: true }
                    }
                    Repeater {
                        model: BarLayoutState.indicatorElementOrder
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.dp(8)
                            property int elemIdx: index
                            Text {
                                text: {
                                    var labels = { "icon": "Icon", "label": "Label", "progress": "Progress", "value": "Value" };
                                    return labels[modelData] || modelData;
                                }
                                color: Theme.textPrimary
                                font.pixelSize: Theme.dp(10)
                                font.weight: Font.Bold
                                Layout.preferredWidth: Theme.dp(80)
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.dp(1)
                                color: Theme.border
                            }
                            RowLayout {
                                spacing: Theme.dp(4)
                                Layout.alignment: Qt.AlignRight
                                VabButton {
                                    text: "▲"
                                    enabled: elemIdx > 0
                                    onClicked: BarLayoutState.moveIndicatorElement(elemIdx, elemIdx - 1)
                                }
                                VabButton {
                                    text: "▼"
                                    enabled: elemIdx < BarLayoutState.indicatorElementOrder.length - 1
                                    onClicked: BarLayoutState.moveIndicatorElement(elemIdx, elemIdx + 1)
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Progress Width"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 40; to: 120; stepSize: 5; value: BarLayoutState.indicatorProgressWidth
                        onValueChanged: BarLayoutState.indicatorProgressWidth = value
                    }
                    Text { text: Math.round(BarLayoutState.indicatorProgressWidth) + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(40); horizontalAlignment: Text.AlignRight }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Value Pos"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: Theme.dp(4)
                        rowSpacing: Theme.dp(4)
                        Repeater {
                            model: ["RIGHT", "LEFT", "TOP", "BOTTOM"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorValuePosition === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorValuePosition = modelData.toLowerCase()
                            }
                        }
                    }
                }

                // Style
                VabSectionHeader { title: "Style" }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Indicator"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ROUNDED", "PILL", "SQUARE", "MINIMAL"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorStyle === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorStyle = modelData.toLowerCase()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Progress"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["FILL", "OUTLINE", "DOTS", "WAVE"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.indicatorProgressStyle === modelData.toLowerCase()
                                onClicked: BarLayoutState.indicatorProgressStyle = modelData.toLowerCase()
                            }
                        }
                    }
                }
            }
        }

        // --- Now Playing ---
        VabSettingsCard {
            id: npCard
            property bool expanded: false
            itemIndex: 5
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 5
            title: "Now Playing Widget"
            desc: "Toggle music player widget on desktop"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: npCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: npCard.expanded = !npCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenNowPlaying
                    onToggled: BarLayoutState.showScreenNowPlaying = !BarLayoutState.showScreenNowPlaying
                }
            }

            ColumnLayout {
                visible: npCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Widget Size"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.5
                        to: 2.0
                        value: BarLayoutState.desktopNowPlayingScale
                        onValueChanged: BarLayoutState.desktopNowPlayingScale = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopNowPlayingScale * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                    VabButton {
                        text: "Reset"
                        onClicked: BarLayoutState.desktopNowPlayingScale = 1.0
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Widget Position"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.fillWidth: true
                    }
                    VabButton {
                        text: "Reset Position"
                        onClicked: {
                            BarLayoutState.desktopNowPlayingX = 1400
                            BarLayoutState.desktopNowPlayingY = 40
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Style"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["NIER", "CARD", "MINIMAL", "GLASS", "RETRO"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopNowPlayingStyle === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopNowPlayingStyle = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Corner Radius"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: 48
                        value: BarLayoutState.desktopNowPlayingRadius
                        onValueChanged: BarLayoutState.desktopNowPlayingRadius = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopNowPlayingRadius) + "px"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                    VabButton {
                        text: "Reset"
                        onClicked: BarLayoutState.desktopNowPlayingRadius = 16
                    }
                }

                VabSectionHeader { title: "Colors" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BG_SECONDARY", "BG_PRIMARY", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopNowPlayingBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopNowPlayingBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Text Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TEXT_PRIMARY", "ACCENT", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopNowPlayingTextColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopNowPlayingTextColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Accent Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "TEXT_PRIMARY", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopNowPlayingAccentColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopNowPlayingAccentColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Border Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["BORDER", "ACCENT", "TRANSPARENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopNowPlayingBorderColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopNowPlayingBorderColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }
            }
        }

        // --- Standalone Equalizer ---
        VabSettingsCard {
            id: eqCard
            property bool expanded: false
            itemIndex: 6
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 6
            title: "Standalone Equalizer"
            desc: "Customizable high-fidelity audio visualizer"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: eqCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: eqCard.expanded = !eqCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenEqualizer
                    onToggled: BarLayoutState.showScreenEqualizer = !BarLayoutState.showScreenEqualizer
                }
            }

            ColumnLayout {
                visible: eqCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Visual Style"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["WAVE", "BARS", "BARS-FILL", "DOTS"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopEqualizerStyle === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopEqualizerStyle = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Color Mode"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "WHITE", "BLACK", "CUSTOM"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopEqualizerColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopEqualizerColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TRANSPARENT", "BG_SECONDARY", "BG_PRIMARY"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopEqualizerBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopEqualizerBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Border Color"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["TRANSPARENT", "BORDER", "ACCENT"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopEqualizerBorderColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopEqualizerBorderColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    visible: BarLayoutState.desktopEqualizerColorMode === "custom"
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Custom Color (Hex)"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(32)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.border
                        TextInput {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.dp(8)
                            verticalAlignment: TextInput.AlignVCenter
                            text: BarLayoutState.desktopEqualizerCustomColor
                            color: Theme.textPrimary
                            font.pixelSize: Theme.dp(10)
                            onAccepted: { BarLayoutState.desktopEqualizerCustomColor = text; BarLayoutState.save() }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Double Wave Effect"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: BarLayoutState.desktopEqualizerDoubleWave
                        onToggled: BarLayoutState.desktopEqualizerDoubleWave = !BarLayoutState.desktopEqualizerDoubleWave
                        enabled: BarLayoutState.desktopEqualizerStyle === "wave"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Filled Wave"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: BarLayoutState.desktopEqualizerFilled
                        onToggled: BarLayoutState.desktopEqualizerFilled = !BarLayoutState.desktopEqualizerFilled
                        enabled: BarLayoutState.desktopEqualizerStyle === "wave"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Mirror Mode"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: BarLayoutState.desktopEqualizerMirrored
                        onToggled: BarLayoutState.desktopEqualizerMirrored = !BarLayoutState.desktopEqualizerMirrored
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Line/Fill"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.05; to: 0.6; value: BarLayoutState.desktopEqualizerFillOpacity
                        onValueChanged: BarLayoutState.desktopEqualizerFillOpacity = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopEqualizerFillOpacity * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Widget Size"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.5; to: 3.0; value: BarLayoutState.desktopEqualizerScale
                        onValueChanged: BarLayoutState.desktopEqualizerScale = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopEqualizerScale * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Widget Position"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.fillWidth: true
                    }
                    VabButton {
                        text: "Reset Position"
                        onClicked: {
                            BarLayoutState.desktopEqualizerX = (Screen.width - 240) / 2
                            BarLayoutState.desktopEqualizerY = (Screen.height - 80) / 2
                        }
                    }
                }
            }
        }

        VabSectionHeader {
            title: "Appearance & Effects"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: opacityCard
            property bool expanded: false
            itemIndex: 7
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 7
            title: "Widget Opacity"
            desc: "Adjust transparency for desktop widgets"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Reset"
                    onClicked: {
                        BarLayoutState.desktopWidgetsOpacity = 1.0
                        BarLayoutState.desktopClockOpacity = 1.0
                        BarLayoutState.desktopNowPlayingOpacity = 1.0
                        BarLayoutState.desktopStatsOpacity = 1.0
                        BarLayoutState.desktopWeatherOpacity = 1.0
                        BarLayoutState.desktopQuickActionsOpacity = 1.0
                        BarLayoutState.desktopEqualizerOpacity = 1.0
                    }
                }
                VabButton {
                    text: opacityCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: opacityCard.expanded = !opacityCard.expanded
                }
            }

            ColumnLayout {
                visible: opacityCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(8)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Global"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.1; to: 1.0; value: BarLayoutState.desktopWidgetsOpacity
                        onValueChanged: BarLayoutState.desktopWidgetsOpacity = value
                    }
                }

                VabSectionHeader { title: "Widget Size & Position"; Layout.topMargin: Theme.dp(12) }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Desktop Clock"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.desktopClockOpacity
                        onValueChanged: BarLayoutState.desktopClockOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.desktopClockOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Now Playing"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.desktopNowPlayingOpacity
                        onValueChanged: BarLayoutState.desktopNowPlayingOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.desktopNowPlayingOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Equalizer"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.desktopEqualizerOpacity
                        onValueChanged: BarLayoutState.desktopEqualizerOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.desktopEqualizerOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "System Stats"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.desktopStatsOpacity
                        onValueChanged: BarLayoutState.desktopStatsOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.desktopStatsOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Weather"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.desktopWeatherOpacity
                        onValueChanged: BarLayoutState.desktopWeatherOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.desktopWeatherOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Quick Actions"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                    Text { text: "Per-instance in QA settings"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); font.italic: true; Layout.fillWidth: true }
                }
            }
        }

        VabSectionHeader {
            title: "Popup Appearance"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: popupAppearanceCard
            property bool expanded: false
            itemIndex: 8
            isFocused: screenPageRoot.focusInContent && screenPageRoot.contentFocusIndex === 8
            title: "Popup Style"
            desc: "Rounded corners and transparency for bar popups"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: popupAppearanceCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: popupAppearanceCard.expanded = !popupAppearanceCard.expanded
                }
            }

            ColumnLayout {
                visible: popupAppearanceCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(8)

                VabSectionHeader {
                    title: "Rounded Corners"
                }

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: Theme.dp(20)
                    rowSpacing: Theme.dp(8)

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Weather Popup"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.weatherPopupRounded
                            onToggled: BarLayoutState.weatherPopupRounded = !BarLayoutState.weatherPopupRounded
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Calendar Popup"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.calendarPopupRounded
                            onToggled: BarLayoutState.calendarPopupRounded = !BarLayoutState.calendarPopupRounded
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Notification Popup"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.notifPopupRounded
                            onToggled: BarLayoutState.notifPopupRounded = !BarLayoutState.notifPopupRounded
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Right Bar Popup"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.barPopupRounded
                            onToggled: BarLayoutState.barPopupRounded = !BarLayoutState.barPopupRounded
                        }
                    }
                }
            }
        }

    // --- App Picker Overlay ---
    Rectangle {
        id: appPickerOverlay
        parent: screenPageRoot
        visible: screenPageRoot.showingAppPicker
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        z: 100

        MouseArea { anchors.fill: parent; onClicked: screenPageRoot.showingAppPicker = false }

        Rectangle {
            width: Math.min(screenPageRoot.width - Theme.dp(40), Theme.dp(320))
            height: Theme.dp(400)
            anchors.centerIn: parent
            color: Theme.bgPrimary
            border.width: 1
            border.color: Theme.border
            radius: Theme.dp(12)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(16)
                spacing: Theme.dp(12)

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Select Application"; color: Theme.accent; font.pixelSize: Theme.dp(14); font.weight: Font.Bold; Layout.fillWidth: true }
                    VabButton { text: "✕"; onClicked: screenPageRoot.showingAppPicker = false }
                }

                Rectangle {
                    Layout.fillWidth: true; height: Theme.dp(36); color: Theme.bgSecondary; border.width: 1; border.color: pickerSearch.activeFocus ? Theme.accent : Theme.border; radius: Theme.dp(6)
                    TextField {
                        id: pickerSearch
                        anchors.fill: parent; anchors.leftMargin: Theme.dp(10); verticalAlignment: TextInput.AlignVCenter
                        placeholderText: "Search apps..."
                        color: Theme.textPrimary; font.pixelSize: Theme.dp(11)
                        placeholderTextColor: Theme.textMuted
                        background: Item {}
                        onTextChanged: if (BarLayoutState.getItem("launcherSvc")) BarLayoutState.getItem("launcherSvc").searchText = text
                        focus: screenPageRoot.showingAppPicker
                    }
                }

                ListView {
                    id: appListView
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: BarLayoutState.getItem("launcherSvc") ? BarLayoutState.getItem("launcherSvc").filteredApps : []
                    clip: true
                    spacing: Theme.dp(4)
                    delegate: Rectangle {
                        width: appListView.width; height: Theme.dp(42); color: mouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                        radius: Theme.dp(6)
                        RowLayout {
                            anchors.fill: parent; anchors.margins: Theme.dp(8); spacing: Theme.dp(12)
                            Image { source: BarLayoutState.getItem("launcherSvc") ? BarLayoutState.getItem("launcherSvc").getIconPath(modelData) : ""; Layout.preferredWidth: Theme.dp(24); Layout.preferredHeight: Theme.dp(24); fillMode: Image.PreserveAspectFit }
                            ColumnLayout {
                                spacing: 0; Layout.fillWidth: true
                                Text { text: modelData.name; color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: modelData.id; color: Theme.textMuted; font.pixelSize: Theme.dp(9); elide: Text.ElideRight; Layout.fillWidth: true }
                            }
                        }
                        MouseArea {
                            id: mouse; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                var cfg = BarLayoutState.getQuickActionsConfig(qaEditingInstance)
                                var c = JSON.parse(JSON.stringify(cfg))
                                var m = c.model.slice()
                                var app = {
                                    type: "app",
                                    label: modelData.name.substring(0, 10),
                                    command: modelData.id,
                                    icon: modelData.icon,
                                    textIcon: ""
                                }
                                if (screenPageRoot.targetIndex >= 0) {
                                    m[screenPageRoot.targetIndex] = app
                                } else {
                                    m.push(app)
                                }
                                c.model = m
                                BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                screenPageRoot.showingAppPicker = false
                                screenPageRoot.editingIndex = (screenPageRoot.targetIndex >= 0 ? screenPageRoot.targetIndex : m.length - 1)
                            }
                        }
                    }
                }
            }
        }
    }

    // --- Action Picker Overlay ---
    Rectangle {
        id: actionPickerOverlay
        parent: screenPageRoot
        visible: screenPageRoot.showingActionPicker
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        z: 101

        MouseArea { anchors.fill: parent; onClicked: screenPageRoot.showingActionPicker = false }

        Rectangle {
            width: Theme.dp(260)
            height: Theme.dp(320)
            anchors.centerIn: parent
            color: Theme.bgPrimary
            border.width: 1
            border.color: Theme.border
            radius: Theme.dp(12)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(16)
                spacing: Theme.dp(12)

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Select Action"; color: Theme.accent; font.pixelSize: Theme.dp(14); font.weight: Font.Bold; Layout.fillWidth: true }
                    VabButton { text: "✕"; onClicked: screenPageRoot.showingActionPicker = false }
                }

                ListView {
                    id: actionListView
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true
                    spacing: Theme.dp(4)
                    model: [
                        { label: "Screenshot", action: "screenshot", icon: "📸", iconComp: "" },
                        { label: "Lock Screen", action: "lock", icon: "🔒", iconComp: "" },
                        { label: "Sleep/Suspend", action: "sleep", icon: "☾", iconComp: "" },
                        { label: "Restart System", action: "restart", icon: "↻", iconComp: "" },
                        { label: "Power Off", action: "power", icon: "⏻", iconComp: "" }
                    ]
                    delegate: Rectangle {
                        width: actionListView.width; height: Theme.dp(42); color: aMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                        radius: Theme.dp(6)
                        RowLayout {
                            anchors.fill: parent; anchors.margins: Theme.dp(8); spacing: Theme.dp(12)
                            Text { text: modelData.icon; font.pixelSize: Theme.dp(16); color: Theme.textPrimary }
                            Text { text: modelData.label; color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.weight: Font.DemiBold; Layout.fillWidth: true }
                        }
                        MouseArea {
                            id: aMouse; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                var cfg = BarLayoutState.getQuickActionsConfig(qaEditingInstance)
                                var c = JSON.parse(JSON.stringify(cfg))
                                var m = c.model.slice()
                                var act = {
                                    type: "action",
                                    label: modelData.label.substring(0, 5),
                                    action: modelData.action,
                                    textIcon: modelData.icon,
                                    iconComp: modelData.iconComp
                                }
                                if (screenPageRoot.targetIndex >= 0) {
                                    m[screenPageRoot.targetIndex] = act
                                } else {
                                    m.push(act)
                                }
                                c.model = m
                                BarLayoutState.updateQuickActionsConfig(qaEditingInstance, c)
                                screenPageRoot.showingActionPicker = false
                                screenPageRoot.editingIndex = (screenPageRoot.targetIndex >= 0 ? screenPageRoot.targetIndex : m.length - 1)
                            }
                        }
                    }
                }
            }
        }
    }
}
}
