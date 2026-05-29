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
    property int currentCategory: 27
    property bool focusInContent: false
    property int contentFocusIndex: 0
    active: page.focusInContent && page.currentCategory === 10
    focusIndex: page.contentFocusIndex
    readonly property string metricKey: "Fan"
    readonly property string metricLabel: "FAN"
    readonly property string metricValue: sysSvc ? sysSvc.fanSpeedText : "0 RPM"
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
                VabSlider { from: 0.5; to: 2.0; value: BarLayoutState["desktop" + page.metricKey + "Scale"] || 1.0; onValueChanged: BarLayoutState["desktop" + page.metricKey + "Scale"] = value }
                VabButton { text: "Reset"; onClicked: BarLayoutState["desktop" + page.metricKey + "Scale"] = 1.0 }
            }
        }
        VabSettingsCard {
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Position"
            desc: "X: " + Math.round(BarLayoutState["desktop" + page.metricKey + "X"]) + " Y: " + Math.round(BarLayoutState["desktop" + page.metricKey + "Y"])
            headerActions: VabButton {
                text: "Reset Position"
                onClicked: {
                    BarLayoutState["desktop" + page.metricKey + "X"] = 1340
                    BarLayoutState["desktop" + page.metricKey + "Y"] = 760
                    BarLayoutState["desktop" + page.metricKey + "Rotation"] = 0
                }
            }
        }
    }
}
