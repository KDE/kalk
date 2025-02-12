/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 * SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal clicked(string text)
    signal longClicked()

    property string text
    property string display: text
    property bool special: false
    property bool down: false
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    
    property color baseColor: Kirigami.Theme.highlightColor
    property color buttonColor: Kirigami.Theme.backgroundColor
    property color buttonHoveredColor: Kirigami.Theme.alternateBackgroundColor
    property color buttonPressedColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.3)
    property color buttonBorderColor: Qt.rgba(buttonTextColor.r, buttonTextColor.g, buttonTextColor.b, 0.2)
    property color buttonBorderHoveredColor: buttonBorderColor
    property color buttonBorderPressedColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.7)
    property color buttonTextColor: Kirigami.Theme.textColor

    // vibration
    // TODO bring back
    //HapticsEffect {
    //    id: vibrate
    //    attackIntensity: 0.0
    //    attackTime: 0
    //    fadeTime: 0
    //    fadeIntensity: 0.0
    //    intensity: 0.5
    //    duration: 10
    //}

    Controls.AbstractButton {
        id: button
        anchors.fill: parent
        focusPolicy: Qt.NoFocus

        background: Rectangle {
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.backgroundColor

            // actual background fill
            Rectangle {
                anchors.fill: parent
                radius: Kirigami.Units.smallSpacing
                color: button.pressed || root.down ? root.buttonPressedColor :
                (hoverHandler.hovered && !Kirigami.Settings.isMobile ? root.buttonHoveredColor : root.buttonColor)
                border.color: button.pressed ? root.buttonBorderPressedColor :
                    (hoverHandler.hovered && !Kirigami.Settings.isMobile ? root.buttonBorderHoveredColor : root.buttonBorderColor)

                Behavior on color { ColorAnimation { duration: 50 } }
                Behavior on border.color { ColorAnimation { duration: 50 } }
            }

            // small box shadow
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height
                z: -1
                color: Qt.rgba(0, 0, 0, 0.05)
                radius: Kirigami.Units.smallSpacing
            }
        }

        contentItem: Item {
            anchors.centerIn: parent

            Controls.Label {
                id: label
                anchors.centerIn: parent
                visible: root.display !== "⌫" // not backspace icon

                font.pointSize: Math.max(Math.min(Math.round(parent.height * 0.27), Math.round(parent.width * 0.27)), 10)
                font.weight: Font.DemiBold
                text: root.display
                opacity: special ? 0.4 : 0.9
                horizontalAlignment: Text.AlignHCenter
                color: root.buttonTextColor
            }
            Kirigami.Icon {
                visible: root.display === "⌫" // backspace icon
                source: "edit-clear"
                anchors.centerIn: parent
                opacity: special ? 0.6 : 1.0
                implicitWidth: Math.round(parent.height * 0.3)
                implicitHeight: width
            }
        }

        onPressedChanged: {
            if (pressed) {
                //vibrate.start();
            }
        }

        onClicked: root.clicked(root.text)
        onPressAndHold: root.longClicked()

        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
        }
    }
}
