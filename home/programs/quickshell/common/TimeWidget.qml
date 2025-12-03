import QtQuick
import "config"

TextObject {
    property string format: "ddd MMM d hh:mm"
    color: Colors.foreground
    text: Qt.formatDateTime(Time.date, format)
}
