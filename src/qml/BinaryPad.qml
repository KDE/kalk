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
    columns: 5
    rowSpacing: Kirigami.Units.smallSpacing
    columnSpacing: Kirigami.Units.smallSpacing

    // Features to add:
    // 1) Left Shift and Right Shift operators
    // 2) Ones and Twos complements
    // 3) +, -, x, / operations
    //
    // Might have to look into adding a function overlay to seperate out uncommon functions (fractional, modulo, abs)

    // Rwo Number from bottom: 6
    NumberButton {text: ""; onClicked: pressed(text); special: true;}
    NumberButton {text: "<<"; onClicked: pressed(text); special: true;}
    NumberButton {text: ">>"; onClicked: pressed(text); special: true;}
    NumberButton {text: "ONEC"; display: "ones"; onClicked: pressed(text); special: true;}
    NumberButton {text: "TWOC"; display: "twos"; onClicked: pressed(text); special: true;}

    // Row Number from bottom: 5
    NumberButton {text: "(" ; onClicked: pressed(text); special: true;}
    NumberButton {text: ")" ; onClicked: pressed(text); special: true;}
    NumberButton {text: "CLEAR"; display: "CLR"; onClicked: clear(); special: true;}
    NumberButton {text: "DEL"; display: "⌫"; onClicked: pressed(text); onLongClicked: clear(); special: true;}
    NumberButton {text: "XOR"; onClicked: pressed(text); special: true;}

    // Row Number from bottom: 4
    NumberButton {text: "C"; onClicked: pressed(text);}
    NumberButton {text: "D"; onClicked: pressed(text);}
    NumberButton {text: "E"; onClicked: pressed(text);}
    NumberButton {text: "F"; onClicked: pressed(text);}
    NumberButton {text: "NOT"; onClicked: pressed(text); special: true;}

    // Row number from bottom: 3
    NumberButton {text: "8"; onClicked: pressed(text);}
    NumberButton {text: "9"; onClicked: pressed(text);}
    NumberButton {text: "A"; onClicked: pressed(text);}
    NumberButton {text: "B"; onClicked: pressed(text);}
    NumberButton {text: "OR"; onClicked: pressed(text); special: true;}

    // Row number from bottom: 2
    NumberButton {text: "4"; onClicked: pressed(text);}
    NumberButton {text: "5"; onClicked: pressed(text);}
    NumberButton {text: "6"; onClicked: pressed(text);}
    NumberButton {text: "7"; onClicked: pressed(text);}
    NumberButton {text: "AND"; onClicked: pressed(text); special: true;}

    // Row number from bottom: 1
    NumberButton {text: "0"; onClicked: pressed(text);}
    NumberButton {text: "1"; onClicked: pressed(text);}
    NumberButton {text: "2"; onClicked: pressed(text);}
    NumberButton {text: "3"; onClicked: pressed(text);}
    NumberButton {text: "="; onClicked: pressed(text); special: true;}
}
