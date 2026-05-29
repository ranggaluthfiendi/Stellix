import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    id: root
    spacing: Theme.dp(8)

    property real buttonSize: Theme.dp(40)

    LockToggleBtn {
        size: root.buttonSize
        icon: "wifi"
        label: "Wi-Fi"
        active: false
        onToggled: active = !active
    }

    LockToggleBtn {
        size: root.buttonSize
        icon: "bluetooth"
        label: "Bluetooth"
        active: false
        onToggled: active = !active
    }

    LockToggleBtn {
        size: root.buttonSize
        icon: "do_not_disturb_on"
        label: "DND"
        active: false
        onToggled: active = !active
    }
}
