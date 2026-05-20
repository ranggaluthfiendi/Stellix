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

    property real s: Scales.uiScale
    property string expression: ""
    property string result: ""
    property alias calcInput: calcInput

    signal closeRequested

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(10)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Calculator"
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(13 * s)
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            StarShape {
                Layout.preferredWidth: Theme.dp(16)
                Layout.preferredHeight: Theme.dp(16)
                color: Theme.accent
                animate: true
            }
        }

        TextField {
            id: calcInput
            Layout.fillWidth: true
            placeholderText: "e.g. 2+2*3"
            placeholderTextColor: Theme.textMuted
            color: Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(14 * s)
            font.weight: Font.Medium
            background: Rectangle {
                color: Theme.bgSecondary
                border.width: 1
                border.color: Theme.border
                radius: 0
            }
            padding: Theme.dp(10)

            onTextChanged: {
                expression = text
                var res = calc.calculate(text)
                result = res !== null ? "= " + res : ""
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.closeRequested()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (result.length > 0) {
                        var clipboard = Qt.clipboard
                        if (clipboard) {
                            clipboard.setText(result.substring(2))
                        }
                    }
                    event.accepted = true
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(48)
            text: result
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(24 * s)
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.dp(2)

            Text {
                text: "Operators:  +  add   -  subtract   *  multiply   /  divide   %  modulo"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: "Grouping:  ( )   |   Decimals:  2.5 + 3.14   |   Enter to copy result"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: "Examples:  (10+5)*2   |   100/3   |   2*3.14*5   |   17%5"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }
}
