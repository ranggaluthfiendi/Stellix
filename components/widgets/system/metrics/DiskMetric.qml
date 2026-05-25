import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "DISK"
        stateKey: "Disk"
        valueText: sysSvc && sysSvc.diskUsage ? sysSvc.diskUsage : "0%"
    }
}
