pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "config"

Item {
    id: root
    property bool active: Mpd.ipcWindowVisibilityState

    property bool mouseFlick: true

    component ScrollBase: Item {
        id: scrollBase
        property Flickable scroller
        property real wheelStep: 52
        property bool mouseFlick: root.mouseFlick

        function clampY(y) {
            const f = scroller;
            const minY = f.originY;
            const maxY = Math.max(minY, f.originY + f.contentHeight - f.height);
            return Math.max(minY, Math.min(maxY, y));
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const dy = event.pixelDelta.y !== 0 ? event.pixelDelta.y : event.angleDelta.y / 120 * scrollBase.wheelStep;
                scrollBase.scroller.cancelFlick();
                scrollBase.scroller.contentY = scrollBase.clampY(scrollBase.scroller.contentY - dy);
            }
        }

        DragHandler {
            property real startY: 0
            target: null
            xAxis.enabled: false
            acceptedDevices: scrollBase.mouseFlick ? PointerDevice.AllDevices : (PointerDevice.TouchScreen | PointerDevice.Stylus)
            onActiveChanged: {
                if (active) {
                    scrollBase.scroller.cancelFlick();
                    startY = scrollBase.scroller.contentY;
                } else {
                    scrollBase.scroller.flick(0, centroid.velocity.y);
                }
            }
            onTranslationChanged: if (active)
                scrollBase.scroller.contentY = scrollBase.clampY(startY - translation.y)
        }
    }

    component TouchList: ScrollBase {
        property alias model: listView.model
        property alias delegate: listView.delegate
        property alias view: listView
        scroller: listView
        ListView {
            id: listView
            anchors.fill: parent
            clip: true
            interactive: false
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 6000
            maximumFlickVelocity: 1000000
        }
    }

    component TouchFlick: ScrollBase {
        default property alias content: contentItem.data
        property alias contentHeight: flickable.contentHeight
        scroller: flickable

        Flickable {
            id: flickable
            anchors.fill: parent
            clip: true
            interactive: false
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 6000
            maximumFlickVelocity: 1000000
            contentWidth: width

            Item {
                id: contentItem
                width: flickable.width
                height: flickable.contentHeight
            }
        }
    }

    component TitleArtist: ColumnLayout {
        property string title
        property string subtitle
        required property Colors colors
        spacing: 0
        clip: true
        TextObject {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: parent.colors.foreground
            text: parent.title
        }
        TextObject {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: parent.colors.foregroundSecondary
            text: parent.subtitle
        }
    }
    component TrackRow: Rectangle {
        id: trackRow
        required property string file
        required property string title
        required property string artist
        required property Colors colors
        property bool highlighted: false
        signal tapped
        width: ListView.view.width
        height: 52
        color: highlighted ? Qt.alpha(trackRow.colors.accent, 0.2) : "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8
            MpdCover {
                colors: trackRow.colors
                size: 40
                store: MpdThumbs.thumbs
                file: trackRow.file
            }
            TitleArtist {
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                title: trackRow.title
                subtitle: trackRow.artist
                colors: trackRow.colors
            }
        }
        TapHandler {
            onTapped: trackRow.tapped()
        }
    }
    component SelectableText: TextEdit {
        id: selectableText
        required property Colors colors
        font: GlobalSettings.font
        readOnly: true
        selectByMouse: true
        wrapMode: TextEdit.Wrap
        color: selectableText.colors.foreground
        selectionColor: selectableText.colors.base0F
        selectedTextColor: selectableText.colors.background
        // TODO: prevent keyboard appearing on mobile when interacting with this
    }
    component TextButton: Rectangle {
        id: textButton
        property string label
        required property Colors colors
        signal clicked
        color: "transparent"
        border.color: textButton.colors.accent
        border.width: 1
        TextObject {
            anchors.centerIn: parent
            color: textButton.colors.foreground
            text: textButton.label
        }
        MouseArea {
            anchors.fill: parent
            onClicked: textButton.clicked()
        }
    }

    Loader {
        id: loader
        active: root.active
        onActiveChanged: Mpd.setContinous(this, active)
        sourceComponent: FloatingWindow {
            id: floatingWindow
            visible: true
            implicitWidth: 420
            implicitHeight: 727
            color: colors.background
            onClosed: Mpd.ipcWindowVisibilityState = false

            property alias colors: colors
            Colors {
                id: colors
                path: (Hostname.hostname == "pinenote" || floatingWindow.screen.name.startsWith("HEADLESS-")) ? `${Quickshell.env("PINENOTE_COLORS_CONFIG")}` : defaultPath
            }

            property int tab: 0
            readonly property var tabNames: ["Queue", "Library", "Playlists", "Lyrics", "Info"]
            property string openPlaylist: "" // "" = playlist list

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Now playing header
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: columnLayout.implicitHeight
                    color: colors.background

                    ColumnLayout {
                        id: columnLayout
                        anchors.fill: parent
                        spacing: 0
                        RowLayout {
                            id: nowPlayingContent
                            Layout.margins: 8
                            spacing: 8

                            RowLayout {
                                MpdCover {
                                    colors: floatingWindow.colors
                                    Layout.margins: -8
                                    Layout.rightMargin: 0
                                    size: columnLayout.implicitHeight - progressBar.height
                                    store: MpdThumbs.thumbs
                                    file: Mpd.file
                                }
                                TitleArtist {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0

                                    colors: floatingWindow.colors
                                    title: Mpd.title
                                    subtitle: Mpd.artist
                                }
                            }

                            RowLayout {
                                spacing: 8
                                Repeater {
                                    model: [
                                        {
                                            // TODO: svg icons
                                            label: "󰒮",
                                            cmd: "prev"
                                        },
                                        {
                                            label: Mpd.playing ? "󰏤" : "󰐊",
                                            cmd: "toggle"
                                        },
                                        {
                                            label: "󰒭",
                                            cmd: "next"
                                        }
                                    ]
                                    delegate: TextButton {
                                        Layout.preferredWidth: 52
                                        Layout.preferredHeight: 52
                                        required property var modelData
                                        colors: floatingWindow.colors
                                        label: modelData.label
                                        onClicked: Mpd.command(modelData.cmd)
                                    }
                                }
                            }
                        }

                        // Progress bar
                        Rectangle {
                            id: progressBar
                            height: 2
                            implicitWidth: parent.width * Mpd.progressPercent / 100
                            color: colors.accent
                        }
                    }
                }

                // Views
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: floatingWindow.tab

                    // Queue
                    TouchList {
                        id: queueList
                        model: Mpd.queue
                        delegate: TrackRow {
                            required property int position
                            colors: floatingWindow.colors
                            highlighted: position === Mpd.currentTrack
                            onTapped: Mpd.command(`play ${position}`)
                        }
                        // TODO: swipe for remove, move, etc
                        TextButton {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 12
                            width: 52
                            height: 52
                            visible: Mpd.currentTrack > 0
                            colors: floatingWindow.colors
                            color: floatingWindow.colors.background
                            label: "Cur"
                            onClicked: queueList.view.positionViewAtIndex(Mpd.currentTrack - 1, ListView.Center)
                        }
                        Component.onCompleted: Qt.callLater(_ => {
                            if (Mpd.currentTrack > 0)
                                view.positionViewAtIndex(Mpd.currentTrack - 1, ListView.Center);
                        }) // without callLater causes persistent high cpu usage ???
                    }

                    // Library / search
                    ColumnLayout {
                        spacing: 0
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 44
                            color: "transparent"
                            border.color: colors.accent
                            border.width: 1
                            TextInput {
                                id: searchInput
                                font: GlobalSettings.font
                                anchors.fill: parent
                                anchors.margins: 8
                                verticalAlignment: TextInput.AlignVCenter
                                color: colors.foreground
                                selectionColor: colors.base0F
                                selectedTextColor: colors.background
                                clip: true
                                onTextChanged: searchDebounce.restart()
                            }
                            Timer {
                                id: searchDebounce
                                interval: 250
                                onTriggered: f.query = searchInput.text
                            }
                        }
                        TouchList {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            MpdFilter {
                                id: f
                                source: Mpd.library
                            }
                            model: f.filtered
                            delegate: TrackRow {
                                colors: floatingWindow.colors
                                onTapped: {
                                    Mpd.command(`insert "${file}"`);
                                    Mpd.command(`next`);
                                }
                            }
                        }
                    }

                    // Playlists (list -> playlist detail)
                    StackLayout {
                        currentIndex: floatingWindow.openPlaylist === "" ? 0 : 1

                        // Playlist list
                        TouchList {
                            model: Mpd.playlists
                            delegate: Rectangle {
                                id: plRow
                                required property string name
                                width: ListView.view.width
                                height: 52
                                color: "transparent"
                                TextObject {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    color: colors.foreground
                                    text: plRow.name
                                }
                                TapHandler {
                                    onTapped: {
                                        floatingWindow.openPlaylist = plRow.name;
                                        Mpd.getPlaylist(plRow.name);
                                    }
                                }
                            }
                        }

                        // Playlist detail
                        ColumnLayout {
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 44
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    TextObject {
                                        color: colors.accent
                                        text: "← " + floatingWindow.openPlaylist
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    TextObject {
                                        color: colors.foreground
                                        text: "Load"
                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.margins: -8
                                            onClicked: {
                                                Mpd.command(`clear`);
                                                Mpd.command(`load "${floatingWindow.openPlaylist}"`);
                                                Mpd.command(`play`);
                                            }
                                        }
                                    }
                                }
                                MouseArea {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width / 2
                                    onClicked: floatingWindow.openPlaylist = ""
                                }
                            }
                            TouchList {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: Mpd.playlist
                                delegate: TrackRow {
                                    colors: floatingWindow.colors
                                    required property int position
                                    onTapped: {
                                        Mpd.command(`clear`);
                                        Mpd.command(`load "${floatingWindow.openPlaylist}"`);
                                        Mpd.command(`play ${position}`);
                                    }
                                }
                            }
                        }
                    }

                    // Lyrics
                    TouchFlick {
                        contentHeight: lyricsText.implicitHeight + 24
                        SelectableText {
                            id: lyricsText
                            x: 12
                            y: 12
                            colors: floatingWindow.colors
                            width: parent.width - 24
                            text: Mpd.lyrics
                        }
                    }

                    // Info
                    TouchList {
                        model: [
                            {
                                key: "Title",
                                value: Mpd.title
                            },
                            {
                                key: "Artist",
                                value: Mpd.artist
                            },
                            {
                                key: "Artists",
                                value: Mpd.tags.ARTISTS?.split(";").join(", ") ?? ""
                            },
                            {
                                key: "File",
                                value: Mpd.file
                            },
                            {
                                key: "Genres",
                                value: Mpd.tags.GENRE?.split(";").join(", ") ?? ""
                            },
                            {
                                key: "PURL",
                                value: Mpd.tags.PURL
                            },
                            {
                                key: "Date",
                                value: Mpd.tags.DATE
                            },
                        ].filter(m => m.value != "" && m.value)
                        // TODO: display all tags, with some getting priority, parsing, default hidden state
                        delegate: Rectangle {
                            required property string key
                            required property string value
                            width: ListView.view.width
                            height: 44
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                TextObject {
                                    Layout.preferredWidth: 90
                                    color: colors.foregroundSecondary
                                    text: key
                                }
                                SelectableText {
                                    colors: floatingWindow.colors
                                    Layout.fillWidth: true
                                    text: value
                                }
                                // TODO: click to toggle hide/fold
                            }
                        }
                    }
                }

                // tab navigation
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Repeater {
                        model: floatingWindow.tabNames
                        delegate: Rectangle {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            implicitHeight: 52
                            property bool active: floatingWindow.tab === index
                            color: active ? Qt.alpha(colors.accent, 0.2) : "transparent"
                            Rectangle {
                                anchors.top: parent.top
                                width: parent.width
                                height: 2
                                color: active ? colors.accent : "transparent"
                            }
                            TextObject {
                                anchors.centerIn: parent
                                color: active ? colors.foreground : colors.foregroundSecondary
                                text: modelData
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: floatingWindow.tab = index
                            }
                        }
                    }
                }
            }
        }
    }
}
