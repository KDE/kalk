/*
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1 as Controls
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.13 as Kirigami

Kirigami.Page {
    id: initialPage
    title: i18n("Calculator")
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    
    property int yTranslate: 0
    property real mainOpacity: 1
    
    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    property int keypadHeight: {
        let rows = 6, columns = 5;
        // restrict keypad so that the height of buttons never go past 0.7 times their width
        if ((initialPage.height - Kirigami.Units.gridUnit * 7) / rows > 0.7 * initialPage.width / columns) {
            return rows * 0.7 * initialPage.width / columns;
        } else {
            return initialPage.height - Kirigami.Units.gridUnit * 7;
        }
    }
    
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Delete:
        case Qt.Key_Backspace:
            inputManager.backspace(); break;
        case Qt.Key_0:
            inputManager.append("0"); break;
        case Qt.Key_1:
            inputManager.append("1"); break;
        case Qt.Key_Plus:
            inputManager.append("+"); break;
        case Qt.Key_Minus:
            inputManager.append("-"); break;
        case Qt.Key_Asterisk:
            inputManager.append("*"); break;
        case Qt.Key_Slash:
            inputManager.append("/"); break;
        case Qt.Key_Ampersand:
            inputManager.append("&"); break;
        case Qt.Key_Bar:
            inputManager.append("|"); break;
        case Qt.Key_AsciiCircum:
            inputManager.append("^"); break;
        case Qt.Key_Period:
            inputManager.append("."); break;
        case Qt.Key_Equal:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            inputManager.equal(); break;
        }
        event.accepted = true;
    }

    onIsCurrentPageChanged: {
        if (!inputManager.binaryMode)
            inputManager.binaryMode = true
    }
    
    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
        opacity: mainOpacity
    }
    
    ColumnLayout {
        anchors.fill: parent
        opacity: mainOpacity
        transform: Translate { y: yTranslate }
        spacing: 0
        
        Item {
            id: outputScreen
            z: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: initialPage.height - initialPage.keypadHeight            
            
            // top panel drop shadow
            RectangularGlow {
                anchors.fill: topPanelBackground
                anchors.topMargin: 1
                glowRadius: 4
                spread: 0.2
                color: dropShadowColor
            }
            Rectangle {
                id: topPanelBackground
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                color: Kirigami.Theme.backgroundColor
                implicitHeight: outputScreen.height
            }
            
            Column {
                id: outputColumn
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.gridUnit
                
                Flickable {
                    anchors.right: parent.right
                    height: Kirigami.Units.gridUnit * 1.5
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: expressionRow.height
                    contentWidth: expressionRow.width
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: expressionRow
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: Kirigami.Units.gridUnit
                        font.weight: Font.Light
                        text: inputManager.expression
                        color: Kirigami.Theme.disabledTextColor
                    }
                    onContentWidthChanged: {
                        if(contentWidth > width)
                            contentX = contentWidth - width;
                    }
                }
                
                Flickable {
                    anchors.right: parent.right
                    height: Kirigami.Units.gridUnit * 2
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: resultBin.height
                    contentWidth: resultBin.width + Kirigami.Units.gridUnit
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: resultBin
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: Kirigami.Units.gridUnit * 1.5
                        font.weight: Font.Light
                        text: inputManager.binaryResult
                        onTextChanged: resultFadeInAnimation.start()
                        Controls.Label {
                            visible: parent.text.length
                            anchors.left: parent.right
                            anchors.bottom: parent.bottom
                            text: "2"
                            font.pointSize: Kirigami.Units.gridUnit * 0.5
                            font.weight: Font.Light
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }
                }
                
                Flickable {
                    anchors.right: parent.right
                    height: Kirigami.Units.gridUnit * 2
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: resultDec.height
                    contentWidth: resultDec.width + Kirigami.Units.gridUnit
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: resultDec
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: Kirigami.Units.gridUnit * 1.5
                        font.weight: Font.Light
                        text: inputManager.result
                        onTextChanged: resultFadeInAnimation.start()
                        Controls.Label {
                            visible: parent.text.length
                            anchors.left: parent.right
                            anchors.bottom: parent.bottom
                            text: "10"
                            font.pointSize: Kirigami.Units.gridUnit * 0.5
                            font.weight: Font.Light
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }
                }
                
                Flickable {
                    anchors.right: parent.right
                    height: Kirigami.Units.gridUnit * 2
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: resultHex.height
                    contentWidth: resultHex.width + Kirigami.Units.gridUnit
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: resultHex
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: Kirigami.Units.gridUnit * 1.5
                        font.weight: Font.Light
                        text: inputManager.hexResult
                        onTextChanged: resultFadeInAnimation.start()
                        Controls.Label {
                            visible: parent.text.length
                            anchors.left: parent.right
                            anchors.bottom: parent.bottom
                            text: "16"
                            font.pointSize: Kirigami.Units.gridUnit * 0.5
                            font.weight: Font.Light
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }
                }

                NumberAnimation on opacity {
                    id: resultFadeInAnimation
                    from: 0.5
                    to: 1
                    duration: Kirigami.Units.shortDuration
                    exclude: [expressionRow]
                }
                NumberAnimation on opacity {
                    id: resultFadeOutAnimation
                    from: 1
                    to: 0
                    duration: Kirigami.Units.shortDuration
                    exclude: [expressionRow]
                }
            }
        }
        
        // Binary Input Pad
        Item {
            property string expression: ""
            id: binaryInputPad
            Layout.fillHeight: true
            Layout.preferredWidth: initialPage.width
            Layout.alignment: Qt.AlignLeft
            
            BinaryPad {
                id: binaryPad
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                // Uncomment next line for function overlay
                // anchors.rightMargin: Kirigami.Units.gridUnit * 1.5
                onPressed: {
                    if (text == "DEL") {
                        inputManager.backspace();
                    } else if (text == "=") {
                        inputManager.equal();
                        resultFadeOutAnimation.start();
                    } else {
                        inputManager.append(text, true);
                    }
                }
                onClear: inputManager.clear()
            }
        }
    }
    
}
