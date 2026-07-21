import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import "common"
import "common/config"

Variants {
    model: Quickshell.screens.filter(s => Hostname.hostname == "fajita")

    PanelWindow {
        id: bar
        property var modelData
        screen: modelData
        color: "transparent"

        Colors {
            id: colors
        }

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
                Layout.leftMargin: 25

                ApplicationMenuWidget {
                    colors: colors
                }
                MangoTagsWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 5
                Layout.rightMargin: 25

                CommandWidget {
                    colors: colors
                    text: "󰚪"
                    command: ["rotate-screen", "switch", bar.screen.name] // TODO:
                }
                BrightnessWidget {
                    colors: colors
                    device: "ae94000.dsi.0"
                    icon: ""
                    max_brightness: 1023
                    min_brightness: 1
                }
                BatteryWidget {
                    colors: colors
                    query: function (d) {
                        return d.nativePath == "bq27411-0";
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
