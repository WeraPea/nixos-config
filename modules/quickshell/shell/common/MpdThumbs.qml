pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property alias thumbs: thumbs

    RerunProcess {
        id: listProc
        running: Mpd.host !== ""
        command: ["sh", "-c", "mkdir -p \"$1\" && ls -1 \"$1\"", "sh", Mpd.cache_dir]
        stdout: StdioCollector {
            onStreamFinished: if (!listProc.restart) {
                const have = {};
                for (const name of this.text.split('\n'))
                    if (name.endsWith(".img"))
                        have[name.slice(0, -4)] = true;
                thumbs.have = have;
                thumbs.ready = true;
                thumbs.rev++;
                thumbs.next();
                thumbs.reloaded();
            }
        }
    }

    Item {
        id: thumbs
        visible: false
        property bool ready: false
        property int rev: 0
        property var have: ({})
        property var failed: ({})
        property var pending: []
        property string current: ""
        signal reloaded

        function has(key) {
            return have[key] === true;
        }
        function request(file) {
            if (file === "")
                return;
            const key = Qt.md5(file);
            if (have[key] || failed[key] || current === file || pending.indexOf(file) !== -1)
                return;
            pending.push(file);
            next();
        }
        function cancel(file) {
            const i = pending.indexOf(file);
            if (i !== -1)
                pending.splice(i, 1);
        }
        function next() {
            if (!ready || thumbProc.running || pending.length === 0)
                return;
            current = pending.pop();
            thumbProc.running = true;
        }

        Process {
            id: thumbProc
            command: ["sh", "-c", `
                file="$1"
                out="$2"
                host="$3"
                mpc -q -h "$host" readpicture "$file" > "$out.tmp" || { rm -f "$out.tmp"; exit 1; }
                [ -s "$out.tmp" ] || { rm -f "$out.tmp"; exit 1; }
                mv "$out.tmp" "$out"
            `, "sh", thumbs.current, Mpd.cache_dir + "/" + Qt.md5(thumbs.current) + ".img", Mpd.host]
            onExited: (exitCode, exitStatus) => {
                if (!thumbs.ready) {
                    return;
                }
                const key = Qt.md5(thumbs.current);
                thumbs.current = "";
                if (exitCode === 0) {
                    thumbs.have[key] = true;
                    thumbs.rev++;
                } else {
                    thumbs.failed[key] = true;
                }
                thumbs.next();
            }
        }
    }
    Connections {
        target: Mpd
        function onHostChanged() {
            thumbs.have = ({});
            thumbs.failed = ({});
            thumbs.pending = [];
            thumbs.current = "";
            thumbProc.running = false;
            thumbs.ready = false;
            thumbs.rev++;
            Qt.callLater(listProc.rerun); // callLater just in case
        }
    }
}
