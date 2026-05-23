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

    readonly property var schemeTypes: [
        { name: "Tonal Spot", value: "scheme-tonal-spot", desc: "Balanced, natural tones" },
        { name: "Content", value: "scheme-content", desc: "Based on image content" },
        { name: "Expressive", value: "scheme-expressive", desc: "Bold, vibrant colors" },
        { name: "Fidelity", value: "scheme-fidelity", desc: "True to original colors" },
        { name: "Fruit Salad", value: "scheme-fruit-salad", desc: "Playful, mixed colors" },
        { name: "Monochrome", value: "scheme-monochrome", desc: "Single color variations" },
        { name: "Neutral", value: "scheme-neutral", desc: "Subtle, muted tones" },
        { name: "Vibrant", value: "scheme-vibrant", desc: "High saturation colors" }
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
        } else if (event.key === Qt.Key_A) {
            colorService.applyTheme()
            event.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(12)

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Color Style"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(14 * s)
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Active: " + colorService.currentTypeName
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(9 * s)
                font.weight: Font.Medium
                opacity: 0.8
            }

            Rectangle {
                Layout.preferredWidth: applyText.implicitWidth + Theme.dp(16)
                Layout.preferredHeight: Theme.dp(26)
                color: applyMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                border.width: 1
                border.color: Theme.accent
                radius: 0

                Text {
                    id: applyText
                    anchors.centerIn: parent
                    text: "Apply"
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
                spacing: Theme.dp(4)

                delegate: Rectangle {
                    width: schemeList.width
                    height: Theme.dp(48)
                    color: schemeList.currentIndex === index
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : schemeMouse.containsMouse
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                            : (colorService.currentType === modelData.value ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05) : "transparent")
                    border.width: schemeList.currentIndex === index ? 1 : 0
                    border.color: Theme.accent
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.dp(12)
                        anchors.rightMargin: Theme.dp(12)
                        spacing: Theme.dp(10)

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Theme.textPrimary
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round(11 * s)
                                font.weight: schemeList.currentIndex === index ? Font.Bold : Font.Medium
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.desc
                                color: Theme.textMuted
                                font.family: Typography.fontFamily
                                font.pixelSize: Math.round(8 * s)
                                horizontalAlignment: Text.AlignLeft
                                opacity: 0.7
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
                    id: vbar
                    policy: ScrollBar.AsNeeded
                    width: Theme.dp(4)
                    contentItem: Rectangle {
                        implicitWidth: Theme.dp(4)
                        radius: 0
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                    }
                }
            }
        }

        // --- Footer Navigation Section ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(28)
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.dp(12)
                anchors.rightMargin: Theme.dp(12)
                spacing: Theme.dp(10)

                FooterHint { label: "Select"; keys: "↑/↓" }
                FooterSeparator {}
                FooterHint { label: "Apply"; keys: "Enter" }
                FooterSeparator {}
                FooterHint { label: "Close"; keys: "Esc" }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "Color Engine"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                    font.weight: Font.Bold
                    opacity: 0.6
                }
            }
        }
    }

    component FooterHint: RowLayout {
        property string label: ""
        property string keys: ""
        spacing: Theme.dp(4)
        
        Text {
            text: keys
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
            font.weight: Font.Bold
        }
        Text {
            text: label
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
        }
    }

    component FooterSeparator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(12)
        color: Theme.border
        opacity: 0.5
    }
}
