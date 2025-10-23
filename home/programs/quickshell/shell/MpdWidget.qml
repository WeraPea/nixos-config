import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "./config"

WrapperMouseArea {
    id: mouseArea
    property string screen
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    TextObject {
        id: mpdText
        color: Mpd.playing ? Colors.foreground : Colors.foregroundSecondary
        function truncate(str, limit) {
            if (str.length <= limit)
                return str;
            return str.slice(0, limit) + "…";
        }

        text: `${truncate(Mpd.artist, (mouseArea.screen == "DP-2" ? 40 : 20))} - ${truncate(Mpd.title, (mouseArea.screen == "DP-2" ? 90 : (mouseArea.screen == "HDMI-A-1" ? 20 : 40)))}` // TODO: make this info .config/
    }
    onPressed: function (mouse) {
        if (mouse.button == Qt.LeftButton) {
            Mpd.toggle();
        } else if (mouse.button == Qt.RightButton) {
            Mango.dispatch("spawn,cantata");
        }
    }
    onWheel: event => {
        if (event.angleDelta.y > 0) {
            Mpd.volumePercent += 1;
        } else {
            Mpd.volumePercent -= 1;
        }
    }
    HoverHandler {
        id: hover
    }
    Window {
        id: tooltipWindow
        visible: hover.hovered
        flags: Qt.ToolTip | Qt.FramelessWindowHint
        width: tooltipText.width + 12
        height: tooltipText.height + 8
        x: hover.point.scenePosition.x + (mouseArea.Window.window ? mouseArea.Window.window.x : 0)
        y: hover.point.scenePosition.y + (mouseArea.Window.window ? mouseArea.Window.window.y : 0) + 20
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Colors.background
            radius: 4

            TextObject {
                id: tooltipText
                color: Colors.foreground
                anchors.centerIn: parent
                text: `${Mpd.artist} - ${Mpd.title} - ${Mpd.realVolumePercent}%` // TODO: add time preview
            }
        }
    }
}
