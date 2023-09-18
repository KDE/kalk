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
    columns: pureNumber ? 3 : 4

    NumberButton {text: "√(" ; display: "√"; onClicked: pressed(text);visible: !pureNumber}
    NumberButton {text: "^2" ; display: "x²"; onClicked: pressed(text);visible: !pureNumber}
    NumberButton {text: "(" ; onClicked: pressed(text); special: true; visible: !pureNumber}
    NumberButton {text: ")" ; onClicked: pressed(text); special: true; visible: !pureNumber}

    NumberButton {text: "%" ; onClicked: pressed(text);visible: !pureNumber}
    NumberButton {text: "CLEAR"; display: "C"; onClicked: clear(); special: true; visible: !pureNumber}
    NumberButton {text: "DEL"; display: "⌫"; onClicked: pressed(text); onLongClicked: clear(); special: true; visible: !pureNumber}
    NumberButton {text: "÷" ; onClicked: pressed(text); special: true; visible: !pureNumber}

    NumberButton {text: "7" ; onClicked: pressed(text);}
    NumberButton {text: "8" ; onClicked: pressed(text);}
    NumberButton {text: "9" ; onClicked: pressed(text);}
    NumberButton {text: "×" ; onClicked: pressed(text); special: true; visible: !pureNumber}

    NumberButton {text: "4" ; onClicked: pressed(text);}
    NumberButton {text: "5" ; onClicked: pressed(text);}
    NumberButton {text: "6" ; onClicked: pressed(text);}
    NumberButton {text: "-" ; onClicked: pressed(text); special: true; visible: !pureNumber}

    NumberButton {text: "1" ; onClicked: pressed(text);}
    NumberButton {text: "2" ; onClicked: pressed(text);}
    NumberButton {text: "3" ; onClicked: pressed(text);}
    NumberButton {text: "+" ; onClicked: pressed(text); special: true; visible: !pureNumber}

    NumberButton {text: "0" ; onClicked: pressed(text);}
    NumberButton {text: Qt.locale().decimalPoint ; onClicked: pressed(text);}
    NumberButton {text: "DEL"; display: "⌫"; onClicked: pressed(text); onLongClicked: clear(); special: true; visible: pureNumber}
    NumberButton {text: "^" ; onClicked: pressed(text); visible: !pureNumber}
    NumberButton {text: "=" ; onClicked: pressed(text); special: true; visible: !pureNumber}
}

