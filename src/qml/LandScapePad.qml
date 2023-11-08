/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.1
import QtQml 2.15

GridLayout {
    signal pressed(string text)
    signal clear()
    property bool pureNumber: false
    columns: 6

    NumberButton {text: "7" ; onClicked: text => pressed(text);}
    NumberButton {text: "8" ; onClicked: text => pressed(text);}
    NumberButton {text: "9" ; onClicked: text => pressed(text);}
    NumberButton {text: "÷" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "CLEAR"; display: "C"; onClicked: clear(); special: true; visible: !pureNumber}
    NumberButton {text: "√(" ; display: "√"; onClicked: text => pressed(text); visible: !pureNumber}

    NumberButton {text: "4" ; onClicked: text => pressed(text);}
    NumberButton {text: "5" ; onClicked: text => pressed(text);}
    NumberButton {text: "6" ; onClicked: text => pressed(text);}
    NumberButton {text: "×" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "(  )" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "π" ; onClicked: text => pressed(text); visible: !pureNumber}

    NumberButton {text: "1" ; onClicked: text => pressed(text);}
    NumberButton {text: "2" ; onClicked: text => pressed(text);}
    NumberButton {text: "3" ; onClicked: text => pressed(text);}
    NumberButton {text: "-" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "%" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "^" ; onClicked: text => pressed(text); visible: !pureNumber}

    NumberButton {text: "0" ; onClicked: text => pressed(text);}
    NumberButton {text: Qt.locale().decimalPoint ; onClicked: text => pressed(text);}
    NumberButton {text: "DEL"; display: "⌫"; onClicked: text => pressed(text); onLongClicked: clear(); special: true}
    NumberButton {text: "+" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "=" ; onClicked: text => pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: "^2" ; display: "x²"; onClicked: text => pressed(text); visible: !pureNumber}
}
