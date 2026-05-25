import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.config

Item {
    id: root

    BaseMetric {
        metricName: BarLayoutState.desktopNetDownLabel || "DOWN"
        stateKey: "NetDown"
        valueText: sysSvc ? sysSvc.netDown : "0 KB/s"
    }
}
