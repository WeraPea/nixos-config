import Quickshell.Hyprland
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "./config"

RowLayout {
    spacing: -1 // TODO: this feels wrong for a fix to a tiny gap where you can't click any workspace
    property string screen
    Repeater {
        id: workspaces
        model: [...Hyprland.workspaces.values].sort((a, b) => {
            return a.id - b.id;
        }).filter(w => w.monitor.name == screen)

        Rectangle {
            id: workspace
            required property HyprlandWorkspace modelData
            property bool active: Hyprland.focusedMonitor?.activeWorkspace.id == modelData.id

            color: "transparent"

            width: workspaceText.width + 20
            height: 30

            border.color: active ? Colors.foreground : "transparent"
            border.width: 2
            radius: 2

            TextObject {
                id: workspaceText
                Layout.topMargin: 3
                anchors.centerIn: parent

                text: workspace.modelData.name
                color: Colors.foreground
                // color: active ? Colors.foreground : Colors.foregroundSecondary
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    Hyprland.dispatch(`workspace ${workspace.modelData.id}`);
                }
            }
        }
    }
}
