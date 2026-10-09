pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "config"

Singleton {
    id: root

    property string host: "localhost"
    property string cache_dir: Quickshell.env("HOME") + "/.cache/werapi-mpd/thumbnails"
    property string musicDir: if (Hostname.hostname === "fajita") {
        return Quickshell.env("HOME") + "/music/";
    } else {
        return "/mpd/music/";
    }

    property bool continous: false
    property var continousLads: ({})
    function setContinous(source, value) {
        continousLads[source] = value;
        for (const source in continousLads) {
            if (continousLads[source]) {
                continous = true;
                return;
            }
        }
        continous = false;
    }
    Timer {
        id: continousTimer
        interval: 1000
        running: root.continous && root.playing
        repeat: true
        onTriggered: {
            if (root.totalTime > 0 && root.currentTime < root.totalTime)
                root.currentTime += 1;
            root.progressPercent = root.totalTime > 0 ? Math.floor(100 * root.currentTime / root.totalTime) : 0;
        }
    }
    onContinousChanged: if (continous)
        statusProc.rerun()

    property bool ipcVisibilityState: false
    property bool ipcWindowVisibilityState: false
    IpcHandler {
        target: "mpd"
        function on(): void {
            ipcVisibilityState = true;
        }
        function off(): void {
            ipcVisibilityState = false;
        }
        function toggle(): void {
            ipcVisibilityState = !ipcVisibilityState;
        }
        function window_on(): void {
            ipcWindowVisibilityState = true;
        }
        function window_off(): void {
            ipcWindowVisibilityState = false;
        }
        function window_toggle(): void {
            ipcWindowVisibilityState = !ipcWindowVisibilityState;
        }
    }

    function runAll() {
        queueProc.rerun();
        libraryProc.rerun();
        playlistsProc.rerun();
        statusProc.rerun();
        currentProc.rerun();
    }

    Process {
        id: idleProc
        command: ["mpc", "-h", root.host, "idleloop"]
        onRunningChanged: if (!running && !idleDisconnectedTimer.running)
            running = root.mpcAvailable
        stdout: SplitParser {
            onRead: line => {
                switch (line) {
                case "player":
                    currentProc.rerun();
                    statusProc.rerun();
                    break;
                case "options":
                case "mixer":
                    statusProc.rerun();
                    break;
                case "playlist":
                    queueProc.rerun();
                    break;
                case "database":
                    libraryProc.rerun();
                    break;
                case "stored_playlist":
                    playlistsProc.rerun();
                    break;
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (this.text != "")
                idleDisconnectedTimer.running = true
        }
    }
    property bool mpcAvailable: false
    Process {
        id: whichProc
        running: true
        command: ["which", "mpc"]
        onExited: (exitCode, exitStatus) => {
            root.mpcAvailable = (exitCode === 0);
            if (root.mpcAvailable) {
                idleProc.running = true;
                root.runAll();
            }
        }
    }
    Process {
        id: idleDisconnectedProc
        command: ["mpc", "-h", root.host, "-q"]
        stderr: StdioCollector {
            onStreamFinished: if (this.text != "") {
                idleDisconnectedTimer.running = true;
            } else {
                idleProc.running = true;
                root.runAll();
            }
        }
    }
    Timer {
        id: idleDisconnectedTimer
        interval: 1000
        onTriggered: idleDisconnectedProc.running = true
    }

    property string title: ""
    property string artist: ""
    property string album: ""
    property string file: ""
    RerunProcess {
        id: currentProc
        command: ["mpc", "-h", root.host, "current", "--format", "%title%\n%artist%\n%album%\n%file%"]
        stdout: StdioCollector {
            onStreamFinished: if (!currentProc.restart) {
                const lines = root.splitLines(text);

                if (lines.length === 4) {
                    root.title = lines[0];
                    root.artist = lines[1];
                    root.album = lines[2];
                    root.file = lines[3];
                } else {
                    root.title = "";
                    root.artist = "";
                    root.album = "";
                    root.file = "";
                }
            }
        }
    }

    function toSec(s) {
        return s.split(":").reduce((a, p) => a * 60 + Number(p), 0);
    }
    function fmtSec(t) {
        const h = Math.floor(t / 3600), m = Math.floor(t % 3600 / 60), s = t % 60;
        const pad = n => String(n).padStart(2, "0");
        return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${m}:${pad(s)}`;
    }

    property int totalTime: 0
    property int currentTime: 0
    property int progressPercent: 0

    property int currentTrack: 0
    property int totalTracks: 0

    property bool playing: false

    property int realVolumePercent: 0
    property int volumePercent: 0

    property bool random: false
    property bool repeat: false
    property bool single: false
    property bool consume: false
    RerunProcess {
        id: statusProc
        command: ["mpc", "-h", root.host, "status", "%totaltime%\n%currenttime%\n%percenttime%\n%songpos%\n%length%\n%state%\n%volume%\n%random%\n%repeat%\n%single%\n%consume%"]
        stdout: StdioCollector {
            onStreamFinished: if (!statusProc.restart) {
                var lines = this.text.trim().split('\n');

                if (lines.length != 0) {
                    root.totalTime = root.toSec(lines.shift());
                    root.currentTime = root.toSec(lines.shift());
                    root.progressPercent = parseInt(lines.shift().trim().slice(0, -1));
                    root.currentTrack = parseInt(lines.shift());
                    root.totalTracks = parseInt(lines.shift());
                    root.playing = lines.shift() === "playing"; // ignores distinction between paused and stopped
                    root.realVolumePercent = parseInt(lines.shift().trim().slice(0, -1));
                    root.volumePercent = root.realVolumePercent;
                    root.random = lines.shift() === "on";
                    root.repeat = lines.shift() === "on";
                    root.single = lines.shift() === "on";
                    root.consume = lines.shift() === "on";
                } else {
                    // MPD error: Connection refused (stderr)
                    // when MPD not active
                    root.totalTime = 0;
                    root.currentTime = 0;
                    root.progressPercent = 0;
                    root.currentTrack = 0;
                    root.totalTracks = 0;
                    root.playing = false;
                    root.realVolumePercent = 0;
                    root.volumePercent = 0;
                    root.random = false;
                    root.repeat = false;
                    root.single = false;
                    root.consume = false;
                }
            }
        }
    }

    Process {
        id: mpcCommandProc
        property var cmds: []
        property var cmd
        onCmdsChanged: cmd = cmds[0]
        command: ["sh", "-c", `mpc -h ${root.host} ${cmd}`]
        onRunningChanged: if (!running) {
            cmds = cmds.slice(1);
            if (cmds.length !== 0)
                running = true;
        }
    }
    function command(command) {
        mpcCommandProc.cmds = [...mpcCommandProc.cmds, command];
        mpcCommandProc.running = true;
    }

    Process {
        id: setVolumeProc
        property int value
        command: ["mpc", "-h", root.host, "-q", "volume", value]
    }
    onVolumePercentChanged: {
        if (realVolumePercent != volumePercent) {
            setVolumeProc.value = volumePercent;
            setVolumeProc.running = true;
            statusProc.rerun(); // handles volume limit TODO: do it better
        }
    }

    function splitLines(text) {
        const lines = text.split('\n');
        if (lines[lines.length - 1] === "")
            lines.pop();
        return lines;
    }
    component PlaylistProc: RerunProcess {
        id: pl
        required property ListModel target
        property var extra: []
        property string cmd: "playlist"

        function syncModel(model, entries) {
            for (let i = 0; i < entries.length; i++) {
                if (i >= model.count) {
                    model.append(entries[i]);
                    continue;
                }
                const cur = model.get(i);
                for (const k in entries[i]) {
                    if (cur[k] !== entries[i][k]) {
                        model.set(i, entries[i]);
                        break;
                    }
                }
            }
            if (model.count > entries.length)
                model.remove(entries.length, model.count - entries.length);
        }
        function parseTracks(text) {
            const lines = root.splitLines(text);
            const out = [];
            for (let i = 0; i + 2 < lines.length; i += 3)
                out.push({
                    file: lines[i],
                    title: lines[i + 1],
                    artist: lines[i + 2],
                    position: i / 3 + 1
                });
            return out;
        }

        command: ["mpc", "-h", root.host, cmd, "--format", "%file%\n%title%\n%artist%", ...extra]
        stdout: StdioCollector {
            onStreamFinished: if (!pl.restart)
                pl.syncModel(pl.target, pl.parseTracks(text))
        }
    }

    ListModel {
        id: queue
    }
    property ListModel queue: queue
    PlaylistProc {
        id: queueProc
        target: queue
    }

    ListModel {
        id: library
    }
    property ListModel library: library
    PlaylistProc {
        id: libraryProc
        target: library
        cmd: "listall"
    }

    ListModel {
        id: playlist
    }
    property ListModel playlist: playlist
    PlaylistProc {
        id: playlistProc
        target: playlist
        property string playlistName: ""
        extra: playlistProc.playlistName !== "" ? [playlistProc.playlistName] : []
    }
    function getPlaylist(name) {
        if (name !== playlistProc.playlistName)
            playlist.clear();
        playlistProc.playlistName = name;
        playlistProc.rerun();
    }

    ListModel {
        id: playlists
    }
    property ListModel playlists: playlists
    RerunProcess {
        id: playlistsProc
        command: ["mpc", "-h", root.host, "lsplaylists"]
        stdout: StdioCollector {
            onStreamFinished: if (!playlistsProc.restart) {
                const lines = text.split('\n');
                if (lines[lines.length - 1] === "")
                    lines.pop();

                const n = lines.length;
                for (let i = 0; i < n; i++) {
                    const entry = {
                        name: lines[i]
                    };
                    if (i < playlists.count) {
                        if (playlists.get(i).name !== entry.name)
                            playlists.set(i, entry);
                    } else {
                        playlists.append(entry);
                    }
                }
                if (playlists.count > n)
                    playlists.remove(n, playlists.count - n);
            }
        }
    }

    property var metadata: ({})
    property var tags: ({})
    property string lyrics: ""
    RerunProcess {
        id: metadataProc

        function findLyrics(tags) {
            if (!tags)
                return "";
            for (const k in tags) {
                const lk = k.toLowerCase();
                if (lk === "lyrics")
                    return tags[k];
            }
            return "";
        }
        function findTags(metadata) {
            const sources = (metadata.streams || []).map(s => s.tags);
            for (const tags of sources) {
                if (!tags)
                    continue;
                for (const k in tags) {
                    const lk = k.toLowerCase();
                    if (lk === "title") {
                        return tags;
                    }
                }
            }
            return null;
        }

        command: ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_streams", "-show_format", root.musicDir + "/" + root.file]
        stdout: StdioCollector {
            onStreamFinished: if (!metadataProc.restart) {
                root.metadata = JSON.parse(this.text);
                root.tags = metadataProc.findTags(root.metadata);
                root.lyrics = metadataProc.findLyrics(tags).trim();
            }
        }
    }
    onFileChanged: {
        lyrics = "";
        if (file === "")
            return;
        Qt.callLater(metadataProc.rerun); // needed for command binding to work properly on the first run for some reason
    }
}
