pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME")
        || (Quickshell.env("HOME") ? `${Quickshell.env("HOME")}/.cache` : "/tmp")
    readonly property string statePath: Quickshell.env("CAELESTIA_GREETER_PREFERENCES_PATH")
        || `${cacheHome}/caelestia-greeter-preferences.json`

    property string lastSessionKey: ""
    property bool initialised: false

    function load() {
        if (initialised)
            return;

        initialised = true;
        if (!preferencesFile.path)
            return;

        try {
            const text = preferencesFile.text().trim();
            if (!text)
                return;

            const parsed = JSON.parse(text);
            lastSessionKey = typeof parsed.lastSessionKey === "string"
                ? parsed.lastSessionKey
                : "";
        } catch (error) {
            console.warn("Caelestia Greeter: invalid preferences file:", error);
        }
    }

    function rememberSession(sessionKey) {
        const key = String(sessionKey || "");
        if (!key || key === lastSessionKey)
            return;

        lastSessionKey = key;
        if (!preferencesFile.path)
            return;

        preferencesFile.setText(JSON.stringify({
            "version": 1,
            "lastSessionKey": key
        }, null, 2) + "\n");
    }

    Component.onCompleted: load()

    FileView {
        id: preferencesFile

        path: root.statePath
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        printErrors: false

        onLoaded: root.load()
        onLoadFailed: root.initialised = true
        onSaveFailed: error => {
            console.warn("Caelestia Greeter: failed to save preferences:", error);
        }
    }
}
