import QtQuick
import "../design"

Rectangle {
    id: root

    property string label: ""
    property var options: []
    property int selectedIndex: 0
    property string nameRole: "name"
    property string detailRole: "detail"
    property bool open: false
    property bool interactive: true
    property int maximumListHeight: 248

    signal toggleRequested()
    signal selected(int index)

    readonly property var selectedOption: options.length > 0
        ? options[Math.max(0, Math.min(selectedIndex, options.length - 1))]
        : null
    readonly property int listHeight: open
        ? Math.min(optionsColumn.implicitHeight, maximumListHeight)
        : 0

    function roleValue(option, role) {
        if (!option || !role || option[role] === undefined || option[role] === null)
            return "";
        return String(option[role]);
    }

    implicitWidth: 286
    implicitHeight: header.height + listHeight
    height: implicitHeight
    radius: 22
    color: Theme.colorSurface
    border.width: 1
    border.color: open ? Theme.colorPrimary : Theme.colorOutline
    clip: true
    opacity: interactive ? 1 : 0.58

    Behavior on height {
        Anim { type: Motion.defaultSpatial }
    }

    Behavior on border.color {
        CAnim { type: Motion.defaultEffects }
    }

    Behavior on opacity {
        Anim { type: Motion.defaultEffects }
    }

    Column {
        anchors.fill: parent

        Rectangle {
            id: header

            width: parent.width
            height: 66
            radius: root.radius
            color: headerMouse.pressed
                ? Theme.colorSurfacePressed
                : headerMouse.containsMouse
                    ? Theme.colorSurfaceContainer
                    : "transparent"

            Behavior on color {
                CAnim { type: Motion.fastEffects }
            }

            Column {
                anchors {
                    left: parent.left
                    right: chevron.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 18
                    rightMargin: 12
                }
                spacing: 2

                Text {
                    width: parent.width
                    text: root.label
                    color: Theme.colorTextMuted
                    elide: Text.ElideRight
                    font.family: Theme.fontBody
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: root.roleValue(root.selectedOption, root.nameRole)
                    color: Theme.colorText
                    elide: Text.ElideRight
                    font.family: Theme.fontBody
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    visible: text.length > 0
                    text: root.roleValue(root.selectedOption, root.detailRole)
                    color: Theme.colorTextMuted
                    elide: Text.ElideRight
                    font.family: Theme.fontBody
                    font.pixelSize: 11
                }
            }

            Text {
                id: chevron

                anchors {
                    right: parent.right
                    rightMargin: 18
                    verticalCenter: parent.verticalCenter
                }
                text: "⌄"
                color: Theme.colorText
                rotation: root.open ? 180 : 0
                font.family: Theme.fontBody
                font.pixelSize: 20
                font.weight: Font.DemiBold

                Behavior on rotation {
                    Anim { type: Motion.fastSpatial }
                }
            }

            MouseArea {
                id: headerMouse

                anchors.fill: parent
                enabled: root.interactive && root.options.length > 0
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleRequested()
            }
        }

        Item {
            width: parent.width
            height: root.listHeight
            clip: true
            visible: height > 0

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: optionsColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: optionsColumn

                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: root.options

                        delegate: Rectangle {
                            id: optionRow

                            required property int index
                            required property var modelData

                            width: optionsColumn.width
                            height: 54
                            color: index === root.selectedIndex
                                ? Theme.colorPrimaryContainer
                                : optionMouse.pressed
                                    ? Theme.colorSurfacePressed
                                    : optionMouse.containsMouse
                                        ? Theme.colorSurfaceContainer
                                        : "transparent"

                            Behavior on color {
                                CAnim { type: Motion.fastEffects }
                            }

                            Column {
                                anchors {
                                    left: parent.left
                                    right: selectedMark.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 18
                                    rightMargin: 10
                                }
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: root.roleValue(optionRow.modelData, root.nameRole)
                                    color: optionRow.index === root.selectedIndex
                                        ? Theme.colorPrimaryContainerText
                                        : Theme.colorText
                                    elide: Text.ElideRight
                                    font.family: Theme.fontBody
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    visible: text.length > 0
                                    text: root.roleValue(optionRow.modelData, root.detailRole)
                                    color: optionRow.index === root.selectedIndex
                                        ? Theme.colorPrimaryContainerText
                                        : Theme.colorTextMuted
                                    opacity: 0.78
                                    elide: Text.ElideRight
                                    font.family: Theme.fontBody
                                    font.pixelSize: 11
                                }
                            }

                            Text {
                                id: selectedMark

                                anchors {
                                    right: parent.right
                                    rightMargin: 18
                                    verticalCenter: parent.verticalCenter
                                }
                                visible: optionRow.index === root.selectedIndex
                                text: "✓"
                                color: Theme.colorPrimaryContainerText
                                font.family: Theme.fontBody
                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: optionMouse

                                anchors.fill: parent
                                enabled: root.interactive
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selected(optionRow.index)
                            }
                        }
                    }
                }
            }
        }
    }
}
