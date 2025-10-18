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
                    Workspaces {
                        screen: bar.modelData.name
                    }
                    // TODO: active window
                    // TextObject {
                    //   color: Colors.foreground
                    // }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 5
                    MpdWidget {
                        screen: bar.modelData.name
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
