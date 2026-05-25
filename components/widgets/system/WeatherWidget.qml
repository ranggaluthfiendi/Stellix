import qs.components.utils
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.elements

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopWeatherScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    WeatherService {
        id: weather
        city: BarLayoutState.desktopWeatherCity !== "" ? BarLayoutState.desktopWeatherCity : BarLayoutState.systemCity
        unit: BarLayoutState.desktopWeatherUnit
    }

    Connections {
        target: BarLayoutState
        function onDesktopWeatherCityChanged() { weather.refresh() }
        function onDesktopWeatherUnitChanged() { weather.refresh() }
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

    Item {
        id: container
        width: weatherLayoutContent.item ? weatherLayoutContent.item.implicitWidth + 20 * s : 200 * s
        height: weatherLayoutContent.item ? weatherLayoutContent.item.implicitHeight + 20 * s : 100 * s

        x: BarLayoutState.desktopWeatherX
        y: BarLayoutState.desktopWeatherY
        rotation: BarLayoutState.desktopWeatherRotation

        opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopWeatherOpacity

        Loader {
            id: weatherLayoutContent
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10 * s
            
            sourceComponent: {
                switch (BarLayoutState.desktopWeatherLayout) {
                    case "compact": return compactLayout;
                    case "inline": return inlineLayout;
                    case "vertical": return verticalLayout;
                    case "minimal": return minimalLayout;
                    default: return defaultLayout;
                }
            }
        }

        Component {
            id: defaultLayout
            RowLayout {
                spacing: 16 * s
                Loader { sourceComponent: weatherIconComp; Layout.alignment: Qt.AlignVCenter }
                ColumnLayout {
                    spacing: 2 * s
                    Layout.alignment: Qt.AlignVCenter
                    Text { text: weather.temp + weather.unitSymbol; color: Theme.textPrimary; font.pixelSize: 28 * s; font.weight: Font.Bold }
                    Text { text: weather.desc; color: Theme.textSecondary; font.pixelSize: 11 * s }
                    Text { 
                        text: weather.location.toUpperCase()
                        color: Theme.accent
                        font.pixelSize: 10 * s
                        font.weight: Font.Bold
                        opacity: 0.8
                    }
                }
            }
        }

        Component {
            id: compactLayout
            RowLayout {
                spacing: 10 * s
                Loader { sourceComponent: weatherIconComp; Layout.preferredWidth: 24 * s; Layout.preferredHeight: 24 * s }
                ColumnLayout {
                    spacing: 0
                    Text { text: weather.temp + weather.unitSymbol; color: Theme.textPrimary; font.pixelSize: 22 * s; font.weight: Font.Bold }
                    Text { text: weather.desc; color: Theme.textSecondary; font.pixelSize: 9 * s }
                }
            }
        }

        Component {
            id: inlineLayout
            RowLayout {
                spacing: 12 * s
                Loader { sourceComponent: weatherIconComp; Layout.preferredWidth: 28 * s; Layout.preferredHeight: 28 * s }
                Text { text: weather.temp + weather.unitSymbol; color: Theme.textPrimary; font.pixelSize: 20 * s; font.weight: Font.Bold }
                Text { text: weather.desc; color: Theme.textSecondary; font.pixelSize: 10 * s }
                Text { text: "|"; color: Theme.border; opacity: 0.5 }
                Text { text: weather.location.toUpperCase(); color: Theme.accent; font.pixelSize: 10 * s; font.weight: Font.Bold }
            }
        }

        Component {
            id: verticalLayout
            ColumnLayout {
                spacing: 4 * s
                Loader { sourceComponent: weatherIconComp; Layout.alignment: Qt.AlignHCenter }
                Text { text: weather.temp + weather.unitSymbol; color: Theme.textPrimary; font.pixelSize: 32 * s; font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
                Text { text: weather.desc; color: Theme.textSecondary; font.pixelSize: 10 * s; Layout.alignment: Qt.AlignHCenter }
                Text { text: weather.location.toUpperCase(); color: Theme.accent; font.pixelSize: 9 * s; font.weight: Font.Bold; opacity: 0.8; Layout.alignment: Qt.AlignHCenter }
            }
        }

        Component {
            id: minimalLayout
            Text {
                text: weather.temp + weather.unitSymbol
                color: Theme.textPrimary
                font.pixelSize: 36 * s
                font.weight: Font.Black
            }
        }

        Component {
            id: weatherIconComp
            Item {
                implicitWidth: 48 * s
                implicitHeight: 48 * s

                Loader {
                    anchors.centerIn: parent
                    width: 36 * s
                    height: 36 * s
                    sourceComponent: {
                        if (root.weatherIconType === "sunny") return sunnyBig
                        if (root.weatherIconType === "cloudy") return cloudyBig
                        if (root.weatherIconType === "rainy") return rainyBig
                        if (root.weatherIconType === "thunder") return thunderBig
                        if (root.weatherIconType === "snowy") return snowyBig
                        if (root.weatherIconType === "foggy") return foggyBig
                        return sunnyBig
                    }
                }
            }
        }

        Component { id: sunnyBig; IconSunny { iconColor: root.weatherIconColor } }
        Component { id: cloudyBig; IconCloudy { iconColor: root.weatherIconColor } }
        Component { id: rainyBig; IconRainy { iconColor: root.weatherIconColor } }
        Component { id: thunderBig; IconThunder { iconColor: root.weatherIconColor } }
        Component { id: snowyBig; IconSnowy { iconColor: root.weatherIconColor } }
        Component { id: foggyBig; IconFoggy { iconColor: root.weatherIconColor } }

        Draggable {
            id: drag
            anchors.fill: parent
            target: container
            boundWidth: root.screenW
            boundHeight: root.screenH
            defaultX: screenW - (weatherLayoutContent.implicitWidth + 20 * s) - 40 * Scales.uiScale
            defaultY: 40 * Scales.uiScale
            currentX: BarLayoutState.desktopWeatherX
            currentY: BarLayoutState.desktopWeatherY
            onDragPositionChanged: (x, y) => {
                BarLayoutState.desktopWeatherX = x
                BarLayoutState.desktopWeatherY = y
            }
            onRotateAction: (r) => {
                BarLayoutState.desktopWeatherRotation = r
            }
        }
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: weather.refresh()
        }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopWeatherDrag", drag)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopWeatherDrag")
    }
}
