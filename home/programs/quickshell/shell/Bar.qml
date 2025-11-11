import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import "./config"

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
                    MangoTagsWidget {
                        screen: bar.modelData.name
                    }
                    MangoLayoutWidget {
                        screen: bar.modelData.name
                    }
                    MangoClientWidget {
                        screen: bar.modelData.name
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 5
                    MpdWidget {
                        screen: bar.modelData.name
                    }
                    BatteryWidget {
                        model: "WH-1000XM6"
                    }
                    AudioWidget {}
                    TextObject {
                        // TODO: calendar on hover
                        color: Colors.foreground
                        text: Time.time
                    }
                }
            }
        }
    }
}
