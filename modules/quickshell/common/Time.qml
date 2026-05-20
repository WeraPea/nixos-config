pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property var date: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
