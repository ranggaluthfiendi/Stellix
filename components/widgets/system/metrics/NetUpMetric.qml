import QtQuick
import qs.services
import qs.config

Item {
    id: root

    BaseMetric {
        metricName: BarLayoutState.desktopNetUpLabel || "UP"
        stateKey: "NetUp"
        valueText: sysSvc ? sysSvc.netUp : "0 KB/s"
    }
}
