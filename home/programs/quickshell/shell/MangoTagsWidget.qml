import QtQuick
import QtQuick.Layouts
import "./config"

RowLayout {
    spacing: -1 // TODO: this feels wrong for a fix to a tiny gap where you can't click any workspace
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)
    Repeater {
        id: workspaces
        model: monitor.tags

        Rectangle {
            id: workspace
            required property MangoTag modelData

            color: "transparent"

            width: workspaceText.width + 20
            height: 30

            border.color: modelData.visible ? (monitor.selmon & modelData.selected ? Colors.accent : Colors.foregroundSecondary) : "transparent"
            border.width: 1
            radius: 0

            TextObject {
                id: workspaceText
                Layout.topMargin: 3
                anchors.centerIn: parent

                text: workspace.modelData.index
                color: modelData.clients != 0 ? Colors.accent : Colors.foreground
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    Mango.select(workspace.modelData.index, screen);
                }
            }
        }
    }
}
