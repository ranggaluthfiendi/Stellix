import QtQuick
import qs.services

Item {
    id: root

    BaseMetric {
        metricName: "GPU"
        stateKey: "Gpu"
        valueText: {
            if (!sysSvc || sysSvc.gpus.length === 0) return "N/A"
            for (var i = 0; i < sysSvc.gpus.length; i++) {
                if (sysSvc.gpus[i].includes("%")) return sysSvc.gpus[i]
            }
            var first = sysSvc.gpus[0].trim()
            if (first.endsWith(")")) first = first.substring(0, first.length - 1)
            var parts = first.split(' ')
            return parts[parts.length - 1]
        }
    }
}
