import QtQuick
import Quickshell
import QtCore
import Quickshell.Io

Item {
    id: root

    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var wallpapers: []
    property int currentIndex: 0
    property string currentWallpaper: ""
    property bool isApplying: false
    property string transitionType: "fade"
    property real transitionDuration: 0.5
    property int transitionFps: 60

    readonly property var currentWallpaperPath: wallpapers.length > 0 ? wallpapers[root.currentIndex] : ""

    StdioCollector { id: lsCollector }
    StdioCollector { id: applyCollector }

    Process {
        id: lsProcess
        stdout: lsCollector
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                var output = lsCollector.text.trim()
                if (output.length > 0) {
                    var files = output.split("\n")
                    var imageFiles = []
                    var imageExts = [".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif"]
                    for (var i = 0; i < files.length; i++) {
                        var file = files[i].trim()
                        if (file.length === 0) continue
                        var lower = file.toLowerCase()
                        for (var j = 0; j < imageExts.length; j++) {
                            if (lower.endsWith(imageExts[j])) {
                                imageFiles.push(root.wallpaperDir + "/" + file)
                                break
                            }
                        }
                    }
                    imageFiles.sort()
                    root.wallpapers = imageFiles
                    if (imageFiles.length > 0) {
                        root.currentIndex = 0
                    }
                }
            }
        }
    }

    Process {
        id: applyProcess
        stdout: applyCollector
        stderr: applyCollector
        onExited: function(exitCode, exitStatus) {
            var output = applyCollector.text.trim()
            root.isApplying = false
        }
    }

    Timer {
        id: applyDebounce
        interval: 500
        repeat: false
    }

    function refresh() {
        lsProcess.exec(["sh", "-c", "ls -1 '" + root.wallpaperDir + "' 2>/dev/null"])
    }

    function next() {
        if (root.wallpapers.length === 0) return
        root.currentIndex = (root.currentIndex + 1) % root.wallpapers.length
    }

    function prev() {
        if (root.wallpapers.length === 0) return
        root.currentIndex = (root.currentIndex - 1 + root.wallpapers.length) % root.wallpapers.length
    }

    function goTo(index) {
        if (index >= 0 && index < root.wallpapers.length) {
            root.currentIndex = index
        }
    }

    function applyWallpaper(monitorIndex) {
        if (root.wallpapers.length === 0 || root.currentIndex < 0 || root.currentIndex >= root.wallpapers.length) return
        if (applyDebounce.running) {
            return
        }

        var path = root.wallpapers[root.currentIndex]
        root.currentWallpaper = path
        root.isApplying = true
        applyDebounce.start()

        var outputArg = ""
        if (monitorIndex !== undefined && monitorIndex !== -1 && monitorIndex < Quickshell.screens.length) {
            outputArg = " --outputs " + Quickshell.screens[monitorIndex].name
        }

        var cmd
        if (root.transitionType === "instant") {
            cmd = "nohup awww img '" + path + "' --transition-type simple --transition-step 255" + outputArg + " </dev/null >/dev/null 2>&1 &"
        } else {
            cmd = "nohup awww img '" + path + "' --transition-type " + root.transitionType + " --transition-duration " + root.transitionDuration + " --transition-fps " + root.transitionFps + " --transition-step 90" + outputArg + " </dev/null >/dev/null 2>&1 &"
        }

        applyProcess.exec(["sh", "-c", cmd])
    }

    function cycleTransition() {
        var transitions = ["simple", "fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "outer", "random", "instant"]
        var idx = transitions.indexOf(root.transitionType)
        root.transitionType = transitions[(idx + 1) % transitions.length]
    }

    function getWallpaperName(index) {
        if (index < 0 || index >= root.wallpapers.length) return ""
        var path = root.wallpapers[index]
        var parts = path.split("/")
        return parts[parts.length - 1]
    }

    Component.onCompleted: {
        root.refresh()
        Quickshell.execDetached({
            command: ["sh", "-c", "nohup awww-daemon </dev/null >/dev/null 2>&1 &"]
        })
    }
}
