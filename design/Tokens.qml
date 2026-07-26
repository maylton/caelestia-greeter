pragma Singleton

import QtQuick

QtObject {
    readonly property string fontFamily: "Inter"
    readonly property string displayFontFamily: "Inter Display"

    readonly property color onSurface: "#fff8f7"
    readonly property color onSurfaceMuted: "#d7c3c8"
    readonly property color surface: "#df20212c"
    readonly property color surfaceContainer: "#b52c2b38"
    readonly property color surfacePressed: "#d13a3948"
    readonly property color outline: "#66ffffff"

    readonly property color primary: "#ffd9e3"
    readonly property color primaryPressed: "#efc5d2"
    readonly property color onPrimary: "#4a1227"
    readonly property color primaryContainer: "#bcffcadb"
    readonly property color onPrimaryContainer: "#4d1328"

    readonly property color secondaryContainer: "#c7e8defd"
    readonly property color onSecondaryContainer: "#2d1737"

    readonly property color field: "#8f24232e"
    readonly property color fieldActive: "#b632303e"
    readonly property color disabled: "#66302e38"

    readonly property color error: "#ffb4ab"
    readonly property color errorContainer: "#bb5a1b25"
    readonly property color errorPressed: "#d46b2833"
    readonly property color errorOutline: "#80ffb4ab"
    readonly property color onErrorContainer: "#ffe9e6"

    readonly property int radiusExtraLarge: 34
    readonly property int motionShort: 120
    readonly property int motionMedium: 220
    readonly property int motionLong: 440
}
