import QtQuick
import "config"

TextObject {
    required property var colors
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
            "default": colors.base0D,
            "clipboard": colors.base0E,
            "primary": colors.base0D,
            "kill": colors.base08,
            "leader": colors.base09,
            "mpd": colors.base0A,
            "run": colors.base0B,
            "qocr": colors.base0A,
            "qocre": colors.base0A,
            "qocrc": colors.base0A,
            "qocrt": colors.base0A,
            "qocra": colors.base0A
        }[keymode] || colors.foreground;
    }

    text: `[${mapKeymode(keymode)}]`
    color: keymodeColors(keymode)
}
