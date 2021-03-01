/*
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.1

GridLayout {
    signal pressed(string text)
    signal clear()
    columns: 4
    rowSpacing: Kirigami.Units.smallSpacing
    columnSpacing: Kirigami.Units.smallSpacing

    // Buttons are from left to right
    // Row Number from bottom: 4
    NumberButton {text: "<<"; onClicked: pressed(text);}
    NumberButton {text: ">>"; onClicked: pressed(text);}
    NumberButton {text: "CLEAR"; display: "CLR"; onClicked: clear(); special: true;}
    NumberButton {text: "DEL"; display: "⌫"; onClicked: pressed(text); onLongClicked: clear(); special: true;}

    // Row number from bottom: 3
    NumberButton {text: "^"; onClicked: pressed(text); special: true;}
    NumberButton {text: "~"; onClicked: pressed(text); special: true;}
    NumberButton {text: "|"; onClicked: pressed(text); special: true;}
    NumberButton {text: "&"; onClicked: pressed(text); special: true;}

    // Row number from bottom: 2
    NumberButton {text: "/"; display: "÷"; onClicked: pressed(text);}
    NumberButton {text: "*"; display: "×"; onClicked: pressed(text);}
    NumberButton {text: "-"; onClicked: pressed(text);}
    NumberButton {text: "+"; onClicked: pressed(text);}

    // Row number from bottom: 1
    NumberButton {text: "0"; onClicked: pressed(text);}
    NumberButton {text: "1"; onClicked: pressed(text);}
    NumberButton {text: ""; onClicked: pressed(text);}
    NumberButton {text: "="; onClicked: pressed(text); special: true;}
}
