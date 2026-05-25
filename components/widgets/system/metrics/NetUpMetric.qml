import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.config

Item {
    id: root

    BaseMetric {
        metricName: BarLayoutState.desktopNetUpLabel || "UP"
        stateKey: "NetUp"
        valueText: sysSvc ? sysSvc.netUp : "0 KB/s"
    }
}
