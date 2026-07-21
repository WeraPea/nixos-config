import "config"

TextObject {
    required property var colors
    text: PrusaStatus.status
    visible: text != ""
    color: colors.foreground
}
