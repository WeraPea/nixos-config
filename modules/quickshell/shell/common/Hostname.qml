pragma Singleton
import Quickshell.Io

Process {
    property string hostname
    running: true
    command: ["hostname"]
    stdout: StdioCollector {
        onStreamFinished: hostname = this.text
    }
}
