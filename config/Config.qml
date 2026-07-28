pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    function env(primaryName, legacyName) {
        const primary = Quickshell.env(primaryName) || "";
        if (primary.length > 0)
            return primary;

        return legacyName ? (Quickshell.env(legacyName) || "") : "";
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

    readonly property string stateDir: {
        const override = env("CAELESTIA_GREETER_STATE_DIR", "");
        if (override.length > 0)
            return override;

        const home = Quickshell.env("HOME") || "";
        const stateHome = Quickshell.env("XDG_STATE_HOME") || (home.length > 0 ? home + "/.local/state" : "");
        return stateHome.length > 0 ? stateHome + "/caelestia" : "";
    }

    readonly property string schemePath: {
        const override = env("CAELESTIA_GREETER_SCHEME_PATH", "");
        if (override.length > 0)
            return override;

        return stateDir.length > 0 ? stateDir + "/scheme.json" : "";
    }

    FileView {
        id: wallpaperStateFile

        path: root.stateDir.length > 0
            ? root.stateDir + "/wallpaper/path.txt"
            : ""
        blockLoading: true
        watchChanges: true
        printErrors: false
    }

    readonly property string currentCaelestiaWallpaper: {
        try {
            return wallpaperStateFile.text().trim();
        } catch (error) {
            return "";
        }
    }

    readonly property string clockLayout: {
        const override = env("CAELESTIA_GREETER_CLOCK_LAYOUT", "LUMINA_GREETER_CLOCK_LAYOUT");
        if (override === "stacked" || override === "horizontal")
            return override;

        return values.clockLayout === "horizontal" ? "horizontal" : "stacked";
    }

    readonly property string defaultUser: {
        const override = env("CAELESTIA_GREETER_USER", "LUMINA_GREETER_USER");
        return override.length > 0 ? override : (values.defaultUser || "");
    }

    readonly property string displayName: {
        const override = env("CAELESTIA_GREETER_DISPLAY_NAME", "LUMINA_GREETER_DISPLAY_NAME");
        if (override.length > 0)
            return override;
        if (typeof values.displayName === "string" && values.displayName.length > 0)
            return values.displayName;
        return defaultUser;
    }

    readonly property string avatarSource: {
        const override = env("CAELESTIA_GREETER_AVATAR", "LUMINA_GREETER_AVATAR");
        const configured = override.length > 0
            ? override
            : (values.avatar || "");

        if (configured.length === 0)
            return "";
        if (configured.startsWith("file:") || configured.startsWith("qrc:"))
            return configured;
        if (configured.startsWith("/"))
            return "file://" + configured;

        return Qt.resolvedUrl("../" + configured);
    }

    readonly property string language: {
        const override = env("CAELESTIA_GREETER_LANGUAGE", "LUMINA_GREETER_LANGUAGE");
        return override.length > 0 ? override : (values.language || "system");
    }

    readonly property bool loginStartsOpen: values.loginStartsOpen !== false

    readonly property var sessions: {
        if (Array.isArray(values.sessions) && values.sessions.length > 0)
            return values.sessions;

        return [{ "name": "Caelestia", "command": ["/usr/bin/Hyprland"] }];
    }

    readonly property string wallpaperSource: {
        const override = env("CAELESTIA_GREETER_WALLPAPER", "LUMINA_GREETER_WALLPAPER");
        let configured = override.length > 0
            ? override
            : (values.wallpaper || "caelestia");

        if (configured === "caelestia")
            configured = currentCaelestiaWallpaper;

        if (configured.length === 0)
            configured = "assets/default-wallpaper.svg";
        if (configured.startsWith("file:") || configured.startsWith("qrc:"))
            return configured;
        if (configured.startsWith("/"))
            return "file://" + configured;

        return Qt.resolvedUrl("../" + configured);
    }
}
