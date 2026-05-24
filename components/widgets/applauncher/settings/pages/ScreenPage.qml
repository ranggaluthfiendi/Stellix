import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import "../components"

VabContentPage {
    id: page

    property int currentCategory: 10
    property bool focusInContent: false
    property int contentFocusIndex: 0

    active: page.focusInContent && page.currentCategory === 10
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader {
            title: "Desktop Widgets"
        }

        // --- System Stats ---
        VabSettingsCard {
            id: statsCard
            property bool expanded: false
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
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

                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: Theme.dp(20)
                    rowSpacing: Theme.dp(8)

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show CPU"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowCpu
                            onToggled: BarLayoutState.desktopStatsShowCpu = !BarLayoutState.desktopStatsShowCpu
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show GPU"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowGpu
                            onToggled: BarLayoutState.desktopStatsShowGpu = !BarLayoutState.desktopStatsShowGpu
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Memory"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowMem
                            onToggled: BarLayoutState.desktopStatsShowMem = !BarLayoutState.desktopStatsShowMem
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Network"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowNet
                            onToggled: BarLayoutState.desktopStatsShowNet = !BarLayoutState.desktopStatsShowNet
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Disk"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowDisk
                            onToggled: BarLayoutState.desktopStatsShowDisk = !BarLayoutState.desktopStatsShowDisk
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Uptime"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowUptime
                            onToggled: BarLayoutState.desktopStatsShowUptime = !BarLayoutState.desktopStatsShowUptime
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Temperature"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopStatsShowTemp
                            onToggled: BarLayoutState.desktopStatsShowTemp = !BarLayoutState.desktopStatsShowTemp
                        }
                    }
                }

                VabSectionHeader {
                    title: "Network Labels"
                    Layout.topMargin: Theme.dp(8)
                }

                Rectangle {
                    id: netLabelContainer
                    Layout.fillWidth: true
                    height: netLabelRow.implicitHeight
                    color: "transparent"

                    property int _netLabelKey: 0

                    Connections {
                        target: BarLayoutState
                        function onDesktopStatsNetDownLabelChanged() { netLabelContainer._netLabelKey++ }
                        function onDesktopStatsNetUpLabelChanged() { netLabelContainer._netLabelKey++ }
                    }

                    RowLayout {
                        id: netLabelRow
                        anchors.fill: parent
                        spacing: Theme.dp(12)
                        Text { text: "Preset"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(100) }
                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: netLabelContainer._netLabelKey > 0 ? ["DOWN/UP", "DOWNLOAD/UPLOAD", "RX/TX", "IN/OUT"] : []
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
                        value: BarLayoutState.desktopStatsScale
                        onValueChanged: BarLayoutState.desktopStatsScale = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopStatsScale * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                    VabButton {
                        text: "Reset"
                        onClicked: BarLayoutState.desktopStatsScale = 1.0
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
                            BarLayoutState.desktopStatsX = 40
                            BarLayoutState.desktopStatsY = 800
                        }
                    }
                }
            }
        }

        // --- Weather ---
        VabSettingsCard {
            id: weatherCard
            property bool expanded: false
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
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
            }
        }

        // --- Quick Actions ---
        VabSettingsCard {
            id: qaCard
            property bool expanded: false
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Quick Action Buttons"
            desc: "Toggle power and utility shortcuts"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: qaCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: qaCard.expanded = !qaCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenQuickActions
                    onToggled: BarLayoutState.showScreenQuickActions = !BarLayoutState.showScreenQuickActions
                }
            }

            ColumnLayout {
                visible: qaCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Pinned (Sticky)"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: BarLayoutState.desktopQuickActionsPinned
                        onToggled: BarLayoutState.desktopQuickActionsPinned = !BarLayoutState.desktopQuickActionsPinned
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
                        to: 32
                        value: BarLayoutState.desktopQuickActionsRadius
                        onValueChanged: BarLayoutState.desktopQuickActionsRadius = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopQuickActionsRadius) + "px"
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
                        from: 0.5
                        to: 2.0
                        value: BarLayoutState.desktopQuickActionsScale
                        onValueChanged: BarLayoutState.desktopQuickActionsScale = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopQuickActionsScale * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                    VabButton {
                        text: "Reset"
                        onClicked: BarLayoutState.desktopQuickActionsScale = 1.0
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
                            BarLayoutState.desktopQuickActionsX = 800
                            BarLayoutState.desktopQuickActionsY = 900
                        }
                    }
                }
            }
        }

        // --- Now Playing ---
        VabSettingsCard {
            id: npCard
            property bool expanded: false
            itemIndex: 4
            isFocused: page.focusInContent && page.contentFocusIndex === 4
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
            }
        }

        // --- Standalone Equalizer ---
        VabSettingsCard {
            id: eqCard
            property bool expanded: false
            itemIndex: 5
            isFocused: page.focusInContent && page.contentFocusIndex === 5
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
            itemIndex: 6
            isFocused: page.focusInContent && page.contentFocusIndex === 6
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
                    Text { text: Math.round(BarLayoutState.desktopWidgetsOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

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
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.desktopQuickActionsOpacity
                        onValueChanged: BarLayoutState.desktopQuickActionsOpacity = value
                    }
                    Text { text: Math.round(BarLayoutState.desktopQuickActionsOpacity * 100) + "%"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
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
            isFocused: page.focusInContent && page.contentFocusIndex === 8
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
                            checked: BarLayoutState.rightbarPopupRounded
                            onToggled: BarLayoutState.rightbarPopupRounded = !BarLayoutState.rightbarPopupRounded
                        }
                    }
                }
            }
        }

        VabSectionHeader {
            title: "Overlay Indicators"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: indicatorCard
            property bool expanded: false
            itemIndex: 9
            isFocused: page.focusInContent && page.contentFocusIndex === 9
            title: "System Indicators"
            desc: "Show volume, brightness, and pin status overlays"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: indicatorCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: indicatorCard.expanded = !indicatorCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showIndicators
                    onToggled: BarLayoutState.showIndicators = !BarLayoutState.showIndicators
                }
            }
        }
    }
}
