pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

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
            console.warn("Lumina Greeter: invalid config/defaults.json:", error);
            return ({});
        }
    }

    readonly property string clockLayout: {
        const override = Quickshell.env("LUMINA_GREETER_CLOCK_LAYOUT") || "";
        if (override === "stacked" || override === "horizontal")
            return override;

        return values.clockLayout === "horizontal" ? "horizontal" : "stacked";
    }

    readonly property string defaultUser: {
        const override = Quickshell.env("LUMINA_GREETER_USER") || "";
        return override.length > 0 ? override : (values.defaultUser || "");
    }

    readonly property bool loginStartsOpen: values.loginStartsOpen === true

    readonly property var sessions: {
        if (Array.isArray(values.sessions) && values.sessions.length > 0)
            return values.sessions;

        return [{ "name": "Niri", "command": ["niri-session"] }];
    }

    readonly property string wallpaperSource: {
        const override = Quickshell.env("LUMINA_GREETER_WALLPAPER") || "";
        const configured = override.length > 0
            ? override
            : (values.wallpaper || "assets/default-wallpaper.svg");

        if (configured.startsWith("file:") || configured.startsWith("qrc:"))
            return configured;
        if (configured.startsWith("/"))
            return "file://" + configured;

        return Qt.resolvedUrl("../" + configured);
    }
}
