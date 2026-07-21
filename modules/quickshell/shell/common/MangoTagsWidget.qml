import QtQuick
import QtQuick.Layouts
import "config"

RowLayout {
    required property var colors
    required property string screen
    property var monitor: Mango.monitors.find(m => m.name == screen)
    spacing: -1 // TODO: this feels wrong for a fix to a tiny gap where you can't click any workspace
    Repeater {
        id: workspaces
        model: monitor.tags.filter(t => t.index <= 5)

        Rectangle {
            id: workspace
            required property MangoTag modelData

            color: "transparent"

            width: workspaceText.width + 20
            height: 30

            border.color: modelData.active ? (monitor.selmon ? colors.accent : colors.foregroundSecondary) : "transparent"
            border.width: 1
            radius: 0

            TextObject {
                id: workspaceText
                Layout.topMargin: 3
                anchors.centerIn: parent

                text: workspace.modelData.index
                color: modelData.urgent ? colors.base08 : modelData.clients != 0 ? colors.accent : colors.foreground
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Mango.select(workspace.modelData.index, screen);
                }
            }
        }
    }
}
