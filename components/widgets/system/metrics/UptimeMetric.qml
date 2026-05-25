import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "UPTIME"
        stateKey: "Uptime"
        valueText: sysSvc && sysSvc.uptime ? sysSvc.uptime : "0d 0h"
    }
}
