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

    property int currentCategory: 9
    property bool focusInContent: false
    property int contentFocusIndex: 0
    property bool subFocusActive: false

    active: page.focusInContent && page.currentCategory === 9
    focusIndex: page.contentFocusIndex

    readonly property var sectionNames: ["left", "center", "right"]
    readonly property var sectionLabels: ["Left Bar", "Center Bar", "Right Bar"]

    function moveUp(section, idx) {
        if (idx > 0) BarLayoutState.moveItemWithinSection(section, idx, idx - 1)
    }

    function moveDown(section, idx) {
        var items = BarLayoutState.getItemsForSection(section)
        if (idx < items.length - 1) BarLayoutState.moveItemWithinSection(section, idx, idx + 1)
    }

    function moveLeft(section, idx) {
        var sIdx = sectionNames.indexOf(section)
        if (sIdx <= 0) return
        var itemId = BarLayoutState.getItemsForSection(section)[idx]
        var targetSection = sectionNames[sIdx - 1]
        var targetItems = BarLayoutState.getItemsForSection(targetSection)
        BarLayoutState.moveItemToSection(itemId, targetSection, targetItems.length)
    }

    function moveRight(section, idx) {
        var sIdx = sectionNames.indexOf(section)
        if (sIdx >= sectionNames.length - 1) return
        var itemId = BarLayoutState.getItemsForSection(section)[idx]
        var targetSection = sectionNames[sIdx + 1]
        var targetItems = BarLayoutState.getItemsForSection(targetSection)
        BarLayoutState.moveItemToSection(itemId, targetSection, 0)
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader { title: "Bar Position" }

        VabSettingsCard {
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Bar Position"; desc: BarLayoutState.isBottom ? "Bar is at the bottom of the screen" : "Bar is at the top of the screen"

            headerActions: VabSwitch {
                checked: BarLayoutState.isBottom
                onToggled: BarLayoutState.toggleBarPosition()
            }
        }

        VabSectionHeader { title: "Bar Appearance"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Bar Height"; desc: "Adjust bar height in pixels"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSlider {
                    from: 24; to: 48; value: BarLayoutState.barHeight
                    onValueChanged: BarLayoutState.barHeight = Math.round(value)
                }
                Text {
                    text: BarLayoutState.barHeight + "px"
                    color: Theme.accent
                    font.pixelSize: Theme.dp(10)
                    font.weight: Font.Bold
                    Layout.preferredWidth: Theme.dp(36)
                    horizontalAlignment: Text.AlignRight
                }
                VabButton {
                    text: "Reset"
                    onClicked: BarLayoutState.resetBarHeight()
                }
            }
        }

        VabSettingsCard {
            id: opacityCard
            property bool expanded: false
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Opacity"; desc: "Adjust transparency for bar and popups"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Reset"
                    onClicked: BarLayoutState.resetOpacity()
                }
                VabButton {
                    text: opacityCard.expanded ? "Close" : "Expand"
                    onClicked: opacityCard.expanded = !opacityCard.expanded
                }
            }

            ColumnLayout {
                visible: opacityCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Bar"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(80)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.barOpacity
                        onValueChanged: BarLayoutState.barOpacity = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.barOpacity * 100) + "%"
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
                        text: "Calendar"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(80)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.calendarOpacity
                        onValueChanged: BarLayoutState.calendarOpacity = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.calendarOpacity * 100) + "%"
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
                        text: "Notification"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(80)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.notifOpacity
                        onValueChanged: BarLayoutState.notifOpacity = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.notifOpacity * 100) + "%"
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
                        text: "System Tray"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(80)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0.0; to: 1.0; value: BarLayoutState.systrayOpacity
                        onValueChanged: BarLayoutState.systrayOpacity = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.systrayOpacity * 100) + "%"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        VabSettingsCard {
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Bar Border"; desc: "Show border line on bar edge"

            headerActions: VabSwitch {
                checked: BarLayoutState.barBorder
                onToggled: BarLayoutState.barBorder = !BarLayoutState.barBorder
            }
        }

        VabSettingsCard {
            itemIndex: 4
            isFocused: page.focusInContent && page.contentFocusIndex === 4
            title: "Item Separators"; desc: "Show dividers between bar items"

            headerActions: VabSwitch {
                checked: BarLayoutState.showSeparators
                onToggled: BarLayoutState.showSeparators = !BarLayoutState.showSeparators
            }
        }

        VabSectionHeader { title: "Item Layout"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 5
            isFocused: page.focusInContent && page.contentFocusIndex === 5
            title: "Rearrange Items"; desc: "Move items between bar sections using arrows"

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)

                Repeater {
                    model: page.sectionNames.length
                    delegate: Rectangle {
                        id: sectionCol
                        required property int index

                        readonly property string sectionName: page.sectionNames[index]
                        readonly property string sectionLabel: page.sectionLabels[index]
                        readonly property var items: BarLayoutState.getItemsForSection(sectionName)

                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(sectionHeader.implicitHeight + itemsColumn.implicitHeight + Theme.dp(16), Theme.dp(80))
                        color: Qt.darker(Theme.bgSecondary, 1.1)
                        border.width: 1
                        border.color: Theme.border
                        radius: 0

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(8)
                            spacing: Theme.dp(4)

                            Text {
                                id: sectionHeader
                                text: sectionCol.sectionLabel
                                color: Theme.accent
                                font.pixelSize: Theme.dp(9)
                                font.weight: Font.Bold
                                Layout.alignment: Qt.AlignHCenter
                            }

                            ColumnLayout {
                                id: itemsColumn
                                Layout.fillWidth: true
                                spacing: Theme.dp(4)

                                Repeater {
                                    model: sectionCol.items
                                    delegate: Rectangle {
                                        id: itemCard
                                        required property int index
                                        required property string modelData

                                        visible: !BarLayoutState.isHidden(itemCard.modelData)
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: visible ? Theme.dp(36) : 0
                                        color: itemMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : "transparent"
                                        border.width: 1
                                        border.color: itemMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
                                        radius: 0

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: Theme.dp(6)
                                            anchors.rightMargin: Theme.dp(4)
                                            spacing: Theme.dp(2)

                                            Text {
                                                text: BarLayoutState.itemLabels[itemCard.modelData] || itemCard.modelData
                                                color: Theme.textPrimary
                                                font.pixelSize: Theme.dp(9)
                                                font.weight: Font.Medium
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            RowLayout {
                                                spacing: Theme.dp(1)

                                                Rectangle {
                                                    width: Theme.dp(18); height: Theme.dp(18)
                                                    color: leftMouse.containsMouse ? Theme.accent : "transparent"
                                                    radius: 0
                                                    visible: sectionCol.index > 0
                                                    Text { anchors.centerIn: parent; text: "◀"; color: leftMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                                    MouseArea { id: leftMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: page.moveLeft(sectionCol.sectionName, itemCard.index) }
                                                }

                                                Rectangle {
                                                    width: Theme.dp(18); height: Theme.dp(18)
                                                    color: upMouse.containsMouse ? Theme.accent : "transparent"
                                                    radius: 0
                                                    visible: itemCard.index > 0
                                                    Text { anchors.centerIn: parent; text: "▲"; color: upMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                                    MouseArea { id: upMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: page.moveUp(sectionCol.sectionName, itemCard.index) }
                                                }

                                                Rectangle {
                                                    width: Theme.dp(18); height: Theme.dp(18)
                                                    color: downMouse.containsMouse ? Theme.accent : "transparent"
                                                    radius: 0
                                                    visible: itemCard.index < sectionCol.items.length - 1
                                                    Text { anchors.centerIn: parent; text: "▼"; color: downMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                                    MouseArea { id: downMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: page.moveDown(sectionCol.sectionName, itemCard.index) }
                                                }

                                                Rectangle {
                                                    width: Theme.dp(18); height: Theme.dp(18)
                                                    color: rightMouse.containsMouse ? Theme.accent : "transparent"
                                                    radius: 0
                                                    visible: sectionCol.index < page.sectionNames.length - 1
                                                    Text { anchors.centerIn: parent; text: "▶"; color: rightMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                                    MouseArea { id: rightMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: page.moveRight(sectionCol.sectionName, itemCard.index) }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: itemMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.NoButton
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Text {
                                visible: sectionCol.items.length === 0
                                text: "Empty"
                                color: Theme.textMuted
                                font.pixelSize: Theme.dp(8)
                                font.italic: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }

        VabSectionHeader { title: "Hide Items"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 6
            isFocused: page.focusInContent && page.contentFocusIndex === 6
            title: "App Launcher"; desc: "Show or hide the app launcher button"

            headerActions: VabSwitch {
                checked: !BarLayoutState.isHidden("launcher")
                onToggled: BarLayoutState.toggleHide("launcher")
            }
        }

        VabSettingsCard {
            itemIndex: 7
            isFocused: page.focusInContent && page.contentFocusIndex === 7
            title: "Workspace"; desc: "Show or hide the workspace indicator"

            headerActions: VabSwitch {
                checked: !BarLayoutState.isHidden("workspace")
                onToggled: BarLayoutState.toggleHide("workspace")
            }
        }

        VabSettingsCard {
            id: systrayCard
            property bool expanded: false
            itemIndex: 8
            isFocused: page.focusInContent && page.contentFocusIndex === 8
            title: "System Tray"; desc: "Show or hide the system tray icons"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: systrayCard.expanded ? "Close" : "Options"
                    onClicked: systrayCard.expanded = !systrayCard.expanded
                }
                VabSwitch {
                    checked: !BarLayoutState.isHidden("systray")
                    onToggled: BarLayoutState.toggleHide("systray")
                }
            }

            ColumnLayout {
                visible: systrayCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Show All Icons on Bar"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch {
                        checked: BarLayoutState.systrayShowAll
                        onToggled: BarLayoutState.systrayShowAll = !BarLayoutState.systrayShowAll
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Collapse Limit"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 1; to: 10; value: BarLayoutState.systrayCollapseLimit
                        onValueChanged: BarLayoutState.systrayCollapseLimit = Math.round(value)
                    }
                    Text {
                        text: BarLayoutState.systrayCollapseLimit
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(24)
                        horizontalAlignment: Text.AlignRight
                    }
                }
                
                Text {
                    text: "When icons exceed this limit, they will be hidden behind an arrow."
                    color: Theme.textMuted
                    font.pixelSize: Theme.dp(8)
                    font.italic: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Layout.topMargin: Theme.dp(4)
                    Text { text: "Arrow Position"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    Rectangle {
                        id: posLeftBtn
                        width: Theme.dp(28)
                        height: Theme.dp(28)
                        color: chevronLeftBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (BarLayoutState.systrayChevronPosition === "left" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent")
                        radius: Theme.dp(4)
                        border.color: BarLayoutState.systrayChevronPosition === "left" ? Theme.accent : Theme.border
                        border.width: 1
                        scale: chevronLeftBtnMouse.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        ChevronLeft {
                            anchors.centerIn: parent
                            width: Theme.dp(14)
                            height: Theme.dp(14)
                            color: BarLayoutState.systrayChevronPosition === "left" ? Theme.accent : Theme.textMuted
                        }
                        MouseArea {
                            id: chevronLeftBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: BarLayoutState.systrayChevronPosition = "left"
                        }
                    }
                    Rectangle {
                        id: posRightBtn
                        width: Theme.dp(28)
                        height: Theme.dp(28)
                        color: chevronRightBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (BarLayoutState.systrayChevronPosition === "right" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent")
                        radius: Theme.dp(4)
                        border.color: BarLayoutState.systrayChevronPosition === "right" ? Theme.accent : Theme.border
                        border.width: 1
                        scale: chevronRightBtnMouse.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        ChevronRight {
                            anchors.centerIn: parent
                            width: Theme.dp(14)
                            height: Theme.dp(14)
                            color: BarLayoutState.systrayChevronPosition === "right" ? Theme.accent : Theme.textMuted
                        }
                        MouseArea {
                            id: chevronRightBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: BarLayoutState.systrayChevronPosition = "right"
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Layout.topMargin: Theme.dp(4)
                    Text { text: "Arrow Direction"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    Rectangle {
                        id: dirLeftBtn
                        width: Theme.dp(28)
                        height: Theme.dp(28)
                        color: arrowLeftMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (BarLayoutState.systrayChevronDirection === "left" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent")
                        radius: Theme.dp(4)
                        border.color: BarLayoutState.systrayChevronDirection === "left" ? Theme.accent : Theme.border
                        border.width: 1
                        scale: arrowLeftMouse.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        ChevronLeft {
                            anchors.centerIn: parent
                            width: Theme.dp(14)
                            height: Theme.dp(14)
                            color: BarLayoutState.systrayChevronDirection === "left" ? Theme.accent : Theme.textMuted
                        }
                        MouseArea {
                            id: arrowLeftMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: BarLayoutState.systrayChevronDirection = "left"
                        }
                    }
                    Rectangle {
                        id: dirDownBtn
                        width: Theme.dp(28)
                        height: Theme.dp(28)
                        color: arrowDownMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (BarLayoutState.systrayChevronDirection === "down" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent")
                        radius: Theme.dp(4)
                        border.color: BarLayoutState.systrayChevronDirection === "down" ? Theme.accent : Theme.border
                        border.width: 1
                        scale: arrowDownMouse.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        ChevronDown {
                            anchors.centerIn: parent
                            width: Theme.dp(14)
                            height: Theme.dp(14)
                            color: BarLayoutState.systrayChevronDirection === "down" ? Theme.accent : Theme.textMuted
                        }
                        MouseArea {
                            id: arrowDownMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: BarLayoutState.systrayChevronDirection = "down"
                        }
                    }
                    Rectangle {
                        id: dirRightBtn
                        width: Theme.dp(28)
                        height: Theme.dp(28)
                        color: arrowRightDirMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (BarLayoutState.systrayChevronDirection === "right" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent")
                        radius: Theme.dp(4)
                        border.color: BarLayoutState.systrayChevronDirection === "right" ? Theme.accent : Theme.border
                        border.width: 1
                        scale: arrowRightDirMouse.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        ChevronRight {
                            anchors.centerIn: parent
                            width: Theme.dp(14)
                            height: Theme.dp(14)
                            color: BarLayoutState.systrayChevronDirection === "right" ? Theme.accent : Theme.textMuted
                        }
                        MouseArea {
                            id: arrowRightDirMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: BarLayoutState.systrayChevronDirection = "right"
                        }
                    }
                }
            }
        }

        VabSettingsCard {
            itemIndex: 9
            isFocused: page.focusInContent && page.contentFocusIndex === 9
            title: "Clock"; desc: "Show or hide the clock display"

            headerActions: VabSwitch {
                checked: !BarLayoutState.isHidden("clock")
                onToggled: BarLayoutState.toggleHide("clock")
            }
        }

        VabSettingsCard {
            itemIndex: 10
            isFocused: page.focusInContent && page.contentFocusIndex === 10
            title: "Notifications"; desc: "Show or hide notification widget"

            headerActions: VabSwitch {
                checked: !BarLayoutState.isHidden("notif")
                onToggled: BarLayoutState.toggleHide("notif")
            }
        }

        VabSettingsCard {
            itemIndex: 11
            isFocused: page.focusInContent && page.contentFocusIndex === 11
            title: "Weather"; desc: "Show or hide weather widget"

            headerActions: VabSwitch {
                checked: !BarLayoutState.isHidden("weather")
                onToggled: BarLayoutState.toggleHide("weather")
            }
        }

        VabSectionHeader { title: "Battery Options"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            id: batteryOptionsCard
            property bool expanded: false
            itemIndex: 12
            isFocused: page.focusInContent && page.contentFocusIndex === 12
            title: "Battery Customization"; desc: "Configure style, charging icon, and threshold"

            headerActions: VabButton {
                text: batteryOptionsCard.expanded ? "Close" : "Expand"
                onClicked: batteryOptionsCard.expanded = !batteryOptionsCard.expanded
            }

            ColumnLayout {
                visible: batteryOptionsCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(6)
                    Text { text: "Style"; color: Theme.textMuted; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
                    Repeater {
                        model: BarLayoutState.batteryStyles
                        delegate: Rectangle {
                            id: styleRow
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.dp(32)
                            color: BarLayoutState.batteryStyle === styleRow.modelData.value ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                            border.width: 1
                            border.color: BarLayoutState.batteryStyle === styleRow.modelData.value ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                            Text { anchors.centerIn: parent; text: styleRow.modelData.label; color: BarLayoutState.batteryStyle === styleRow.modelData.value ? Theme.accent : Theme.textPrimary; font.pixelSize: Theme.dp(9) }
                            MouseArea { anchors.fill: parent; onClicked: BarLayoutState.batteryStyle = styleRow.modelData.value }
                        }
                    }
                }

                VabSectionHeader {
                    title: "Element Order"
                }

                Rectangle {
                    id: batteryElementsContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: batteryElementsColumn.implicitHeight
                    color: "transparent"

                    property int _batteryElementsKey: 0

                    Connections {
                        target: BarLayoutState
                        function onBatteryElementsChanged() { batteryElementsContainer._batteryElementsKey++ }
                    }

                    ColumnLayout {
                        id: batteryElementsColumn
                        anchors.fill: parent
                        spacing: Theme.dp(8)

                        Repeater {
                            model: batteryElementsContainer._batteryElementsKey > 0 ? BarLayoutState.batteryElements.length : 0
                            delegate: Rectangle {
                                id: batteryElementCard
                                required property int index

                                readonly property string elementType: index < BarLayoutState.batteryElements.length ? BarLayoutState.batteryElements[index] : ""
                                readonly property string elementLabel: elementType==="charging"?"Charging Indicator":(elementType==="percentage"?"Percentage":"Battery Icon")
                                readonly property string elementSymbol: elementType==="charging"?"⚡":(elementType==="percentage"?"%":"🔋")

                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.dp(32)
                                color: beCardMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : "transparent"
                                border.width: 1
                                border.color: beCardMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
                                radius: 0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.dp(6)
                                    anchors.rightMargin: Theme.dp(4)
                                    spacing: Theme.dp(4)

                                    Text {
                                        text: batteryElementCard.elementSymbol
                                        font.pixelSize: Theme.dp(12)
                                        Layout.preferredWidth: Theme.dp(20)
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Text { text: batteryElementCard.elementLabel; color: Theme.textPrimary; font.pixelSize: Theme.dp(9); font.weight: Font.Medium; Layout.fillWidth: true }

                                    Rectangle {
                                        width: Theme.dp(18); height: Theme.dp(18); color: "transparent"; radius: 0
                                        visible: batteryElementCard.index > 0
                                        Text { anchors.centerIn: parent; text: "▲"; color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var a=BarLayoutState.batteryElements.slice(); var p=batteryElementCard.index; if(p>0){var t=a[p];a[p]=a[p-1];a[p-1]=t;BarLayoutState.batteryElements=a}
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: Theme.dp(18); height: Theme.dp(18); color: "transparent"; radius: 0
                                        visible: batteryElementCard.index < BarLayoutState.batteryElements.length-1
                                        Text { anchors.centerIn: parent; text: "▼"; color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var a=BarLayoutState.batteryElements.slice(); var p=batteryElementCard.index; if(p>=0&&p<a.length-1){var t=a[p];a[p]=a[p+1];a[p+1]=t;BarLayoutState.batteryElements=a}
                                            }
                                        }
                                    }
                                }
                                MouseArea { id: beCardMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                            }
                        }
                    }
                }

                Rectangle {
                    id: batteryPreviewBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(28)
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                    radius: 0

                    property int _batteryPreviewKey: 0

                    Connections {
                        target: BarLayoutState
                        function onBatteryElementsChanged() { batteryPreviewBox._batteryPreviewKey++ }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.dp(4)
                        leftPadding: Theme.dp(8)
                        rightPadding: Theme.dp(8)

                        Repeater {
                            model: batteryPreviewBox._batteryPreviewKey > 0 ? BarLayoutState.batteryElements : []
                            delegate: Text {
                                required property string modelData
                                text: modelData==="charging"?"⚡":(modelData==="percentage"?"85%":"🔋")
                                color: Theme.accent
                                font.pixelSize: Theme.dp(10)
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Charging Indicator"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.batteryShowCharging; onToggled: BarLayoutState.batteryShowCharging = !BarLayoutState.batteryShowCharging }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(4)
                    Text { text: "Low Battery Threshold (" + BarLayoutState.batteryLowThreshold + "%)"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                    VabSlider { Layout.fillWidth: true; from: 5; to: 50; value: BarLayoutState.batteryLowThreshold; onValueChanged: BarLayoutState.batteryLowThreshold = Math.round(value) }
                }
            }
        }

        VabSectionHeader { title: "Workspace Options"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 13
            isFocused: page.focusInContent && page.contentFocusIndex === 13
            title: "Workspace Count"; desc: "Number of dots: " + BarLayoutState.workspaceCount

            headerActions: VabSlider {
                Layout.preferredWidth: Theme.dp(120)
                from: 3; to: 10; value: BarLayoutState.workspaceCount
                onValueChanged: BarLayoutState.workspaceCount = Math.round(value)
            }
        }

        VabSectionHeader { title: "Presets"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            id: presetsCard
            property bool expanded: false
            itemIndex: 14
            isFocused: page.focusInContent && page.contentFocusIndex === 14
            title: "Layout Presets"; desc: "Quick apply predefined bar layouts"

            headerActions: VabButton {
                text: presetsCard.expanded ? "Close" : "Expand"
                onClicked: presetsCard.expanded = !presetsCard.expanded
            }

            ColumnLayout {
                visible: presetsCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(6)
                Layout.topMargin: Theme.dp(4)

                Repeater {
                    model: BarLayoutState.presets
                    delegate: Rectangle {
                        id: presetRow
                        required property int index
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(40)
                        color: presetMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : "transparent"
                        border.width: 1
                        border.color: presetMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
                        RowLayout {
                            anchors.fill: parent; anchors.margins: Theme.dp(8)
                            Column {
                                Layout.fillWidth: true
                                Text { text: modelData.name; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                                Text { text: modelData.desc; color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
                            }
                            VabButton { text: "Apply"; onClicked: BarLayoutState.applyPreset(presetRow.index) }
                        }
                        MouseArea { id: presetMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }
            }
        }

        VabSectionHeader { title: "Reset"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 15
            isFocused: page.focusInContent && page.contentFocusIndex === 15
            title: "Reset All Settings"; desc: "Restore all bar settings to defaults"

            headerActions: VabButton {
                text: "Reset All"
                onClicked: BarLayoutState.resetAll()
            }
        }
    }
}
