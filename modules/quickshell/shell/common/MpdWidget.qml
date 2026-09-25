import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "config"

Rectangle {
    id: root
    required property var colors
    required property string screen
    visible: Mpd.mpcAvailable
    property real volAcc: 0
    property bool tooltipForced: Mpd.ipcVisibilityState

    implicitHeight: 30
    implicitWidth: mpdText.implicitWidth
    color: colors.background

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
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
    }
    onVolAccChanged: {
        if (Math.abs(volAcc) >= 1) {
            Mpd.volumePercent += Math.round(volAcc);
            volAcc -= Math.round(volAcc);
        }
    }

    TextObject {
        id: mpdText
        anchors.centerIn: parent
        color: Mpd.playing ? colors.foreground : colors.foregroundSecondary
        function truncate(str, limit) {
            if (str.length <= limit)
                return str;
            return str.slice(0, limit) + "…";
        }

        text: `${truncate(Mpd.artist, (root.screen == "DP-2" ? 40 : 20))} - ${truncate(Mpd.title, (root.screen == "DP-2" ? 90 : (root.screen == "HDMI-A-1" ? 20 : 40)))}` // TODO: make this info .config/
    }

    function updateTooltipPosition() {
        const pos = root.mapToGlobal(0, root.height);
        tooltipWindow.x = pos.x;
        tooltipWindow.y = pos.y;
    }
    onTooltipForcedChanged: if (tooltipForced)
        updateTooltipPosition()
    onWidthChanged: if (tooltipForced)
        Qt.callLater(updateTooltipPosition)
    HoverHandler {
        id: hover
        onPointChanged: if (!tooltipForced) {
            tooltipWindow.x = point.scenePosition.x + (root.Window.window ? root.Window.window.x : 0) - tooltipWindow.width;
            tooltipWindow.y = point.scenePosition.y + (root.Window.window ? root.Window.window.y : 0) + 20;
        }
    }
    Window {
        id: tooltipWindow
        visible: tooltipForced || hover.hovered
        onVisibleChanged: Mpd.continous = visible
        flags: Qt.ToolTip | Qt.FramelessWindowHint
        width: columnLayout.width + 12
        height: columnLayout.height + 8
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: colors.background
            radius: 0
            border.color: colors.accent
            border.width: 1

            ColumnLayout {
                id: columnLayout
                anchors.centerIn: parent
                TextObject {
                    id: tooltipText
                    color: colors.foreground
                    text: `${Mpd.artist} - ${Mpd.title}`
                }
                TextObject {
                    id: tooltipText2
                    color: colors.foreground
                    text: `${Mpd.currentTime}/${Mpd.totalTime} (${Mpd.progressPercent}%) - ${Mpd.realVolumePercent}%`
                }
            }
        }
    }
}
