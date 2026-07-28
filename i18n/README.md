# Translations

Caelestia Greeter keeps user-facing strings in JSON catalogs.

- `en.json` is the required fallback catalog.
- `pt-BR.json` provides Brazilian Portuguese.
- `I18n.qml` detects the system locale, loads the matching catalog and falls back to English for missing keys.

## Adding a language

1. Copy `en.json` to a new file using a BCP 47 language tag, such as `es.json` or `fr-FR.json`.
2. Translate values without changing their keys.
3. Add the locale mapping to `languageFromLocale()` and `localeName` in `I18n.qml`.
4. Test with `CAELESTIA_GREETER_LANGUAGE=<tag> ./scripts/run-preview.sh`.

Keep `date.pattern` compatible with Qt date format strings.
