import QtQuick
import "./config"

TextObject {
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    text: `${monitor.title}`
    color: Colors.foreground
    elide: Text.ElideRight
    wrapMode: Text.NoWrap
}
