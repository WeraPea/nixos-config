import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var store
    required property var colors
    property alias thumb: thumb
    property string file: ""
    property int size: 40
    readonly property real aspect: thumb.implicitHeight > 0 ? thumb.implicitWidth / thumb.implicitHeight : 1
    Layout.preferredWidth: size * 16 / 9 // most thumbnail are video thumbnails
    Layout.preferredHeight: size
    color: thumb.status != Image.Null ? "transparent" : root.colors.foregroundSecondary
    MpdThumb {
        id: thumb
        anchors.fill: parent
        store: parent.store
        file: parent.file
    }
}
