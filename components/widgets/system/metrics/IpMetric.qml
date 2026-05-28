import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "IP"
        stateKey: "Ip"
        valueText: {
            if (!sysSvc) return "N/A"
            return sysSvc.ipAddress
        }
    }
}
