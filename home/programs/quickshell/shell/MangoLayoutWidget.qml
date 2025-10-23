import QtQuick
import "./config"

TextObject {
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    text: `[${monitor.layout}]`
    color: Colors.foreground
}
