import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    required property var textTarget
    required property string monitor_name
    property alias tapHandler: tapHandler
    TextEdit {
        id: probe
        visible: false
        readOnly: true
        x: 0
        y: 0
        width: root.textTarget.width
        font: root.textTarget.font
        text: root.textTarget.text
        textFormat: TextEdit.PlainText
        wrapMode: root.textTarget.wrapMode === Text.NoWrap ? TextEdit.NoWrap : TextEdit.Wrap
    }
    Process {
        id: clientProc
        property var callback
        stdout: StdioCollector {
            onStreamFinished: {
                const client_info = JSON.parse(text);
                clientProc.callback(client_info);
            }
        }
    }
    TapHandler {
        id: tapHandler
        acceptedButtons: Qt.MiddleButton
        function lineBounds(text, pos) {
            const start = text.lastIndexOf("\n", pos - 1) + 1;
            let end = text.indexOf("\n", pos);
            if (end === -1)
                end = text.length;
            return {
                start,
                end,
                idx: pos - start,
                line: text.slice(start, end)
            };
        }
        onTapped: eventPoint => {
            const p = probe.mapFromItem(parent, eventPoint.position.x, eventPoint.position.y);
            const idx_hit = probe.positionAt(p.x, p.y);
            const r_hit = probe.positionToRectangle(idx_hit);
            const idx = p.x < r_hit.x ? idx_hit - 1 : idx_hit;
            const r = probe.positionToRectangle(idx);
            console.log(textTarget.text[idx]);

            const monitor = Mango.monitors.find(m => m.name === monitor_name);
            const client_id = monitor.id;
            clientProc.running = false;
            clientProc.command = ["mmsg", "get", "client", client_id];
            console.log(client_id);

            const lb = lineBounds(textTarget.text, idx);
            const global_pos = probe.mapToItem(null, r.x, r.y);
            clientProc.callback = client_info => {
                let popup_x = Math.round(client_info.x - monitor.x + global_pos.x);
                let popup_y = Math.round(client_info.y - monitor.y + global_pos.y) - 480 - 10;
                if (popup_x + 400 > monitor.width)
                    popup_x = monitor.width - 400;
                if (popup_y < 0)
                    popup_y = Math.round(client_info.y - monitor.y + global_pos.y) + r.height + 10;
                Quickshell.execDetached(["qocr", "ipc", "call", "ocr", "trigger_popup_term", popup_x, popup_y, floatingWindow.screen.name, lb.line.slice(lb.idx), lb.line, lb.idx]);
            };
            clientProc.running = true;
        }
    }
}
