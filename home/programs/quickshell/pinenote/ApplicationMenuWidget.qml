import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Widgets
import "common/config"

Item {
    id: root

    // implicitWidth: 40
    // implicitHeight: 30
    // IconImage {
    //     id: icon
    //     anchors.centerIn: parent
    //     implicitWidth: 18
    //     implicitHeight: 18
    //     source: Quickshell.iconPath("nix-snowflake")
    // }
    implicitWidth: icon.implicitWidth + 30
    implicitHeight: 30
    TextObject {
        id: icon
        anchors.centerIn: parent
        text: ""
        color: Colors.foreground
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: menuLoader.active = !menuLoader.active
    }

    FileView {
        id: usageFile
        path: Quickshell.env("HOME") + "/.config/quickshell/app-usage.json"
        adapter: JsonAdapter {
            id: jsonAdapter
            property var usage: ({})
        }
        onAdapterChanged: writeAdapter()
        onLoadFailed: err => err === FileViewError.FileNotFound && writeAdapter()
        function getUsageCount(desktopId) {
            return jsonAdapter.usage[desktopId] ?? 0;
        }

        function incrementUsage(desktopId) {
            jsonAdapter.usage[desktopId] = (jsonAdapter.usage[desktopId] || 0) + 1;
        }
    }

    Loader {
        id: menuLoader
        active: false
        sourceComponent: PanelWindow {
            id: menuWindow
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            color: Colors.background

            MouseArea {
                anchors.fill: parent
                onClicked: menuLoader.active = false
            }

            GridLayout {
                // TODO: pagination
                columnSpacing: 0
                rowSpacing: 0
                property int leftRightMargins: 100
                property int topBottomMargins: 60
                columns: (parent.width - leftRightMargins * 2) / children[0].width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: topBottomMargins
                anchors.bottomMargin: topBottomMargins

                Repeater {
                    id: entries
                    model: [...DesktopEntries.applications.values].sort(function (a, b) {
                        var countA = usageFile.getUsageCount(a.id);
                        var countB = usageFile.getUsageCount(b.id);
                        if (countB !== countA) {
                            return countB - countA;
                        }
                        return a.name.localeCompare(b.name);
                    })

                    Rectangle {
                        id: entry
                        required property DesktopEntry modelData
                        property int margins: 5

                        color: "transparent"

                        implicitWidth: entryIcon.width + margins * 2
                        implicitHeight: entryIcon.height + entryText.height + margins * 2

                        Column {
                            anchors.centerIn: parent
                            IconImage {
                                id: entryIcon
                                implicitWidth: 100
                                implicitHeight: 100
                                source: Quickshell.iconPath(entry.modelData.icon, true)
                                // source: (i => i !== "" ? i : Quickshell.iconPath("nix-snowflake"))(Quickshell.iconPath(entry.modelData.icon, true)) // TODO:
                            }
                            TextObject {
                                id: entryText
                                width: entryIcon.width
                                height: maximumLineCount * fm.height
                                FontMetrics {
                                    id: fm
                                    font: entryText.font
                                }

                                horizontalAlignment: Text.AlignHCenter

                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight

                                color: Colors.foreground
                                text: entry.modelData.name
                            }
                        }

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            onClicked: {
                                usageFile.incrementUsage(entry.modelData.id);
                                entry.modelData.execute();
                                menuLoader.active = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
