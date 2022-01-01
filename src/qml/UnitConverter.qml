/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.13 as Kirigami
import QtGraphicalEffects 1.12

Kirigami.Page {
    id: unitConverter
    title: i18n("Conversion")
    topPadding: Kirigami.Units.largeSpacing
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    
    property int yTranslate: 0
    property real mainOpacity: 1
    
    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    property int keypadHeight: unitConverter.height * 3 / 7
    property int screenHeight: unitConverter.height - unitConverter.keypadHeight
    
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Delete:
        case Qt.Key_Backspace:
            unitNumberPad.pressed("DEL"); break;
        case Qt.Key_0:
            unitNumberPad.pressed("0"); break;
        case Qt.Key_1:
            unitNumberPad.pressed("1"); break;
        case Qt.Key_2:
            unitNumberPad.pressed("2"); break;
        case Qt.Key_3:
            unitNumberPad.pressed("3"); break;
        case Qt.Key_4:
            unitNumberPad.pressed("4"); break;
        case Qt.Key_5:
            unitNumberPad.pressed("5"); break;
        case Qt.Key_6:
            unitNumberPad.pressed("6"); break;
        case Qt.Key_7:
            unitNumberPad.pressed("7"); break;
        case Qt.Key_8:
            unitNumberPad.pressed("8"); break;
        case Qt.Key_9:
            unitNumberPad.pressed("9"); break;
        case Qt.Key_Period:
            unitNumberPad.pressed("."); break;
        case Qt.Key_Equal:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            inputManager.equal(); break;
        }
        event.accepted = true;
    }
    
    Component {
        id: delegateComponent
        Controls.Label {
            text: modelData
            opacity: 0.4 + Math.max(0, 1 - Math.abs(Controls.Tumbler.displacement)) * 0.6
            horizontalAlignment: Text.AlignHCenter
            font.bold: Controls.Tumbler.displacement == 0
            font.pointSize: unitConverter.screenHeight * 0.04
        }
    }
    
    Item {
        anchors.fill: parent
        opacity: mainOpacity
        transform: Translate { y: yTranslate }
        
        // top panel drop shadow
        RectangularGlow {
            anchors.fill: topPanelBackground
            anchors.topMargin: 1
            z: -2
            glowRadius: 4
            spread: 0.2
            color: dropShadowColor
        }
        
        Rectangle {
            id: topPanelBackground
            z: -1
            color: Kirigami.Theme.backgroundColor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            implicitHeight: topPanel.height + Kirigami.Units.largeSpacing * 2
            anchors.margins: -Kirigami.Units.largeSpacing
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            ColumnLayout {
                id: topPanel
                Layout.fillWidth: true
                Layout.preferredHeight: unitConverter.screenHeight
                Layout.maximumWidth: unitConverter.width
                
                Controls.ComboBox {
                    id: categoryTumbler
                    
                    Layout.fillWidth: true
                    Layout.maximumWidth: unitConverter.width
                    
                    model: unitModel
                    currentIndex: unitModel.currentIndex
                    onCurrentIndexChanged: {
                        unitModel.currentIndex = currentIndex;
                    }
                }
                
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.maximumWidth: unitConverter.width
                    Layout.maximumHeight: unitConverter.screenHeight * 3 / 5
                    
                    Controls.Tumbler {
                        id: fromTumbler
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: unitConverter.screenHeight * 0.3
                        
                        model: unitModel.typeList
                        currentIndex: unitModel.fromUnitIndex
                        delegate: delegateComponent
                        onCurrentIndexChanged: {
                            unitModel.fromUnitIndex = currentIndex;
                        }
                    }
                    
                    Controls.ToolButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Swap")
                        icon.name: "gtk-convert"
                        icon.height: unitConverter.screenHeight * 0.1
                        icon.width: unitConverter.screenHeight * 0.1
                        display: Controls.AbstractButton.IconOnly
                        onClicked: {
                            let tmp = fromTumbler.currentIndex;
                            fromTumbler.currentIndex = toTumbler.currentIndex;
                            toTumbler.currentIndex = tmp;
                        }
                    }
                    
                    Controls.Tumbler {
                        id: toTumbler
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: unitConverter.screenHeight * 0.3
                        
                        model: unitModel.typeList
                        currentIndex: unitModel.toUnitIndex
                        delegate: delegateComponent
                        onCurrentIndexChanged: {
                            unitModel.toUnitIndex = currentIndex;
                        }
                    }
                }
                
                Kirigami.Separator {
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true
                }
                
                Controls.Label {
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    font.pointSize: unitConverter.screenHeight * 0.04
                    text: unitModel.value
                    color: Kirigami.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Controls.Label {
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true
                    font.pointSize: unitConverter.screenHeight * 0.04
                    text: unitModel.result
                    color: Kirigami.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            GridLayout {
                id: unitNumberPad
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: unitConverter.width
                Layout.maximumHeight: unitConverter.height
                Layout.topMargin: Kirigami.Units.largeSpacing * 2
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
    }
    
    background: Rectangle {
        opacity: mainOpacity
        
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }
}

