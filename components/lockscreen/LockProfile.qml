import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config

Item {
    id: root
    width: contentColumn.implicitWidth
    height: contentColumn.implicitHeight

    property string username: "Unknown"
    property string profileImage: ""
    property real avatarSize: Theme.dp(120)

    property string greeting: {
        const hour = new Date().getHours()
        if (hour >= 5 && hour < 12) return "Good Morning"
        if (hour >= 12 && hour < 17) return "Good Afternoon"
        if (hour >= 17 && hour < 21) return "Good Evening"
        return "Good Night"
    }

    Column {
        id: contentColumn
        spacing: Theme.dp(12)
        anchors.horizontalCenter: parent.horizontalCenter

        // Avatar with ring and pulse animation
        Rectangle {
            id: avatarRing
            width: root.avatarSize + Theme.dp(8)
            height: root.avatarSize + Theme.dp(8)
            radius: width / 2
            color: "transparent"
            border.color: Theme.accent
            border.width: Theme.dp(3)
            anchors.horizontalCenter: parent.horizontalCenter

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.03; duration: 2000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutQuad }
            }

            // Inner circle - using ClippingWrapperRectangle for proper circular clipping
            ClippingWrapperRectangle {
                anchors.centerIn: parent
                width: root.avatarSize
                height: root.avatarSize
                radius: width / 2
                color: Theme.bgSecondary

                Image {
                    anchors.fill: parent
                    source: root.profileImage || ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                }
            }

            // Fallback icon shown when image not loaded
            Text {
                anchors.centerIn: parent
                text: "person"
                font.family: Typography.materialSymbols
                font.styleName: "Regular"
                font.pixelSize: Theme.dp(48)
                color: Theme.textMuted
                visible: profileImage === ""
            }
        }

        // Greeting and username
        Column {
            spacing: Theme.dp(4)
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: root.greeting
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Typography.sizeSM
                font.weight: Typography.weightNormal
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: root.username
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Theme.dp(28)
                font.weight: Typography.weightBold
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Fetch username and profile image
    Process {
        id: whoamiProc
        command: ["whoami"]
        stdout: StdioCollector {
            onStreamFinished: {
                const name = this.text.trim()
                if (name.length > 0) {
                    root.username = name
                    const accIconPath = "/var/lib/AccountsService/icons/" + name
                    checkImage.command = ["sh", "-c", "test -f " + accIconPath + " && echo OK || echo NO"]
                    checkImage.running = true
                }
            }
        }
    }

    Process {
        id: checkImage
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                const iconPath = "/var/lib/AccountsService/icons/" + root.username
                root.profileImage = (this.text.trim() === "OK") ? "file://" + iconPath : ""
            }
        }
    }

    Component.onCompleted: whoamiProc.running = true
}
