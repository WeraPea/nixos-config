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
        command: ["mmsg", "-w"]
        // DP-2 selmon 1
        // DP-2 tag 1 0 1 0
        // DP-2 tag 2 0 0 0
        // DP-2 tag 3 0 0 0
        // DP-2 tag 4 1 3 1
        // DP-2 tag 5 0 1 0
        // DP-2 tag 6 0 0 0
        // DP-2 tag 7 0 0 0
        // DP-2 tag 8 0 0 0
        // DP-2 tag 9 0 0 0
        // DP-2 title mmsg -w ~
        // DP-2 appid kitty
        // DP-2 layout T
        // DP-2 fullscreen 0
        // DP-2 floating 0
        // DP-2 x 3104
        // DP-2 y 30
        // DP-2 width 1280
        // DP-2 height 705
        // DP-2 last_layer quickshell
        // DP-2 kb_layout pl
        // DP-2 keymode default
        // DP-2 clients 5
        // DP-2 tags 25 8 0 // ignore
        // DP-2 tags 000011001 000001000 000000000 // ignore
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(" ");
                const name = parts[0];
                const key = parts[1];
                const values = parts.slice(2);

                let monitor = root.monitorMap[name];
                if (!monitor) {
                    monitor = monitorComp.createObject(null, {
                        name: name
                    });
                    root.monitors.push(monitor);
                    root.monitorMap[name] = monitor;
                    root.tagMaps[name] = {};
                }

                switch (key) {
                case "tag":
                    const tagIndex = parseInt(values[0]);
                    const visible = values[1] === "1";
                    const clients = parseInt(values[2]);
                    const selected = values[3] === "1";

                    let tag = root.tagMaps[name][tagIndex];
                    if (!tag) {
                        tag = tagComp.createObject(monitor, {
                            index: tagIndex,
                            visible: visible,
                            clients: clients,
                            selected: selected
                        });
                        monitor.tags.push(tag);
                        root.tagMaps[name][tagIndex] = tag;
                    } else {
                        tag.visible = visible;
                        tag.clients = clients;
                        tag.selected = selected;
                    }
                    break;
                case "selmon":
                case "fullscreen":
                case "floating":
                    monitor[key] = values[0] === "1";
                    break;
                case "title":
                case "appid":
                case "layout":
                case "last_layer":
                case "kb_layout":
                case "keymode":
                    monitor[key] = values.join(" ");
                    break;
                // NOTE: this are the selected client's x,y,width,height not monitor's
                case "x":
                case "y":
                case "width":
                case "height":
                case "clients":
                    monitor[key] = parseInt(values[0]);
                    break;
                }
            }
        }
    }
    Process {
        id: dispatch
        property string dispatch_command
        command: ["mmsg", "-d", dispatch_command]
    }
    function dispatch(dispatch_command) {
        dispatch.dispatch_command = dispatch_command;
        dispatch.running = true;
    }
    Process {
        id: select
        property string tag
        property string monitor
        command: ["mmsg", "-s", "-t", tag, "-o", monitor]
    }
    function select(tag, monitor) {
        select.tag = tag;
        select.monitor = monitor;
        select.running = true;
    }
}
