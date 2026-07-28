import Quickshell
import QtQuick
import "../design"
import "../i18n"

Item {
    id: root

    property real baseSize: 210

    readonly property real clockGap: Math.max(8, Math.round(baseSize * 0.035))
    readonly property real dateSize: Math.max(15, Math.min(20, baseSize * 0.085))

    function topOffset(metrics) {
        return metrics.tightBoundingRect.y - metrics.boundingRect.y;
    }

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Column {
        id: content

        anchors.centerIn: parent
        spacing: Math.max(16, Math.round(root.baseSize * 0.09))

        Item {
            id: clockFace

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: hours.implicitWidth + minutes.implicitWidth + root.clockGap
            implicitHeight: Math.max(
                hourMetrics.tightBoundingRect.height,
                minuteMetrics.tightBoundingRect.height
            )

            Text {
                id: hours

                y: -root.topOffset(hourMetrics)
                text: Qt.formatTime(systemClock.date, "HH")
                color: Theme.colorPrimary
                font.family: Theme.fontDisplay
                font.pixelSize: root.baseSize
                font.weight: Font.Normal
                font.stretch: Font.UltraCondensed
                font.variableAxes: ({ "wdth": 30 })

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
                font.family: Theme.fontDisplay
                font.pixelSize: root.baseSize
                font.weight: Font.Normal
                font.stretch: Font.UltraCondensed
                font.variableAxes: ({ "wdth": 30 })

                TextMetrics {
                    id: minuteMetrics
                    text: minutes.text
                    font: minutes.font
                }
            }
        }

        Text {
            id: dateLabel

            anchors.horizontalCenter: parent.horizontalCenter
            text: I18n.formatDate(systemClock.date).toUpperCase()
            color: Theme.colorText
            font.family: Theme.fontBody
            font.pixelSize: root.dateSize
            font.weight: Font.DemiBold
        }
    }
}
