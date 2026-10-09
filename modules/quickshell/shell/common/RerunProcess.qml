import Quickshell.Io

Process {
    property bool restart: false
    function rerun() {
        if (running) {
            restart = true;
            running = false;
        } else {
            running = true;
        }
    }
    onExited: if (restart) {
        restart = false;
        running = true;
    }
}
