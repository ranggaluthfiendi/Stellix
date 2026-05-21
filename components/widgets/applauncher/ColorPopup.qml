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

            Rectangle {
                Layout.preferredWidth: applyText.width + Theme.dp(14)
                Layout.preferredHeight: Theme.dp(24)
                color: applyMouse.containsMouse ? Theme.accentHover : "transparent"
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
                        ? Theme.accentHover
                        : schemeMouse.containsMouse
                            ? Theme.accentHover
                            : (colorService.currentType === modelData.value ? Theme.accentHover : "transparent")
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
                text: "Esc Close"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }
        }
    }
}
