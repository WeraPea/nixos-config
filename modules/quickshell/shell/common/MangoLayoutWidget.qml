import QtQuick
import "config"

TextObject {
    required property var colors
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    text: `[${monitor.layout}]`
    property var layoutColors: function (layout) {
        return {
            "M": colors.base0A,
            "T": colors.base0E,
            "VT": colors.base0E,
            "RT": colors.base0E,
            "G": colors.base0D,
            "VG": colors.base0D,
            "F": colors.base0D,
            "VF": colors.base0D,
            "DW": colors.base0D
        }[layout] || colors.foreground;
    }

    color: layoutColors(monitor.layout)
}
