import QtQuick
import "../design"

ColorAnimation {
    property int type: Motion.defaultEffects

    duration: Motion.duration(type)
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.curve(type)
}
