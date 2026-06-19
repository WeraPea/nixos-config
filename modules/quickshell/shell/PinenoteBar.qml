import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import "common"

Variants {
    model: Quickshell.screens.filter(s => Hostname.hostname == "pinenote" || s.name.startsWith("HEADLESS-"))

    PanelWindow {
        id: bar
        property var modelData
        screen: modelData
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 30

        RowLayout {
            anchors.fill: parent
            spacing: 5
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                spacing: 5
                ApplicationMenuWidget {}
                MangoTagsWidget {
                    screen: bar.modelData.name
                }
                MangoLayoutWidget {
                    screen: bar.modelData.name
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 5
                CommandWidget {
                    visible: Hostname.hostname == "pinenote"
                    text: "󰚪"
                    command: ["rotate-screen", "auto", bar.screen.name]
                }
                CommandWidget {
                    text: ""
                    command: ["busctl", "--user", "call", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "GlobalRefresh"]
                }
                EinkWidget {}
                CommandWidget {
                    visible: Hostname.hostname == "pinenote"
                    text: "󰓶"
                    command: ["sudo", "usb-tablet"]
                }
                BrightnessWidget {
                    brightnessctl: "brightnessctl-pinenote"
                    device: "backlight_cool"
                    icon: ""
                    max_brightness: 220
                }
                BrightnessWidget {
                    brightnessctl: "brightnessctl-pinenote"
                    device: "backlight_warm"
                    icon: ""
                    max_brightness: 190
                }
                BatteryWidget {
                    query: function (d) {
                        return d.nativePath == "ws8100_pen" && d.isPresent;
                    }
                    icon: "   "
                    icon_charging: "   "
                    // icon_charging: "󱐋   "
                }
                BatteryWidget {
                    query: function (d) {
                        return d.nativePath == "rk817-battery";
                    }
                }
                TimeWidget {
                    format: "hh:mm"
                }
                TrayWidget {}
                CommandWidget {
                    text: ""
                    command: ["mmsg", "dispatch", "killclient"]
                }
            }
        }
    }
}
