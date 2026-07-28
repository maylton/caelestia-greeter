import Quickshell
import QtQuick
import "../design"
import "../i18n"

Item {
    id: root

    property string layoutMode: "stacked"
    property real baseSize: 180

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Column {
        id: content

        anchors.centerIn: parent
        spacing: 16

        Loader {
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: root.layoutMode === "horizontal"
                ? horizontalClock
                : stackedClock
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: dateLabel.implicitWidth + 34
            height: 42
            radius: height / 2
            color: Theme.colorTertiaryContainer
            border.color: Theme.colorOutline

            Text {
                id: dateLabel

                anchors.centerIn: parent
                text: I18n.formatDate(systemClock.date)
                color: Theme.colorTertiaryContainerText
                font.family: Theme.fontBody
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
        }
    }

    Component {
        id: stackedClock

        Column {
            spacing: -Math.round(root.baseSize * 0.18)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(systemClock.date, "HH")
                color: Theme.colorText
                font.family: Theme.fontDisplay
                font.pixelSize: root.baseSize * 0.74
                font.weight: Font.Bold
                font.letterSpacing: -4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(systemClock.date, "mm")
                color: Theme.colorText
                font.family: Theme.fontDisplay
                font.pixelSize: root.baseSize * 0.74
                font.weight: Font.Bold
                font.letterSpacing: -4
            }
        }
    }

    Component {
        id: horizontalClock

        Text {
            text: Qt.formatTime(systemClock.date, "HH:mm")
            color: Theme.colorText
            font.family: Theme.fontDisplay
            font.pixelSize: root.baseSize
            font.weight: Font.Bold
            font.letterSpacing: -5
        }
    }
}
