import QtQuick
import "../design"

NumberAnimation {
    property int type: Motion.defaultSpatial

    duration: Motion.duration(type)
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.curve(type)
}
