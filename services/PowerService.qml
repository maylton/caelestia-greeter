pragma Singleton

import Quickshell
import QtQuick

Singleton {
    function powerOff() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }
}
