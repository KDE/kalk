/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1 as Controls
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.13 as Kirigami
 
Kirigami.Page {
    id: binaryCalculatorPage
    title: il8n("Binary Calculator")
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            property string expression: ""
            id: inputPad
            Layout.fillHeight: true
            Layout.preferredWidth: binaryCalculatorPage.width
            Layout.alignment: Qt.AlignLeft
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color:  Kirigami.Theme.backgroundColor

            NumberPad {
                id: numberPad
                anchors.fill: parent
                anchors.topMargin: Kirigami.Units.gridUnit * 0.7
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                anchors.rightMargin: Kirigami.Units.gridUnit * 1.5
                onPressed: {
                    if (text == "DEL") {
                        inputManager.backspace();
                    } else if (text == "=") {
                        inputManager.equal();
                        resultFadeOutAnimation.start();
                    } else {
                        InputManager.append(text);
                    }
                }
                onClear: inputManager.clear()
            }
        }
    }
}
