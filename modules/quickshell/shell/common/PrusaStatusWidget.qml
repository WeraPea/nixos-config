import "config"

TextObject {
    text: PrusaStatus.status
    visible: text != ""
    color: Colors.foreground
}
