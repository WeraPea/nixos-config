import QtQuick
import "config"

TextObject {
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)
    visible: monitor.keymode !== "default"

    text: `[${mapKeymode(monitor.keymode)}]`
    property var mapKeymode: function (keymode) {
        return {
            "default": "D",
            "clipboard": "O",
            "primary": "P",
            "kill": "K",
            "leader": "L",
            "mpd": "M",
            "run": "R",
            "qocr": "Q",
            "qocre": "QE",
            "qocrc": "QE",
        }[keymode] || keymode;
    }
    property var keymodeColors: function (keymode) {
        return {
            "default": Colors.base0D,
            "clipboard": Colors.base0E,
            "primary": Colors.base0D,
            "kill": Colors.base08,
            "leader": Colors.base09,
            "mpd": Colors.base0A,
            "run": Colors.base0B,
            "qocr": Colors.base0A,
            "qocre": Colors.base0A,
            "qocrc": Colors.base0A,
        }[keymode] || Colors.foreground;
    }

    color: keymodeColors(monitor.keymode)
}
