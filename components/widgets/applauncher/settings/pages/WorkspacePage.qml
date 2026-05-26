import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import "../components"

VabContentPage {
    id: page
    
    // External data
    property var systemInfo: null
    property int currentCategory: 1
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    active: page.focusInContent && page.currentCategory === 1
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        width: parent.width
        spacing: Theme.dp(14)
        
        VabSectionHeader { title: "Bar Indicator Style" }

        VabSettingsCard {
            id: styleCard
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Indicator Style"
            desc: "Choose the visual style for workspace indicators in the bar"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)
                Layout.topMargin: Theme.dp(4)

                GridLayout {
                    columns: 3
                    Layout.fillWidth: true
                    columnSpacing: Theme.dp(8)
                    rowSpacing: Theme.dp(8)

                    Repeater {
                        model: BarLayoutState.workspaceStyles
                        delegate: Rectangle {
                            id: styleItem
                            required property int index
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(40)
                            color: BarLayoutState.workspaceStyle === styleItem.modelData.value ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                            border.width: 1
                            border.color: BarLayoutState.workspaceStyle === styleItem.modelData.value ? Theme.accent : Theme.border
                            radius: Theme.dp(4)

                            Column {
                                anchors.centerIn: parent
                                spacing: Theme.dp(2)
                                Text {
                                    text: styleItem.modelData.label
                                    color: BarLayoutState.workspaceStyle === styleItem.modelData.value ? Theme.accent : Theme.textPrimary
                                    font.pixelSize: Theme.dp(9)
                                    font.weight: BarLayoutState.workspaceStyle === styleItem.modelData.value ? Font.Bold : Font.Normal
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: BarLayoutState.workspaceStyle = styleItem.modelData.value
                            }
                        }
                    }
                }
            }
        }

        VabSectionHeader { title: "Dimensions & Spacing"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Indicator Sizing"
            desc: "Adjust base and active size of indicators"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Base Size"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 2; to: 20; value: BarLayoutState.workspaceDotSize
                        onValueChanged: BarLayoutState.workspaceDotSize = Math.round(value)
                    }
                    Text { text: BarLayoutState.workspaceDotSize + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Active Size"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 2; to: 40; value: BarLayoutState.workspaceActiveDotSize
                        onValueChanged: BarLayoutState.workspaceActiveDotSize = Math.round(value)
                    }
                    Text { text: BarLayoutState.workspaceActiveDotSize + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Corner Radius"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0; to: 10; value: BarLayoutState.workspaceRadius
                        onValueChanged: BarLayoutState.workspaceRadius = Math.round(value)
                    }
                    Text { text: BarLayoutState.workspaceRadius + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Spacing"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0; to: 20; value: BarLayoutState.workspaceSpacing
                        onValueChanged: BarLayoutState.workspaceSpacing = Math.round(value)
                    }
                    Text { text: BarLayoutState.workspaceSpacing + "px"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(30); horizontalAlignment: Text.AlignRight }
                }
            }
        }

        VabSectionHeader { title: "Behavior & Content"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Workspace Count"
            desc: "Set fixed number of workspaces to show"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSlider {
                    Layout.preferredWidth: Theme.dp(100)
                    from: 1; to: 12; value: BarLayoutState.workspaceCount
                    onValueChanged: BarLayoutState.workspaceCount = Math.round(value)
                }
                Text { text: BarLayoutState.workspaceCount.toString(); color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(20); horizontalAlignment: Text.AlignRight }
            }
        }

        VabSettingsCard {
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Show Numbers"
            desc: "Display workspace ID inside indicators"

            headerActions: VabSwitch {
                checked: BarLayoutState.workspaceShowNumbers
                onToggled: BarLayoutState.workspaceShowNumbers = !BarLayoutState.workspaceShowNumbers
            }
        }

        VabSettingsCard {
            itemIndex: 4
            isFocused: page.focusInContent && page.contentFocusIndex === 4
            title: "Show Empty Workspaces"
            desc: "Show indicators for workspaces without windows"

            headerActions: VabSwitch {
                checked: BarLayoutState.workspaceShowEmpty
                onToggled: BarLayoutState.workspaceShowEmpty = !BarLayoutState.workspaceShowEmpty
            }
        }

        VabSectionHeader { title: "Color Modes"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 5
            isFocused: page.focusInContent && page.contentFocusIndex === 5
            title: "Active Color"
            desc: "Color for the currently focused workspace"

            headerActions: RowLayout {
                spacing: Theme.dp(4)
                Repeater {
                    model: ["accent", "text_primary", "success"]
                    delegate: Rectangle {
                        required property string modelData
                        width: Theme.dp(24); height: Theme.dp(24); radius: Theme.dp(12)
                        color: modelData === "accent" ? Theme.accent : (modelData === "success" ? Theme.success : Theme.textPrimary)
                        border.width: BarLayoutState.workspaceActiveColorMode === modelData ? 2 : 0
                        border.color: Theme.textPrimary
                        MouseArea { anchors.fill: parent; onClicked: BarLayoutState.workspaceActiveColorMode = modelData }
                    }
                }
            }
        }

        VabSettingsCard {
            itemIndex: 6
            isFocused: page.focusInContent && page.contentFocusIndex === 6
            title: "Has Windows Color"
            desc: "Color for workspaces that have open windows"

            headerActions: RowLayout {
                spacing: Theme.dp(4)
                Repeater {
                    model: ["text_primary", "accent", "text_muted"]
                    delegate: Rectangle {
                        required property string modelData
                        width: Theme.dp(24); height: Theme.dp(24); radius: Theme.dp(12)
                        color: modelData === "accent" ? Theme.accent : (modelData === "text_muted" ? Theme.textMuted : Theme.textPrimary)
                        border.width: BarLayoutState.workspaceHasWinColorMode === modelData ? 2 : 0
                        border.color: Theme.textPrimary
                        MouseArea { anchors.fill: parent; onClicked: BarLayoutState.workspaceHasWinColorMode = modelData }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
