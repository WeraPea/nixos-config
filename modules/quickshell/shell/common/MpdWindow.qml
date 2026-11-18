pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
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
        readonly property bool moving: dragHandler.active || wheelTimer.running || scroller.flicking

        function clampY(y) {
            const f = scroller;
            const minY = f.originY;
            const maxY = Math.max(minY, f.originY + f.contentHeight - f.height);
            return Math.max(minY, Math.min(maxY, y));
        }

        Timer {
            id: wheelTimer
            interval: 300
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const dy = event.angleDelta.y / 120 * scrollBase.wheelStep;
                wheelTimer.restart();
                scrollBase.scroller.cancelFlick();
                scrollBase.scroller.contentY = scrollBase.clampY(scrollBase.scroller.contentY - dy);
            }
        }

        DragHandler {
            id: dragHandler
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
        id: titleArtist
        property string title
        property string subtitle
        required property Colors colors
        required property string monitor_name
        spacing: 0
        clip: true
        TextObject {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: parent.colors.foreground
            text: parent.title
            QocrPopup {
                anchors.fill: parent
                textTarget: parent
                monitor_name: titleArtist.monitor_name
            }
        }
        TextObject {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: parent.colors.foregroundSecondary
            text: parent.subtitle
            QocrPopup {
                anchors.fill: parent
                textTarget: parent
                monitor_name: titleArtist.monitor_name
            }
        }
    }
    component TrackRow: Rectangle {
        id: trackRow
        required property string file
        required property string title
        required property string artist
        required property int time
        required property Colors colors
        required property string monitor_name
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
                monitor_name: trackRow.monitor_name
            }
            TextObject {
                color: trackRow.colors.foregroundSecondary
                text: Mpd.fmtSec(trackRow.time)
            }
        }
        TapHandler {
            onTapped: trackRow.tapped()
        }
    }
    component SelectableText: Item {
        id: selectableText
        required property Colors colors
        property alias text: textEdit.text
        property alias font: textEdit.font

        FontMetrics {
            id: selectableTextMetrics
            font: textEdit.font
        }

        readonly property real primaryLineHeight: Math.ceil(selectableTextMetrics.height)
        implicitHeight: textEdit.lineCount * primaryLineHeight

        TextEdit {
            id: textEdit
            width: parent.width
            height: contentHeight
            font: GlobalSettings.font

            transform: Translate {
                y: Math.round(selectableTextMetrics.ascent - textEdit.baselineOffset + textEdit.topPadding)
            }
            readOnly: true
            selectByMouse: true
            wrapMode: TextEdit.Wrap
            color: selectableText.colors.foreground
            selectionColor: selectableText.colors.base0F
            selectedTextColor: selectableText.colors.background
            // TODO: prevent keyboard appearing on mobile when interacting with this
        }
    }
    component TextButton: Rectangle {
        id: textButton
        property string label
        property alias textObject: textObject
        required property Colors colors
        property color textColor: textButton.colors.foreground
        signal clicked
        color: "transparent"
        border.color: mouseArea.pressed ? textButton.colors.accent : textButton.colors.foregroundSecondary
        border.width: 1
        TextObject {
            id: textObject
            anchors.centerIn: parent
            color: textButton.textColor
            text: textButton.label
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: textButton.clicked()
        }
    }
    component MpdSlider: Item {
        id: mpdSlider
        Layout.fillWidth: true
        implicitHeight: 2
        signal changed

        property alias slider: slider
        property alias position: slider.position
        property alias max: slider.to
        property alias color: sliderFill.color
        required property real current
        // required property color color

        Rectangle {
            id: sliderFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: slider.visualPosition * parent.width
            height: 2
            color: mpdSlider.colors.accent
        }
        Slider {
            id: slider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: 32

            from: 0
            stepSize: 1
            handle: null
            background: null
            snapMode: Slider.SnapOnRelease
            live: false
            onPressedChanged: if (!pressed) {
                changed();
                showRealTimer.restart();
            } else {
                slider.showReal = false;
            }

            property bool showReal: true
            Binding {
                target: slider
                property: "value"
                value: mpdSlider.current
                when: slider.showReal
            }
            Timer {
                id: showRealTimer
                interval: 250
                onTriggered: slider.showReal = true
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
    component Menu: Item {
        id: menu

        required property Colors colors

        visible: false
        implicitWidth: columnLayout.implicitWidth
        implicitHeight: columnLayout.implicitHeight
        MouseArea {
            x: {
                menu.x; // for bindings
                menu.y;
                return menu.mapFromItem(menu.parent, 0, 0).x;
            }
            y: {
                menu.x;
                menu.y;
                return menu.mapFromItem(menu.parent, 0, 0).y;
            }
            width: menu.parent.width
            height: menu.parent.height
            onClicked: menu.visible = false
        }
        ColumnLayout {
            id: columnLayout
            spacing: 0
            Repeater {
                model: [
                    {
                        label: "Toggle sleep timer",
                        cmd: _ => Mpd.sleepTimer.toggle(),
                        textColor: Mpd.sleepTimer.running ? menu.colors.foreground : menu.colors.foregroundSecondary
                    },
                    {
                        label: "Cycle hosts: " + Mpd.host,
                        cmd: _ => {
                            const hosts = ["nixos", "fajita",];
                            Mpd.host = hosts[(hosts.indexOf(Mpd.host) + 1) % hosts.length];
                        },
                        textColor: menu.colors.foreground
                    },
                ]
                delegate: TextButton {
                    id: textButton
                    required property var modelData
                    textColor: modelData.textColor ?? colors.foreground
                    colors: menu.colors
                    color: colors.background

                    label: modelData.label
                    onClicked: modelData.cmd()

                    Layout.preferredWidth: 300
                    Layout.preferredHeight: textObject.primaryLineHeight + 2 * textObject.anchors.margins
                    textObject.anchors.centerIn: null
                    textObject.anchors.fill: textButton
                    textObject.anchors.margins: 22
                    textObject.horizontalAlignment: Text.AlignLeft
                    textObject.verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    component MenuButton: TextButton {
        id: menuButton
        border.color: "transparent"
        label: ""
        textObject.font.pointSize: GlobalSettings.font.pointSize * 1.5
        onClicked: menuButton.menu.visible = !menuButton.menu.visible
        property Menu menu
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

            property int tab: 1
            StackLayout {
                anchors.fill: parent
                currentIndex: floatingWindow.tab

                Item {
                    id: songMenu

                    Menu {
                        id: menu
                        colors: floatingWindow.colors
                        z: 1
                        anchors.right: songMenu.right
                        anchors.top: songMenu.top
                        anchors.topMargin: header.height
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            id: header
                            Layout.fillWidth: true
                            implicitHeight: headerContent.implicitHeight
                            MouseArea {
                                anchors.fill: parent
                                onClicked: floatingWindow.tab = 1
                            }
                            RowLayout {
                                id: headerContent
                                anchors.fill: parent
                                TitleArtist {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 0
                                    Layout.margins: 8

                                    colors: floatingWindow.colors
                                    title: Mpd.title
                                    subtitle: Mpd.artist
                                    monitor_name: floatingWindow.screen.name
                                }
                                MenuButton {
                                    Layout.preferredWidth: header.height
                                    Layout.preferredHeight: header.height
                                    colors: floatingWindow.colors
                                    menu: menu
                                }
                            }
                        }
                        // Cover
                        Item {
                            id: coverSwipe
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            property int page: 0
                            property int prevPage: -1
                            property real offset: 0
                            readonly property bool dragging: drag.active
                            property real commitFraction: 0.33
                            property real commitVelocity: 500
                            clip: true

                            Component.onCompleted: {
                                page = Math.max(0, Mpd.currentTrack - 1);
                            }

                            function goTo(index, force) {
                                var i;
                                if (force)
                                    i = index;
                                else
                                    i = Math.max(0, Math.min(repeater.count - 1, index));
                                snapAnim.stop();
                                offset += (i - page) * width;
                                prevPage = page;
                                page = i;
                                snapAnim.restart();
                            }

                            NumberAnimation {
                                id: snapAnim
                                target: coverSwipe
                                property: "offset"
                                to: 0
                                duration: 250
                                easing.type: Easing.OutCubic
                            }

                            Repeater {
                                id: repeater
                                model: Mpd.queue
                                delegate: Item {
                                    id: coverItem
                                    required property string file
                                    required property int index
                                    readonly property bool shown: Math.abs(index - coverSwipe.page) <= 1 || (snapAnim.running && index === coverSwipe.prevPage)
                                    visible: shown
                                    width: coverSwipe.width
                                    height: coverSwipe.height
                                    x: (index - coverSwipe.page) * width + coverSwipe.offset

                                    MpdCover {
                                        anchors.fill: parent
                                        colors: floatingWindow.colors
                                        store: MpdThumbs.thumbs
                                        file: coverItem.shown ? coverItem.file : ""
                                    }
                                }
                            }

                            DragHandler {
                                id: drag
                                target: null
                                yAxis.enabled: false
                                property real startOffset: 0
                                property real v: 0
                                onActiveChanged: {
                                    if (active) {
                                        snapAnim.stop();
                                        startOffset = coverSwipe.offset;
                                        v = 0;
                                    } else {
                                        const delta = coverSwipe.offset - startOffset;
                                        let target = coverSwipe.page;
                                        if (delta < -coverSwipe.width * coverSwipe.commitFraction || v < -coverSwipe.commitVelocity)
                                            target += 1;
                                        else if (delta > coverSwipe.width * coverSwipe.commitFraction || v > coverSwipe.commitVelocity)
                                            target -= 1;
                                        coverSwipe.goTo(target, false);
                                        if (coverSwipe.page + 1 !== Mpd.currentTrack)
                                            Mpd.command(`play ${coverSwipe.page + 1}`);
                                    }
                                }
                                onTranslationChanged: if (active) {
                                    coverSwipe.offset = startOffset + translation.x;
                                    v = centroid.velocity.x;
                                }
                            }

                            Connections {
                                target: Mpd
                                function onCurrentTrackChanged() {
                                    if (coverSwipe.page + 1 !== Mpd.currentTrack && !coverSwipe.dragging)
                                        coverSwipe.goTo(Mpd.currentTrack - 1, true);
                                }
                            }

                            TapHandler {
                                onTapped: Mpd.command("toggle")
                            }
                        }
                        // Progress bar
                        MpdSlider {
                            onChanged: Mpd.command(`seek ${Mpd.fmtSec(Math.round(slider.valueAt(position)))}`)
                            max: Mpd.totalTime
                            current: Mpd.currentTime
                            color: floatingWindow.colors.accent
                        }
                        RowLayout {
                            TextObject {
                                Layout.margins: 8
                                text: Mpd.currentTimeText
                                color: floatingWindow.colors.foreground
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            TextObject {
                                Layout.margins: 8
                                text: Mpd.totalTimeText
                                color: floatingWindow.colors.foreground
                            }
                            TextObject {
                                visible: Mpd.sleepTimer.gonnaPause
                                Layout.margins: 8
                                text: Mpd.sleepTimer.running ? Mpd.fmtSec(Mpd.sleepTimer.sleepRemaining) : "0:00"
                                color: floatingWindow.colors.foreground
                            }
                        }
                        RowLayout {
                            // spacing: 8
                            Layout.fillWidth: true
                            spacing: 0
                            Repeater {
                                model: [
                                    // TODO: svg icons
                                    {
                                        label: "󰑖",
                                        cmd: "repeat",
                                        textColor: Mpd.repeat ? floatingWindow.colors.foreground : floatingWindow.colors.foregroundSecondary
                                    },
                                    {
                                        label: "󰒮",
                                        cmd: "prev"
                                    },
                                    {
                                        label: Mpd.playing ? "󰏤" : "󰐊",
                                        cmd: "toggle"
                                    },
                                    {
                                        label: "󰓛",
                                        cmd: "stop"
                                    },
                                    {
                                        label: "󰒭",
                                        cmd: "next"
                                    },
                                    {
                                        label: "1",
                                        cmd: "single",
                                        textColor: Mpd.single ? floatingWindow.colors.foreground : floatingWindow.colors.foregroundSecondary
                                    },
                                ]
                                delegate: TextButton {
                                    Layout.fillWidth: true
                                    implicitWidth: 52
                                    implicitHeight: 52
                                    required property var modelData
                                    textColor: modelData.textColor ?? colors.foreground
                                    border.color: "transparent"
                                    colors: floatingWindow.colors
                                    textObject.font.pointSize: GlobalSettings.font.pointSize * 1.5
                                    label: modelData.label
                                    onClicked: Mpd.command(modelData.cmd)
                                }
                            }
                        }
                    }
                }
                Item {
                    id: tabbed
                    property int tab: 0
                    readonly property var tabNames: ["Queue", "Library", "Playlists", "Lyrics", "Info"]
                    property string openPlaylist: "" // "" = playlist list
                    Connections {
                        target: Mpd
                        function onHostChanged() {
                            tabbed.openPlaylist = "";
                        }
                    }

                    Menu {
                        id: tabbedMenu
                        colors: floatingWindow.colors
                        z: 1
                        anchors.right: tabbed.right
                        anchors.top: tabbed.top
                        anchors.topMargin: nowPlayingHeader.height
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Now playing header
                        Rectangle {
                            id: nowPlayingHeader
                            Layout.fillWidth: true
                            implicitHeight: columnLayout.implicitHeight
                            color: colors.background
                            z: 1 // for progressBar clicks

                            ColumnLayout {
                                id: columnLayout
                                anchors.fill: parent
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    implicitHeight: nowPlayingContent.implicitHeight + 16
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: floatingWindow.tab = 0
                                    }

                                    RowLayout {
                                        id: nowPlayingContent
                                        anchors.fill: parent
                                        anchors.margins: 8
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
                                                monitor_name: floatingWindow.screen.name
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
                                                    textObject.font.pointSize: GlobalSettings.font.pointSize * 1.5
                                                    label: modelData.label
                                                    onClicked: Mpd.command(modelData.cmd)
                                                }
                                            }
                                        }

                                        MenuButton {
                                            Layout.preferredWidth: header.height
                                            Layout.preferredHeight: header.height
                                            colors: floatingWindow.colors
                                            menu: tabbedMenu
                                        }
                                    }
                                }

                                // Progress bar
                                Rectangle {
                                    id: progressBar
                                    Layout.alignment: Qt.AlignLeft
                                    implicitWidth: Mpd.currentTime / Mpd.totalTime * parent.width
                                    implicitHeight: 2
                                    color: floatingWindow.colors.accent
                                }
                            }
                        }

                        // Views
                        StackLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            currentIndex: tabbed.tab

                            // Queue
                            TouchList {
                                id: queueList
                                model: Mpd.queue
                                delegate: TrackRow {
                                    required property int position
                                    monitor_name: floatingWindow.screen.name
                                    colors: floatingWindow.colors
                                    highlighted: position === Mpd.currentTrack
                                    border.width: Mpd.sleepTimer.gonnaPause && position === Mpd.sleepTimer.sleepEndIndex + 1 ? 1 : 0
                                    border.color: colors.base0F
                                    onTapped: {
                                        queueList.ignoreNextChange = true;
                                        Mpd.command(`play ${position}`);
                                    }
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
                                    label: "󰹹"
                                    textObject.font.pointSize: GlobalSettings.font.pointSize * 1.5
                                    onClicked: queueList.view.positionViewAtIndex(Mpd.currentTrack - 1, ListView.Center)
                                }
                                property int lastTrack: Mpd.currentTrack
                                property bool ignoreNextChange: false
                                property real lastHeight: view.height
                                property bool wannaCenter: true // center on start

                                function tryCenter() {
                                    if (!wannaCenter)
                                        return;
                                    if (Mpd.currentTrack <= 0) {
                                        wannaCenter = false;
                                        return;
                                    }
                                    view.positionViewAtIndex(Mpd.currentTrack - 1, ListView.Center);
                                    const item = view.itemAtIndex(Mpd.currentTrack - 1);
                                    if (item && (view.atYEnd || Math.abs(item.y + item.height / 2 - (view.contentY + view.height / 2)) < 1))
                                        wannaCenter = false;
                                }
                                Connections {
                                    target: queueList.view
                                    function onContentHeightChanged() {
                                        queueList.tryCenter();
                                    }
                                }
                                Connections {
                                    target: Mpd
                                    function onCurrentTrackChanged() {
                                        const prev = queueList.view.itemAtIndex(queueList.lastTrack - 1);
                                        if (!prev) {
                                            if (Mpd.currentTrack !== 0) {
                                                queueList.wannaCenter = true;
                                                queueList.tryCenter();
                                            }
                                            return;
                                        } else if (!queueList.ignoreNextChange) {
                                            const wasVisible = prev.y + prev.height > queueList.view.contentY && prev.y < queueList.view.contentY + queueList.view.height;
                                            const amount = Mpd.currentTrack - queueList.lastTrack;
                                            if (wasVisible && !queueList.interacting)
                                                queueList.view.contentY = queueList.clampY(queueList.view.contentY + prev.height * amount + queueList.view.spacing);
                                        }
                                        queueList.ignoreNextChange = false;
                                        queueList.lastTrack = Mpd.currentTrack;
                                    }
                                }
                                onHeightChanged: {
                                    const current = queueList.view.itemAtIndex(Mpd.currentTrack - 1);
                                    const wasVisible = current && current.y + current.height > view.contentY && current.y < view.contentY + lastHeight;
                                    if (wasVisible && !queueList.interacting)
                                        queueList.view.positionViewAtIndex(Mpd.currentTrack - 1, ListView.Contain);
                                    lastHeight = view.height;
                                }
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
                                        monitor_name: floatingWindow.screen.name
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
                                currentIndex: tabbed.openPlaylist === "" ? 0 : 1

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
                                                tabbed.openPlaylist = plRow.name;
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
                                                text: "← " + tabbed.openPlaylist
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
                                                        Mpd.command(`load "${tabbed.openPlaylist}"`);
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
                                            onClicked: tabbed.openPlaylist = ""
                                        }
                                    }
                                    TouchList {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        model: Mpd.playlist
                                        delegate: TrackRow {
                                            monitor_name: floatingWindow.screen.name
                                            colors: floatingWindow.colors
                                            required property int position
                                            onTapped: {
                                                Mpd.command(`clear`);
                                                Mpd.command(`load "${tabbed.openPlaylist}"`);
                                                Mpd.command(`play ${position}`);
                                            }
                                        }
                                    }
                                }
                            }

                            // Lyrics
                            TouchFlick {
                                contentHeight: lyricsText.height + 24
                                SelectableText {
                                    id: lyricsText
                                    x: 12
                                    y: 12
                                    colors: floatingWindow.colors
                                    width: parent.width - 24
                                    text: Mpd.lyrics
                                    QocrPopup {
                                        anchors.fill: parent
                                        textTarget: lyricsText
                                        monitor_name: floatingWindow.screen.name
                                    }
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
                                        value: Mpd.tags?.ARTISTS?.split(";").join(", ") ?? ""
                                    },
                                    {
                                        key: "File",
                                        value: Mpd.file
                                    },
                                    {
                                        key: "Genres",
                                        value: Mpd.tags?.GENRE?.split(";").join(", ") ?? ""
                                    },
                                    {
                                        key: "PURL",
                                        value: Mpd.tags?.PURL ?? ""
                                    },
                                    {
                                        key: "Date",
                                        value: Mpd.tags?.DATE ?? ""
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
                                            QocrPopup {
                                                anchors.fill: parent
                                                textTarget: parent
                                                monitor_name: floatingWindow.screen.name
                                            }
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
                                model: tabbed.tabNames
                                delegate: Rectangle {
                                    required property int index
                                    required property string modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 52
                                    property bool active: tabbed.tab === index
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
                                        onClicked: tabbed.tab = index
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
