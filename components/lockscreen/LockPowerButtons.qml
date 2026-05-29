import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config

RowLayout {
    id: root
    spacing: Theme.dp(8)

    property real buttonSize: Theme.dp(36)

    LockPowerBtn {
        size: root.buttonSize
        icon: "lock"
        label: "Lock"
        onClicked: root.lockRequested()
    }

    LockPowerBtn {
        size: root.buttonSize
        icon: "power_settings_new"
        label: "Shutdown"
        onClicked: {
            powerProc.command = ["systemctl", "poweroff"]
            powerProc.running = true
        }
    }

    LockPowerBtn {
        size: root.buttonSize
        icon: "restart_alt"
        label: "Reboot"
        onClicked: {
            powerProc.command = ["systemctl", "reboot"]
            powerProc.running = true
        }
    }

    Process {
        id: powerProc
    }

    signal lockRequested()
}
