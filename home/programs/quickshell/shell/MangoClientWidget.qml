import QtQuick
import "./config"

TextObject {
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    text: `${monitor.title}`
    color: monitor.selmon ? Colors.foreground : Colors.foregroundSecondary
    elide: Text.ElideRight
    wrapMode: Text.NoWrap
}
