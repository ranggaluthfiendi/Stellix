import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "RAM"
        stateKey: "Mem"
        valueText: sysSvc ? (Math.round(sysSvc.memUsed / 1024) + " GB") : "0 GB"
    }
}
