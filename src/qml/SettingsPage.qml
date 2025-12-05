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

FormCard.FormCardPage {
    title: i18nc("@title:window", "Settings")

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.gridUnit
        FormCard.FormSpinBoxDelegate {
            id: precision
            label: i18nc("@label:spinbox digits of precision", "Precision")
            value: KalkConfig.precision
            from: 1
            to: 1000000
            onValueChanged: {
                KalkConfig.precision = value;
                KalkConfig.save();
            }
        }

        FormCard.FormDelegateSeparator { above: precision; below: angleUnit }

        FormCard.FormComboBoxDelegate {
            id: angleUnit
            text: i18nc("@label:listbox trigonometric angle unit", "Angle unit")
            description: applicationWindow().width >= 250 ? i18nc("@info:whatsthis", "Default angle unit for trigonometric functions.") : ""
            currentIndex: KalkConfig.angleUnit
            model: [
                i18nc("@item:inlistbox Angle unit", "Radians"),
                i18nc("@item:inlistbox Angle unit", "Degrees"),
                i18nc("@item:inlistbox Angle unit", "Gradians"),
                i18nc("@item:inlistbox Angle unit", "Arcminute"),
                i18nc("@item:inlistbox Angle unit", "Arcsecond"),
                i18nc("@item:inlistbox Angle unit", "Turn")
            ]
            onCurrentValueChanged: {
                KalkConfig.angleUnit = currentIndex;
                KalkConfig.save();
            }
        }

        FormCard.FormDelegateSeparator { above: angleUnit; below: parsingMode }

        FormCard.FormComboBoxDelegate {
            id: parsingMode
            text: i18nc("@label:listbox control how expressions are parsed (read/interpreted)", "Parsing mode")
            description: applicationWindow().width >= 250 ? i18nc("@info:whatsthis", "Expression evaluation order.") : ""
            currentIndex: KalkConfig.parsingMode
            model: [
                i18nc("@item:inlistbox Parsing mode", "Adaptive"),
                i18nc("@item:inlistbox Parsing mode", "Conventional"),
                i18nc("@item:inlistbox Parsing mode", "Implicit first"),
                i18nc("@item:inlistbox Parsing mode", "Chain")
            ]
            onCurrentValueChanged: {
                KalkConfig.parsingMode = currentIndex;
                KalkConfig.save();
            }
        }
    }

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.gridUnit

        FormCard.FormButtonDelegate {
            text: i18n("About")
            icon.name: "help-about"
            onClicked: {
                let page = applicationWindow().mainPagePool.loadPage(Qt.resolvedUrl("AboutPage.qml"));
                applicationWindow().pageStack.push(page);
            }
        }
    }
}
