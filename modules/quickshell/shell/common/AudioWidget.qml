import QtQuick
import Quickshell.Widgets
import "config"

Item {
    required property var colors
    implicitWidth: volumeText.implicitWidth
    implicitHeight: volumeText.primaryLineHeight
    TextObject {
        id: volumeText
        anchors.centerIn: parent
        property int volume: Number(Audio.sink?.audio.volume * 100).toFixed(1)
        property string icon: Audio.sink == null ? "?" : (Audio.sink.audio.muted ? "󰖁" : "󰕾")
        color: Audio.sink?.audio.muted ?? true ? colors.foregroundSecondary : colors.foreground
        text: `${icon} ${volume}%`
    }
    WrapperMouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        anchors.topMargin: -((30 - volumeText.primaryLineHeight) / 2)
        anchors.bottomMargin: -((30 - volumeText.primaryLineHeight) / 2)
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
