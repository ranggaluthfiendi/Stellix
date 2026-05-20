import QtQuick
import Quickshell

Item {
    id: root

    property bool isRecording: false

    function startRecording() {
        isRecording = true
        Quickshell.execDetached({
            command: ["sh", "-c", "wf-recorder -g \"$(slurp)\" -f ~/Videos/$(date +%Y%m%d_%H%M%S).mp4 2>/dev/null"]
        })
    }

    function stopRecording() {
        isRecording = false
        Quickshell.execDetached({
            command: ["sh", "-c", "pkill -SIGINT wf-recorder"]
        })
    }

    function toggleRecording() {
        if (isRecording) {
            stopRecording()
        } else {
            startRecording()
        }
    }
}
