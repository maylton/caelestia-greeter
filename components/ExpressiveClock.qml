import Quickshell
import QtQuick
import "../design"
import "../i18n"

Item {
    id: root

    property real baseSize: 180

    readonly property real centerScale: Math.min(1, baseSize / 360)
    readonly property real headlinePointSize: 224 * centerScale
    readonly property real titlePointSize: 16 * centerScale
    readonly property real clockGap: 8 * centerScale

    function topOffset(metrics) {
        return metrics.tightBoundingRect.y - metrics.boundingRect.y;
    }

    implicitWidth: content.width
    implicitHeight: content.implicitHeight

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Column {
        id: content

        anchors.centerIn: parent
        width: Math.max(clockFace.width, dateHolder.width)
        spacing: 22 * root.centerScale

        Item {
            id: clockFace

            x: Math.round((parent.width - width) / 2)
            width: hours.implicitWidth + minutes.implicitWidth + root.clockGap
            height: Math.max(
                hourMetrics.tightBoundingRect.height,
                minuteMetrics.tightBoundingRect.height
            )

            Text {
                id: hours

                y: -root.topOffset(hourMetrics)
                text: Qt.formatTime(systemClock.date, "HH")
                color: Theme.colorPrimary
                font.family: Theme.fontHeadline
                font.pointSize: root.headlinePointSize
                font.weight: Font.Medium
                font.variableAxes: ({
                    "opsz": root.headlinePointSize,
                    "wght": 500,
                    "wdth": 30,
                    "ROND": 25
                })

                TextMetrics {
                    id: hourMetrics
                    text: hours.text
                    font: hours.font
                }
            }

            Text {
                id: minutes

                anchors.right: parent.right
                y: -root.topOffset(minuteMetrics)
                text: Qt.formatTime(systemClock.date, "mm")
                color: Theme.colorSecondary
                font.family: Theme.fontHeadline
                font.pointSize: root.headlinePointSize
                font.weight: Font.Medium
                font.variableAxes: ({
                    "opsz": root.headlinePointSize,
                    "wght": 500,
                    "wdth": 30,
                    "ROND": 25
                })

                TextMetrics {
                    id: minuteMetrics
                    text: minutes.text
                    font: minutes.font
                }
            }
        }

        Item {
            id: dateHolder

            x: Math.round((parent.width - width) / 2)
            width: dateLabel.implicitWidth
            height: dateLabel.implicitHeight

            Text {
                id: dateLabel

                anchors.centerIn: parent
                text: I18n.formatDate(systemClock.date).toUpperCase()
                color: Theme.colorText
                font.family: Theme.fontTitle
                font.pointSize: root.titlePointSize
                font.weight: Font.DemiBold
                font.variableAxes: ({
                    "opsz": root.titlePointSize,
                    "wght": 600,
                    "ROND": 25
                })
            }
        }
    }
}
