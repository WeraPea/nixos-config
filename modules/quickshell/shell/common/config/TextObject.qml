import QtQuick
import QtQuick.Layouts

Text {
    id: root
    font: GlobalSettings.font

    FontMetrics {
        id: fontMetrics
        font: root.font
    }

    readonly property real primaryLineHeight: Math.ceil(fontMetrics.height)

    height: primaryLineHeight
    Layout.preferredHeight: primaryLineHeight

    transform: Translate {
        y: Math.round(fontMetrics.ascent - root.baselineOffset + root.topPadding)
    }
}
