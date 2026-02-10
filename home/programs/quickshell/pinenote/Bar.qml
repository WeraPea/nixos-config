import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import "common"

Scope {
    Variants {
        model: Quickshell.screens

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
                        text: "󰚪"
                        command: ["rotate-screen", "switch", bar.screen.name] // TODO:
                    }
                    CommandWidget {
                        text: ""
                        command: ["dbus-send", "--dest=org.pinenote.PineNoteCtl", "--type=method_call", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1.GlobalRefresh"]
                    }
                    CommandWidget {
                        text: "󰓶"
                        command: ["sudo", "usb-tablet"]
                    }
                    BrightnessWidget {
                        device: "backlight_cool"
                        icon: ""
                        max_brightness: 220
                    }
                    BrightnessWidget {
                        device: "backlight_warm"
                        icon: ""
                        max_brightness: 190
                    }
                    BatteryWidget {
                        query: function (d) {
                            return d.nativePath == "ws8100_pen";
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
                        command: ["mmsg", "-d", "killclient"]
                    }
                }
            }
        }
    }
}
