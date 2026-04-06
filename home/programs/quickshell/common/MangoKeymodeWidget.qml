import QtQuick
import "config"

TextObject {
    required property string screen
    property int modeIndex: 0
    property var monitor: Mango.monitors.find(m => m.name == screen)
    visible: keymode !== "default"

    property string keymode: {
        var parts = monitor.keymode.split("-");
        if (parts.length <= modeIndex)
            return "default";
        else
            return parts[parts.length - 1 - modeIndex];
    }

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
            "qocrc": "QC",
            "qocrt": "QT",
            "qocra": "QA"
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
            "qocrt": Colors.base0A,
            "qocra": Colors.base0A
        }[keymode] || Colors.foreground;
    }

    text: `[${mapKeymode(keymode)}]`
    color: keymodeColors(keymode)
}
