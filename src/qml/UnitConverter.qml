/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as Components
import org.kde.kirigamiaddons.delegates as Delegates

Kirigami.Page {
    id: unitConverter
    title: i18n("Converter")
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    property int yTranslate: 0
    property real mainOpacity: 1
    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    property int screenHeight: unitConverter.height * 0.5
    property int flexPointSize: Math.max(Math.min(screenHeight / 14, width / 24), Kirigami.Theme.defaultFont.pointSize - 3)

    Keys.onPressed: event => {
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
            InputManager.equal(); break;
        }
        event.accepted = true;
    }

    actions: Kirigami.Action {
        id: category
        icon.name: "category"
        text: i18n("Category")
        onTriggered: categories.open();
    }

    Component {
        id: delegateComponent
        Controls.Label {
            text: modelData
            opacity: 0.4 + Math.max(0, 1 - Math.abs(Controls.Tumbler.displacement)) * 0.6
            horizontalAlignment: Text.AlignHCenter
            font.bold: Controls.Tumbler.displacement === 0
            font.pointSize: flexPointSize
        }
    }
    
    Item {
        anchors.fill: parent
        opacity: mainOpacity
        transform: Translate { y: yTranslate }
        
        Kirigami.ShadowedRectangle {
            id: topPanelBackground
            z: -1
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            implicitHeight: topPanel.height
            shadow {
                yOffset: 1
                size: 4
                color: dropShadowColor
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            ColumnLayout {
                id: topPanel
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    
                    Controls.Tumbler {
                        id: fromTumbler
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: unitConverter.screenHeight * 0.5
                        wrap: false
                        
                        model: UnitModel.typeList
                        currentIndex: UnitModel.fromUnitIndex
                        delegate: delegateComponent
                        onCurrentIndexChanged: {
                            UnitModel.fromUnitIndex = currentIndex;
                        }
                    }
                    
                    Controls.ToolButton {
                        icon.name: "gtk-convert"
                        icon.height: unitConverter.screenHeight * 0.15
                        icon.width: unitConverter.screenHeight * 0.15
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
                        Layout.maximumHeight: unitConverter.screenHeight * 0.5
                        wrap: false
                        
                        model: UnitModel.typeList
                        currentIndex: UnitModel.toUnitIndex
                        delegate: delegateComponent
                        onCurrentIndexChanged: {
                            UnitModel.toUnitIndex = currentIndex;
                        }
                    }
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                }
                
                GridLayout {
                    columns: unitConverter.width > unitConverter.height ? 3 : 1
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter

                    Controls.Label {
                        Layout.fillWidth: true
                        font.pointSize: flexPointSize
                        text: UnitModel.value
                        color: Kirigami.Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Controls.Label {
                        visible: parent.columns > 1 || unitConverter.height > 250
                        Layout.fillWidth: true
                        font.pointSize: flexPointSize
                        text: "="
                        color: Kirigami.Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        font.pointSize: flexPointSize
                        text: UnitModel.result
                        color: Kirigami.Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            PortraitPad {
                id: unitNumberPad
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                pureNumber: true
                onPressed: text => {
                    if (text === "DEL") {
                        UnitModel.value = UnitModel.value.slice(0, UnitModel.value.length - 1);
                    } else {
                        UnitModel.value += text;
                    }
                }
                onClear: {
                    UnitModel.value = "";
                }
            }
        }
    }
    
    background: Rectangle {
        opacity: mainOpacity
        
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }

    Components.BottomDrawer {
        id: categories

        height: unitConverter.height - Kirigami.Units.gridUnit * 5
        parent: applicationWindow().overlay

        ListView {
            id: listview
            model: UnitModel
            clip: true
            delegate: Controls.RadioDelegate {
                width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                text: modelData
                checked: index === UnitModel.currentIndex
                onClicked: {
                    category.text = text;
                    UnitModel.currentIndex = index;
                    categories.close();
                }
            }

            Component.onCompleted: category.text = listview.currentItem.text
        }
    }
}
