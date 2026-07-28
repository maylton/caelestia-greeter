pragma Singleton

import QtQuick

QtObject {
    readonly property int standardSmall: 0
    readonly property int standard: 1
    readonly property int standardLarge: 2
    readonly property int standardExtraLarge: 3
    readonly property int emphasizedSmall: 4
    readonly property int emphasized: 5
    readonly property int emphasizedLarge: 6
    readonly property int emphasizedExtraLarge: 7
    readonly property int fastSpatial: 8
    readonly property int defaultSpatial: 9
    readonly property int slowSpatial: 10
    readonly property int fastEffects: 11
    readonly property int defaultEffects: 12
    readonly property int slowEffects: 13

    readonly property var standardCurve: [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedCurve: [
        0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4,
        5 / 24, 0.82, 0.25, 1, 1, 1
    ]
    readonly property var fastSpatialCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
    readonly property var defaultSpatialCurve: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property var slowSpatialCurve: [0.39, 1.29, 0.35, 0.98, 1, 1]
    readonly property var fastEffectsCurve: [0.31, 0.94, 0.34, 1, 1, 1]
    readonly property var defaultEffectsCurve: [0.34, 0.8, 0.34, 1, 1, 1]
    readonly property var slowEffectsCurve: [0.34, 0.88, 0.34, 1, 1, 1]

    function duration(type) {
        switch (type) {
        case standardSmall:
        case emphasizedSmall:
            return 200;
        case standard:
        case emphasized:
            return 400;
        case standardLarge:
        case emphasizedLarge:
            return 600;
        case standardExtraLarge:
        case emphasizedExtraLarge:
            return 1000;
        case fastSpatial:
            return 350;
        case defaultSpatial:
            return 500;
        case slowSpatial:
            return 650;
        case fastEffects:
            return 150;
        case defaultEffects:
            return 200;
        case slowEffects:
            return 300;
        default:
            return 400;
        }
    }

    function curve(type) {
        switch (type) {
        case emphasizedSmall:
        case emphasized:
        case emphasizedLarge:
        case emphasizedExtraLarge:
            return emphasizedCurve;
        case fastSpatial:
            return fastSpatialCurve;
        case defaultSpatial:
            return defaultSpatialCurve;
        case slowSpatial:
            return slowSpatialCurve;
        case fastEffects:
            return fastEffectsCurve;
        case defaultEffects:
            return defaultEffectsCurve;
        case slowEffects:
            return slowEffectsCurve;
        default:
            return standardCurve;
        }
    }
}
