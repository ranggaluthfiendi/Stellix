import QtQuick
import qs.services

Item {
    id: root

    BaseMetric {
        metricName: "UPTIME"
        stateKey: "Uptime"
        valueText: sysSvc && sysSvc.uptime ? sysSvc.uptime : "0d 0h"
    }
}
