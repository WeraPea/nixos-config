import QtQuick
import "config"

TextObject {
    required property var colors
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)

    text: `${monitor.title}`
    color: monitor.selmon ? colors.foreground : colors.foregroundSecondary
    elide: Text.ElideRight
    wrapMode: Text.NoWrap
}
