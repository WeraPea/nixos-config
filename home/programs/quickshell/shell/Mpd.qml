pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    Process {
        id: queryProc
        running: true
        command: ["mpc", "status", "--format", "%title%\n%artist%\n%album%"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split('\n');

                if (lines.length >= 5) {
                    // Title
                    // Artist
                    // Album
                    // [<paused/playing>]  #677/1475   1:22/3:29 (39%)
                    // volume: 25%   repeat: on    random: on    single: off   consume: off

                    root.title = lines[0];
                    root.artist = lines[1];
                    root.album = lines[2];

                    // [<paused/playing>]  #677/1475   1:22/3:29 (39%)
                    var statusLine = lines[3];

                    root.playing = !statusLine.includes("[paused]");

                    var trackMatch = statusLine.match(/#(\d+)\/(\d+)\s+(\d+:\d+)\/(\d+:\d+)\s+\((\d+)%\)/);
                    if (trackMatch) {
                        root.currentTrack = parseInt(trackMatch[1]);
                        root.totalTracks = parseInt(trackMatch[2]);
                        root.currentTime = trackMatch[3];
                        root.totalTime = trackMatch[4];
                        root.progressPercent = parseInt(trackMatch[5]);
                    } else {
                        root.currentTrack = 0;
                        root.totalTracks = 0;
                        root.currentTime = "";
                        root.totalTime = "";
                        root.progressPercent = 0;
                    }

                    // volume: 25%   repeat: on    random: on    single: off   consume: off
                    var modesLine = lines[4];

                    var volMatch = modesLine.match(/volume:\s*(\d+)%/);
                    root.realVolumePercent = volMatch ? parseInt(volMatch[1]) : 0;
                    root.volumePercent = root.realVolumePercent;
                    root.repeat = modesLine.includes("repeat: on");
                    root.random = modesLine.includes("random: on");
                    root.single = modesLine.includes("single: on");
                    root.consume = modesLine.includes("consume: on");
                } else if (lines.length === 1 && lines[0].startsWith("volume:")) {
                    // volume: 25%   repeat: on    random: on    single: off   consume: off
                    // When nothing in playlist
                    root.title = "";
                    root.artist = "";
                    root.album = "";
                    root.playing = false;
                    root.currentTrack = 0;
                    root.totalTracks = 0;
                    root.currentTime = "";
                    root.totalTime = "";
                    root.progressPercent = 0;

                    var modesLine = lines[0];

                    var volMatch = modesLine.match(/volume:\s*(\d+)%/);
                    root.realVolumePercent = volMatch ? parseInt(volMatch[1]) : 0;
                    root.volumePercent = root.realVolumePercent;
                    root.repeat = modesLine.includes("repeat: on");
                    root.random = modesLine.includes("random: on");
                    root.single = modesLine.includes("single: on");
                    root.consume = modesLine.includes("consume: on");
                } else {
                    // MPD error: Connection refused (stderr)
                    // when MPD not active
                    root.title = "";
                    root.artist = "";
                    root.album = "";
                    root.playing = false;
                    root.currentTrack = 0;
                    root.totalTracks = 0;
                    root.currentTime = "";
                    root.totalTime = "";
                    root.progressPercent = 0;
                    root.realVolumePercent = 0;
                    root.volumePercent = 0;
                    root.repeat = false;
                    root.random = false;
                    root.single = false;
                    root.consume = false;
                }
            }
        }
    }

    Process {
        id: idleProc
        running: true
        command: ["mpc", "idle"]
        onRunningChanged: if (!running && !idleDisconnectedTimer.running)
            running = true
        stdout: StdioCollector {
            onStreamFinished: queryProc.running = true
        }
        stderr: StdioCollector {
            onStreamFinished: if (this.text != "")
                idleDisconnectedTimer.running = true
        }
    }
    Process {
        id: idleDisconnectedProc
        command: ["mpc", "-q"]
        stderr: StdioCollector {
            onStreamFinished: if (this.text != "") {
                idleDisconnectedTimer.running = true;
            } else {
                idleProc.running = true;
                queryProc.running = true;
            }
        }
    }
    Timer {
        id: idleDisconnectedTimer
        interval: 1000
        onTriggered: idleDisconnectedProc.running = true
    }
    Process {
        id: toggleProc
        command: ["mpc", "toggle"]
    }
    function toggle() {
        toggleProc.running = true;
    }

    Process {
        id: setVolumeProc
        property int value
        command: ["mpc", "-q", "volume", value]
    }
    onVolumePercentChanged: {
        if (realVolumePercent != volumePercent) {
            setVolumeProc.value = volumePercent;
            setVolumeProc.running = true;
            queryProc.running = true; // handles volume limit TODO: do it better
        }
    }

    property bool playing: false
    property string title: ""
    property string artist: ""
    property string album: ""

    property int currentTrack: 0
    property int totalTracks: 0
    property string currentTime: ""
    property string totalTime: ""
    property int progressPercent: 0

    property int realVolumePercent: 0
    property int volumePercent: 0
    property bool repeat: false
    property bool random: false
    property bool single: false
    property bool consume: false
}
