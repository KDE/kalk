/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 * SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.2 as Controls
import QtFeedback 5.0

import org.kde.kirigami 2.15 as Kirigami

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal clicked(string text)
    signal longClicked()

    property string text
    property alias fontSize: label.font.pointSize
    property alias backgroundColor: keyRect.color
    property alias textColor: label.color
    property string display: text
    property bool special: false
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    
    property color baseColor: Kirigami.Theme.highlightColor
    property color buttonColor: "transparent"
    property color buttonHoveredColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.2)
    property color buttonPressedColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.3)
    property color buttonBorderColor: "transparent"
    property color buttonBorderHoveredColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.2)
    property color buttonBorderPressedColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.7)
    property color buttonTextColor: Kirigami.Theme.textColor

    // vibration
    HapticsEffect {
        id: vibrate
        attackIntensity: 0.0
        attackTime: 0
        fadeTime: 0
        fadeIntensity: 0.0
        intensity: 0.5
        duration: 10
    }
    
    Rectangle {
        id: keyRect
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing
        color: button.pressed ? root.buttonPressedColor : 
                                (hoverHandler.hovered ? root.buttonHoveredColor : root.buttonColor)
        border.color: button.pressed ? root.buttonBorderPressedColor : 
                                       (hoverHandler.hovered ? root.buttonBorderHoveredColor : root.buttonBorderColor)
        
        Behavior on color { ColorAnimation { duration: 50 } }
        Behavior on border.color { ColorAnimation { duration: 50 } }
        
        Controls.AbstractButton {
            id: button
            anchors.fill: parent
            
            onPressedChanged: {
                if (pressed) {
                    vibrate.start();
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

    Controls.Label {
        id: label
        anchors.centerIn: keyRect
        visible: root.display !== "⌫" // not backspace icon

        font.pointSize: Math.min(Math.round(keyRect.height * 0.28), Math.round(keyRect.width * 0.28))
        font.weight: Font.Light
        text: root.display
        opacity: special ? 0.4 : 1.0
        horizontalAlignment: Text.AlignHCenter
        color: root.buttonTextColor
    }
    Kirigami.Icon {
        visible: root.display === "⌫" // backspace icon
        source: "edit-clear"
        anchors.centerIn: keyRect
        opacity: special ? 0.6 : 1.0
        implicitWidth: Math.round(keyRect.height * 0.3)
        implicitHeight: width
    }
}
