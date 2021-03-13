/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 * SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.2 as Controls
import QtFeedback 5.0

import org.kde.kirigami 2.2 as Kirigami

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
    
    property color buttonColor: Qt.lighter(Kirigami.Theme.backgroundColor, 1.3)
    property color buttonPressedColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.08)
    property color buttonTextColor: Kirigami.Theme.textColor
    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)

    // vibration
    HapticsEffect {
        id: vibrate
        attackIntensity: 0.0
        attackTime: 0
        fadeTime: 0
        fadeIntensity: 0.0
        intensity: 0.5
        duration: Kirigami.Units.shortDuration
    }
    
    // fast drop shadow
    RectangularGlow {
        anchors.topMargin: 1
        anchors.fill: keyRect
        cornerRadius: keyRect.radius * 2
        glowRadius: 4
        spread: 0.3
        color: root.dropShadowColor
    }
    
    Rectangle {
        id: keyRect
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing * 0.5
        radius: Kirigami.Units.smallSpacing
        color: root.buttonColor
        
        Controls.AbstractButton {
            anchors.fill: parent
            onPressedChanged: {
                if (pressed) {
                    vibrate.start();
                    parent.color = root.buttonPressedColor;
                } else {
                    parent.color = root.buttonColor;
                }
            }

            onClicked: root.clicked(root.text)
            onPressAndHold: root.longClicked()
        }
    }

    Controls.Label {
        id: label
        anchors.centerIn: keyRect

        font.pointSize: keyRect.height * 0.3
        text: root.display
        opacity: special ? 0.4 : 1.0
        horizontalAlignment: Text.AlignHCenter
        color: root.buttonTextColor
    }
}
