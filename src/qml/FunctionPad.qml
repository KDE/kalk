/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Layouts
GridLayout {
    id: functionPad
    signal pressed(string text)
    columns: root.width >= root.height * 1.6 ? 6 : 4
    rows: root.width >= root.height * 1.6 ? 4 : 6
    flow: root.width >= root.height * 1.6 ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rowSpacing: Kirigami.Units.smallSpacing
    columnSpacing: Kirigami.Units.smallSpacing

    property bool inverse: false
    property bool hyperbolic: false

    NumberButton {text: "INV" ; onClicked: inverse = !inverse; down: inverse}
    NumberButton {text: "sin(" ; display: "sin"; onClicked: text => pressed(text); visible: !inverse && !hyperbolic;}
    NumberButton {text: "cos(" ; display: "cos"; onClicked: text => pressed(text); visible: !inverse && !hyperbolic;}
    NumberButton {text: "tan(" ; display: "tan"; onClicked: text => pressed(text); visible: !inverse && !hyperbolic;}
    NumberButton {text: "asin("; display: "sin⁻¹"; onClicked: text => pressed(text); visible: inverse && !hyperbolic;}
    NumberButton {text: "acos(" ; display: "cos⁻¹"; onClicked: text => pressed(text); visible: inverse && !hyperbolic;}
    NumberButton {text: "atan(" ; display: "tan⁻¹"; onClicked: text => pressed(text); visible: inverse && !hyperbolic;}
    NumberButton {text: "sinh(" ; display: "sinh"; onClicked: text => pressed(text); visible: !inverse && hyperbolic;}
    NumberButton {text: "cosh(" ; display: "cosh"; onClicked: text => pressed(text); visible: !inverse && hyperbolic;}
    NumberButton {text: "tanh(" ; display: "tanh"; onClicked: text => pressed(text); visible: !inverse && hyperbolic;}
    NumberButton {text: "asinh("; display: "sinh⁻¹"; onClicked: text => pressed(text); visible: inverse && hyperbolic;}
    NumberButton {text: "acosh(" ; display: "cosh⁻¹"; onClicked: text => pressed(text); visible: inverse && hyperbolic;}
    NumberButton {text: "atanh(" ; display: "tanh⁻¹"; onClicked: text => pressed(text); visible: inverse && hyperbolic;}

    NumberButton {text: "HYP" ; onClicked: hyperbolic = !hyperbolic; down: hyperbolic}
    NumberButton {text: "sec("; display: "sec"; onClicked: text => pressed(text); visible: !inverse && !hyperbolic;}
    NumberButton {text: "csc(" ; display: "csc"; onClicked: text => pressed(text); visible: !inverse && !hyperbolic;}
    NumberButton {text: "cot(" ; display: "cot"; onClicked: text => pressed(text); visible: !inverse && !hyperbolic;}
    NumberButton {text: "asec("; display: "sec⁻¹"; onClicked: text => pressed(text); visible: inverse && !hyperbolic;}
    NumberButton {text: "acsc(" ; display: "csc⁻¹"; onClicked: text => pressed(text); visible: inverse && !hyperbolic;}
    NumberButton {text: "acot(" ; display: "cot⁻¹"; onClicked: text => pressed(text); visible: inverse && !hyperbolic;}
    NumberButton {text: "sech("; display: "sech"; onClicked: text => pressed(text); visible: !inverse && hyperbolic;}
    NumberButton {text: "csch(" ; display: "csch"; onClicked: text => pressed(text); visible: !inverse && hyperbolic;}
    NumberButton {text: "coth(" ; display: "coth"; onClicked: text => pressed(text); visible: !inverse && hyperbolic;}
    NumberButton {text: "asech("; display: "sech⁻¹"; onClicked: text => pressed(text); visible: inverse && hyperbolic;}
    NumberButton {text: "acsch(" ; display: "csch⁻¹"; onClicked: text => pressed(text); visible: inverse && hyperbolic;}
    NumberButton {text: "acoth(" ; display: "coth⁻¹"; onClicked: text => pressed(text); visible: inverse && hyperbolic;}

    NumberButton {text: "ln(" ; display: "ln"; onClicked: text => pressed(text); visible: !inverse}
    NumberButton {text: "exp(" ; display: "eˣ"; onClicked: text => pressed(text); visible: inverse}
    NumberButton {text: "log10("; display: "log₁₀"; onClicked: text => pressed(text); visible: !inverse}
    NumberButton {text: "10^"; display: "10ˣ"; onClicked: text => pressed(text); visible: inverse}
    NumberButton {text: "log2("; display: "log₂"; onClicked: text => pressed(text); visible: !inverse}
    NumberButton {text: "2^"; display: "2ˣ"; onClicked: text => pressed(text); visible: inverse}
    NumberButton {text: "∛" ; display: "∛"; onClicked: text => pressed(text); visible: !inverse}
    NumberButton {text: "^3" ; display: "x³"; onClicked: text => pressed(text); visible: inverse}

    NumberButton {text: "!" ; onClicked: text => pressed(text);}
    NumberButton {text: "e" ; onClicked: text => pressed(text);}
    NumberButton {text: "inv(" ; display: "¹⁄ₓ"; onClicked: text => pressed(text);}
    NumberButton {text: "E" ; display: "E"; onClicked: text => pressed(text);}

    NumberButton {text: "abs(" ; display: "|𝑥|"; onClicked: text => pressed(text);}
    NumberButton {text: "factor(" ; display: "a×b"; onClicked: text => pressed(text);}
    NumberButton {text: " mod " ; display: "mod"; onClicked: text => pressed(text);}
    NumberButton {text: "rand()" ; display: "rand"; onClicked: text => pressed(text);}

    NumberButton {text: "root(;)"; display: "ⁿ√"; onClicked: text => pressed(text);}
    NumberButton {text: "log(;)" ; display: "logₙ"; onClicked: text => pressed(text);}
    NumberButton {text: "∫(" ; display: "∫"; onClicked: text => pressed(text);}
    NumberButton {text: "diff(" ; display: "d/dx"; onClicked: text => pressed(text);}
}
