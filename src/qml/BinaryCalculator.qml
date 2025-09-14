// SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: initialPage

    title: i18n("Programmer")

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    actions: [
        Kirigami.Action {
            icon.name: "edit-undo-symbolic"
            text: i18n("Undo")
            shortcut: "Ctrl+Z"
            enabled: InputManager.canUndo
            onTriggered: InputManager.undo()
        },
        Kirigami.Action {
            icon.name: "edit-redo-symbolic"
            text: i18n("Redo")
            shortcut: "Ctrl+Shift+Z"
            enabled: InputManager.canRedo
            onTriggered: InputManager.redo()
        }
    ]

    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    property int keypadHeight: initialPage.height * 3 / 7
    property int screenHeight: initialPage.height - initialPage.keypadHeight

    Keys.onPressed: event => {
        if (event.matches(StandardKey.Undo)) {
            InputManager.undo();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.Redo)) {
            InputManager.redo();
            event.accepted = true;
            return;
        }

        switch(event.key) {
        case Qt.Key_Delete:
        case Qt.Key_Backspace:
            InputManager.backspace(); break;
        case Qt.Key_0:
            InputManager.append("0"); break;
        case Qt.Key_1:
            InputManager.append("1"); break;
        case Qt.Key_Plus:
            InputManager.append("+"); break;
        case Qt.Key_Minus:
            InputManager.append("-"); break;
        case Qt.Key_Asterisk:
            InputManager.append("*"); break;
        case Qt.Key_Slash:
            InputManager.append("/"); break;
        case Qt.Key_Ampersand:
            InputManager.append("&"); break;
        case Qt.Key_Bar:
            InputManager.append("|"); break;
        case Qt.Key_AsciiCircum:
            InputManager.append("^"); break;
        case Qt.Key_Period:
            InputManager.append("."); break;
        case Qt.Key_Equal:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            InputManager.equal(); break;
        }
        event.accepted = true;
    }

    onIsCurrentPageChanged: {
        if (!InputManager.binaryMode)
            InputManager.binaryMode = true
    }

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: outputScreen
            z: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: initialPage.screenHeight

            Kirigami.ShadowedRectangle {
                id: topPanelBackground
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                Kirigami.Theme.inherit: false
                color: Kirigami.Theme.backgroundColor
                implicitHeight: outputScreen.height
                shadow {
                    yOffset: 1
                    size: 4
                    color: dropShadowColor
                }
            }

            Column {
                id: outputColumn
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: initialPage.screenHeight / 8

                Flickable {
                    anchors.right: parent.right
                    height: initialPage.screenHeight / 8
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: expressionRow.height
                    contentWidth: expressionRow.width
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: expressionRow
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: initialPage.screenHeight * 0.1 / 1.5
                        font.weight: Font.Light
                        text: InputManager.expression
                        color: Kirigami.Theme.disabledTextColor
                    }
                    onContentWidthChanged: {
                        if(contentWidth > width)
                            contentX = contentWidth - width;
                    }
                }

                Flickable {
                    anchors.right: parent.right
                    height: initialPage.screenHeight / 8
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: resultBin.height
                    contentWidth: resultBin.width + Kirigami.Units.gridUnit
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: resultBin
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: initialPage.screenHeight * 0.1
                        font.weight: Font.Light
                        text: InputManager.binaryResult
                        onTextChanged: resultFadeInAnimation.start()
                        Controls.Label {
                            visible: parent.text.length
                            anchors.left: parent.right
                            anchors.bottom: parent.bottom
                            text: "2"
                            font.pointSize: initialPage.screenHeight * 0.1 * 0.3
                            font.weight: Font.Light
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }
                }

                Flickable {
                    anchors.right: parent.right
                    height: initialPage.screenHeight / 8
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: resultDec.height
                    contentWidth: resultDec.width + Kirigami.Units.gridUnit
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: resultDec
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: initialPage.screenHeight * 0.1
                        font.weight: Font.Light
                        text: InputManager.result
                        onTextChanged: resultFadeInAnimation.start()
                        Controls.Label {
                            visible: parent.text.length
                            anchors.left: parent.right
                            anchors.bottom: parent.bottom
                            text: "10"
                            font.pointSize: initialPage.screenHeight * 0.1 * 0.3
                            font.weight: Font.Light
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }
                }

                Flickable {
                    anchors.right: parent.right
                    height: initialPage.screenHeight / 8
                    width: Math.min(parent.width, contentWidth)
                    contentHeight: resultHex.height
                    contentWidth: resultHex.width + Kirigami.Units.gridUnit
                    flickableDirection: Flickable.HorizontalFlick
                    Controls.Label {
                        id: resultHex
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: initialPage.screenHeight * 0.1
                        font.weight: Font.Light
                        text: InputManager.hexResult
                        onTextChanged: resultFadeInAnimation.start()
                        Controls.Label {
                            visible: parent.text.length
                            anchors.left: parent.right
                            anchors.bottom: parent.bottom
                            text: "16"
                            font.pointSize: initialPage.screenHeight * 0.1 * 0.3
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
                onPressed: text => {
                    if (text === "DEL") {
                        InputManager.backspace();
                    } else if (text === "=") {
                        InputManager.equal();
                        resultFadeOutAnimation.start();
                    } else {
                        InputManager.append(text);
                    }
                }
                onClear: InputManager.clear()
            }
        }
    }
}
