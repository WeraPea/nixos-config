import QtQuick
import Quickshell.Services.UPower
import "./config"

TextObject {
    required property string model

    property var device: UPower.devices.values.find(d => d.model == model)
    // property string icon: device.type

    text: `󰥉${Math.round(device.percentage * 100)}%`
    color: Colors.foreground
    visible: !!device
}
