pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property list<MangoMonitor> monitors
    property var monitorMap: ({})
    property var tagMaps: ({})
    Component {
        id: monitorComp
        MangoMonitor {}
    }
    Component {
        id: tagComp
        MangoTag {}
    }
    Process {
        id: queryProc
        running: true
        onRunningChanged: running = true
        command: ["mmsg", "watch", "all-monitors"]
        stdout: SplitParser {
            onRead: line => {
                const data = JSON.parse(line);

                for (const m of data.monitors) {
                    const name = m.name;

                    let monitor = root.monitorMap[name];
                    if (!monitor) {
                        monitor = monitorComp.createObject(null, {
                            name
                        });
                        root.monitors.push(monitor);
                        root.monitorMap[name] = monitor;
                        root.tagMaps[name] = {};
                    }

                    monitor.selmon = m.active;
                    monitor.layout = m.layout_symbol;
                    monitor.last_layer = m.last_open_surface;
                    monitor.keymode = m.keymode;
                    monitor.kb_layout = m.keyboardlayout;
                    monitor.x = m.x;
                    monitor.y = m.y;
                    monitor.width = m.width;
                    monitor.height = m.height;

                    const ac = m.active_client;
                    monitor.title = ac?.title ?? "";
                    monitor.appid = ac?.appid ?? "";

                    for (const t of m.tags) {
                        const index = t.index;
                        const active = t.is_active;
                        const clients = t.client_count;
                        const urgent = t.is_urgent;

                        let tag = root.tagMaps[name][index];
                        if (!tag) {
                            tag = tagComp.createObject(monitor, {
                                index,
                                active,
                                clients,
                                urgent
                            });
                            monitor.tags.push(tag);
                            root.tagMaps[name][index] = tag;
                        } else {
                            tag.active = active;
                            tag.clients = clients;
                            tag.urgent = urgent;
                        }
                    }
                }
            }
        }
    }
    Process {
        id: dispatch
        property string dispatch_command
        command: ["mmsg", "dispatch", dispatch_command]
    }
    function dispatch(dispatch_command) {
        dispatch.dispatch_command = dispatch_command;
        dispatch.running = true;
    }
    Process {
        id: select
        property string tag
        property string monitor
        command: ["mmsg", "dispatch", `viewcrossmon,${tag},${monitor}`]
    }
    function select(tag, monitor) {
        select.tag = tag;
        select.monitor = monitor;
        select.running = true;
    }
}
