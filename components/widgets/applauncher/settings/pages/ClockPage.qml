import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import "../components"

VabContentPage {
    id: page

    property int currentCategory: 12
    property bool focusInContent: false
    property int contentFocusIndex: 0

    active: page.focusInContent && page.currentCategory === 12
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader {
            title: "Bar Clock"
        }

        VabSettingsCard {
            id: barClockCard
            property bool expanded: false
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Bar Clock Display"
            desc: "Format and options for the clock in the bar"

            headerActions: VabButton {
                text: barClockCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: barClockCard.expanded = !barClockCard.expanded
            }

            ColumnLayout {
                visible: barClockCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(6)
                    Text { text: "Format"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
                    Repeater {
                        model: BarLayoutState.clockFormats
                        delegate: Rectangle {
                            id: formatRow
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: BarLayoutState.clockFormat === formatRow.modelData.value ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                            border.width: 1
                            border.color: BarLayoutState.clockFormat === formatRow.modelData.value ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                            Text { anchors.centerIn: parent; text: formatRow.modelData.label; color: BarLayoutState.clockFormat === formatRow.modelData.value ? Theme.accent : Theme.textPrimary; font.pixelSize: Theme.dp(9) }
                            MouseArea { anchors.fill: parent; onClicked: BarLayoutState.clockFormat = formatRow.modelData.value }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "24-Hour Format"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.clock24Hour; onToggled: BarLayoutState.clock24Hour = !BarLayoutState.clock24Hour }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Seconds"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.clockShowSeconds; onToggled: BarLayoutState.clockShowSeconds = !BarLayoutState.clockShowSeconds }
                }
            }
        }

        VabSectionHeader {
            title: "Desktop Clock"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: desktopClockCard
            property bool expanded: false
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Desktop Clock Widget"
            desc: "Toggle and customize the desktop clock widget"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: desktopClockCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: desktopClockCard.expanded = !desktopClockCard.expanded
                }
                VabSwitch {
                    checked: BarLayoutState.showScreenClock
                    onToggled: BarLayoutState.showScreenClock = !BarLayoutState.showScreenClock
                }
            }

            ColumnLayout {
                visible: desktopClockCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

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
                                active: BarLayoutState.desktopClockColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.desktopClockColorMode = modelData.toLowerCase()
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
                        value: BarLayoutState.desktopClockScale
                        onValueChanged: BarLayoutState.desktopClockScale = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.desktopClockScale * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                    VabButton {
                        text: "Reset"
                        onClicked: BarLayoutState.desktopClockScale = 1.0
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
                        Text { text: "24-Hour Format"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopClock24Hour
                            onToggled: BarLayoutState.desktopClock24Hour = !BarLayoutState.desktopClock24Hour
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Seconds"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopClockShowSeconds
                            onToggled: BarLayoutState.desktopClockShowSeconds = !BarLayoutState.desktopClockShowSeconds
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Date"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopClockShowDate
                            onToggled: BarLayoutState.desktopClockShowDate = !BarLayoutState.desktopClockShowDate
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Weekday"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopClockShowWeekday
                            onToggled: BarLayoutState.desktopClockShowWeekday = !BarLayoutState.desktopClockShowWeekday
                        }
                    }

                    RowLayout {
                        spacing: Theme.dp(8)
                        Layout.fillWidth: true
                        Text { text: "Show Year"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                        VabSwitch {
                            checked: BarLayoutState.desktopClockShowYear
                            onToggled: BarLayoutState.desktopClockShowYear = !BarLayoutState.desktopClockShowYear
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Text Alignment"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["Left", "Center", "Right"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopClockAlignment === index
                                onClicked: BarLayoutState.desktopClockAlignment = index
                            }
                        }
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
                            BarLayoutState.desktopClockX = 40
                            BarLayoutState.desktopClockY = 40
                        }
                    }
                }
            }
        }
    }
}
