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
    id: unitConversionPage
    title: i18n("Acceleration")
    visible: false

    onTitleChanged: {
        fromSearchField.text = "";
        toSearchField.text = "";
        value.text = "";
        result.text = "";
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            id: searchRow
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit * 2
            RowLayout {
                Controls.Label {
                    text: i18n("From: ")
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                }
                Kirigami.SearchField {
                    id: fromSearchField
                    Layout.fillWidth: true
                    onTextEdited: {
                        fromListView.model = unitModel.search(fromSearchField.text, 0);
                        fromListViewPopup.open();
                    }

                    onPressed: {
                        fromListView.model = unitModel.search(fromSearchField.text, 0);
                        fromListViewPopup.open();
                    }
                }
            }

            RowLayout {
                Controls.Label {
                    text: i18n("To: ")
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                }
                Kirigami.SearchField {
                    id: toSearchField
                    Layout.fillWidth: true
                    onTextEdited: {
                        toListView.model = unitModel.search(toSearchField.text, 1);
                        toListViewPopup.open();
                    }
                    onPressed: {
                        toListView.model = unitModel.search(toSearchField.text, 1);
                        toListViewPopup.open();
                    }
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width
            Controls.Popup {
                id: fromListViewPopup
                height: fromListView.height
                width: parent.width
                anchors.centerIn: parent
                ListView {
                    id: fromListView
                    width: parent.width
                    height: Math.min(contentHeight, unitNumberPad.height) + Kirigami.Units.gridUnit
                    delegate: Kirigami.BasicListItem {
                        text: modelData
                        onClicked: {
                            fromSearchField.text = modelData;
                            result.text = unitModel.getRet(Number(value.text),fromListView.currentIndex,toListView.currentIndex);
                            fromListViewPopup.close();
                        }
                    }
                }
            }
            Controls.Popup {
                id: toListViewPopup
                height: toListView.height
                width: parent.width
                anchors.centerIn: parent
                ListView {
                    id: toListView
                    width: parent.width
                    height: Math.min(contentHeight, unitNumberPad.height) + Kirigami.Units.gridUnit
                    delegate: Kirigami.BasicListItem {
                        text: modelData
                        onClicked: {
                            toSearchField.text = modelData;
                            result.text = unitModel.getRet(Number(value.text),fromListView.currentIndex,toListView.currentIndex);
                            toListViewPopup.close();
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label {
                    id: value
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                    onTextChanged: {
                        result.text = unitModel.getRet(Number(value.text),fromListView.currentIndex, toListView.currentIndex);
                    }
                }
                Controls.Label {
                    text: fromSearchField.text
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                }
            }

            Controls.Label {
                id: result
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        GridLayout {
            id: unitNumberPad
            columns: 3
            
            function pressed(text) {
                if (text == "DEL") {
                    value.text = value.text.slice(0, value.text.length - 1);
                } else {
                    value.text += text;
                }
            }
            function clear() {
                value.text = "";
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

