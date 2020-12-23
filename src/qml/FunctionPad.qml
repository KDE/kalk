/*
 * This file is part of Kalk
 *
 * Copyright (C) 2020 Han Young <hanyoung@protonmail.com>
 *
 *
 * $BEGIN_LICENSE:GPL3+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 */
import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.1
GridLayout {
    signal pressed(string text)
    columns: 2
    rowSpacing: Kirigami.Units.smallSpacing
    columnSpacing: Kirigami.Units.smallSpacing
    NumberButton {text: "sin(" ; display: "sin"; onClicked: pressed(text);}
    NumberButton {text: "cos(" ; display: "cos"; onClicked: pressed(text);}
    NumberButton {text: "tan(" ; display: "tan"; onClicked: pressed(text);}
    NumberButton {text: "log(" ; display: "ln"; onClicked: pressed(text);}
    NumberButton {text: "log10("; display: "log10"; onClicked: pressed(text);}
    NumberButton {text: "log2("; display: "log2"; onClicked: pressed(text);}
    NumberButton {text: "π" ; onClicked: pressed(text);}
    NumberButton {text: "e" ; onClicked: pressed(text);}
    NumberButton {text: "asin("; display: "asin"; onClicked: pressed(text);}
    NumberButton {text: "acos(" ; display: "acos"; onClicked: pressed(text);}
    NumberButton {text: "atan(" ; display: "atan"; onClicked: pressed(text);}
}
