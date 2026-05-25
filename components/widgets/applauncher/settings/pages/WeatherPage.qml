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
    id: page

    property int currentCategory: 11
    property bool focusInContent: false
    property int contentFocusIndex: 0

    active: page.focusInContent && page.currentCategory === 11
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader {
            title: "Location"
        }

        VabSettingsCard {
            id: locationCard
            property bool expanded: false
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Weather Location"
            desc: "Set your default city for weather data"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: locationCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: locationCard.expanded = !locationCard.expanded
                }
            }

            ColumnLayout {
                visible: locationCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "City"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(32)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: weatherCityInput.activeFocus ? Theme.accent : Theme.border
                        TextInput {
                            id: weatherCityInput
                            anchors.fill: parent
                            anchors.leftMargin: Theme.dp(8)
                            verticalAlignment: TextInput.AlignVCenter
                            text: BarLayoutState.desktopWeatherCity
                            color: Theme.textPrimary
                            font.pixelSize: Theme.dp(10)
                            selectByMouse: true
                            onAccepted: {
                                BarLayoutState.desktopWeatherCity = text
                                BarLayoutState.save()
                            }
                        }
                    }
                    VabButton {
                        text: "Apply"
                        onClicked: {
                            BarLayoutState.desktopWeatherCity = weatherCityInput.text
                            BarLayoutState.save()
                            page.forceActiveFocus()
                        }
                    }
                }

                Text {
                    text: "Supports worldwide locations: villages, cities, districts, or landmarks."
                    color: Theme.textMuted
                    font.pixelSize: Theme.dp(8)
                    font.italic: true
                    Layout.leftMargin: Theme.dp(112)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)

                    Text { text: "Quick Select Location"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(8)

                        property string activeTab: "ASIA"

                        RowLayout {
                            spacing: Theme.dp(4)
                            Repeater {
                                model: ["ASIA", "EUROPE", "AMERICA", "OTHERS"]
                                delegate: VabButton {
                                    text: modelData
                                    active: parent.parent.activeTab === modelData
                                    onClicked: parent.parent.activeTab = modelData
                                }
                            }
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Theme.dp(6)

                        readonly property var locations: ({
                            "ASIA": ["Jakarta", "Bandung", "Singapore", "Tokyo", "Seoul", "Beijing", "Bangkok", "Dubai"],
                            "EUROPE": ["London", "Paris", "Berlin", "Moscow", "Rome", "Amsterdam", "Madrid", "Zurich"],
                            "AMERICA": ["New York", "Los Angeles", "Toronto", "Sao Paulo", "Mexico City", "Chicago"],
                            "OTHERS": ["Sydney", "Melbourne", "Cairo", "Cape Town", "Nairobi"]
                        })

                        Repeater {
                            model: parent.parent.children[1].activeTab ? parent.locations[parent.parent.children[1].activeTab] : []
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.desktopWeatherCity === modelData
                                onClicked: {
                                    BarLayoutState.desktopWeatherCity = modelData
                                    BarLayoutState.save()
                                }
                            }
                        }
                    }
                }
            }
        }

        VabSectionHeader {
            title: "Temperature"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Temperature Unit"
            desc: "Choose your preferred temperature scale"

            headerActions: RowLayout {
                spacing: Theme.dp(4)
                Repeater {
                    model: ["C", "F", "R", "K"]
                    delegate: VabButton {
                        text: modelData === "C" ? "°C" : (modelData === "F" ? "°F" : (modelData === "R" ? "°R" : "K"))
                        active: BarLayoutState.desktopWeatherUnit === modelData
                        onClicked: BarLayoutState.desktopWeatherUnit = modelData
                    }
                }
            }
        }

        VabSectionHeader {
            title: "Bar Weather"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: barWeatherCard
            property bool expanded: false
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Bar Weather Display"
            desc: "Customize what shows in the bar weather widget"

            headerActions: VabButton {
                text: barWeatherCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: barWeatherCard.expanded = !barWeatherCard.expanded
            }

            ColumnLayout {
                visible: barWeatherCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(8)
                Layout.topMargin: Theme.dp(4)

                Rectangle {
                    id: barWeatherCardsContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: barWeatherCardsColumn.implicitHeight
                    color: "transparent"

                    property int _barWeatherCardsKey: 0

                    Connections {
                        target: BarLayoutState
                        function onWeatherElementsChanged() { barWeatherCardsContainer._barWeatherCardsKey++ }
                        function onWeatherElementsDisabledChanged() { barWeatherCardsContainer._barWeatherCardsKey++ }
                    }

                    ColumnLayout {
                        id: barWeatherCardsColumn
                        anchors.fill: parent
                        spacing: Theme.dp(8)

                        Repeater {
                            model: barWeatherCardsContainer._barWeatherCardsKey > 0 ? BarLayoutState.weatherElements.length : 0
                            delegate: Rectangle {
                                id: barWeatherCard
                                required property int index

                                readonly property string elementType: index < BarLayoutState.weatherElements.length ? BarLayoutState.weatherElements[index] : ""
                                readonly property bool isDisabled: BarLayoutState.weatherElementsDisabled.indexOf(elementType) !== -1
                                readonly property string elementLabel: elementType==="icon"?"Icon":(elementType==="temp"?"Temperature":"Description")
                                readonly property color elementColor: elementType==="icon"?"#f5c542":(elementType==="temp"?Theme.accent:Theme.textSecondary)
                                readonly property string elementSymbol: elementType==="icon"?"●":(elementType==="temp"?"°":"☁")

                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.dp(32)
                                color: barWeatherCard.isDisabled ? Qt.rgba(Theme.textMuted.r, Theme.textMuted.g, Theme.textMuted.b, 0.05) : (bwCardMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : "transparent")
                                border.width: 1
                                border.color: barWeatherCard.isDisabled ? Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.2) : (bwCardMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5))
                                radius: 0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.dp(6)
                                    anchors.rightMargin: Theme.dp(4)
                                    spacing: Theme.dp(4)

                                    Rectangle {
                                        Layout.preferredWidth: Theme.dp(14); Layout.preferredHeight: Theme.dp(14)
                                        radius: width/2; color: barWeatherCard.isDisabled ? Theme.textMuted : barWeatherCard.elementColor
                                        opacity: barWeatherCard.isDisabled ? 0.4 : 1.0
                                        Text {
                                            anchors.centerIn: parent
                                            text: barWeatherCard.elementType === "icon" ? "" : barWeatherCard.elementSymbol
                                            color: "white"
                                            font.pixelSize: Theme.dp(8)
                                            visible: text !== ""
                                        }
                                        Loader {
                                            anchors.centerIn: parent
                                            width: Theme.dp(10)
                                            height: Theme.dp(10)
                                            visible: barWeatherCard.elementType === "icon"
                                            sourceComponent: barWeatherCard.isDisabled ? disabledIconComp : enabledIconComp
                                        }
                                    }

                                    Text { text: barWeatherCard.elementLabel; color: barWeatherCard.isDisabled ? Theme.textMuted : Theme.textPrimary; font.pixelSize: Theme.dp(9); font.weight: Font.Medium; Layout.fillWidth: true }

                                    VabSwitch {
                                        checked: !barWeatherCard.isDisabled
                                        onToggled: {
                                            var d = BarLayoutState.weatherElementsDisabled.slice()
                                            var idx = d.indexOf(barWeatherCard.elementType)
                                            if (idx === -1) d.push(barWeatherCard.elementType)
                                            else d.splice(idx, 1)
                                            BarLayoutState.weatherElementsDisabled = d
                                        }
                                    }

                                    Rectangle {
                                        width: Theme.dp(18); height: Theme.dp(18); color: "transparent"; radius: 0
                                        visible: barWeatherCard.index > 0
                                        Text { anchors.centerIn: parent; text: "▲"; color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var a=BarLayoutState.weatherElements.slice(); var p=barWeatherCard.index; if(p>0){var t=a[p];a[p]=a[p-1];a[p-1]=t;BarLayoutState.weatherElements=a}
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: Theme.dp(18); height: Theme.dp(18); color: "transparent"; radius: 0
                                        visible: barWeatherCard.index < BarLayoutState.weatherElements.length-1
                                        Text { anchors.centerIn: parent; text: "▼"; color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var a=BarLayoutState.weatherElements.slice(); var p=barWeatherCard.index; if(p>=0&&p<a.length-1){var t=a[p];a[p]=a[p+1];a[p+1]=t;BarLayoutState.weatherElements=a}
                                            }
                                        }
                                    }
                                }
                                MouseArea { id: bwCardMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                            }
                        }
                    }
                }

                Rectangle {
                    id: barWeatherPreviewBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(28)
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                    radius: 0

                    property int _barWeatherPreviewKey: 0

                    readonly property var activeElements: {
                        var result = []
                        for (var i = 0; i < BarLayoutState.weatherElements.length; i++) {
                            var el = BarLayoutState.weatherElements[i]
                            if (BarLayoutState.weatherElementsDisabled.indexOf(el) === -1) {
                                result.push(el)
                            }
                        }
                        return result
                    }

                    Connections {
                        target: BarLayoutState
                        function onWeatherElementsChanged() { barWeatherPreviewBox._barWeatherPreviewKey++ }
                        function onWeatherElementsDisabledChanged() { barWeatherPreviewBox._barWeatherPreviewKey++ }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.dp(4)
                        Repeater {
                            model: barWeatherPreviewBox._barWeatherPreviewKey > 0 ? barWeatherPreviewBox.activeElements : []
                            delegate: Text {
                                required property string modelData
                                text: modelData==="icon"?"●":(modelData==="temp"?"24°C":"Cloudy")
                                color: modelData==="icon"?"#f5c542":(modelData==="temp"?Theme.textPrimary:Theme.textSecondary)
                                font.pixelSize: Theme.dp(9); font.weight: modelData==="temp"?Font.Bold:Font.Normal
                            }
                        }
                        Text { text: barWeatherPreviewBox.activeElements.length===0?"No elements enabled":""; color: Theme.textMuted; font.pixelSize: Theme.dp(8); font.italic: true }
                    }
                }
            }
        }
    }

    Component {
        id: enabledIconComp
        IconSunny { iconColor: "#f5c542"; iconSize: Theme.dp(10) }
    }

    Component {
        id: disabledIconComp
        IconSunny { iconColor: Theme.textMuted; iconSize: Theme.dp(10) }
    }
}
