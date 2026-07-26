import Quickshell
import Quickshell.Wayland
import QtQuick
import "../config"
import "../design"
import "../services"

PanelWindow {
    id: window

    required property var modelData
    readonly property bool interactiveScreen: modelData === Quickshell.screens[0]
    property bool loginOpen: Config.loginStartsOpen
    property string clockLayout: Config.clockLayout

    screen: modelData
    color: "transparent"
    focusable: interactiveScreen
    aboveWindows: true

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: interactiveScreen
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    WlrLayershell.namespace: "lumina-greeter"

    Item {
        id: scene
        anchors.fill: parent
        focus: window.interactiveScreen

        Keys.onPressed: event => {
            if (!window.interactiveScreen)
                return;

            if (event.key === Qt.Key_Escape && window.loginOpen) {
                AuthService.cancel();
                window.loginOpen = false;
                event.accepted = true;
                return;
            }

            if (!window.loginOpen) {
                window.loginOpen = true;
                event.accepted = true;
            }
        }

        Image {
            anchors.fill: parent
            source: Config.wallpaperSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#30121a2d" }
                GradientStop { position: 0.52; color: "#160a1220" }
                GradientStop { position: 1.0; color: "#75101420" }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: window.loginOpen ? "#29030a12" : "transparent"

            Behavior on color {
                ColorAnimation { duration: Tokens.motionMedium }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: window.interactiveScreen && !window.loginOpen
            cursorShape: Qt.PointingHandCursor
            onClicked: window.loginOpen = true
        }

        ExpressiveClock {
            id: clock
            layoutMode: window.clockLayout
            baseSize: Math.max(112, Math.min(scene.width * 0.16, scene.height * 0.25))
            x: Math.round((scene.width - width) / 2)
            y: window.loginOpen
                ? Math.max(52, scene.height * 0.10)
                : Math.round((scene.height - height) / 2 - 26)

            Behavior on y {
                NumberAnimation {
                    duration: Tokens.motionLong
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.04
                }
            }
        }

        LoginSurface {
            id: loginSurface
            visible: window.interactiveScreen
            width: Math.min(540, scene.width - 40)
            x: Math.round((scene.width - width) / 2)
            y: Math.min(scene.height - height - 84, clock.y + clock.height + 34)
            opacity: window.loginOpen ? 1 : 0
            scale: window.loginOpen ? 1 : 0.94
            enabled: window.loginOpen
            active: window.loginOpen
            defaultUser: Config.defaultUser
            sessions: Config.sessions

            onCloseRequested: {
                AuthService.cancel();
                window.loginOpen = false;
                scene.forceActiveFocus();
            }

            Behavior on opacity {
                NumberAnimation { duration: Tokens.motionMedium }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Tokens.motionLong
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.08
                }
            }
        }

        Text {
            visible: window.interactiveScreen && !window.loginOpen
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48
            text: qsTr("Clique ou pressione uma tecla para entrar")
            color: Tokens.onSurfaceMuted
            font.family: Tokens.fontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        Row {
            visible: window.interactiveScreen
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 24
            spacing: 10

            ActionChip {
                text: window.clockLayout === "stacked"
                    ? qsTr("Relógio: vertical")
                    : qsTr("Relógio: horizontal")
                onClicked: window.clockLayout = window.clockLayout === "stacked"
                    ? "horizontal"
                    : "stacked"
            }

            ActionChip {
                text: qsTr("Reiniciar")
                onClicked: PowerService.reboot()
            }

            ActionChip {
                text: qsTr("Desligar")
                destructive: true
                onClicked: PowerService.powerOff()
            }
        }

        Rectangle {
            visible: AuthService.previewMode && window.interactiveScreen
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 24
            width: previewLabel.implicitWidth + 28
            height: 38
            radius: height / 2
            color: Tokens.surfaceContainer
            border.color: Tokens.outline

            Text {
                id: previewLabel
                anchors.centerIn: parent
                text: qsTr("Modo de demonstração")
                color: Tokens.onSurface
                font.family: Tokens.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }
    }
}
