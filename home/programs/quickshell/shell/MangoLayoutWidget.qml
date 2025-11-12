import QtQuick
import "./config"

TextObject {
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    text: `[${monitor.layout}]`
    property var layoutColors: function (layout) {
        return {
            "M": Colors.base0A,
            "T": Colors.base0E,
            "VT": Colors.base0E,
            "RT": Colors.base0E,
            "G": Colors.base0D,
            "VG": Colors.base0D
        }[layout] || Colors.foreground;
    }

    color: layoutColors(monitor.layout)
}
