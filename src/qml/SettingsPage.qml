/*
 * SPDX-FileCopyrightText: 2023 Michael Lang <criticaltemp@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.kalk
import org.kde.kalk.config

FormCard.FormCardPage {
    title: i18nc("@title:window", "Settings")

    property int yTranslate: 0
    property real mainOpacity: 1

    FormCard.FormCard {
        FormCard.FormSpinBoxDelegate {
            id: precision
            label: i18nc("@label:spinbox digits of precision", "Precision")
            value: Config.precision
            from: 1
            to: 1000000
            onValueChanged: {
                Config.precision = value;
                Config.save();
            }
        }

        FormCard.FormDelegateSeparator { above: precision; below: angleUnit }

        FormCard.FormComboBoxDelegate {
            id: angleUnit
            text: i18nc("@label:listbox trigonometric angle unit", "Angle unit")
            description: applicationWindow().width >= 250 ? i18nc("@info:whatsthis", "Default angle unit for trigonometric functions.") : ""
            currentIndex: model.indexOf(Config.angleUnit)
            model: ["Radians", "Degrees", "Gradians", "Arcminute", "Arcsecond", "Turn"]
            onCurrentValueChanged: {
                Config.angleUnit = currentValue;
                Config.save();
            }
        }

        FormCard.FormDelegateSeparator { above: angleUnit; below: parsingMode }

        FormCard.FormComboBoxDelegate {
            id: parsingMode
            text: i18nc("@label:listbox control how expressions are parsed (read/interpreted)", "Parsing mode")
            description: applicationWindow().width >= 250 ? i18nc("@info:whatsthis", "Expression evaluation order.") : ""
            currentIndex: Config.parsingMode
            model: ["Adaptive", "Conventional", "Implicit first", "Chain"]
            onCurrentValueChanged: {
                Config.parsingMode = currentIndex;
                Config.save();
            }
        }
    }
}
