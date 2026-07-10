import QtQuick
import Quickshell.Widgets
import Quickshell.Hyprland
import "config"

Item {
    implicitWidth: volumeText.implicitWidth
    implicitHeight: volumeText.implicitHeight
    FontMetrics {
        id: fm
        font: volumeText.font
    }
    TextObject {
        id: volumeText
        anchors.centerIn: parent
        height: fm.height
        property int volume: Number(Audio.sink?.audio.volume * 100).toFixed(1)
        property string icon: Audio.sink == null ? "?" : (Audio.sink.audio.muted ? "󰖁" : "󰕾")
        color: Audio.sink.audio.muted ? Colors.foregroundSecondary : Colors.foreground
        text: `${icon} ${volume}%`
    }
    WrapperMouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        anchors.topMargin: -((30 - volumeText.implicitHeight) / 2)
        anchors.bottomMargin: -((30 - volumeText.implicitHeight) / 2)
        property real volAcc: 0

        onPressed: function (mouse) {
            if (mouse.button == Qt.LeftButton) {
                Audio.sink.audio.muted = !Audio.sink.audio.muted;
            } else if (mouse.button == Qt.RightButton) {
                Mango.dispatch("spawn,pwvucontrol");
            }
        }
        onWheel: event => {
            volAcc += Math.max(Math.min(event.angleDelta.y / 120, 1), -1);
        }
        onVolAccChanged: {
            if (Math.abs(volAcc) >= 1) {
                Audio.sink.audio.volume += Math.round(volAcc) / 100;
                volAcc -= Math.round(volAcc);
            }
        }
    }
}
