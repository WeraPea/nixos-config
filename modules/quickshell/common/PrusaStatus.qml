pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string status
    Process {
        command: ["prusa-status"]
        running: true
        stdout: SplitParser {
            onRead: line => root.status = line
        }
    }
}
