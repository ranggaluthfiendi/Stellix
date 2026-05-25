import QtQuick
import qs.services

Item {
    id: root

    BaseMetric {
        metricName: "DISK"
        stateKey: "Disk"
        valueText: sysSvc && sysSvc.diskUsage ? sysSvc.diskUsage : "0%"
    }
}
