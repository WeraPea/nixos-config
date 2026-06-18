import QtQuick
import Quickshell.Services.UPower
import "config"

TextObject {
    required property var query
    property string icon: "󰁹"
    property string icon_charging: "󰂄"
    property string prefix: ""

    property var device: UPower.devices.values.find(d => query(d))

    property string d_icon: device && (device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.FullyCharged || device.state === UPowerDeviceState.PendingCharge ? icon_charging : icon)

    text: `${prefix}${d_icon}${Math.round(device.percentage * 100)}%`
    color: Colors.foreground
    visible: !!device
}
