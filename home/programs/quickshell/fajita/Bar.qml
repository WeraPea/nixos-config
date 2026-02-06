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
                    Layout.leftMargin: 25

                    ApplicationMenuWidget {}
                    MangoTagsWidget {
                        screen: bar.modelData.name
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 5
                    Layout.rightMargin: 25

                    CommandWidget {
                        text: "󰚪"
                        command: ["rotate-screen", "switch"] // TODO:
                    }
                    BrightnessWidget {
                        device: "ae94000.dsi.0"
                        icon: ""
                        max_brightness: 1023
                        min_brightness: 1
                    }
                    BatteryWidget {
                        query: function (d) {
                            return d.nativePath == "bq27411-0";
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
