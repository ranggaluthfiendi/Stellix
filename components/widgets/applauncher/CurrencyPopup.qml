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

Rectangle {
    id: root

    color: "transparent"

    property real s: Scales.uiScale
    property string currencyResult: ""
    property alias currencyInput: currencyInput

    signal closeRequested

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(12)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Currency Converter"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(14 * s)
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

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(36)

            ComboBox {
                id: fromCombo
                anchors.left: parent.left
                anchors.right: swapBtn.left
                anchors.rightMargin: Theme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                height: Theme.dp(36)
                model: currencyService.currencies.map(function(c) { return c.code + " - " + c.name })
                currentIndex: findCurrencyIndex(currencyService.fromCurrency)
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(10 * s)
                font.weight: Font.Medium
                contentItem: Text {
                    text: fromCombo.displayText
                    color: Theme.textPrimary
                    font: fromCombo.font
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: Theme.dp(10)
                }
                background: Rectangle {
                    color: Theme.bgSecondary
                    border.width: 1
                    border.color: Theme.border
                    radius: 0
                }
                delegate: ItemDelegate {
                    width: fromCombo.width
                    height: Theme.dp(28)
                    contentItem: Text {
                        text: modelData
                        color: fromCombo.highlightedIndex === index ? Theme.bgPrimary : Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: index === fromCombo.currentIndex ? Font.Bold : Font.Normal
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.dp(8)
                    }
                    background: Rectangle {
                        color: fromCombo.highlightedIndex === index ? Theme.accent : "transparent"
                        radius: 0
                    }
                }
                popup: Popup {
                    y: fromCombo.height
                    width: fromCombo.width
                    padding: Theme.dp(4)
                    background: Rectangle {
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                    }
                    contentItem: ListView {
                        model: fromCombo.delegateModel
                        clip: true
                        implicitHeight: contentHeight > Theme.dp(200) ? Theme.dp(200) : contentHeight
                        ScrollBar.vertical: ScrollBar {
                            width: Theme.dp(4)
                            contentItem: Rectangle {
                                implicitWidth: Theme.dp(4)
                                radius: 0
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                            }
                        }
                    }
                }
                onActivated: function(index) {
                    var code = currencyService.currencies[index].code
                    currencyService.fromCurrency = code
                    updateCurrencyResult()
                }
            }

            Rectangle {
                id: swapBtn
                anchors.centerIn: parent
                width: Theme.dp(36)
                height: Theme.dp(36)
                color: swapMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Theme.bgSecondary
                border.width: 1
                border.color: Theme.accent
                radius: 0

                Text {
                    anchors.centerIn: parent
                    text: "⇄"
                    color: Theme.accent
                    font.pixelSize: Math.round(16 * s)
                }

                MouseArea {
                    id: swapMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: doSwap()
                }
            }

            ComboBox {
                id: toCombo
                anchors.left: swapBtn.right
                anchors.right: parent.right
                anchors.leftMargin: Theme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                height: Theme.dp(36)
                model: currencyService.currencies.map(function(c) { return c.code + " - " + c.name })
                currentIndex: findCurrencyIndex(currencyService.toCurrency)
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(10 * s)
                font.weight: Font.Medium
                contentItem: Text {
                    text: toCombo.displayText
                    color: Theme.textPrimary
                    font: toCombo.font
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: Theme.dp(10)
                }
                background: Rectangle {
                    color: Theme.bgSecondary
                    border.width: 1
                    border.color: Theme.border
                    radius: 0
                }
                delegate: ItemDelegate {
                    width: toCombo.width
                    height: Theme.dp(28)
                    contentItem: Text {
                        text: modelData
                        color: toCombo.highlightedIndex === index ? Theme.bgPrimary : Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: index === toCombo.currentIndex ? Font.Bold : Font.Normal
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.dp(8)
                    }
                    background: Rectangle {
                        color: toCombo.highlightedIndex === index ? Theme.accent : "transparent"
                        radius: 0
                    }
                }
                popup: Popup {
                    y: toCombo.height
                    width: toCombo.width
                    padding: Theme.dp(4)
                    background: Rectangle {
                        color: Theme.bgSecondary
                        border.width: 1
                        border.color: Theme.border
                        radius: 0
                    }
                    contentItem: ListView {
                        model: toCombo.delegateModel
                        clip: true
                        implicitHeight: contentHeight > Theme.dp(200) ? Theme.dp(200) : contentHeight
                        ScrollBar.vertical: ScrollBar {
                            width: Theme.dp(4)
                            contentItem: Rectangle {
                                implicitWidth: Theme.dp(4)
                                radius: 0
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                            }
                        }
                    }
                }
                onActivated: function(index) {
                    var code = currencyService.currencies[index].code
                    currencyService.toCurrency = code
                    updateCurrencyResult()
                }
            }
        }

        TextField {
            id: currencyInput
            Layout.fillWidth: true
            placeholderText: "Enter amount..."
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

            onTextChanged: updateCurrencyResult()

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.closeRequested()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (currencyResult.length > 0) {
                        var clipboard = Qt.clipboard
                        if (clipboard) {
                            clipboard.setText(currencyResult.replace(/^[^0-9-]/, ""))
                        }
                    }
                    event.accepted = true
                } else if (event.key === Qt.Key_S && !event.modifiers) {
                    doSwap()
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    doSwap()
                    event.accepted = true
                } else if (event.key === Qt.Key_Right) {
                    doSwap()
                    event.accepted = true
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(48)
            text: currencyResult
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(20 * s)
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: currencyService.isLoading ? "Fetching rates..." : (currencyService.lastUpdated !== "" ? "Updated at " + currencyService.lastUpdated : "")
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(7 * s)
            horizontalAlignment: Text.AlignHCenter
            visible: currencyService.isLoading || currencyService.lastUpdated !== ""
        }

        Item { Layout.fillHeight: true }

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

                FooterHint { label: "Swap"; keys: "S / ←→" }
                FooterSeparator {}
                FooterHint { label: "Copy Result"; keys: "Enter" }
                FooterSeparator {}
                FooterHint { label: "Close"; keys: "Esc" }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "Currency Converter"
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

    function findCurrencyIndex(code) {
        for (var i = 0; i < currencyService.currencies.length; i++) {
            if (currencyService.currencies[i].code === code) return i
        }
        return 0
    }

    function doSwap() {
        currencyService.swapCurrencies()
        fromCombo.currentIndex = findCurrencyIndex(currencyService.fromCurrency)
        toCombo.currentIndex = findCurrencyIndex(currencyService.toCurrency)
        updateCurrencyResult()
    }

    function updateCurrencyResult() {
        var amount = parseFloat(currencyInput.text)
        if (isNaN(amount) || currencyInput.text === "") {
            currencyResult = ""
            return
        }
        var res = currencyService.calculate(currencyService.fromCurrency, currencyService.toCurrency, amount)
        if (res !== null) {
            var fromSym = currencyService.getSymbol(currencyService.fromCurrency)
            var formatted = currencyService.formatCurrency(res, currencyService.toCurrency)
            currencyResult = fromSym + amount + " " + currencyService.fromCurrency + " = " + formatted + " " + currencyService.toCurrency
        } else {
            currencyResult = "Invalid currency"
        }
    }
}
