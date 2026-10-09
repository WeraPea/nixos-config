import QtQuick
import Quickshell.Io

Item {
    id: root

    property string query: ""
    property ListModel source
    property ListModel filtered: ListModel {}

    property var lines: [] // "artist title"

    function refilter() {
        if (!source)
            return;
        if (query === "") {
            filtered.clear();
            for (let i = 0; i < source.count; i++)
                filtered.append(source.get(i));
            return;
        }

        lines = [];
        for (let i = 0; i < source.count; i++) {
            const entry = source.get(i);
            lines.push((entry.artist + " " + entry.title).replace(/\n/g, " "));
        }

        proc.command = ["yuru", "-x", "-f", query];
        proc.stdinEnabled = true;
        proc.rerun();
    }

    onQueryChanged: refilter()
    onSourceChanged: refilter()
    Connections {
        target: root.source
        function onRowsInserted() {
            refilterDebounce.restart();
        }
        function onRowsRemoved() {
            refilterDebounce.restart();
        }
        function onDataChanged() {
            refilterDebounce.restart();
        }
        function onModelReset() {
            refilterDebounce.restart();
        }
    }
    Timer {
        id: refilterDebounce
        interval: 50
        onTriggered: root.refilter()
    }

    RerunProcess {
        id: proc
        stdinEnabled: true
        stdout: StdioCollector {
            onStreamFinished: if (!proc.restart) {
                const buckets = {};
                for (let i = 0; i < root.lines.length; i++)
                    (buckets[root.lines[i]] || (buckets[root.lines[i]] = [])).push(i);

                root.filtered.clear();
                for (const line of text.split("\n")) {
                    if (line === "")
                        continue;
                    const q = buckets[line];
                    if (q && q.length)
                        root.filtered.append(root.source.get(q.shift()));
                }
            }
        }
        onStarted: {
            write(root.lines.join("\n") + "\n");
            stdinEnabled = false;
        }
    }
}
