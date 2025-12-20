import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Widgets
import "config"

Item {
    id: root
    required property string text
    required property var command

    implicitWidth: commandText.implicitWidth + 30
    implicitHeight: 30
    TextObject {
        id: commandText
        anchors.centerIn: parent
        text: root.text
        color: Colors.foreground
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: commandProc.running = true
    }

    Process {
        id: commandProc
        running: false
        command: root.command
    }
}
