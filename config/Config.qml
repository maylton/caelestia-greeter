pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    function env(name) {
        return Quickshell.env(name) || "";
    }

    FileView {
        id: defaultsFile

        path: Qt.resolvedUrl("defaults.json")
        blockLoading: true
        watchChanges: true
    }

    readonly property var values: {
        try {
            const parsed = JSON.parse(defaultsFile.text());
            return parsed && typeof parsed === "object" ? parsed : ({});
        } catch (error) {
            console.warn("Caelestia Greeter: invalid config/defaults.json:", error);
            return ({});
        }
    }

    readonly property string homeDir: env("HOME")
    readonly property string configHome: env("XDG_CONFIG_HOME")
        || (homeDir ? `${homeDir}/.config` : "")
    readonly property string shellConfigPath: env("CAELESTIA_GREETER_SHELL_CONFIG_PATH")
        || (configHome ? `${configHome}/caelestia/shell.json` : "")

    readonly property string stateDir: {
        const override = env("CAELESTIA_GREETER_STATE_DIR");
        if (override)
            return override;

        const stateHome = env("XDG_STATE_HOME") || (homeDir ? `${homeDir}/.local/state` : "");
        return stateHome ? `${stateHome}/caelestia` : "";
    }

    readonly property string schemePath: env("CAELESTIA_GREETER_SCHEME_PATH")
        || (stateDir ? `${stateDir}/scheme.json` : "")

    FileView {
        id: wallpaperStateFile

        path: root.stateDir ? `${root.stateDir}/wallpaper/path.txt` : ""
        blockLoading: true
        watchChanges: true
        printErrors: false
    }

    readonly property string currentWallpaper: {
        try {
            return wallpaperStateFile.text().trim();
        } catch (error) {
            return "";
        }
    }

    readonly property string defaultUser: env("CAELESTIA_GREETER_USER")
        || values.defaultUser
        || ""

    readonly property string displayName: env("CAELESTIA_GREETER_DISPLAY_NAME")
        || values.displayName
        || defaultUser

    readonly property string avatarSource: resolveSource(
        env("CAELESTIA_GREETER_AVATAR") || values.avatar || ""
    )

    readonly property string language: env("CAELESTIA_GREETER_LANGUAGE")
        || values.language
        || "system"

    readonly property bool loginStartsOpen: values.loginStartsOpen !== false

    readonly property var sessions: Array.isArray(values.sessions) && values.sessions.length > 0
        ? values.sessions
        : [{ "name": "Caelestia", "command": ["/usr/local/bin/caelestia-session"] }]

    readonly property string wallpaperSource: {
        let configured = env("CAELESTIA_GREETER_WALLPAPER")
            || values.wallpaper
            || "caelestia";

        if (configured === "caelestia")
            configured = currentWallpaper;

        return resolveSource(configured || "assets/default-wallpaper.svg");
    }

    function resolveSource(path) {
        if (!path)
            return "";
        if (path.startsWith("file:") || path.startsWith("qrc:"))
            return path;
        if (path.startsWith("/"))
            return `file://${path}`;
        return Qt.resolvedUrl(`../${path}`);
    }
}
