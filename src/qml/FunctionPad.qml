/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.1
GridLayout {
    id: functionPad
    signal pressed(string text)
    columns: 3
    rowSpacing: Kirigami.Units.smallSpacing
    columnSpacing: Kirigami.Units.smallSpacing

    NumberButton {text: "sin(" ; display: "sin"; onClicked: text => pressed(text);}
    NumberButton {text: "cos(" ; display: "cos"; onClicked: text => pressed(text);}
    NumberButton {text: "tan(" ; display: "tan"; onClicked: text => pressed(text);}
    NumberButton {text: "asin("; display: "asin"; onClicked: text => pressed(text);}
    NumberButton {text: "acos(" ; display: "acos"; onClicked: text => pressed(text);}
    NumberButton {text: "atan(" ; display: "atan"; onClicked: text => pressed(text);}
    NumberButton {text: "log(" ; display: "ln"; onClicked: text => pressed(text);}
    NumberButton {text: "log10("; display: "log10"; onClicked: text => pressed(text);}
    NumberButton {text: "log2("; display: "log2"; onClicked: text => pressed(text);}
    NumberButton {text: "π" ; onClicked: text => pressed(text);}
    NumberButton {text: "e" ; onClicked: text => pressed(text);}
    NumberButton {text: "abs(" ; display: "abs"; onClicked: text => pressed(text);}
}
