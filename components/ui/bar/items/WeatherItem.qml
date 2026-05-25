import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.widgets.barpopup
import qs.components.elements

Item {
    id: root

    property real s: Scales.uiScale

    implicitWidth: weatherRow.implicitWidth + Theme.dp(16)
    implicitHeight: BarLayoutState.barHeight * s

    readonly property string weatherSection: BarLayoutState.findItemSection("weather")
    readonly property bool isCenterWeather: weatherSection === "center"
    readonly property bool isLeftWeather: weatherSection === "left"
    readonly property bool isRightWeather: weatherSection === "right"
    readonly property real popupW: Theme.dp(372)
    readonly property real screenW: BarLayoutState.barScreenWidth > 0 ? BarLayoutState.barScreenWidth : Screen.width
    readonly property real centerMargin: Math.max(0, (screenW - popupW) / 2)

    readonly property real popupRadius: BarLayoutState.weatherPopupRounded ? Theme.radiusMedium : 0

    WeatherService {
        id: weather
        city: BarLayoutState.desktopWeatherCity !== "" ? BarLayoutState.desktopWeatherCity : BarLayoutState.systemCity
        unit: BarLayoutState.desktopWeatherUnit
    }

    readonly property string weatherIconType: {
        var d = weather.desc.toLowerCase()
        if (d.includes("sun") || d.includes("clear")) return "sunny"
        if (d.includes("thunder") || d.includes("storm")) return "thunder"
        if (d.includes("rain") || d.includes("drizzle")) return "rainy"
        if (d.includes("snow")) return "snowy"
        if (d.includes("fog") || d.includes("mist")) return "foggy"
        if (d.includes("cloud")) return "cloudy"
        return "sunny"
    }

    readonly property color weatherIconColor: {
        var d = weather.desc.toLowerCase()
        if (d.includes("sun") || d.includes("clear")) return "#FDB813"
        if (d.includes("cloud")) return "#B0BEC5"
        if (d.includes("rain") || d.includes("drizzle")) return "#90A4AE"
        if (d.includes("snow")) return "#CFD8DC"
        if (d.includes("thunder")) return "#78909C"
        if (d.includes("fog") || d.includes("mist")) return "#B0BEC5"
        return Theme.accent
    }

    readonly property var activeElements: {
        var result = []
        for (var i = 0; i < BarLayoutState.weatherElements.length; i++) {
            var el = BarLayoutState.weatherElements[i]
            if (BarLayoutState.weatherElementsDisabled.indexOf(el) === -1) {
                result.push(el)
            }
        }
        return result
    }

    RowLayout {
        id: weatherRow
        anchors.left: parent.left
        anchors.leftMargin: Theme.dp(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(6)

        Repeater {
            model: root.activeElements
            delegate: Loader {
                Layout.alignment: Qt.AlignVCenter
                sourceComponent: {
                    switch (modelData) {
                        case "icon": return iconComp
                        case "temp": return tempComp
                        case "desc": return descComp
                        default: return null
                    }
                }
            }
        }
    }

    Component {
        id: iconComp
        Item {
            implicitWidth: Theme.dp(14)
            implicitHeight: Theme.dp(14)
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (weatherIconType === "sunny") return sunnyComp
                    if (weatherIconType === "cloudy") return cloudyComp
                    if (weatherIconType === "rainy") return rainyComp
                    if (weatherIconType === "thunder") return thunderComp
                    if (weatherIconType === "snowy") return snowyComp
                    if (weatherIconType === "foggy") return foggyComp
                    return sunnyComp
                }
            }
        }
    }

    Component {
        id: tempComp
        Text {
            text: weather.temp + weather.unitSymbol
            color: Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Theme.dp(10)
            font.weight: Font.Bold
            verticalAlignment: Text.AlignVCenter
        }
    }

    Component {
        id: descComp
        Text {
            text: weather.desc
            color: Theme.textSecondary
            font.family: Typography.fontFamily
            font.pixelSize: Theme.dp(8.5)
            verticalAlignment: Text.AlignVCenter
        }
    }

    Component { id: sunnyComp; IconSunny { iconColor: root.weatherIconColor } }
    Component { id: cloudyComp; IconCloudy { iconColor: root.weatherIconColor } }
    Component { id: rainyComp; IconRainy { iconColor: root.weatherIconColor } }
    Component { id: thunderComp; IconThunder { iconColor: root.weatherIconColor } }
    Component { id: snowyComp; IconSnowy { iconColor: root.weatherIconColor } }
    Component { id: foggyComp; IconFoggy { iconColor: root.weatherIconColor } }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            if (BarPopupState.weatherDetailOpen) {
                BarPopupState.weatherDetailOpen = false
            } else {
                BarPopupState.closeAll()
                BarPopupState.weatherDetailOpen = true
            }
        }
    }

    Connections {
        target: BarPopupState
        function onOpenChanged() {
            if (BarPopupState.open) BarPopupState.weatherDetailOpen = false
        }
        function onCalendarOpenChanged() {
            if (BarPopupState.calendarOpen) BarPopupState.weatherDetailOpen = false
        }
        function onWorkspaceSwitcherOpenChanged() {
            if (BarPopupState.workspaceSwitcherOpen) BarPopupState.weatherDetailOpen = false
        }
        function onSettingsOpenChanged() {
            if (BarPopupState.settingsOpen) BarPopupState.weatherDetailOpen = false
        }
        function onGuideOpenChanged() {
            if (BarPopupState.guideOpen) BarPopupState.weatherDetailOpen = false
        }
        function onLauncherToggleRequested() {
            BarPopupState.weatherDetailOpen = false
        }
    }

    PanelWindow {
        id: weatherPanel
        visible: BarPopupState.weatherDetailOpen
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: !BarLayoutState.isBottom
            bottom: BarLayoutState.isBottom
            left: true
            right: true
        }

        implicitWidth: root.popupW
        implicitHeight: weatherDetailContent.implicitHeight

        margins.left: root.isCenterWeather ? root.centerMargin : (root.isLeftWeather ? Theme.dp(5) : root.screenW - root.popupW - Theme.dp(5))
        margins.right: root.isCenterWeather ? root.centerMargin : (root.isRightWeather ? Theme.dp(5) : root.screenW - root.popupW - Theme.dp(5))
        margins.top: !BarLayoutState.isBottom ? (BarLayoutState.barHeight * s + Theme.dp(4)) : 0
        margins.bottom: BarLayoutState.isBottom ? (BarLayoutState.barHeight * s + Theme.dp(4)) : 0

        Rectangle {
            id: weatherBg
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: root.popupRadius

            property real animOpacity: 0
            opacity: animOpacity

            states: State {
                name: "visible"
                when: weatherPanel.visible
                PropertyChanges { target: weatherBg; animOpacity: 1 }
            }

            transitions: [
                Transition {
                    from: ""
                    to: "visible"
                    NumberAnimation { target: weatherBg; property: "animOpacity"; duration: 180; easing.type: Easing.OutCubic }
                },
                Transition {
                    from: "visible"
                    to: ""
                    NumberAnimation { target: weatherBg; property: "animOpacity"; duration: 140; easing.type: Easing.InCubic }
                }
            ]

            ColumnLayout {
                id: weatherDetailContent
                anchors.fill: parent
                anchors.margins: Theme.dp(16)
                spacing: Theme.dp(14)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(6)

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(2)

                        Text {
                            text: weather.location.toUpperCase()
                            color: Theme.accent
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(12 * s)
                            font.weight: Font.Bold
                        }

                        Text {
                            text: weather.desc
                            color: Theme.textSecondary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(9 * s)
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: Theme.dp(4)
                        Layout.alignment: Qt.AlignRight

                        Rectangle {
                            width: Theme.dp(28)
                            height: Theme.dp(28)
                            color: rightbarMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                            radius: root.popupRadius > 0 ? Theme.radiusSmall : 0

                            IconGrip {
                                anchors.centerIn: parent
                                width: Theme.dp(14)
                                height: Theme.dp(14)
                                color: rightbarMouse.containsMouse ? Theme.accent : Theme.textMuted
                            }

                            MouseArea {
                                id: rightbarMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    BarPopupState.closeAll()
                                    BarPopupState.open = true
                                }
                            }
                        }

                        Rectangle {
                            width: Theme.dp(28)
                            height: Theme.dp(28)
                            color: notifMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                            radius: root.popupRadius > 0 ? Theme.radiusSmall : 0

                            IconBell {
                                anchors.centerIn: parent
                                iconColor: notifMouse.containsMouse ? Theme.accent : Theme.textMuted
                                iconSize: Theme.dp(12)
                            }

                            MouseArea {
                                id: notifMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    BarPopupState.closeAll()
                                    BarPopupState.notifPanelRequested = true
                                }
                            }
                        }

                        Rectangle {
                            width: Theme.dp(28)
                            height: Theme.dp(28)
                            color: closeMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1) : "transparent"
                            radius: root.popupRadius > 0 ? Theme.radiusSmall : 0

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: closeMouse.containsMouse ? Theme.danger : Theme.textMuted
                                font.pixelSize: Theme.dp(10)
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: BarPopupState.weatherDetailOpen = false
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.border
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(16)
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(72)
                        Layout.preferredHeight: Theme.dp(72)
                        Layout.alignment: Qt.AlignHCenter
                        radius: Theme.dp(12)
                        color: Qt.rgba(root.weatherIconColor.r, root.weatherIconColor.g, root.weatherIconColor.b, 0.15)
                        border.width: 1
                        border.color: Qt.rgba(root.weatherIconColor.r, root.weatherIconColor.g, root.weatherIconColor.b, 0.3)

                        Loader {
                            anchors.centerIn: parent
                            width: Theme.dp(40)
                            height: Theme.dp(40)
                            sourceComponent: {
                                if (weatherIconType === "sunny") return bigSunnyComp
                                if (weatherIconType === "cloudy") return bigCloudyComp
                                if (weatherIconType === "rainy") return bigRainyComp
                                if (weatherIconType === "thunder") return bigThunderComp
                                if (weatherIconType === "snowy") return bigSnowyComp
                                if (weatherIconType === "foggy") return bigFoggyComp
                                return bigSunnyComp
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(2)

                        Text {
                            text: weather.temp + weather.unitSymbol
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(52 * s)
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "Feels like " + weather.temp + weather.unitSymbol
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(10 * s)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.border
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: Theme.dp(8)
                    rowSpacing: Theme.dp(8)

                    WeatherDetailCard { icon: "💧"; label: "Humidity"; value: "72%"; desc: "Moisture in the air" }
                    WeatherDetailCard { icon: "💨"; label: "Wind"; value: "12 km/h"; desc: "Air speed & direction" }
                    WeatherDetailCard { icon: "☀️"; label: "UV Index"; value: "5"; desc: "UV radiation level" }
                    WeatherDetailCard { icon: "🌡️"; label: "Pressure"; value: "1013 hPa"; desc: "Atmospheric pressure" }
                    WeatherDetailCard { icon: "👁️"; label: "Visibility"; value: "10 km"; desc: "Clear sight distance" }
                    WeatherDetailCard { icon: "🌅"; label: "Sunrise"; value: "05:42"; desc: "Sun appears today" }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.border
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(8)

                    Rectangle {
                        width: Theme.dp(28)
                        height: Theme.dp(28)
                        color: refreshMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                        radius: root.popupRadius > 0 ? Theme.radiusSmall : 0

                        Text {
                            anchors.centerIn: parent
                            text: "↻"
                            color: refreshMouse.containsMouse ? Theme.accent : Theme.textMuted
                            font.pixelSize: Theme.dp(12)
                        }

                        MouseArea {
                            id: refreshMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: weather.refresh()
                        }
                    }

                    Text {
                        text: "Refresh"
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "City: " + weather.city
                        color: Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(8 * s)
                    }
                }
            }
        }
    }

    Component { id: bigSunnyComp; IconSunny { iconColor: root.weatherIconColor } }
    Component { id: bigCloudyComp; IconCloudy { iconColor: root.weatherIconColor } }
    Component { id: bigRainyComp; IconRainy { iconColor: root.weatherIconColor } }
    Component { id: bigThunderComp; IconThunder { iconColor: root.weatherIconColor } }
    Component { id: bigSnowyComp; IconSnowy { iconColor: root.weatherIconColor } }
    Component { id: bigFoggyComp; IconFoggy { iconColor: root.weatherIconColor } }

    component WeatherDetailCard: Rectangle {
        id: detailCard
        property string icon: ""
        property string label: ""
        property string value: ""
        property string desc: ""

        Layout.fillWidth: true
        Layout.preferredHeight: Theme.dp(60)
        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.04)
        border.width: 1
        border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
        radius: root.popupRadius > 0 ? Theme.radiusSmall : 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(2)

            RowLayout {
                spacing: Theme.dp(4)
                Text {
                    text: detailCard.icon
                    font.pixelSize: Theme.dp(12)
                }
                Text {
                    text: detailCard.label
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }
            }

            Text {
                text: detailCard.value
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(12 * s)
                font.weight: Font.Bold
            }

            Text {
                text: detailCard.desc
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(7 * s)
                font.italic: true
            }
        }
    }
}
