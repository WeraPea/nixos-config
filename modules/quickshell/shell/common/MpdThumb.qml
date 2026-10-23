import QtQuick

Image {
    id: thumb
    required property var store
    property string file: ""
    readonly property string key: file === "" ? "" : Qt.md5(file)
    asynchronous: true
    cache: false
    fillMode: Image.PreserveAspectFit
    mipmap: true
    source: {
        thumb.store.rev;
        return key !== "" && store.has(key) ? "file://" + Mpd.cache_dir + "/" + key + ".img" : "";
    }
    onFileChanged: store.request(file)
    Component.onCompleted: store.request(file)
    Component.onDestruction: store.cancel(file)
}
