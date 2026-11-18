pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property alias thumbs: thumbs

    Process {
        id: listProc
        running: Mpd.host !== ""
        command: ["sh", "-c", "mkdir -p \"$1\" && ls -1 \"$1\"", "sh", Mpd.cache_dir]
        stdout: StdioCollector {
            onStreamFinished: {
                const have = {};
                for (const name of this.text.split('\n'))
                    if (name.endsWith(".img"))
                        have[name.slice(0, -4)] = true;
                thumbs.have = have;
                thumbs.ready = true;
                thumbs.rev++;
                thumbs.next();
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
            command: ["sh", "-c", "mpc -h \"$3\" readpicture \"$1\" > \"$2.tmp\" && [ -s \"$2.tmp\" ] && mv \"$2.tmp\" \"$2\" || { rm -f \"$2.tmp\"; exit 1; }", "sh", thumbs.current, Mpd.cache_dir + "/" + Qt.md5(thumbs.current) + ".img", Mpd.host]
            onExited: (exitCode, exitStatus) => {
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
}
