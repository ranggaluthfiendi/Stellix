import QtQuick
import QtCore
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked()
    signal failed()
    signal lockRequested()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property int failedAttempts: 0
    property bool isLockedOut: false
    property int lockoutRemainingSeconds: 0

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText === "" || unlockInProgress || isLockedOut) return
        unlockInProgress = true
        pam.start()
    }

    function recordFailedAttempt() {
        failedAttempts++
        if (failedAttempts >= 5) {
            isLockedOut = true
            lockoutRemainingSeconds = 30
            lockoutTimer.start()
        }
    }

    function resetFailedAttempts() {
        failedAttempts = 0
        isLockedOut = false
        lockoutRemainingSeconds = 0
        lockoutTimer.stop()
    }

    Timer {
        id: lockoutTimer
        interval: 1000
        repeat: true
        onTriggered: {
            lockoutRemainingSeconds--
            if (lockoutRemainingSeconds <= 0) {
                stop()
                isLockedOut = false
                failedAttempts = 0
            }
        }
    }

    PamContext {
        id: pam
        configDirectory: "/home/rang/.config/quickshell/pam"
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText)
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                resetFailedAttempts()
                root.unlocked()
            } else {
                root.currentText = ""
                root.showFailure = true
                root.recordFailedAttempt()
                root.failed()
            }
            root.unlockInProgress = false
        }
    }
}
