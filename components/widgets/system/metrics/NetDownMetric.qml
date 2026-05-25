import QtQuick
import qs.services
import qs.config

Item {
    id: root

    BaseMetric {
        metricName: BarLayoutState.desktopNetDownLabel || "DOWN"
        stateKey: "NetDown"
        valueText: sysSvc ? sysSvc.netDown : "0 KB/s"
    }
}
