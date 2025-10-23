import QtQuick
import QtQuick.Layouts
import "./config"

RowLayout {
    spacing: -1 // TODO: this feels wrong for a fix to a tiny gap where you can't click any workspace
    required property string screen
    Repeater {
        id: workspaces
        model: Mango.monitors.find(m => m.name == screen).tags

        Rectangle {
            id: workspace
            required property MangoTag modelData

            color: "transparent"

            width: workspaceText.width + 20
            height: 30

            border.color: modelData.visible ? Colors.accent : "transparent"
            border.width: 2
            radius: 2

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
