pragma Singleton
import QtQuick
import Quickshell
import "../"

Singleton {
    readonly property font font: Qt.font({
        // font HAS to have cjk characters in it, or any text with cjk chars gets misaligned
        family: "UDEVGothic35HSDZNFLG",
        pointSize: 13
    })
}
