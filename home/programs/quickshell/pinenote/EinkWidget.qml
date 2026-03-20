pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import "common"
import "common/config"

Item {
    id: root
    property string icon: "󰘮"
    implicitWidth: einkText.implicitWidth + 30
    implicitHeight: 30

    TextObject {
        id: einkText
        anchors.centerIn: parent
        text: root.icon
        color: Colors.foreground
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            introspectProc.running = true;
            watchProc.running = true;
        }
    }

    PopupWidget {
        id: popup
        anchor.item: root
        anchor.edges: Qt.BottomEdge
        anchor.gravity: Qt.BottomEdge | Qt.HCenter
        backgroundColor: Colors.background
        border.color: Colors.foreground
        border.width: 1
        visible: false

        property string defaultHintHr: ""
        property int ditherMode: -1
        property int driverMode: -1
        property int redrawDelay: -1

        property string bitDepth: defaultHintHr.split("|")[0]
        property bool usesDither: defaultHintHr.includes("|D")
        property bool usesRedraw: defaultHintHr.includes("|R")

        onVisibleChanged: {
            if (!visible) {
                watchProc.running = false;
                defaultHintHr = "";
                ditherMode = -1;
                driverMode = -1;
                redrawDelay = -1;
            }
        }

        Process {
            id: introspectProc
            running: false
            command: ["busctl", "--user", "get-property", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "DefaultHintHr", "DitherMode", "DriverMode", "RedrawDelay"]

            stdout: StdioCollector {
                onStreamFinished: {
                    const lines = this.text.trim().split("\n");
                    const parseVal = line => line.replace(/^[a-z()\s]+/, "").replace(/"/g, "").trim();
                    if (lines[0] !== undefined)
                        popup.defaultHintHr = parseVal(lines[0]);
                    if (lines[1] !== undefined)
                        popup.ditherMode = parseInt(parseVal(lines[1]));
                    if (lines[2] !== undefined)
                        popup.driverMode = parseInt(parseVal(lines[2]));
                    if (lines[3] !== undefined)
                        popup.redrawDelay = parseInt(parseVal(lines[4]));
                    popup.visible = true;
                }
            }
        }

        Process {
            id: watchProc
            running: false
            command: ["busctl", "--user", "monitor", "org.pinenote.PineNoteCtl", "--json", "short"]

            stdout: SplitParser {
                onRead: line => {
                    let msg;
                    try {
                        msg = JSON.parse(line);
                    } catch (e) {
                        return;
                    }
                    if (msg.type !== "signal")
                        return;
                    if (msg.member !== "PropertiesChanged")
                        return;
                    const changed = msg.payload?.data?.[1];
                    if (!changed)
                        return;
                    if (changed.DefaultHintHr !== undefined)
                        popup.defaultHintHr = changed.DefaultHintHr.data;
                    if (changed.DitherMode !== undefined)
                        popup.ditherMode = changed.DitherMode.data;
                    if (changed.DriverMode !== undefined)
                        popup.driverMode = changed.DriverMode.data;
                    if (changed.RedrawDelay !== undefined)
                        popup.redrawDelay = changed.RedrawDelay.data;
                }
            }
        }

        content: Component {
            RowLayout {
                spacing: 5

                CommandWidget {
                    text: ({
                            Y1: "1",
                            Y2: "2",
                            Y4: "4"
                            // Y1: "󰎤",
                            // Y2: "󰎧",
                            // Y4: "󰎭"
                        })[popup.bitDepth] ?? ""
                    command: {
                        const next = ({
                                Y1: "Y2",
                                Y2: "Y4",
                                Y4: "Y1"
                            })[popup.bitDepth];
                        const val = next + (popup.usesDither ? "|D" : "") + (popup.usesRedraw ? "|R" : "");
                        return ["busctl", "--user", "set-property", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "DefaultHintHr", "s", val];
                    }
                }

                CommandWidget {
                    text: popup.usesDither ? "󱝊" : "󰬛"
                    command: {
                        const val = popup.bitDepth + (popup.usesDither ? "" : "|D") + (popup.usesRedraw ? "|R" : "");
                        return ["busctl", "--user", "set-property", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "DefaultHintHr", "s", val];
                    }
                }

                CommandWidget {
                    text: popup.usesRedraw ? "󰬙" : "󰰞"
                    command: {
                        const val = popup.bitDepth + (popup.usesDither ? "|D" : "") + (popup.usesRedraw ? "" : "|R");
                        return ["busctl", "--user", "set-property", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "DefaultHintHr", "s", val];
                    }
                }

                CommandWidget {
                    text: (["󰾆", "󰓅"])[popup.driverMode] ?? ""
                    command: ["busctl", "--user", "call", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "CycleDriverMode"]
                }

                CommandWidget {
                    text: (["Bayer", "BN-16", "BN-32"])[popup.ditherMode] ?? ""
                    command: ["busctl", "--user", "call", "org.pinenote.PineNoteCtl", "/org/pinenote/PineNoteCtl", "org.pinenote.Ebc1", "CycleDitherMode"]
                }
            }
        }
    }
}
