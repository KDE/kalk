/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.13 as Kirigami

Kirigami.Page {
    id: unitConverter
    ColumnLayout {
        anchors.fill: parent
        Controls.ComboBox {
            id: categoryTumbler
            Layout.preferredWidth: unitConverter.width * 0.9
            model: unitModel
            currentIndex: unitModel.currentIndex
            onCurrentIndexChanged: {
                unitModel.currentIndex = currentIndex;
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Controls.Tumbler {
                id: fromTumbler
                Layout.preferredWidth: unitConverter.width * 0.5
                model: unitModel.typeList
                currentIndex: unitModel.fromUnitIndex
                delegate: delegateComponent
                onCurrentIndexChanged: {
                    unitModel.fromUnitIndex = currentIndex;
                }
            }
            Controls.Tumbler {
                id: toTumbler
                Layout.preferredWidth: unitConverter.width * 0.5
                model: unitModel.typeList
                currentIndex: unitModel.toUnitIndex
                delegate: delegateComponent
                onCurrentIndexChanged: {
                    unitModel.toUnitIndex = currentIndex;
                }
            }
        }
        Component {
            id: delegateComponent
            Text {
                text: modelData
                opacity: 0.4 + Math.max(0, 1 - Math.abs(Controls.Tumbler.displacement)) * 0.6
            }
        }
        Text {
            text: unitModel.value
            color: Kirigami.Theme.textColor
        }
        Text {
            text: unitModel.result
            color: Kirigami.Theme.textColor
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        GridLayout {
            id: unitNumberPad
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 3

            function pressed(text) {
                if (text == "DEL") {
                    unitModel.value = unitModel.value.slice(0, unitModel.value.length - 1);
                } else {
                    unitModel.value += text;
                }
            }
            function clear() {
                unitModel.value = "";
            }

            NumberButton {text: "7" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "8" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "9" ; onClicked: unitNumberPad.pressed(text);}

            NumberButton {text: "4" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "5" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "6" ; onClicked: unitNumberPad.pressed(text);}

            NumberButton {text: "1" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "2" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "3" ; onClicked: unitNumberPad.pressed(text);}

            NumberButton {text: "." ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "0" ; onClicked: unitNumberPad.pressed(text);}
            NumberButton {text: "DEL"; display: "⌫"; onClicked: unitNumberPad.pressed(text); onLongClicked: unitNumberPad.clear(); special: true; }
        }
    }
    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }
}

