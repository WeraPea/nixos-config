import QtQuick
import "./config"

TextObject {
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    property var layoutColors: ({
            "M": Colors.base0A,
            "T": Colors.base0E,
            "VT": Colors.base0E,
            "RT": Colors.base0E,
            "G": Colors.base0D,
            "VG": Colors.base0D
        })

    text: `[${monitor.layout}]`
    color: layoutColors[monitor.layout] || Colors.foreground
}
