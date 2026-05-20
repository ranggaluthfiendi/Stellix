import QtQuick
import Quickshell

Item {
    id: root

    function shutdown() {
        Quickshell.execDetached({
            command: ["sh", "-c", "systemctl poweroff"]
        })
    }

    function reboot() {
        Quickshell.execDetached({
            command: ["sh", "-c", "systemctl reboot"]
        })
    }

    function logout() {
        Quickshell.execDetached({
            command: ["sh", "-c", "hyprctl dispatch exit"]
        })
    }

    function lock() {
        Quickshell.execDetached({
            command: ["sh", "-c", "hyprlock"]
        })
    }

    function suspend() {
        Quickshell.execDetached({
            command: ["sh", "-c", "systemctl suspend"]
        })
    }
}
