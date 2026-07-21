import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import "common"
import "common/config"

Variants {
    model: Quickshell.screens.filter(s => Hostname.hostname == "pinenote" || s.name.startsWith("HEADLESS-"))

    PanelWindow {
        id: bar
        property var modelData
        screen: modelData
        color: "transparent"

        Colors {
            id: colors
            path: `${Quickshell.env("PINENOTE_COLORS_CONFIG")}`
        }

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 30

        Background {
            colors: colors
            screen: bar.screen
        }

        RowLayout {
            anchors.fill: parent
            spacing: 5
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                spacing: 5
                ApplicationMenuWidget {
                    colors: colors
                }
                MangoTagsWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
                MangoLayoutWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 5
                CommandWidget {
                    colors: colors
                    visible: Hostname.hostname == "pinenote"
                    text: "󰚪"
                    command: ["rotate-screen", "auto", bar.screen.name]
                }
                CommandWidget {
                    colors: colors
                    text: ""
                    command: ["busctl", "--user", "call", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "GlobalRefresh"]
                }
                EinkWidget {
                    colors: colors
                }
                CommandWidget {
                    colors: colors
                    visible: Hostname.hostname == "pinenote"
                    text: "󰓶"
                    command: ["sudo", "usb-tablet"]
                }
                BrightnessWidget {
                    colors: colors
                    brightnessctl: "brightnessctl-pinenote"
                    device: "backlight_cool"
                    icon: ""
                    max_brightness: 220
                }
                BrightnessWidget {
                    colors: colors
                    brightnessctl: "brightnessctl-pinenote"
                    device: "backlight_warm"
                    icon: ""
                    max_brightness: 190
                }
                BatteryWidget {
                    colors: colors
                    query: function (d) {
                        return d.nativePath == "ws8100_pen" && d.isPresent;
                    }
                    icon: "   "
                    icon_charging: "   "
                    // icon_charging: "󱐋   "
                }
                BatteryWidget {
                    colors: colors
                    query: function (d) {
                        return d.nativePath == "rk817-battery";
                    }
                }
                TimeWidget {
                    colors: colors
                    format: "hh:mm"
                }
                TrayWidget {}
                CommandWidget {
                    colors: colors
                    text: ""
                    command: ["mmsg", "dispatch", "killclient"]
                }
            }
        }
    }
}
