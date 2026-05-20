import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.components.widgets.rightbar

PanelWindow {
    id: root

    property real s: Scales.uiScale
    property real popupW: Theme.dp(560)
    property real popupH: Theme.dp(500)
    property real itemH: Theme.dp(42)
    property int viewMode: 0
    property var contextMenuApp: null

    readonly property var currentModel: launcher.groupByCategory && launcher.filterMode === 0
        ? launcher.groupedApps
        : launcher.filteredApps

    visible: RightBarState.launcherOpen
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: RightBarState.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    MouseArea {
        anchors.fill: parent
        visible: root.visible
        z: -1
        onClicked: closeLauncher()
    }

    Rectangle {
        x: Math.round((parent.width - popupW) / 2)
        y: Math.round((parent.height - popupH) / 2)
        width: popupW
        height: popupH
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0
        z: 1

        opacity: RightBarState.launcherOpen ? 1 : 0
        scale: RightBarState.launcherOpen ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(12)
            spacing: Theme.dp(8)

            // Search input
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(42)
                color: Theme.bgPrimary
                border.width: 1
                border.color: searchInput.activeFocus ? Theme.accent : Theme.border
                radius: 0

                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(10)
                    spacing: Theme.dp(8)

                    Image {
                        Layout.preferredWidth: Theme.dp(16)
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.alignment: Qt.AlignVCenter
                        source: Quickshell.iconPath("system-search", true)
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                    }

                    Text {
                        text: "⌕"
                        font.pixelSize: Theme.dp(16)
                        Layout.alignment: Qt.AlignVCenter
                        color: Theme.textMuted
                        visible: parent.children[0].status !== Image.Ready
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        placeholderText: "Search applications..."
                        placeholderTextColor: Theme.textMuted
                        text: launcher.searchText
                        color: Theme.textPrimary
                        selectionColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                        selectedTextColor: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(13 * s)
                        focus: RightBarState.launcherOpen
                        background: Item {}
                        leftPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: launcher.searchText = text

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape) {
                                closeLauncher()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (appList.currentIndex >= 0 && appList.currentIndex < root.currentModel.length) {
                                    launcher.launchApp(root.currentModel[appList.currentIndex])
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                appList.currentIndex = Math.min(appList.currentIndex + 1, root.currentModel.length - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Tab) {
                                root.viewMode = (root.viewMode + 1) % 2
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            // Control bar
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(26)
                spacing: Theme.dp(6)

                // View mode toggle
                Rectangle {
                    Layout.preferredWidth: Theme.dp(28)
                    Layout.preferredHeight: Theme.dp(26)
                    color: viewToggleMouse.containsMouse
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : "transparent"
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.viewMode === 0 ? "☰" : "⊞"
                        color: Theme.accent
                        font.pixelSize: Math.round(13 * s)
                    }

                    MouseArea {
                        id: viewToggleMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.viewMode = (root.viewMode + 1) % 2
                    }
                }

                // Sort toggle (A-Z / Z-A)
                Rectangle {
                    Layout.preferredWidth: sortText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(26)
                    color: sortMouse.containsMouse
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : "transparent"
                    border.width: 1
                    border.color: Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        id: sortText
                        anchors.centerIn: parent
                        text: launcher.sortMode === "az" ? "A-Z" : "Z-A"
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(10 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: sortMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: launcher.sortMode = launcher.sortMode === "az" ? "za" : "az"
                    }
                }

                // Group by category toggle (only when All is selected)
                Rectangle {
                    Layout.preferredWidth: groupText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(26)
                    color: launcher.filterMode === 0 && groupMouse.containsMouse
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : "transparent"
                    border.width: 1
                    border.color: launcher.filterMode === 0 && launcher.groupByCategory ? Theme.accent : Theme.border
                    radius: 0

                    visible: launcher.filterMode === 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        id: groupText
                        anchors.centerIn: parent
                        text: launcher.groupByCategory ? "Grouped" : "Group"
                        color: launcher.groupByCategory ? Theme.accent : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: groupMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: launcher.groupByCategory = !launcher.groupByCategory
                    }
                }

                // "All" button (fixed, not scrollable)
                Rectangle {
                    Layout.preferredWidth: allText.width + Theme.dp(14)
                    Layout.preferredHeight: Theme.dp(26)
                    color: launcher.filterMode === 0
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                        : "transparent"
                    border.width: 1
                    border.color: launcher.filterMode === 0 ? Theme.accent : Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: allText
                        anchors.centerIn: parent
                        text: "All"
                        color: launcher.filterMode === 0 ? Theme.accent : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            launcher.filterMode = 0
                            launcher.groupByCategory = false
                        }
                    }
                }

                // Category chips (scrollable with mouse wheel)
                Flickable {
                    id: categoryFlick
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(26)
                    contentWidth: categoryRow.implicitWidth
                    interactive: contentWidth > width
                    clip: true

                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        height: Theme.dp(3)
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y !== 0) {
                                var newX = categoryFlick.contentX - (wheel.angleDelta.y > 0 ? 60 : -60)
                                var maxScroll = Math.max(0, categoryFlick.contentWidth - categoryFlick.width)
                                categoryFlick.contentX = Math.max(0, Math.min(newX, maxScroll))
                            }
                        }
                    }

                    Row {
                        id: categoryRow
                        height: parent.height
                        spacing: Theme.dp(4)

                        Repeater {
                            model: launcher.categoryList.length > 1 ? launcher.categoryList.slice(1) : []

                            delegate: Rectangle {
                                height: Theme.dp(24)
                                width: chipText.width + Theme.dp(14)
                                color: (launcher.filterMode === index + 1)
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                                    : "transparent"
                                border.width: 1
                                border.color: (launcher.filterMode === index + 1) ? Theme.accent : Theme.border
                                radius: 0

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Behavior on border.color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    id: chipText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: (launcher.filterMode === index + 1) ? Theme.accent : Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(9 * s)
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        launcher.filterMode = index + 1
                                        launcher.groupByCategory = false
                                    }
                                }
                            }
                        }
                    }
                }

                // App count
                Text {
                    text: root.currentModel.length + " Apps"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(11 * s)
                    font.weight: Font.Bold
                }
            }

            // App views
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.viewMode

                // LIST VIEW
                Rectangle {
                    color: "transparent"
                    radius: 0
                    clip: true

                    ListView {
                        id: appList
                        anchors.fill: parent
                        model: root.currentModel
                        currentIndex: 0

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                            NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 150 }
                        }

                        remove: Transition {
                            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutCubic }
                        }

                        section.property: "_categoryGroup"
                        section.criteria: ViewSection.FullString
                        section.delegate: Item {
                            width: appList.width
                            height: Theme.dp(28)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.dp(12)
                                anchors.rightMargin: Theme.dp(12)
                                spacing: Theme.dp(8)

                                Image {
                                    Layout.preferredWidth: Theme.dp(14)
                                    Layout.preferredHeight: Theme.dp(14)
                                    Layout.alignment: Qt.AlignVCenter
                                    source: Quickshell.iconPath(launcher.getCategoryIcon(section), true)
                                    fillMode: Image.PreserveAspectFit
                                    visible: status === Image.Ready
                                }

                                Text {
                                    text: section
                                    color: Theme.accent
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(9 * s)
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: Theme.border
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }

                        delegate: Rectangle {
                            width: appList.width
                            height: root.itemH
                            color: appList.currentIndex === index
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                : mouseArea.containsMouse
                                    ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                                    : "transparent"

                            radius: 0

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(8)
                                anchors.leftMargin: Theme.dp(12)
                                anchors.rightMargin: Theme.dp(12)
                                spacing: Theme.dp(10)

                                Item {
                                    Layout.preferredWidth: Theme.dp(28)
                                    Layout.preferredHeight: Theme.dp(28)
                                    Layout.alignment: Qt.AlignVCenter

                                    Image {
                                        anchors.fill: parent
                                        source: launcher.getIconPath(modelData)
                                        fillMode: Image.PreserveAspectFit
                                        visible: source !== "" && status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.bgPrimary
                                        border.width: 1
                                        border.color: Theme.border
                                        radius: Theme.dp(4)
                                        visible: !parent.children[0].visible

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name ? modelData.name.charAt(0).toUpperCase() : "?"
                                            color: Theme.textMuted
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round(12 * s)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    Text {
                                        text: modelData.name || "Unknown"
                                        color: Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round(11 * s)
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.id
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round(8 * s)
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        opacity: 0.7
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launcher.launchApp(modelData)
                                onEntered: appList.currentIndex = index
                                onPressed: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        root.contextMenuApp = modelData
                                        contextMenu.popup(mouse.x, mouse.y)
                                    }
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: Theme.dp(6)
                        }

                        highlightMoveDuration: 100
                    }
                }

                // GRID VIEW
                Rectangle {
                    color: "transparent"
                    radius: 0
                    clip: true

                    GridView {
                        id: gridView
                        anchors.fill: parent
                        model: root.currentModel
                        cellWidth: Theme.dp(72)
                        cellHeight: Theme.dp(88)
                        currentIndex: 0

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                            NumberAnimation { property: "scale"; from: 0.8; to: 1; duration: 150 }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutCubic }
                        }

                        delegate: Item {
                            width: Theme.dp(72)
                            height: Theme.dp(88)

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: Theme.dp(6)

                                Item {
                                    Layout.preferredWidth: Theme.dp(36)
                                    Layout.preferredHeight: Theme.dp(36)
                                    Layout.alignment: Qt.AlignHCenter

                                    Image {
                                        anchors.fill: parent
                                        source: launcher.getIconPath(modelData)
                                        fillMode: Image.PreserveAspectFit
                                        visible: source !== "" && status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.bgPrimary
                                        border.width: 1
                                        border.color: Theme.border
                                        radius: 0
                                        visible: !parent.children[0].visible

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name ? modelData.name.charAt(0).toUpperCase() : "?"
                                            color: Theme.textMuted
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round(14 * s)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                Text {
                                    text: modelData.name || "Unknown"
                                    color: Theme.textPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(9 * s)
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: Theme.dp(64)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launcher.launchApp(modelData)
                                onEntered: gridView.currentIndex = index
                                onPressed: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        root.contextMenuApp = modelData
                                        contextMenu.popup(mouse.x, mouse.y)
                                    }
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: Theme.dp(6)
                        }

                        highlightMoveDuration: 100
                    }
                }
            }

            // Footer hint
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(10)
                Layout.topMargin: Theme.dp(2)
                Layout.bottomMargin: Theme.dp(2)

                Text {
                    text: "↑↓ Navigate"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Text {
                    text: "Enter Launch"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Text {
                    text: "Tab Switch View"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }

                Text {
                    text: "Esc Close"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }
            }
        }
    }

    // Context menu
    Rectangle {
        id: contextMenu
        visible: false
        z: 100
        width: Theme.dp(200)
        height: menuCol.implicitHeight + Theme.dp(8)
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        property real menuX: 0
        property real menuY: 0

        function popup(x, y) {
            menuX = x
            menuY = y
            visible = true
        }

        function hide() {
            visible = false
            root.contextMenuApp = null
        }

        x: Math.min(menuX, parent.width - width - Theme.dp(12))
        y: Math.min(menuY, parent.height - height - Theme.dp(12))

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: menuCol
            anchors.fill: parent
            anchors.margins: Theme.dp(4)
            spacing: Theme.dp(2)

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(28)
                text: root.contextMenuApp ? root.contextMenuApp.name : ""
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(10 * s)
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.leftMargin: Theme.dp(8)
                Layout.rightMargin: Theme.dp(8)
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
                Layout.leftMargin: Theme.dp(8)
                Layout.rightMargin: Theme.dp(8)
            }

            // Launch
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(28)
                color: launchMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                radius: Theme.dp(6)

                Behavior on color { ColorAnimation { duration: 80 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(6)
                    spacing: Theme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: "Launch"
                        color: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                    }
                }

                MouseArea {
                    id: launchMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (root.contextMenuApp) launcher.launchApp(root.contextMenuApp)
                        contextMenu.hide()
                    }
                }
            }

            // Categories
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(28)
                color: catMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                radius: Theme.dp(6)

                Behavior on color { ColorAnimation { duration: 80 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(6)
                    spacing: Theme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.contextMenuApp ? launcher.getAppCategories(root.contextMenuApp) : ""
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(8 * s)
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: catMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: contextMenu.hide()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
                Layout.leftMargin: Theme.dp(8)
                Layout.rightMargin: Theme.dp(8)
            }

            // Close
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(28)
                color: closeMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                radius: Theme.dp(6)

                Behavior on color { ColorAnimation { duration: 80 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(6)
                    spacing: Theme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: "Close"
                        color: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                    }
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: contextMenu.hide()
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }
    }

    // Keyboard navigation
    Item {
        anchors.fill: parent
        focus: true
        Keys.enabled: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (contextMenu.visible) {
                    contextMenu.hide()
                } else {
                    closeLauncher()
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (appList.currentIndex >= 0 && appList.currentIndex < root.currentModel.length) {
                    launcher.launchApp(root.currentModel[appList.currentIndex])
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                appList.currentIndex = Math.min(appList.currentIndex + 1, root.currentModel.length - 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                event.accepted = true
            }
        }
    }

    function closeLauncher() {
        RightBarState.launcherOpen = false
        launcher.close()
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function() {
                searchInput.forceActiveFocus()
            })
        }
    }
}
