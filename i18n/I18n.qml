pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config"

Singleton {
    id: root

    readonly property string activeLanguage: resolveLanguage(Config.language)
    readonly property string localeName: activeLanguage === "pt-BR" ? "pt_BR" : "en_US"
    readonly property var locale: Qt.locale(localeName)

    FileView {
        id: fallbackFile
        path: Qt.resolvedUrl("en.json")
        blockLoading: true
        watchChanges: true
    }

    FileView {
        id: localizedFile
        path: Qt.resolvedUrl(root.activeLanguage + ".json")
        blockLoading: true
        watchChanges: true
    }

    readonly property var fallbackMessages: parseFile(fallbackFile, "en")
    readonly property var localizedMessages: root.activeLanguage === "en"
        ? fallbackMessages
        : parseFile(localizedFile, root.activeLanguage)

    function normalizeLocale(value) {
        let normalized = (value || "").trim();
        if (normalized.length === 0)
            return "";

        normalized = normalized.split(".")[0];
        normalized = normalized.split("@")[0];
        return normalized.replace(/_/g, "-");
    }

    function languageFromLocale(value) {
        const normalized = normalizeLocale(value).toLowerCase();
        if (normalized === "c" || normalized === "posix")
            return "en";
        if (normalized.startsWith("pt"))
            return "pt-BR";
        if (normalized.startsWith("en"))
            return "en";
        return "";
    }

    function resolveLanguage(requestedLanguage) {
        const requested = normalizeLocale(requestedLanguage);
        if (requested.length > 0 && requested.toLowerCase() !== "system") {
            const explicitLanguage = languageFromLocale(requested);
            return explicitLanguage.length > 0 ? explicitLanguage : "en";
        }

        const candidates = [
            Quickshell.env("LC_ALL") || "",
            Quickshell.env("LC_MESSAGES") || "",
            Quickshell.env("LANG") || "",
            Qt.locale().name || ""
        ];

        for (const candidate of candidates) {
            const detectedLanguage = languageFromLocale(candidate);
            if (detectedLanguage.length > 0)
                return detectedLanguage;
        }

        return "en";
    }

    function parseFile(file, languageName) {
        try {
            const contents = file.text();
            if (!contents || contents.trim().length === 0)
                return ({});

            const parsed = JSON.parse(contents);
            return parsed && typeof parsed === "object" ? parsed : ({});
        } catch (parseError) {
            console.warn("Lumina Greeter: invalid translation file for", languageName, parseError);
            return ({});
        }
    }

    function lookup(source, key) {
        if (!source || typeof source !== "object")
            return undefined;

        const parts = key.split(".");
        let current = source;
        for (const part of parts) {
            if (!current || typeof current !== "object" || !(part in current))
                return undefined;
            current = current[part];
        }
        return current;
    }

    function t(key) {
        const localized = lookup(localizedMessages, key);
        if (typeof localized === "string")
            return localized;

        const fallback = lookup(fallbackMessages, key);
        if (typeof fallback === "string")
            return fallback;

        return key;
    }

    function capitalizeFirst(value) {
        if (!value || value.length === 0)
            return value;
        return value.charAt(0).toLocaleUpperCase() + value.slice(1);
    }

    function formatDate(date) {
        const formatted = date.toLocaleDateString(locale, t("date.pattern"));
        return capitalizeFirst(formatted);
    }
}
