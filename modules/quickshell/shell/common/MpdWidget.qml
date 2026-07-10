import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "config"

WrapperMouseArea {
    id: mouseArea
    property string screen
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    visible: Mpd.mpcAvailable
    property real volAcc: 0

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
            Mpd.command("toggle");
        } else if (mouse.button == Qt.RightButton) {
            Mango.dispatch("spawn,cantata");
        }
    }
    onWheel: event => {
        volAcc += Math.max(Math.min(event.angleDelta.y / 120, 1), -1);
    }
    onVolAccChanged: {
        if (Math.abs(volAcc) >= 1) {
            Mpd.volumePercent += Math.round(volAcc);
            volAcc -= Math.round(volAcc);
        }
    }
    HoverHandler {
        id: hover
    }
    Window {
        id: tooltipWindow
        visible: hover.hovered
        onVisibleChanged: Mpd.continous = visible
        flags: Qt.ToolTip | Qt.FramelessWindowHint
        width: columnLayout.width + 12
        height: columnLayout.height + 8
        x: hover.point.scenePosition.x + (mouseArea.Window.window ? mouseArea.Window.window.x : 0) - width
        y: hover.point.scenePosition.y + (mouseArea.Window.window ? mouseArea.Window.window.y : 0) + 20
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Colors.background
            radius: 0
            border.color: Colors.accent
            border.width: 1

            ColumnLayout {
                id: columnLayout
                anchors.centerIn: parent
                TextObject {
                    id: tooltipText
                    color: Colors.foreground
                    text: `${Mpd.artist} - ${Mpd.title}`
                }
                TextObject {
                    id: tooltipText2
                    color: Colors.foreground
                    text: `${Mpd.currentTime}/${Mpd.totalTime} (${Mpd.progressPercent}%) - ${Mpd.realVolumePercent}%`
                }
            }
        }
    }
}
