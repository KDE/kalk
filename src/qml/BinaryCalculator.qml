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
    
    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    property int keypadHeight: {
        let rows = 6, columns = 5;
        // restrict keypad so that the height of buttons never go past 0.85 times their width
        if ((initialPage.height - Kirigami.Units.gridUnit * 7) / rows > 0.85 * initialPage.width / columns) {
            return rows * 0.85 * initialPage.width / columns;
        } else {
            return initialPage.height - Kirigami.Units.gridUnit * 7;
        }
    }

    onIsCurrentPageChanged: {
        inputManager.setBinaryMode(true)
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            id: outputScreen
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: initialPage.height - initialPage.keypadHeight
            color: Kirigami.Theme.backgroundColor
            
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
                    height: Kirigami.Units.gridUnit * 4
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: result.height
                    contentWidth: result.width
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: result
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: Kirigami.Units.gridUnit * 2
                        text: inputManager.result
                        NumberAnimation on opacity {
                            id: resultFadeInAnimation
                            from: 0.5
                            to: 1
                            duration: Kirigami.Units.shortDuration
                        }
                        NumberAnimation on opacity {
                            id: resultFadeOutAnimation
                            from: 1
                            to: 0
                            duration: Kirigami.Units.shortDuration
                        }

                        onTextChanged: resultFadeInAnimation.start()
                    }
                }
            }
        }
        
        // Binary Input Pad
        Rectangle {
            property string expression: ""
            id: binaryInputPad
            Layout.fillHeight: true
            Layout.preferredWidth: initialPage.width
            Layout.alignment: Qt.AlignLeft
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            
            BinaryPad {
                id: binaryPad
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                // Uncomment next line for function overlay
                // anchors.rightMargin: Kirigami.Units.gridUnit * 1.5
                onPressed: {
                    if (text == "DEL") {
                        inputManager.backspace();
                    } else {
                        inputManager.append(text, true);
                    }
                }
                onClear: inputManager.clear()
            }
        }
        
        // top panel drop shadow (has to be above the keypad) - from main calculator
        DropShadow {
            anchors.fill: outputScreen
            source: outputScreen
            horizontalOffset: 0
            verticalOffset: 1
            radius: 4
            samples: 6
            color: initialPage.dropShadowColor
        }
    }
    
}
