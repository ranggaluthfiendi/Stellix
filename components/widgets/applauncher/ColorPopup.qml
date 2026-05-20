import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.elements

Rectangle {
    id: root

    color: "transparent"
    focus: true

    property real s: Scales.uiScale

    signal closeRequested

    property int previewIndex: 0

    function next() {
        schemeList.currentIndex = (schemeList.currentIndex + 1) % root.schemeTypes.length
        root.previewIndex = schemeList.currentIndex
    }

    function prev() {
        schemeList.currentIndex = (schemeList.currentIndex - 1 + root.schemeTypes.length) % root.schemeTypes.length
        root.previewIndex = schemeList.currentIndex
    }

    function applyCurrent() {
        colorService.setType(root.schemeTypes[root.previewIndex].value)
        root.closeRequested()
    }

    function getLuminance(color) {
        var r = color.r
        var g = color.g
        var b = color.b
        return 0.299 * r + 0.587 * g + 0.114 * b
    }

    function colorToHex(color) {
        var r = Math.round(color.r * 255)
        var g = Math.round(color.g * 255)
        var b = Math.round(color.b * 255)
        return "#" + ("0" + r.toString(16)).slice(-2) + ("0" + g.toString(16)).slice(-2) + ("0" + b.toString(16)).slice(-2)
    }

    function copyToClipboard(text) {
        var cb = Qt.clipboard
        if (cb) cb.setText(text)
    }

    function copyToHex(hex) {
        var cb = Qt.clipboard
        if (cb) cb.setText(hex)
    }

    function createColorBox(label, hexColor, luminance) {
        return {
            label: label,
            hex: hexColor,
            textColor: luminance > 0.5 ? "#000000" : "#ffffff"
        }
    }

    readonly property var schemeTypes: [
        { name: "Tonal Spot", value: "scheme-tonal-spot", desc: "Balanced, natural tones", accent: "#bcc6e5" },
        { name: "Content", value: "scheme-content", desc: "Based on image content", accent: "#c4b896" },
        { name: "Expressive", value: "scheme-expressive", desc: "Bold, vibrant colors", accent: "#b8c496" },
        { name: "Fidelity", value: "scheme-fidelity", desc: "True to original colors", accent: "#c4a896" },
        { name: "Fruit Salad", value: "scheme-fruit-salad", desc: "Playful, mixed colors", accent: "#a8c496" },
        { name: "Monochrome", value: "scheme-monochrome", desc: "Single color variations", accent: "#b0b0b0" },
        { name: "Neutral", value: "scheme-neutral", desc: "Subtle, muted tones", accent: "#b8b4a8" },
        { name: "Vibrant", value: "scheme-vibrant", desc: "High saturation colors", accent: "#96c4c4" }
    ]

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.applyCurrent()
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            root.closeRequested()
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            root.next()
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            root.prev()
            event.accepted = true
        } else if (event.key === Qt.Key_M) {
            colorService.toggleMode()
            event.accepted = true
        } else if (event.key === Qt.Key_D) {
            colorService.setMode("dark")
            event.accepted = true
        } else if (event.key === Qt.Key_L) {
            colorService.setMode("light")
            event.accepted = true
        } else if (event.key === Qt.Key_R) {
            colorService.applyTheme()
            event.accepted = true
        } else if (event.key === Qt.Key_A) {
            colorService.applyTheme()
            event.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(10)

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Color Style"
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(13 * s)
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Active: " + colorService.currentTypeName
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(9 * s)
                font.weight: Font.Medium
            }

            Text {
                text: "Selected: " + root.schemeTypes[root.previewIndex].name
                color: Theme.warning
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(9 * s)
                font.weight: Font.Medium
                visible: root.schemeTypes[root.previewIndex].value !== colorService.currentType
            }

            Rectangle {
                Layout.preferredWidth: applyText.width + Theme.dp(14)
                Layout.preferredHeight: Theme.dp(24)
                color: applyMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                border.width: 1
                border.color: Theme.accent
                radius: 0

                Text {
                    id: applyText
                    anchors.centerIn: parent
                    text: "Enter Apply"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: applyMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.applyCurrent()
                }
            }
        }

        // Color preview - shows full palette for selected scheme
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(110)
            color: Theme.bgPrimary
            border.width: 1
            border.color: root.schemeTypes[root.previewIndex].value !== colorService.currentType ? Theme.warning : Theme.border
            radius: 0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(6)
                spacing: Theme.dp(3)

                // Preview header
                Text {
                    text: root.schemeTypes[root.previewIndex].name + (root.schemeTypes[root.previewIndex].value !== colorService.currentType ? " (Preview)" : " (Active)")
                    color: root.schemeTypes[root.previewIndex].value !== colorService.currentType ? Theme.warning : Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                    font.weight: Font.Medium
                }

                // Row 1: Primary, Primary Container, On Primary
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: root.schemeTypes[root.previewIndex].accent
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: primaryTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Primary\n" + root.colorToHex(root.schemeTypes[root.previewIndex].accent))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(root.schemeTypes[root.previewIndex].accent) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                            Behavior on text { NumberAnimation { duration: 0 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(root.schemeTypes[root.previewIndex].accent))
                                parent.copied = true
                                primaryTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Qt.lighter(root.schemeTypes[root.previewIndex].accent, 1.3)
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: primaryContainerTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Primary Container\n" + root.colorToHex(Qt.lighter(root.schemeTypes[root.previewIndex].accent, 1.3)))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Qt.lighter(root.schemeTypes[root.previewIndex].accent, 1.3)) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Qt.lighter(root.schemeTypes[root.previewIndex].accent, 1.3)))
                                parent.copied = true
                                primaryContainerTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Qt.darker(root.schemeTypes[root.previewIndex].accent, 1.5)
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: onPrimaryTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("On Primary\n" + root.colorToHex(Qt.darker(root.schemeTypes[root.previewIndex].accent, 1.5)))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Qt.darker(root.schemeTypes[root.previewIndex].accent, 1.5)) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Qt.darker(root.schemeTypes[root.previewIndex].accent, 1.5)))
                                parent.copied = true
                                onPrimaryTimer.restart()
                            }
                        }
                    }
                }

                // Row 2: Secondary, Tertiary, Error
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Qt.rgba(root.schemeTypes[root.previewIndex].accent.r * 0.8, root.schemeTypes[root.previewIndex].accent.g * 0.9, root.schemeTypes[root.previewIndex].accent.b, 1)
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: secondaryTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Secondary\n" + root.colorToHex(Qt.rgba(root.schemeTypes[root.previewIndex].accent.r * 0.8, root.schemeTypes[root.previewIndex].accent.g * 0.9, root.schemeTypes[root.previewIndex].accent.b, 1)))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Qt.rgba(root.schemeTypes[root.previewIndex].accent.r * 0.8, root.schemeTypes[root.previewIndex].accent.g * 0.9, root.schemeTypes[root.previewIndex].accent.b, 1)) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Qt.rgba(root.schemeTypes[root.previewIndex].accent.r * 0.8, root.schemeTypes[root.previewIndex].accent.g * 0.9, root.schemeTypes[root.previewIndex].accent.b, 1)))
                                parent.copied = true
                                secondaryTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Qt.rgba(root.schemeTypes[root.previewIndex].accent.b, root.schemeTypes[root.previewIndex].accent.r * 0.7, root.schemeTypes[root.previewIndex].accent.g * 0.8, 1)
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: tertiaryTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Tertiary\n" + root.colorToHex(Qt.rgba(root.schemeTypes[root.previewIndex].accent.b, root.schemeTypes[root.previewIndex].accent.r * 0.7, root.schemeTypes[root.previewIndex].accent.g * 0.8, 1)))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Qt.rgba(root.schemeTypes[root.previewIndex].accent.b, root.schemeTypes[root.previewIndex].accent.r * 0.7, root.schemeTypes[root.previewIndex].accent.g * 0.8, 1)) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Qt.rgba(root.schemeTypes[root.previewIndex].accent.b, root.schemeTypes[root.previewIndex].accent.r * 0.7, root.schemeTypes[root.previewIndex].accent.g * 0.8, 1)))
                                parent.copied = true
                                tertiaryTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: "#ffb4ab"
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: errorTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : "Error\n#ffb4ab"
                            color: parent.copied ? "#ffffff" : "#000000"
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex("#ffb4ab")
                                parent.copied = true
                                errorTimer.restart()
                            }
                        }
                    }
                }

                // Row 3: Surface, Surface Container, Outline
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(3)

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Theme.bgPrimary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: surfaceTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Surface\n" + root.colorToHex(Theme.bgPrimary))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Theme.bgPrimary) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Theme.bgPrimary))
                                parent.copied = true
                                surfaceTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                        property bool copied: false
                        Timer { id: surfaceContainerTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Surface Container\n" + root.colorToHex(Theme.bgSecondary))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Theme.bgSecondary) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Theme.bgSecondary))
                                parent.copied = true
                                surfaceContainerTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(22)
                        color: Theme.border
                        border.width: 1
                        border.color: Theme.textMuted
                        radius: 0
                        property bool copied: false
                        Timer { id: outlineTimer; interval: 800; repeat: false; onTriggered: parent.copied = false }
                        Text {
                            anchors.centerIn: parent
                            text: parent.copied ? "Copied!" : ("Outline\n" + root.colorToHex(Theme.border))
                            color: parent.copied ? "#ffffff" : (root.getLuminance(Theme.border) > 0.5 ? "#000000" : "#ffffff")
                            font.pixelSize: Math.round(5 * s)
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copyToHex(root.colorToHex(Theme.border))
                                parent.copied = true
                                outlineTimer.restart()
                            }
                        }
                    }
                }
            }
        }

        // Mode toggle - Mode text left, single toggle button right
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Mode"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(9 * s)
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: Theme.dp(90)
                Layout.preferredHeight: Theme.dp(28)
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                border.width: 1
                border.color: Theme.accent
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: {
                        var scheme = colorService.currentScheme
                        if (scheme === "light") return "Light"
                        return "Dark"
                    }
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(10 * s)
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: colorService.toggleMode()
                }
            }
        }

        // Scheme list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 0
            clip: true

            ListView {
                id: schemeList
                anchors.fill: parent
                model: root.schemeTypes
                currentIndex: 0

                delegate: Rectangle {
                    width: schemeList.width
                    height: Theme.dp(48)
                    color: schemeList.currentIndex === index
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : schemeMouse.containsMouse
                            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                            : (colorService.currentType === modelData.value ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent")
                    border.width: 1
                    border.color: schemeList.currentIndex === index ? Theme.accent : (colorService.currentType === modelData.value ? Theme.accent : "transparent")
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.dp(12)
                        anchors.rightMargin: Theme.dp(12)
                        anchors.topMargin: Theme.dp(6)
                        anchors.bottomMargin: Theme.dp(6)
                        spacing: Theme.dp(10)

                        Rectangle {
                            Layout.preferredWidth: Theme.dp(20)
                            Layout.preferredHeight: Theme.dp(20)
                            Layout.alignment: Qt.AlignVCenter
                            color: modelData.accent
                            border.width: 1
                            border.color: Theme.border
                            radius: 0
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Theme.textPrimary
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round(10 * s)
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.desc
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round(7 * s)
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: Theme.dp(20)
                            Layout.preferredHeight: Theme.dp(20)
                            Layout.alignment: Qt.AlignVCenter
                            color: "transparent"
                            visible: colorService.currentType === modelData.value

                            StarShape {
                                anchors.centerIn: parent
                                Layout.preferredWidth: Theme.dp(12)
                                Layout.preferredHeight: Theme.dp(12)
                                color: Theme.accent
                                animate: false
                            }
                        }
                    }

                    MouseArea {
                        id: schemeMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            schemeList.currentIndex = index
                            root.previewIndex = index
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: Theme.dp(6)
                }
            }
        }

        // Footer hints
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(24)
            spacing: Theme.dp(6)

            Text {
                text: "↑↓ Select"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "Enter Apply"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "M Toggle Mode"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "R Re-extract"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: Theme.dp(14); color: Theme.border }

            Text {
                text: "Esc Close"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }
        }
    }
}
