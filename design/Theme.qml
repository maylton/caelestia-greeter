pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

Singleton {
    id: root

    readonly property string fontBody: Quickshell.env("CAELESTIA_GREETER_FONT_BODY") || "Inter"
    readonly property string fontDisplay: Quickshell.env("CAELESTIA_GREETER_FONT_DISPLAY") || "Inter Display"

    FileView {
        id: schemeFile

        path: Config.schemePath
        blockLoading: true
        watchChanges: true
        printErrors: false
    }

    readonly property var schemeData: {
        try {
            const contents = schemeFile.text();
            if (!contents || contents.trim().length === 0)
                return ({});

            const parsed = JSON.parse(contents);
            return parsed && typeof parsed === "object" ? parsed : ({});
        } catch (error) {
            console.warn("Caelestia Greeter: invalid Caelestia scheme:", error);
            return ({});
        }
    }

    readonly property var schemeColours: schemeData.colours
        && typeof schemeData.colours === "object"
        ? schemeData.colours
        : ({})
    readonly property bool light: schemeData.mode === "light"

    function colour(name, darkFallback, lightFallback) {
        const value = root.schemeColours[name];
        if (typeof value === "string" && value.length > 0)
            return value.startsWith("#") ? value : "#" + value;

        return root.light ? lightFallback : darkFallback;
    }

    function withAlpha(value, alpha) {
        return Qt.rgba(value.r, value.g, value.b, alpha);
    }

    readonly property color baseText: colour("onSurface", "#efdfe2", "#211a1d")
    readonly property color baseTextMuted: colour("onSurfaceVariant", "#d5c2c6", "#524347")
    readonly property color baseSurface: colour("surfaceContainerHigh", "#31282a", "#ede0e3")
    readonly property color baseSurfaceContainer: colour("surfaceContainer", "#261d20", "#f3e6e9")
    readonly property color baseSurfaceHighest: colour("surfaceContainerHighest", "#3c3235", "#e7dadd")
    readonly property color baseOutline: colour("outlineVariant", "#514347", "#d5c2c6")
    readonly property color baseScrim: colour("scrim", "#000000", "#000000")

    readonly property color colorText: baseText
    readonly property color colorTextMuted: baseTextMuted
    readonly property color colorSurface: withAlpha(baseSurface, 0.90)
    readonly property color colorSurfaceContainer: withAlpha(baseSurfaceContainer, 0.82)
    readonly property color colorSurfacePressed: withAlpha(baseSurfaceHighest, 0.96)
    readonly property color colorOutline: withAlpha(baseOutline, 0.82)

    readonly property color colorPrimary: colour("primary", "#ffb0ca", "#8b4a62")
    readonly property color colorPrimaryPressed: colour("primaryFixedDim", "#ffb0ca", "#a8627b")
    readonly property color colorPrimaryText: colour("onPrimary", "#541d34", "#ffffff")
    readonly property color colorPrimaryContainer: withAlpha(colour("primaryContainer", "#6f334a", "#ffd9e3"), 0.94)
    readonly property color colorPrimaryContainerText: colour("onPrimaryContainer", "#ffd9e3", "#3a071e")

    readonly property color colorSecondaryContainer: withAlpha(colour("secondaryContainer", "#5a3f48", "#ffd9e3"), 0.94)
    readonly property color colorSecondaryContainerText: colour("onSecondaryContainer", "#ffd9e3", "#2a151c")
    readonly property color colorTertiaryContainer: withAlpha(colour("tertiaryContainer", "#654524", "#ffdcc2"), 0.90)
    readonly property color colorTertiaryContainerText: colour("onTertiaryContainer", "#ffdcc2", "#2f1500")

    readonly property color colorField: withAlpha(baseSurfaceHighest, 0.76)
    readonly property color colorFieldActive: withAlpha(baseSurfaceHighest, 0.94)
    readonly property color colorDisabled: withAlpha(colour("surfaceVariant", "#514347", "#eadde0"), 0.48)

    readonly property color colorErrorText: colour("error", "#ffb4ab", "#ba1a1a")
    readonly property color colorErrorContainer: withAlpha(colour("errorContainer", "#93000a", "#ffdad6"), 0.90)
    readonly property color colorErrorContainerPressed: withAlpha(colour("error", "#ffb4ab", "#ba1a1a"), 0.88)
    readonly property color colorErrorOutline: withAlpha(colour("error", "#ffb4ab", "#ba1a1a"), 0.62)
    readonly property color colorErrorContainerText: colour("onErrorContainer", "#ffdad6", "#410002")

    readonly property color scrimTop: withAlpha(baseScrim, light ? 0.16 : 0.24)
    readonly property color scrimMiddle: withAlpha(baseScrim, light ? 0.08 : 0.12)
    readonly property color scrimBottom: withAlpha(baseScrim, light ? 0.42 : 0.54)
    readonly property color loginScrim: withAlpha(baseScrim, light ? 0.18 : 0.30)

    readonly property int radiusXL: 34
    readonly property int durationShort: 120
    readonly property int durationMedium: 220
    readonly property int durationLong: 440
}
