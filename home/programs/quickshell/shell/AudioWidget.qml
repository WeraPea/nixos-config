import QtQuick
import Quickshell.Widgets
import "./config"

Item {
    implicitWidth: volumeText.implicitWidth
    implicitHeight: volumeText.implicitHeight
    TextObject {
        id: volumeText
        anchors.centerIn: parent
        property int volume: Number(Audio.sink?.audio.volume * 100).toFixed(1)
        property string icon: Audio.sink == null ? "?" : (Audio.sink.audio.muted ? "󰖁" : "󰕾")
        color: Audio.sink.audio.muted ? Colors.foregroundSecondary : Colors.foreground
        text: `${icon} ${volume}%`
    }
    WrapperMouseArea {
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        anchors.topMargin: -((30 - volumeText.implicitHeight) / 2)
        anchors.bottomMargin: -((30 - volumeText.implicitHeight) / 2)

        onPressed: {
            Audio.sink.audio.muted = !Audio.sink.audio.muted;
        }
        onWheel: event => {
            if (event.angleDelta.y > 0) {
                Audio.sink.audio.volume += 0.01;
            } else {
                Audio.sink.audio.volume -= 0.01;
            }
        }
    }
}
