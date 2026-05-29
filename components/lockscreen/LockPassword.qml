import QtQuick
import QtQuick.Controls
import qs.config

Rectangle {
    id: root
    width: Theme.dp(300)
    height: passwordField.implicitHeight + Theme.dp(24)
    radius: Theme.radiusLarge
    color: "transparent"
    border.width: Theme.dp(2)
    border.color: passwordField.isError ? Theme.danger : (passwordField.activeFocus ? Theme.accent : Theme.border)

    property bool isError: false
    property bool isLockedOut: false
    property int lockoutSeconds: 0
    property bool unlockInProgress: false
    property string basePlaceholder: "Enter password"
    property int dotCount: 0
    property bool showKeyboard: false

    signal toggleKeyboardRequested()
    signal keyFlashRequested(string key)

    signal accepted(string password)
    property alias text: passwordField.text

    Behavior on border.color { ColorAnimation { duration: 150 } }

    TextField {
        id: passwordField
        property bool isError: root.isError
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        padding: Theme.dp(8)
        enabled: !root.unlockInProgress && !root.isLockedOut
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData
        horizontalAlignment: Text.AlignHCenter
        focus: true

        background: Rectangle {
            radius: Theme.radiusLarge
            color: "transparent"
        }

        font.family: Typography.fontFamily
        font.pixelSize: Typography.sizeMD
        color: Theme.textPrimary
        placeholderText: root.isLockedOut
            ? "Locked (" + root.lockoutSeconds + "s)"
            : (root.unlockInProgress ? "Verifying..." : root.basePlaceholder + placeholderDots)
        placeholderTextColor: root.isError ? Theme.danger : Theme.textMuted

        onTextChanged: {
            if (passwordField.isError && text.trim().length > 0) {
                passwordField.isError = false
                if (errorHoldTimer.running) errorHoldTimer.stop()
            }
        }

        onAccepted: {
            if (text.length === 0) {
                root.isError = true
                triggerError()
            } else if (text.trim().length === 0) {
                root.isError = true
                triggerError()
            } else if (!root.isLockedOut && !root.unlockInProgress) {
                root.accepted(text)
            }
        }

        Keys.onEscapePressed: passwordField.focus = false

        Keys.onPressed: (event) => {
            // Ctrl+K toggle keyboard
            if (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier)) {
                root.toggleKeyboardRequested()
                event.accepted = true
                return
            }

            // Flash on-screen key
            if (root.showKeyboard) {
                var keyStr = ""
                if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
                    keyStr = String.fromCharCode(event.key + 32)
                } else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                    keyStr = String.fromCharCode(event.key)
                } else if (event.key === Qt.Key_Space) {
                    keyStr = " "
                } else if (event.key === Qt.Key_Backspace) {
                    keyStr = "⌫"
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    keyStr = "Enter"
                } else if (event.key === Qt.Key_Tab) {
                    keyStr = "Tab"
                } else if (event.key === Qt.Key_Comma) {
                    keyStr = ","
                } else if (event.key === Qt.Key_Period) {
                    keyStr = "."
                } else if (event.key === Qt.Key_Slash) {
                    keyStr = "/"
                } else if (event.key === Qt.Key_Minus) {
                    keyStr = "-"
                } else if (event.key === Qt.Key_Equal) {
                    keyStr = "="
                } else if (event.key === Qt.Key_BracketLeft) {
                    keyStr = "["
                } else if (event.key === Qt.Key_BracketRight) {
                    keyStr = "]"
                } else if (event.key === Qt.Key_Apostrophe) {
                    keyStr = "'"
                } else if (event.key === Qt.Key_QuoteLeft) {
                    keyStr = "`"
                } else if (event.key === Qt.Key_Semicolon) {
                    keyStr = ";"
                }
                if (keyStr !== "") {
                    root.keyFlashRequested(keyStr)
                }
            }
        }
    }

    property string placeholderDots: {
        var dots = ""
        for (var i = 0; i < root.dotCount; i++) dots += "."
        return dots
    }

    Timer {
        id: placeholderAnim
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            root.dotCount = (root.dotCount + 1) % 4
        }
    }

    function triggerError() {
        root.isError = true
        if (shakeAnim.running) shakeAnim.stop()
        if (errorHoldTimer.running) errorHoldTimer.stop()
        shakeAnim.start()
        passwordField.text = ""
        hideErrorTimer.restart()
    }

    Timer {
        id: errorHoldTimer
        interval: 150
        repeat: false
        onTriggered: passwordField.isError = false
    }

    Timer {
        id: hideErrorTimer
        interval: 2000
        repeat: false
        onTriggered: root.isError = false
    }

    SequentialAnimation {
        id: shakeAnim
        running: false
        PropertyAnimation { target: root; property: "x"; to: -10; duration: 50 }
        PropertyAnimation { target: root; property: "x"; to: 10; duration: 50 }
        PropertyAnimation { target: root; property: "x"; to: -6; duration: 40 }
        PropertyAnimation { target: root; property: "x"; to: 6; duration: 40 }
        PropertyAnimation { target: root; property: "x"; to: 0; duration: 30 }
        onStopped: errorHoldTimer.start()
    }
}
