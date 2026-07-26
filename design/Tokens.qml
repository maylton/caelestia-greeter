pragma Singleton

import QtQuick

QtObject {
    readonly property string fontBody: "Inter"
    readonly property string fontDisplay: "Inter Display"

    readonly property color colorText: "#fff8f7"
    readonly property color colorTextMuted: "#d7c3c8"
    readonly property color colorSurface: "#df20212c"
    readonly property color colorSurfaceContainer: "#b52c2b38"
    readonly property color colorSurfacePressed: "#d13a3948"
    readonly property color colorOutline: "#66ffffff"

    readonly property color colorPrimary: "#ffd9e3"
    readonly property color colorPrimaryPressed: "#efc5d2"
    readonly property color colorPrimaryText: "#4a1227"
    readonly property color colorPrimaryContainer: "#bcffcadb"
    readonly property color colorPrimaryContainerText: "#4d1328"

    readonly property color colorSecondaryContainer: "#c7e8defd"
    readonly property color colorSecondaryContainerText: "#2d1737"

    readonly property color colorField: "#8f24232e"
    readonly property color colorFieldActive: "#b632303e"
    readonly property color colorDisabled: "#66302e38"

    readonly property color colorErrorText: "#ffb4ab"
    readonly property color colorErrorContainer: "#bb5a1b25"
    readonly property color colorErrorContainerPressed: "#d46b2833"
    readonly property color colorErrorOutline: "#80ffb4ab"
    readonly property color colorErrorContainerText: "#ffe9e6"

    readonly property int radiusXL: 34
    readonly property int durationShort: 120
    readonly property int durationMedium: 220
    readonly property int durationLong: 440
}
