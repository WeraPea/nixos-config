import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

PopupWindow {
    id: root
    property alias margin: background.margin
    property alias backgroundColor: background.color
    property alias border: background.border
    required property Component content

    color: "transparent"

    implicitWidth: background.width
    implicitHeight: background.height

    WrapperRectangle {
        id: background

        Loader {
            active: root.visible
            sourceComponent: root.content
        }
    }

    PanelWindow {
        id: backgroundWindow
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: root.visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.visible = false;
            }
        }
    }
}
