import QtQuick
import "config"

TextObject {
    required property var colors
    property string format: "ddd MMM d hh:mm"
    color: colors.foreground
    text: Qt.formatDateTime(Time.date, format)
}
