import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtCore
import qs.config
import qs.core.state
import "../components"

VabContentPage {
    id: page

    property int currentCategory: 13
    property bool focusInContent: false
    property int contentFocusIndex: 0

    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var wallpaperFiles: []
    property int selectedWallpaper: -1

    active: page.focusInContent && page.currentCategory === 13
    focusIndex: page.contentFocusIndex

    StdioCollector {
        id: lsCollector
        onStreamFinished: {
            var files = this.text.trim().split("\n").filter(function(f) { return f.length > 0 })
            page.wallpaperFiles = files
            if (files.length > 0 && page.selectedWallpaper === -1) {
                var currentPath = BarLayoutState.lockscreenWallpaperPath
                if (currentPath === "") currentPath = Theme.wallpaperPath || ""
                for (var i = 0; i < files.length; i++) {
                    if (files[i] === currentPath) {
                        page.selectedWallpaper = i
                        break
                    }
                }
                if (page.selectedWallpaper === -1) page.selectedWallpaper = 0
            }
        }
    }

    Process {
        id: lsProcess
        stdout: lsCollector
    }

    function loadWallpapers() {
        var dir = page.wallpaperDir
        if (dir !== "") {
            lsProcess.exec(["sh", "-c", "find '" + dir + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"])
        }
    }

    function getWallpaperDir() {
        if (BarLayoutState.lockscreenWallpaperPath !== "") {
            var parts = BarLayoutState.lockscreenWallpaperPath.split("/")
            parts.pop()
            return parts.join("/")
        }
        return page.wallpaperDir
    }

    function applyWallpaper(path) {
        BarLayoutState.lockscreenWallpaperPath = path
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader { title: "Lockscreen Wallpaper" }

        VabSettingsCard {
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Wallpaper Gallery"
            desc: page.wallpaperFiles.length + " wallpapers found"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Refresh"
                    onClicked: {
                        page.selectedWallpaper = -1
                        page.loadWallpapers()
                    }
                }
                VabButton {
                    text: "Apply"
                    onClicked: {
                        if (page.selectedWallpaper >= 0 && page.selectedWallpaper < page.wallpaperFiles.length) {
                            page.applyWallpaper(page.wallpaperFiles[page.selectedWallpaper])
                        }
                    }
                }
                VabButton {
                    text: galleryRow.visible ? "Close" : "Gallery"
                    onClicked: galleryRow.visible = !galleryRow.visible
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(140)
                color: Theme.bgPrimary
                border.width: 1
                border.color: Theme.border
                radius: 0
                clip: true

                Image {
                    anchors.fill: parent
                    source: page.wallpaperFiles.length > 0 && page.selectedWallpaper >= 0 ? page.wallpaperFiles[page.selectedWallpaper] : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.dp(8)
                    width: Theme.dp(28)
                    height: Theme.dp(28)
                    color: prevWpM.containsMouse ? Theme.accent : Qt.rgba(0,0,0,0.4)
                    radius: width/2
                    Text { anchors.centerIn: parent; text: "‹"; color: prevWpM.containsMouse ? Theme.bgPrimary : "white"; font.pixelSize: Theme.dp(18); font.weight: Font.Bold }
                    MouseArea {
                        id: prevWpM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (page.selectedWallpaper > 0) page.selectedWallpaper--
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Theme.dp(8)
                    width: Theme.dp(28)
                    height: Theme.dp(28)
                    color: nextWpM.containsMouse ? Theme.accent : Qt.rgba(0,0,0,0.4)
                    radius: width/2
                    Text { anchors.centerIn: parent; text: "›"; color: nextWpM.containsMouse ? Theme.bgPrimary : "white"; font.pixelSize: Theme.dp(18); font.weight: Font.Bold }
                    MouseArea {
                        id: nextWpM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (page.selectedWallpaper < page.wallpaperFiles.length - 1) page.selectedWallpaper++
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Theme.dp(24)
                    color: Qt.rgba(0,0,0,0.6)
                    Text {
                        anchors.centerIn: parent
                        text: (page.selectedWallpaper + 1) + " / " + page.wallpaperFiles.length
                        color: "white"
                        font.pixelSize: Theme.dp(9)
                        font.weight: Font.Bold
                    }
                }
            }

            RowLayout {
                id: galleryRow
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(100)
                spacing: Theme.dp(6)
                Layout.topMargin: Theme.dp(6)

                Repeater {
                    model: Math.min(page.wallpaperFiles.length, 8)
                    delegate: Rectangle {
                        required property int index
                        Layout.preferredWidth: Theme.dp(60)
                        Layout.preferredHeight: Theme.dp(60)
                        color: "transparent"
                        border.width: page.selectedWallpaper === index ? 2 : 0
                        border.color: Theme.accent
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: page.wallpaperFiles[index]
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.selectedWallpaper = index
                        }
                    }
                }
            }
        }

        VabSettingsCard {
            id: lockscreenPathCard
            property bool expanded: false
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Custom Wallpaper Path"
            desc: BarLayoutState.lockscreenWallpaperPath !== "" ? BarLayoutState.lockscreenWallpaperPath.replace(Quickshell.env("HOME"), "~") : "Using desktop wallpaper"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Reset"
                    onClicked: {
                        BarLayoutState.lockscreenWallpaperPath = ""
                        page.selectedWallpaper = -1
                        page.loadWallpapers()
                    }
                }
                VabButton {
                    text: lockscreenPathCard.expanded ? "Close" : "Set Path"
                    onClicked: lockscreenPathCard.expanded = !lockscreenPathCard.expanded
                }
            }

            Rectangle {
                visible: lockscreenPathCard.expanded
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(40)
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.dp(8)

                    TextField {
                        id: lsWallpaperInput
                        Layout.fillWidth: true
                        text: BarLayoutState.lockscreenWallpaperPath
                        placeholderText: "Leave empty to use desktop wallpaper"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        background: Rectangle {
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: lsWallpaperInput.activeFocus ? Theme.accent : Theme.border
                            radius: 0
                        }
                        onAccepted: {
                            BarLayoutState.lockscreenWallpaperPath = text
                            page.selectedWallpaper = -1
                            page.loadWallpapers()
                        }
                    }

                    Rectangle {
                        width: Theme.dp(60)
                        height: Theme.dp(28)
                        color: lsWallpaperApplyMouse.containsMouse ? Theme.accent : "transparent"
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            color: lsWallpaperApplyMouse.containsMouse ? Theme.bgPrimary : Theme.accent
                            font.pixelSize: Theme.dp(9)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: lsWallpaperApplyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                BarLayoutState.lockscreenWallpaperPath = lsWallpaperInput.text
                                page.selectedWallpaper = -1
                                page.loadWallpapers()
                            }
                        }
                    }
                }
            }
        }

        VabSettingsCard {
            id: wallpaperDirCard
            property bool expanded: false
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Wallpaper Directory"
            desc: page.wallpaperDir.replace(Quickshell.env("HOME"), "~")

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Reset"
                    onClicked: {
                        page.wallpaperDir = Quickshell.env("HOME") + "/Pictures/Wallpapers"
                        page.selectedWallpaper = -1
                        page.loadWallpapers()
                    }
                }
                VabButton {
                    text: wallpaperDirCard.expanded ? "Close" : "Change"
                    onClicked: wallpaperDirCard.expanded = !wallpaperDirCard.expanded
                }
            }

            Rectangle {
                visible: wallpaperDirCard.expanded
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(40)
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.dp(8)

                    TextField {
                        id: dirInput
                        Layout.fillWidth: true
                        text: page.getWallpaperDir()
                        placeholderText: Quickshell.env("HOME") + "/Pictures/Wallpapers"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        background: Rectangle {
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: dirInput.activeFocus ? Theme.accent : Theme.border
                            radius: 0
                        }
                        onAccepted: {
                            page.wallpaperDir = text
                            page.selectedWallpaper = -1
                            page.loadWallpapers()
                        }
                    }

                    Rectangle {
                        width: Theme.dp(60)
                        height: Theme.dp(28)
                        color: dirApplyMouse.containsMouse ? Theme.accent : "transparent"
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            color: dirApplyMouse.containsMouse ? Theme.bgPrimary : Theme.accent
                            font.pixelSize: Theme.dp(9)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: dirApplyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                page.wallpaperDir = dirInput.text
                                page.selectedWallpaper = -1
                                page.loadWallpapers()
                            }
                        }
                    }
                }
            }
        }

        VabSectionHeader {
            title: "Lockscreen Appearance"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: lockscreenColorCard
            property bool expanded: false
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Background & Overlay"
            desc: "Wallpaper overlay and background colors"

            headerActions: VabButton {
                text: lockscreenColorCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: lockscreenColorCard.expanded = !lockscreenColorCard.expanded
            }

            ColumnLayout {
                visible: lockscreenColorCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "BG_SEC", "BG_PRI", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Overlay"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "BG_SEC", "BG_PRI", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenOverlayColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenOverlayColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Opacity"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        stepSize: 0.05
                        value: BarLayoutState.lockscreenOverlayOpacity
                        onValueChanged: BarLayoutState.lockscreenOverlayOpacity = value
                    }
                    Text {
                        text: Math.round(BarLayoutState.lockscreenOverlayOpacity * 100) + "%"
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
            id: lockscreenMediaStyleCard
            property bool expanded: false
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Media Widget Style"
            desc: "Layout and visual style for the media card"

            headerActions: VabButton {
                text: lockscreenMediaStyleCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: lockscreenMediaStyleCard.expanded = !lockscreenMediaStyleCard.expanded
            }

            ColumnLayout {
                visible: lockscreenMediaStyleCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Style"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["COMPACT", "CARD", "MINIMAL", "FULL"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenMediaStyle === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenMediaStyle = modelData.toLowerCase()
                            }
                        }
                    }
                }

                Text {
                    text: {
                        switch (BarLayoutState.lockscreenMediaStyle) {
                            case "compact": return "Compact: Small art + text + controls in a single row."
                            case "card": return "Card: Full art background with wave visualizer and white text."
                            case "minimal": return "Minimal: Clean controls and progress bar, no album art."
                            case "full": return "Full: Large art + detailed info + all controls."
                            default: return ""
                        }
                    }
                    color: Theme.textMuted
                    font.pixelSize: Typography.sizeXS
                    font.italic: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        VabSettingsCard {
            id: lockscreenMediaColorCard
            property bool expanded: false
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Media Widget Colors"
            desc: "Customize media card appearance"

            headerActions: VabButton {
                text: lockscreenMediaColorCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: lockscreenMediaColorCard.expanded = !lockscreenMediaColorCard.expanded
            }

            ColumnLayout {
                visible: lockscreenMediaColorCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "BG_SEC", "BG_PRI", "WHITE", "BLACK", "TRANS"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenMediaBgColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenMediaBgColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Text"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "TXT_PRI", "TXT_MUT", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenMediaTextColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenMediaTextColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Accent"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "ACC_SOFT", "WHITE", "BLACK"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenMediaAccentColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenMediaAccentColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Border"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    RowLayout {
                        spacing: Theme.dp(4)
                        Repeater {
                            model: ["ACCENT", "BORDER", "TXT_PRI", "TRANS"]
                            delegate: VabButton {
                                text: modelData
                                active: BarLayoutState.lockscreenMediaBorderColorMode === modelData.toLowerCase()
                                onClicked: BarLayoutState.lockscreenMediaBorderColorMode = modelData.toLowerCase()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Blur Background"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenMediaBlurBackground; onToggled: BarLayoutState.lockscreenMediaBlurBackground = !BarLayoutState.lockscreenMediaBlurBackground }
                }
            }
        }

        VabSettingsCard {
            id: lockscreenMediaElementsCard
            property bool expanded: false
            itemIndex: 4
            isFocused: page.focusInContent && page.contentFocusIndex === 4
            title: "Media Widget Elements"
            desc: "Toggle media card components"

            headerActions: VabButton {
                text: lockscreenMediaElementsCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: lockscreenMediaElementsCard.expanded = !lockscreenMediaElementsCard.expanded
            }

            ColumnLayout {
                visible: lockscreenMediaElementsCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Album Art"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenMediaShowAlbumArt; onToggled: BarLayoutState.lockscreenMediaShowAlbumArt = !BarLayoutState.lockscreenMediaShowAlbumArt }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Controls"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenMediaShowControls; onToggled: BarLayoutState.lockscreenMediaShowControls = !BarLayoutState.lockscreenMediaShowControls }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Progress Bar"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenMediaShowProgress; onToggled: BarLayoutState.lockscreenMediaShowProgress = !BarLayoutState.lockscreenMediaShowProgress }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text { text: "Corner Radius"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.preferredWidth: Theme.dp(80) }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: 24
                        stepSize: 2
                        value: BarLayoutState.lockscreenMediaRadius
                        onValueChanged: BarLayoutState.lockscreenMediaRadius = Math.round(value)
                    }
                    Text {
                        text: BarLayoutState.lockscreenMediaRadius + "px"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        VabSectionHeader {
            title: "Lockscreen"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: lockscreenGeneralCard
            property bool expanded: false
            itemIndex: 5
            isFocused: page.focusInContent && page.contentFocusIndex === 5
            title: "General"
            desc: "Lockscreen visibility and behavior"

            headerActions: VabButton {
                text: lockscreenGeneralCard.expanded ? "CLOSE" : "EXPAND"
                onClicked: lockscreenGeneralCard.expanded = !lockscreenGeneralCard.expanded
            }

            ColumnLayout {
                visible: lockscreenGeneralCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Media Widget"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenShowMedia; onToggled: BarLayoutState.lockscreenShowMedia = !BarLayoutState.lockscreenShowMedia }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show On-Screen Keyboard"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenShowKeyboard; onToggled: BarLayoutState.lockscreenShowKeyboard = !BarLayoutState.lockscreenShowKeyboard }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Power Buttons"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenShowPowerButtons; onToggled: BarLayoutState.lockscreenShowPowerButtons = !BarLayoutState.lockscreenShowPowerButtons }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Show Status Bar"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); Layout.fillWidth: true }
                    VabSwitch { checked: BarLayoutState.lockscreenShowStatusBar; onToggled: BarLayoutState.lockscreenShowStatusBar = !BarLayoutState.lockscreenShowStatusBar }
                }
            }
        }

        VabSectionHeader {
            title: "Power Actions"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: powerActionsCard
            property bool expanded: false
            itemIndex: 6
            isFocused: page.focusInContent && page.contentFocusIndex === 6
            title: "Shutdown/Reboot Confirmation"
            desc: "Countdown timer before executing power actions"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: powerActionsCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: powerActionsCard.expanded = !powerActionsCard.expanded
                }
            }

            ColumnLayout {
                visible: powerActionsCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Confirm Time"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 3
                        to: 10
                        stepSize: 1
                        value: BarLayoutState.lockscreenPowerConfirmTime
                        onValueChanged: BarLayoutState.lockscreenPowerConfirmTime = Math.round(value)
                    }
                    Text {
                        text: BarLayoutState.lockscreenPowerConfirmTime + "s"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Text {
                    text: "Power actions will show a confirmation dialog with a countdown timer. Click Confirm to execute immediately, or Cancel to abort."
                    color: Theme.textMuted
                    font.pixelSize: Typography.sizeXS
                    font.italic: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        VabSectionHeader {
            title: "Hot Corners"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: hotCornersCard
            property bool expanded: false
            itemIndex: 7
            isFocused: page.focusInContent && page.contentFocusIndex === 7
            title: "Volume & Brightness Hot Corners"
            desc: "Scroll in top corners to adjust volume/brightness"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSwitch { checked: BarLayoutState.lockscreenHotCorners; onToggled: BarLayoutState.lockscreenHotCorners = !BarLayoutState.lockscreenHotCorners }
                VabButton {
                    text: hotCornersCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: hotCornersCard.expanded = !hotCornersCard.expanded
                }
            }

            ColumnLayout {
                visible: hotCornersCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                Text {
                    text: "Top-left corner: Volume control. Top-right corner: Brightness control. Scroll up/down to adjust."
                    color: Theme.textMuted
                    font.pixelSize: Typography.sizeXS
                    font.italic: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        VabSectionHeader {
            title: "Idle Behavior"
            Layout.topMargin: Theme.dp(10)
        }

        VabSettingsCard {
            id: idleBehaviorCard
            property bool expanded: false
            itemIndex: 8
            isFocused: page.focusInContent && page.contentFocusIndex === 8
            title: "Idle Blur"
            desc: "Automatically blur the lockscreen when idle"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSwitch { checked: BarLayoutState.lockscreenIdleBlur; onToggled: BarLayoutState.lockscreenIdleBlur = !BarLayoutState.lockscreenIdleBlur }
                VabButton {
                    text: idleBehaviorCard.expanded ? "CLOSE" : "EXPAND"
                    onClicked: idleBehaviorCard.expanded = !idleBehaviorCard.expanded
                }
            }

            ColumnLayout {
                visible: idleBehaviorCard.expanded
                Layout.fillWidth: true
                spacing: Theme.dp(12)
                Layout.topMargin: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(12)
                    Text {
                        text: "Idle Timeout"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        Layout.preferredWidth: Theme.dp(100)
                    }
                    VabSlider {
                        Layout.fillWidth: true
                        from: 5
                        to: 30
                        stepSize: 1
                        value: BarLayoutState.lockscreenIdleTimeout
                        onValueChanged: BarLayoutState.lockscreenIdleTimeout = Math.round(value)
                    }
                    Text {
                        text: BarLayoutState.lockscreenIdleTimeout + "s"
                        color: Theme.accent
                        font.pixelSize: Theme.dp(10)
                        font.weight: Font.Bold
                        Layout.preferredWidth: Theme.dp(36)
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }

    Connections {
        target: page
        function onSelectedWallpaperChanged() {
            if (page.selectedWallpaper >= 0 && page.selectedWallpaper < page.wallpaperFiles.length) {
                page.applyWallpaper(page.wallpaperFiles[page.selectedWallpaper])
            }
        }
    }

    Component.onCompleted: page.loadWallpapers()
}
