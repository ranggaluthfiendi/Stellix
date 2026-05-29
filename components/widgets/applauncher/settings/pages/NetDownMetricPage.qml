import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import "../components"

VabContentPage {
    id: page

    property int currentCategory: 20
    property bool focusInContent: false
    property int contentFocusIndex: 0

    active: page.focusInContent && page.currentCategory === 10
    focusIndex: page.contentFocusIndex

    readonly property string metricKey: "NetDown"
    readonly property string metricLabel: "NET DOWN"
    readonly property string metricValue: sysSvc ? sysSvc.netDown : "0 KB/s"

    property var sysSvc: BarLayoutState.getItem("systemInfo")

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader { title: metricLabel + " Widget" }

        VabSettingsCard {
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Enable " + metricLabel
            desc: "Show " + metricLabel + " metric on desktop"

            headerActions: VabSwitch {
                checked: BarLayoutState["desktop" + page.metricKey + "Show"]
                onToggled: BarLayoutState["desktop" + page.metricKey + "Show"] = !BarLayoutState["desktop" + page.metricKey + "Show"]
            }
        }

        VabSectionHeader { title: "Appearance"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Preview"
            desc: "Current value: " + page.metricValue

            headerActions: RowLayout {
                spacing: Theme.dp(4)
                Repeater {
                    model: ["ACCENT", "SUCCESS", "DANGER", "WHITE", "BLACK"]
                    delegate: VabButton {
                        text: modelData
                        active: BarLayoutState["desktop" + page.metricKey + "ColorMode"] === modelData.toLowerCase()
                        onClicked: BarLayoutState["desktop" + page.metricKey + "ColorMode"] = modelData.toLowerCase()
                    }
                }
            }
        }

        VabSettingsCard {
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Size"
            desc: Math.round((BarLayoutState["desktop" + page.metricKey + "Scale"] || 1.0) * 100) + "%"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSlider {
                    from: 0.5; to: 2.0; value: BarLayoutState["desktop" + page.metricKey + "Scale"] || 1.0
                    onValueChanged: BarLayoutState["desktop" + page.metricKey + "Scale"] = value
                }
                VabButton { text: "Reset"; onClicked: BarLayoutState["desktop" + page.metricKey + "Scale"] = 1.0 }
            }
        }

        VabSettingsCard {
            id: netDownLabelCard
            property bool expanded: false
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Label"
            desc: BarLayoutState.desktopNetDownLabel || "DOWN"

            headerActions: VabButton {
                text: netDownLabelCard.expanded ? "Close" : "Options"
                onClicked: netDownLabelCard.expanded = !netDownLabelCard.expanded
            }

            ColumnLayout {
                visible: netDownLabelCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(10)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(8)
                    Text {
                        text: "Custom"
                        color: Theme.textMuted
                        font.pixelSize: Theme.dp(9)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(60)
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(32)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: netDownInput.activeFocus ? Theme.accent : Theme.border
                        TextInput {
                            id: netDownInput
                            anchors.fill: parent
                            anchors.leftMargin: Theme.dp(8)
                            verticalAlignment: TextInput.AlignVCenter
                            text: BarLayoutState.desktopNetDownLabel || "DOWN"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.dp(10)
                            selectByMouse: true
                        }
                    }
                    VabButton {
                        text: "Apply"
                        onClicked: {
                            BarLayoutState.desktopNetDownLabel = netDownInput.text
                            BarLayoutState.save()
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(4)
                    Text {
                        text: "Presets"
                        color: Theme.textMuted
                        font.pixelSize: Theme.dp(9)
                        font.weight: Font.Bold
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: Theme.dp(6)
                        rowSpacing: Theme.dp(6)

                        Repeater {
                            model: [
                                { label: "DOWN", value: "DOWN" },
                                { label: "DOWNLOAD", value: "DOWNLOAD" },
                                { label: "RX", value: "RX" },
                                { label: "IN", value: "IN" },
                                { label: "arrow_drop_down", value: "arrow_drop_down" },
                                { label: "↓", value: "↓" }
                            ]
                            delegate: VabButton {
                                required property var modelData
                                Layout.fillWidth: true
                                text: modelData.label
                                active: BarLayoutState.desktopNetDownLabel === modelData.value
                                onClicked: {
                                    BarLayoutState.desktopNetDownLabel = modelData.value
                                    BarLayoutState.save()
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(4)
                    Text {
                        text: "Label Color"
                        color: Theme.textMuted
                        font.pixelSize: Theme.dp(9)
                        font.weight: Font.Bold
                    }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "SUCCESS", "DANGER", "WHITE", "BLACK"]
                            delegate: VabButton {
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                active: BarLayoutState.desktopNetDownColorMode === modelData.toLowerCase()
                                onClicked: {
                                    BarLayoutState.desktopNetDownColorMode = modelData.toLowerCase()
                                    BarLayoutState.save()
                                }
                            }
                        }
                    }
                }
            }
        }

        VabSettingsCard {
            itemIndex: 4
            isFocused: page.focusInContent && page.contentFocusIndex === 4
            title: "Position"
            desc: "X: " + Math.round(BarLayoutState["desktop" + page.metricKey + "X"]) + " Y: " + Math.round(BarLayoutState["desktop" + page.metricKey + "Y"])

            headerActions: VabButton {
                text: "Reset Position"
                onClicked: {
                    BarLayoutState["desktop" + page.metricKey + "X"] = 640
                    BarLayoutState["desktop" + page.metricKey + "Y"] = 760
                    BarLayoutState["desktop" + page.metricKey + "Rotation"] = 0
                }
            }
        }
    }
}
