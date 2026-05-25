import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string fromCurrency: "USD"
    property string toCurrency: "IDR"
    property bool isLoading: false
    property string lastUpdated: ""
    property bool hasData: false

    readonly property var currencies: [
        { code: "USD", name: "United States", symbol: "$" },
        { code: "IDR", name: "Indonesia", symbol: "Rp" },
        { code: "EUR", name: "Eurozone", symbol: "€" },
        { code: "GBP", name: "United Kingdom", symbol: "£" },
        { code: "JPY", name: "Japan", symbol: "¥" },
        { code: "SGD", name: "Singapore", symbol: "S$" },
        { code: "AUD", name: "Australia", symbol: "A$" },
        { code: "CNY", name: "China", symbol: "¥" },
        { code: "KRW", name: "South Korea", symbol: "₩" },
        { code: "MYR", name: "Malaysia", symbol: "RM" },
        { code: "THB", name: "Thailand", symbol: "฿" },
        { code: "INR", name: "India", symbol: "₹" },
        { code: "PHP", name: "Philippines", symbol: "₱" },
        { code: "VND", name: "Vietnam", symbol: "₫" },
        { code: "CHF", name: "Switzerland", symbol: "Fr" },
        { code: "CAD", name: "Canada", symbol: "C$" },
        { code: "HKD", name: "Hong Kong", symbol: "HK$" },
        { code: "NZD", name: "New Zealand", symbol: "NZ$" },
        { code: "SEK", name: "Sweden", symbol: "kr" },
        { code: "NOK", name: "Norway", symbol: "kr" }
    ]

    property var rates: ({})

    StdioCollector { id: fetchCollector }

    Process {
        id: fetchProcess
        stdout: fetchCollector
        stderr: fetchCollector
        onExited: function(exitCode) {
            root.isLoading = false
            if (exitCode === 0) {
                var text = fetchCollector.text.trim()
                if (text.length === 0 || text.indexOf("{") < 0) {
                    root.loadFallback()
                    return
                }
                try {
                    var json = JSON.parse(text)
                    if (json.rates && typeof json.rates === "object") {
                        root.rates = json.rates
                        root.hasData = true
                        var now = new Date()
                        root.lastUpdated = now.getHours().toString().padStart(2, "0") + ":" + now.getMinutes().toString().padStart(2, "0")
                    } else {
                        root.loadFallback()
                    }
                } catch (e) {
                    root.loadFallback()
                }
            } else {
                root.loadFallback()
            }
        }
    }

    function loadFallback() {
        root.rates = {
            "USD": 1.0,
            "IDR": 17713.0,
            "EUR": 0.86,
            "GBP": 0.75,
            "JPY": 159.0,
            "SGD": 1.28,
            "AUD": 1.41,
            "CNY": 7.12,
            "KRW": 1350.0,
            "MYR": 4.22,
            "THB": 33.5,
            "INR": 85.0,
            "PHP": 56.0,
            "VND": 25400.0,
            "CHF": 0.79,
            "CAD": 1.37,
            "HKD": 7.81,
            "NZD": 1.52,
            "SEK": 9.6,
            "NOK": 10.1
        }
        root.hasData = true
    }

    function fetchRates() {
        root.isLoading = true
        fetchProcess.exec(["sh", "-c",
            "curl -s --max-time 8 'https://open.er-api.com/v6/latest/USD'"
        ])
    }

    function convert(from, to, value) {
        if (from === to) return value
        var fromRate = rates[from]
        var toRate = rates[to]
        if (fromRate === undefined || toRate === undefined) return null
        return (value / fromRate) * toRate
    }

    function formatCurrency(value, currencyCode) {
        if (value === null || value === undefined) return "N/A"
        var sym = getSymbol(currencyCode)
        if (value >= 1000) {
            return sym + formatNumber(value.toFixed(2))
        } else if (value >= 1) {
            return sym + value.toFixed(2)
        } else {
            return sym + value.toFixed(4)
        }
    }

    function formatNumber(str) {
        var parts = str.split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        return parts.join(".")
    }

    function getSymbol(code) {
        for (var i = 0; i < currencies.length; i++) {
            if (currencies[i].code === code) return currencies[i].symbol
        }
        return code + " "
    }

    function getName(code) {
        for (var i = 0; i < currencies.length; i++) {
            if (currencies[i].code === code) return currencies[i].name
        }
        return code
    }

    function swapCurrencies() {
        var temp = root.fromCurrency
        root.fromCurrency = root.toCurrency
        root.toCurrency = temp
    }

    function calculate(from, to, value) {
        var num = parseFloat(value)
        if (isNaN(num)) return null
        return convert(from, to, num)
    }

    Component.onCompleted: {
        root.loadFallback()
        root.fetchRates()
    }

    Timer {
        interval: 300000
        running: true
        repeat: true
        onTriggered: root.fetchRates()
    }
}
