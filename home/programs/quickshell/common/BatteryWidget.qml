import QtQuick
import Quickshell.Services.UPower
import "config"

TextObject {
    required property var query

    property var device: UPower.devices.values.find(d => query(d))

    text: `󰥉${Math.round(device.percentage * 100)}%`
    color: Colors.foreground
    visible: !!device
}
