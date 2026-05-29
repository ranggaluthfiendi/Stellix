import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs.config
import qs.core.state
import qs.components.lockscreen

Rectangle {
    id: root
    color: Theme.bgPrimary
    visible: true
    focus: true
    required property LockContext context
    property var mprisService: null
    property var brightnessService: null

    readonly property string wallpaperPath: BarLayoutState.lockscreenWallpaperPath !== "" ? BarLayoutState.lockscreenWallpaperPath : (Theme.wallpaperPath || "")
    property var node: Pipewire.defaultAudioSink
    property var currentPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property bool showKeyboard: false
    property bool keyboardSymbols: false
    property bool keyboardShift: false
    property bool keyboardCaps: false
    property string flashKey: ""

    Timer {
        id: flashTimer
        interval: 150
        repeat: false
        onTriggered: root.flashKey = ""
    }

    // Indicator state
    property string indicatorType: ""
    property real indicatorValue: 0
    property bool indicatorMuted: false
    property bool indicatorVisible: false

    Timer {
        id: indicatorHideTimer
        interval: 1500
        repeat: false
        onTriggered: root.indicatorVisible = false
    }

    function showIndicator(type, value, muted) {
        root.indicatorType = type
        root.indicatorValue = value
        root.indicatorMuted = muted || false
        root.indicatorVisible = true
        indicatorHideTimer.restart()
    }

    PwObjectTracker { objects: [ root.node ].filter(function(x) { return x }) }

    // Ctrl+K shortcut for keyboard toggle
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: root.showKeyboard = !root.showKeyboard
    }

    Shortcut {
        sequence: "Ctrl+Shift+K"
        onActivated: root.showKeyboard = !root.showKeyboard
    }

    // Lock/unlock animations
    property bool isUnlocking: false

    // Entry animation (lock) - fade in
    opacity: 0
    SequentialAnimation on opacity {
        id: entryAnim
        NumberAnimation { to: 1; duration: 500; easing.type: Easing.OutCubic }
    }

    // Exit animation (unlock) - fade out
    SequentialAnimation {
        id: exitAnim
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InCubic }
    }

    Component.onCompleted: {
        idleBlurTimer.start()
        passwordBox.forceActiveFocus()
    }

    function startExitAnimation() {
        root.isUnlocking = true
        exitAnim.start()
    }

    Connections {
        target: root.context
        function onUnlocked() {
            root.startExitAnimation()
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Tab) {
            if (passwordBox.focus) {
                passwordBox.focus = false
            } else {
                passwordBox.forceActiveFocus()
            }
            event.accepted = true
        } else if ((event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !passwordBox.focus) {
            passwordBox.forceActiveFocus()
        }
    }

    Keys.onShortcutOverride: (event) => {
        if (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier)) {
            root.showKeyboard = !root.showKeyboard
            event.accepted = true
        }
    }

    MouseArea {
        id: unfocusArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        onClicked: (mouse) => {
            if (!passwordBox.containsMouse) passwordBox.focus = false
            mouse.accepted = false
        }
    }

    // Wallpaper layer
    Item {
        anchors.fill: parent
        Rectangle {
            color: {
                switch (BarLayoutState.lockscreenBgColorMode) {
                    case "accent": return Theme.accent
                    case "bg_secondary": return Theme.bgSecondary
                    case "bg_primary": return Theme.bgPrimary
                    case "white": return "#ffffff"
                    case "black": return "#000000"
                    default: return Theme.bgPrimary
                }
            }
            anchors.fill: parent
        }
        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: true
            source: root.wallpaperPath
        }
        Rectangle {
            anchors.fill: parent
            color: {
                switch (BarLayoutState.lockscreenOverlayColorMode) {
                    case "accent": return Theme.accent
                    case "bg_secondary": return Theme.bgSecondary
                    case "bg_primary": return Theme.bgPrimary
                    case "white": return "#ffffff"
                    case "black": return "#000000"
                    default: return "#000000"
                }
            }
            opacity: BarLayoutState.lockscreenOverlayOpacity
        }
    }

    // Idle blur
    property real idleBlurAmount: 0
    Timer {
        id: idleBlurTimer
        interval: BarLayoutState.lockscreenIdleTimeout * 1000
        repeat: false
        onTriggered: idleBlurAnim.start()
    }
    NumberAnimation {
        id: idleBlurAnim
        target: root
        property: "idleBlurAmount"
        to: 30
        duration: 2000
        easing.type: Easing.InOutQuad
    }
    NumberAnimation {
        id: clearBlurAnim
        target: root
        property: "idleBlurAmount"
        to: 0
        duration: 300
        easing.type: Easing.OutQuad
    }
    MouseArea {
        id: activityArea
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: {
            if (root.idleBlurAmount > 0) clearBlurAnim.start()
            if (BarLayoutState.lockscreenIdleBlur) idleBlurTimer.restart()
        }
        Keys.onPressed: {
            if (root.idleBlurAmount > 0) clearBlurAnim.start()
            if (BarLayoutState.lockscreenIdleBlur) idleBlurTimer.restart()
        }
    }

    // Volume/brightness indicator
    Rectangle {
        id: indicatorOverlay
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Theme.dp(60)
        width: indicatorContent.implicitWidth + Theme.dp(24)
        height: Theme.dp(44)
        radius: Theme.radiusLarge
        color: Theme.bgSecondary
        border.color: Theme.border
        border.width: Theme.borderWidth
        opacity: root.indicatorVisible ? 1 : 0
        scale: root.indicatorVisible ? 1 : 0.8
        z: 100
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        RowLayout {
            id: indicatorContent
            anchors.centerIn: parent
            spacing: Theme.dp(10)
            Text {
                text: root.indicatorType === "volume" ? (root.indicatorMuted ? "volume_off" : "volume_up") : "light_mode"
                font.family: Typography.materialSymbols
                font.styleName: "Regular"
                font.pixelSize: Theme.dp(20)
                color: Theme.accent
            }
            Rectangle {
                width: Theme.dp(100)
                height: Theme.dp(6)
                radius: Theme.dp(3)
                color: Theme.bgPrimary
                Rectangle {
                    width: parent.width * root.indicatorValue
                    height: parent.height
                    radius: Theme.dp(3)
                    color: root.indicatorMuted ? Theme.textMuted : Theme.accent
                    Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                }
            }
            Text {
                text: Math.round(root.indicatorValue * 100) + "%"
                font.family: Typography.fontFamily
                font.pixelSize: Typography.sizeSM
                font.weight: Font.Bold
                color: Theme.textPrimary
            }
        }
    }

    // Volume hot corner (top-left)
    Item {
        id: volumeHotCorner
        width: Theme.dp(100)
        height: Theme.dp(100)
        anchors.top: parent.top
        anchors.left: parent.left
        z: 2
        visible: BarLayoutState.lockscreenHotCorners
        opacity: 0
        scale: 0.5
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
        Component.onCompleted: { volumeHotCorner.opacity = 1; volumeHotCorner.scale = 1 }

        Text {
            id: volumeIcon
            anchors.centerIn: parent
            text: "volume_up"
            font.family: Typography.materialSymbols
            font.styleName: "Regular"
            font.pixelSize: Theme.dp(28)
            color: "#ffffff"
            opacity: maVolume.containsMouse ? 0.8 : 0
            scale: 1.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        MouseArea {
            id: maVolume
            anchors.fill: parent
            hoverEnabled: true
            onWheel: (wheel) => {
                if (!root.node || !root.node.audio) return
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                root.node.audio.volume = Math.max(0, Math.min(1, root.node.audio.volume + delta))
                root.showIndicator("volume", root.node.audio.volume, root.node.audio.muted)
            }
        }
    }

    // Brightness hot corner (top-right)
    Item {
        id: brightnessHotCorner
        width: Theme.dp(100)
        height: Theme.dp(100)
        anchors.top: parent.top
        anchors.right: parent.right
        z: 2
        visible: BarLayoutState.lockscreenHotCorners
        opacity: 0
        scale: 0.5
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
        Component.onCompleted: { brightnessHotCorner.opacity = 1; brightnessHotCorner.scale = 1 }

        Text {
            id: brightnessIcon
            anchors.centerIn: parent
            text: "light_mode"
            font.family: Typography.materialSymbols
            font.styleName: "Regular"
            font.pixelSize: Theme.dp(28)
            color: "#ffffff"
            opacity: maBrightness.containsMouse ? 0.8 : 0
            scale: 1.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        MouseArea {
            id: maBrightness
            anchors.fill: parent
            hoverEnabled: true
            onWheel: (wheel) => {
                if (!root.brightnessService) return
                const delta = wheel.angleDelta.y > 0 ? 5 : -5
                var current = root.brightnessService.percentage
                root.brightnessService.setPercentage(Math.max(0, Math.min(100, current + delta)))
                root.showIndicator("brightness", root.brightnessService.percentage / 100, false)
            }
        }
    }

    // Power actions - bottom right
    ColumnLayout {
        id: powerButtonsCol
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.dp(30)
        spacing: Theme.dp(8)
        visible: BarLayoutState.lockscreenShowPowerButtons
        opacity: visible ? 1 : 0
        x: Theme.dp(30)
        SequentialAnimation on opacity {
            NumberAnimation { to: 1; duration: 600; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 400 }
        }
        Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        Component.onCompleted: powerButtonsCol.x = 0

        Rectangle {
            width: Theme.dp(40); height: Theme.dp(40); radius: Theme.radiusMedium
            color: maLock.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
            border.color: Theme.accent; border.width: Theme.borderWidth
            Layout.alignment: Qt.AlignRight
            Text { anchors.centerIn: parent; text: "lock"; font.family: Typography.materialSymbols; font.styleName: "Regular"; font.pixelSize: Theme.dp(20); color: Theme.accent }
            MouseArea {
                id: maLock; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                onClicked: root.context.lockRequested()
            }
        }

        Rectangle {
            id: powerBtn; width: Theme.dp(40); height: Theme.dp(40); radius: width / 2
            color: maPower.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.2) : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1)
            border.color: Theme.danger; border.width: Theme.borderWidth
            Layout.alignment: Qt.AlignRight
            Text { anchors.centerIn: parent; text: "power_settings_new"; font.family: Typography.materialSymbols; font.styleName: "Regular"; font.pixelSize: Theme.dp(20); color: Theme.danger }
            MouseArea {
                id: maPower; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                onClicked: powerDialog.visible = !powerDialog.visible
            }
        }

        Rectangle {
            id: rebootBtn; width: Theme.dp(40); height: Theme.dp(40); radius: width / 2
            color: maReboot.containsMouse ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.2) : Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.1)
            border.color: Theme.warning; border.width: Theme.borderWidth
            Layout.alignment: Qt.AlignRight
            Text {
                id: rebootIconText; anchors.centerIn: parent; text: "restart_alt"
                font.family: Typography.materialSymbols; font.styleName: "Regular"; font.pixelSize: Theme.dp(20); color: Theme.warning
            }
            Timer {
                id: rebootRotateTimer; interval: 4000; repeat: true; running: true
                onTriggered: rebootRotateAnim.start()
            }
            NumberAnimation {
                id: rebootRotateAnim; target: rebootIconText; property: "rotation"
                from: 0; to: 360; duration: 1500; easing.type: Easing.InOutQuad
            }
            MouseArea {
                id: maReboot; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                onEntered: rebootRotateTimer.stop()
                onExited: rebootRotateTimer.start()
                onClicked: rebootDialog.visible = !rebootDialog.visible
            }
        }
    }

    // Power dialog with countdown
    Rectangle {
        id: powerDialog
        visible: false
        width: Theme.dp(280)
        height: Theme.dp(120)
        radius: Theme.radiusLarge
        color: Theme.bgSecondary
        border.color: Theme.border
        border.width: Theme.borderWidth
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Theme.dp(80)
        z: 50

        property int countdown: BarLayoutState.lockscreenPowerConfirmTime
        property bool counting: false

        onVisibleChanged: {
            if (visible) {
                countdown = BarLayoutState.lockscreenPowerConfirmTime
                counting = true
                powerCountdownTimer.restart()
            } else {
                counting = false
                powerCountdownTimer.stop()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(16)
            spacing: Theme.dp(8)

            Text {
                text: "Shutdown?"
                color: Theme.textPrimary
                font.pixelSize: Typography.sizeMD
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: powerDialog.counting ? "Auto-executing in " + powerDialog.countdown + "s" : "Ready"
                color: Theme.textMuted
                font.pixelSize: Typography.sizeXS
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.dp(8)

                Rectangle {
                    width: Theme.dp(80)
                    height: Theme.dp(34)
                    radius: Theme.radiusSmall
                    color: confirmMouse.containsMouse ? Qt.darker(Theme.danger, 1.2) : Theme.danger
                    opacity: powerDialog.counting ? 1 : 0.5

                    Text {
                        anchors.centerIn: parent
                        text: powerDialog.counting ? "Confirm" : "Done"
                        color: "#ffffff"
                        font.pixelSize: Typography.sizeXS
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        enabled: powerDialog.counting
                        onClicked: {
                            var proc = Qt.createQmlObject("import Quickshell.Io; Process {}", root)
                            proc.command = ["sh", "-c", "systemctl poweroff"]
                            proc.running = true
                            powerDialog.visible = false
                        }
                    }
                }

                Rectangle {
                    width: Theme.dp(80)
                    height: Theme.dp(34)
                    radius: Theme.radiusSmall
                    color: cancelMouse.containsMouse ? Theme.accent : Theme.bgPrimary
                    border.color: Theme.border
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: cancelMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted
                        font.pixelSize: Typography.sizeXS
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: powerDialog.visible = false
                    }
                }
            }
        }

        Timer {
            id: powerCountdownTimer
            interval: 1000
            repeat: true
            onTriggered: {
                if (powerDialog.countdown > 0) {
                    powerDialog.countdown--
                } else {
                    var proc = Qt.createQmlObject("import Quickshell.Io; Process {}", root)
                    proc.command = ["sh", "-c", "systemctl poweroff"]
                    proc.running = true
                    powerDialog.visible = false
                }
            }
        }
    }

    // Reboot dialog with countdown
    Rectangle {
        id: rebootDialog
        visible: false
        width: Theme.dp(280)
        height: Theme.dp(120)
        radius: Theme.radiusLarge
        color: Theme.bgSecondary
        border.color: Theme.border
        border.width: Theme.borderWidth
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Theme.dp(80)
        z: 50

        property int countdown: BarLayoutState.lockscreenPowerConfirmTime
        property bool counting: false

        onVisibleChanged: {
            if (visible) {
                countdown = BarLayoutState.lockscreenPowerConfirmTime
                counting = true
                rebootCountdownTimer.restart()
            } else {
                counting = false
                rebootCountdownTimer.stop()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(16)
            spacing: Theme.dp(8)

            Text {
                text: "Reboot?"
                color: Theme.textPrimary
                font.pixelSize: Typography.sizeMD
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: rebootDialog.counting ? "Auto-executing in " + rebootDialog.countdown + "s" : "Ready"
                color: Theme.textMuted
                font.pixelSize: Typography.sizeXS
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.dp(8)

                Rectangle {
                    width: Theme.dp(80)
                    height: Theme.dp(34)
                    radius: Theme.radiusSmall
                    color: rebootConfirmMouse.containsMouse ? Qt.darker(Theme.warning, 1.2) : Theme.warning
                    opacity: rebootDialog.counting ? 1 : 0.5

                    Text {
                        anchors.centerIn: parent
                        text: rebootDialog.counting ? "Confirm" : "Done"
                        color: "#ffffff"
                        font.pixelSize: Typography.sizeXS
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: rebootConfirmMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        enabled: rebootDialog.counting
                        onClicked: {
                            var proc = Qt.createQmlObject("import Quickshell.Io; Process {}", root)
                            proc.command = ["sh", "-c", "systemctl reboot"]
                            proc.running = true
                            rebootDialog.visible = false
                        }
                    }
                }

                Rectangle {
                    width: Theme.dp(80)
                    height: Theme.dp(34)
                    radius: Theme.radiusSmall
                    color: rebootCancelMouse.containsMouse ? Theme.accent : Theme.bgPrimary
                    border.color: Theme.border
                    border.width: Theme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: rebootCancelMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted
                        font.pixelSize: Typography.sizeXS
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: rebootCancelMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: rebootDialog.visible = false
                    }
                }
            }
        }

        Timer {
            id: rebootCountdownTimer
            interval: 1000
            repeat: true
            onTriggered: {
                if (rebootDialog.countdown > 0) {
                    rebootDialog.countdown--
                } else {
                    var proc = Qt.createQmlObject("import Quickshell.Io; Process {}", root)
                    proc.command = ["sh", "-c", "systemctl reboot"]
                    proc.running = true
                    rebootDialog.visible = false
                }
            }
        }
    }

    // Main center content - simple Column with explicit spacing
    Column {
        id: centerColumn
        anchors.centerIn: parent
        spacing: Theme.dp(16)

        // Clock
        LockClock {
            id: lockClock
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0
            SequentialAnimation on opacity {
                NumberAnimation { to: 1; duration: 600; easing.type: Easing.OutCubic }
            }
        }

        // Profile
        LockProfile {
            id: lockProfile
            anchors.horizontalCenter: parent.horizontalCenter
            avatarSize: Theme.dp(100)
            opacity: 0
            SequentialAnimation on opacity {
                NumberAnimation { to: 1; duration: 800; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 200 }
            }
        }

        // Password
        LockPassword {
            id: passwordBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.dp(300)
            isLockedOut: root.context.isLockedOut
            lockoutSeconds: root.context.lockoutRemainingSeconds
            unlockInProgress: root.context.unlockInProgress
            showKeyboard: root.showKeyboard
            opacity: 0
            SequentialAnimation on opacity {
                NumberAnimation { to: 1; duration: 600; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 400 }
            }

            onToggleKeyboardRequested: root.showKeyboard = !root.showKeyboard
            onKeyFlashRequested: (key) => {
                root.flashKey = key
                flashTimer.restart()
            }

            onAccepted: (password) => {
                root.context.currentText = password
                root.context.tryUnlock()
            }

            Connections {
                target: root.context
                function onFailed() {
                    passwordBox.triggerError()
                }
            }
        }

        // Media
        LockMedia {
            id: lockMedia
            anchors.horizontalCenter: parent.horizontalCenter
            mprisService: root.mprisService
            visible: BarLayoutState.lockscreenShowMedia
            opacity: 0
            SequentialAnimation on opacity {
                NumberAnimation { to: 1; duration: 800; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 600 }
            }
        }
    }

    // Keyboard toggle - bottom left
    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Theme.dp(30)
        width: Theme.dp(40); height: Theme.dp(40); radius: Theme.radiusMedium
        color: maKb.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
        border.color: Theme.border; border.width: Theme.borderWidth
        z: 5
        visible: BarLayoutState.lockscreenShowKeyboard
        x: -Theme.dp(50)
        opacity: visible ? 1 : 0
        Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        Component.onCompleted: kbToggle.x = 0
        id: kbToggle
        Text {
            anchors.centerIn: parent
            text: root.showKeyboard ? "keyboard_hide" : "keyboard"
            font.family: Typography.materialSymbols; font.styleName: "Regular"
            font.pixelSize: Theme.dp(20); color: Theme.textSecondary
        }
        MouseArea {
            id: maKb; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
            onClicked: root.showKeyboard = !root.showKeyboard
        }
        Text {
            anchors.right: parent.left
            anchors.rightMargin: Theme.dp(8)
            anchors.verticalCenter: parent.verticalCenter
            text: "Ctrl+K"
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeXS
            color: Theme.textMuted
            opacity: maKb.containsMouse ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    // On-screen keyboard - 60% layout
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dp(20)
        width: Theme.dp(680)
        height: Theme.dp(190)
        radius: Theme.radiusLarge
        color: Theme.bgSecondary
        border.color: Theme.border
        border.width: Theme.borderWidth
        visible: root.showKeyboard
        z: 50

        ColumnLayout {
            id: keyboardContent
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(4)

            // Row 1: numbers
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Repeater {
                    model: ["1","2","3","4","5","6","7","8","9","0"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
            }

            // Row 2: QWERTY + backspace
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Repeater {
                    model: ["q","w","e","r","t","y","u","i","o","p"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
                KeyBtn { keyText: "⌫"; wide: true; onClicked: doBackspace() }
            }

            // Row 3: Tab + ASDF + brackets
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                KeyBtn { keyText: "Tab"; wide: true; onClicked: typeKey("\t") }
                Repeater {
                    model: ["a","s","d","f","g","h","j","k","l"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
                Repeater {
                    model: ["[", "]"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
            }

            // Row 4: Caps + ZXCV + punctuation + Enter
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                KeyBtn { keyText: "Caps"; wide: true; active: root.keyboardCaps; onClicked: root.keyboardCaps = !root.keyboardCaps }
                Repeater {
                    model: ["z","x","c","v","b","n","m"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
                Repeater {
                    model: [",",".","/","-"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
                KeyBtn { keyText: "Enter"; extraWide: true; accent: true; onClicked: doEnter() }
            }

            // Row 5: Shift + Sym + space + Sym + Shift
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                KeyBtn { keyText: "Shift"; wide: true; active: root.keyboardShift; onClicked: root.keyboardShift = !root.keyboardShift }
                KeyBtn { keyText: "123"; wide: true; active: root.keyboardSymbols; onClicked: root.keyboardSymbols = !root.keyboardSymbols }
                KeyBtn { keyText: " "; extraWide: true; onClicked: typeKey(" ") }
                KeyBtn { keyText: "#+="; wide: true; onClicked: root.keyboardSymbols = !root.keyboardSymbols }
                KeyBtn { keyText: "Shift"; wide: true; active: root.keyboardShift; onClicked: root.keyboardShift = !root.keyboardShift }
            }
        }
    }

    // Symbol overlay keyboard - replaces number row with more symbols
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dp(20)
        width: Theme.dp(680)
        height: Theme.dp(190)
        radius: Theme.radiusLarge
        color: Theme.bgSecondary
        border.color: Theme.border
        border.width: Theme.borderWidth
        visible: root.showKeyboard && root.keyboardSymbols
        z: 50

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(4)

            // Row 1: symbols
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Repeater {
                    model: ["!","@","#","$","%","^","&","*","(",")"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
            }

            // Row 2: more symbols + backspace
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Repeater {
                    model: ["_","+","=","{","}","|","\\",":","\""]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
                KeyBtn { keyText: "⌫"; wide: true; onClicked: doBackspace() }
            }

            // Row 3: < > ; ' ~ ` ? !
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                KeyBtn { keyText: "Tab"; wide: true; onClicked: typeKey("\t") }
                Repeater {
                    model: ["<",">",";","'","~","`","?","!","'"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
            }

            // Row 4: € £ ¥ ¢ + Enter
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                KeyBtn { keyText: "Caps"; wide: true; active: root.keyboardCaps; onClicked: root.keyboardCaps = !root.keyboardCaps }
                Repeater {
                    model: ["€","£","¥","¢","§","¶","•","°"]
                    delegate: KeyBtn { keyText: modelData; onClicked: typeKey(modelData) }
                }
                KeyBtn { keyText: "Enter"; extraWide: true; accent: true; onClicked: doEnter() }
            }

            // Row 5: Shift + ABC + space + ABC + Shift
            RowLayout {
                spacing: Theme.dp(4)
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                KeyBtn { keyText: "Shift"; wide: true; active: root.keyboardShift; onClicked: root.keyboardShift = !root.keyboardShift }
                KeyBtn { keyText: "ABC"; wide: true; active: true; onClicked: root.keyboardSymbols = false }
                KeyBtn { keyText: " "; extraWide: true; onClicked: typeKey(" ") }
                KeyBtn { keyText: "ABC"; wide: true; onClicked: root.keyboardSymbols = false }
                KeyBtn { keyText: "Shift"; wide: true; active: root.keyboardShift; onClicked: root.keyboardShift = !root.keyboardShift }
            }
        }
    }

    function doBackspace() {
        if (passwordBox.text.length > 0) passwordBox.text = passwordBox.text.slice(0, -1)
        passwordBox.forceActiveFocus()
    }

    function doEnter() {
        if (passwordBox.text.length > 0) {
            root.context.currentText = passwordBox.text
            root.context.tryUnlock()
        }
    }

    function typeKey(key) {
        if (key === "\t") {
            passwordBox.forceActiveFocus()
            return
        }
        var finalKey = key
        if (key.length === 1 && key.match(/[a-z]/)) {
            if (root.keyboardShift || root.keyboardCaps) {
                finalKey = key.toUpperCase()
            }
            if (root.keyboardShift) {
                root.keyboardShift = false
            }
        }
        passwordBox.text += finalKey
        passwordBox.forceActiveFocus()
    }

    component KeyBtn: Rectangle {
        id: keyBtn
        property string keyText: ""
        property bool wide: false
        property bool extraWide: false
        property bool active: false
        property bool accent: false
        property string displayText: {
            if (keyText.length === 1 && keyText.match(/[a-z]/)) {
                return (root.keyboardShift || root.keyboardCaps) ? keyText.toUpperCase() : keyText
            }
            return keyText
        }
        property real pressScale: 1.0
        property bool isFlashing: root.flashKey.toLowerCase() === keyText.toLowerCase() && root.flashKey !== ""
        signal clicked()
        width: extraWide ? Theme.dp(90) : (wide ? Theme.dp(55) : Theme.dp(42))
        height: Theme.dp(32); radius: Theme.radiusMedium
        scale: pressScale * (isFlashing ? 0.92 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        color: {
            if (accent) return Theme.accent
            if (active) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
            return kMouse.containsMouse ? Qt.lighter(Theme.bgSecondary, 1.08) : Theme.bgPrimary
        }
        border.color: active ? Theme.accent : Theme.border
        border.width: Theme.borderWidth
        Text {
            anchors.centerIn: parent
            text: displayText
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeSM
            font.weight: accent ? Font.Bold : Font.Normal
            color: {
                if (accent) return Theme.bgPrimary
                if (active) return Theme.accent
                return kMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
            }
        }
        MouseArea {
            id: kMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onPressed: keyBtn.pressScale = 0.92
            onReleased: keyBtn.pressScale = 1.0
            onClicked: keyBtn.clicked()
        }
    }
}
