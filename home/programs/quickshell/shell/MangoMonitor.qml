import QtQuick

QtObject {
    property string name
    property bool selmon
    property int x
    property int y
    property int width
    property int height
    property list<MangoTag> tags
    property string appid
    property string title
    property string layout
    property bool fullscreen // TODO: is it bool?
    property bool floating
    property string last_layer
    property string kb_layout
    property string keymode
    property string clients
}
