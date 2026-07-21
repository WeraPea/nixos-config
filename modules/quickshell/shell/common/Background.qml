import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property var colors
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore
    color: colors.background

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
}
