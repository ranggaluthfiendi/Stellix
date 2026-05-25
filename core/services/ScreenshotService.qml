import QtQuick
import Quickshell

Item {
    id: root

    function screenshotRegion() {
        Quickshell.execDetached({
            command: ["sh", "-c", "hyprshot -m region"]
        })
    }

    function screenshotWindow() {
        Quickshell.execDetached({
            command: ["sh", "-c", "hyprshot -m window"]
        })
    }

    function screenshotOutput() {
        Quickshell.execDetached({
            command: ["sh", "-c", "hyprshot -m output"]
        })
    }
}
