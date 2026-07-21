import Quickshell
import QtQuick.Layouts
import "common"
import "common/config"

Variants {
    model: Quickshell.screens.filter(s => !(["fajita", "pinenote"].includes(Hostname.hostname) || s.name.startsWith("HEADLESS-")))

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
                MangoTagsWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
                MangoLayoutWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
                MangoKeymodeWidget {
                    colors: colors
                    screen: bar.modelData.name
                    modeIndex: 1
                }
                MangoKeymodeWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
                MangoClientWidget {
                    colors: colors
                    screen: bar.modelData.name
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 5
                PrusaStatusWidget {
                    colors: colors
                }
                MpdWidget {
                    colors: colors
                    screen: bar.modelData.name
                }
                BatteryWidget {
                    colors: colors
                    query: function (d) {
                        return d.model == "WH-1000XM6";
                    }
                    prefix: "󰂱"
                }
                AudioWidget {
                    colors: colors
                }
                TimeWidget {
                    colors: colors
                    format: "ddd MMM d hh:mm"
                }
                TrayWidget {}
            }
        }
    }
}
