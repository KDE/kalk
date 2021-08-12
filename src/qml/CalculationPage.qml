/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
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
    readonly property bool inPortrait: initialPage.width < initialPage.height
    property int keypadHeight: {
        let height = 0;
        if (inPortrait) {
            height = initialPage.width * 7/6;
        } else {
            height = initialPage.width * 3/4;
        }
        if (height > initialPage.height - Kirigami.Units.gridUnit * 7) {
            height = initialPage.height - Kirigami.Units.gridUnit * 7;
        }
        return height;
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
        case Qt.Key_2:
            inputManager.append("2"); break;
        case Qt.Key_3:
            inputManager.append("3"); break;
        case Qt.Key_4:
            inputManager.append("4"); break;
        case Qt.Key_5:
            inputManager.append("5"); break;
        case Qt.Key_6:
            inputManager.append("6"); break;
        case Qt.Key_7:
            inputManager.append("7"); break;
        case Qt.Key_8:
            inputManager.append("8"); break;
        case Qt.Key_9:
            inputManager.append("9"); break;
        case Qt.Key_Plus:
            inputManager.append("+"); break;
        case Qt.Key_Minus:
            inputManager.append("-"); break;
        case Qt.Key_Asterisk:
            inputManager.append("×"); break;
        case Qt.Key_Slash:
            inputManager.append("÷"); break;
        case Qt.Key_AsciiCircum:
            inputManager.append("^"); break;
        case Qt.Key_Period:
            inputManager.append("."); break;
        case Qt.Key_ParenLeft:
            inputManager.append("("); break;
        case Qt.Key_ParenRight:
            inputManager.append(")"); break;
        case Qt.Key_Equal:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            inputManager.equal(); break;
        default:
          switch(event.text) {
          case "⋅":
          case "×":
          case "*":
            inputManager.append("×"); break;
          case "∶":
          case "∕":
          case "÷":
          case "/":
            inputManager.append("÷"); break;
          case "−":
          case "-":
            inputManager.append("-"); break;
					case "+":
						inputManager.append("+"); break;
          }
        }
        event.accepted = true;
    }

    // Changes the current mode of the backend to non-binary
    onIsCurrentPageChanged: {
        if (inputManager.binaryMode)
            inputManager.binaryMode = false
    }

    background: Rectangle {
        opacity: mainOpacity

        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }

    Item {
        anchors.fill: parent
        opacity: mainOpacity
        transform: Translate { y: yTranslate }

        // top panel drop shadow
        RectangularGlow {
            opacity: mainOpacity

            anchors.fill: topPanelBackground
            anchors.topMargin: 1
            glowRadius: 4
            spread: 0.2
            color: dropShadowColor
        }

        Rectangle {
            id: topPanelBackground
            opacity: mainOpacity

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: Kirigami.Theme.backgroundColor
            implicitHeight: outputScreen.height
        }

        ColumnLayout {
            opacity: mainOpacity
            transform: Translate { y: yTranslate }
            anchors.fill: parent
            spacing: 0

            Item {
                id: outputScreen
                z: 1
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: initialPage.height - initialPage.keypadHeight

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
                        height: Kirigami.Units.gridUnit * 4
                        width: Math.min(parent.width, contentWidth)
                        contentHeight: result.height
                        contentWidth: result.width
                        flickableDirection: Flickable.HorizontalFlick
                        Controls.Label {
                            id: result
                            horizontalAlignment: Text.AlignRight
                            font.pointSize: Kirigami.Units.gridUnit * 2
                            font.weight: Font.Light
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

            // keypad area
            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Item {
                    property string expression: ""
                    id: inputPad
                    Layout.fillHeight: true
                    Layout.preferredWidth: inPortrait ? initialPage.width : initialPage.width * 0.5
                    Layout.alignment: Qt.AlignLeft

                    NumberPad {
                        id: numberPad
                        anchors.fill: parent
                        anchors.topMargin: Kirigami.Units.gridUnit * 0.7
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        anchors.leftMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: Kirigami.Units.gridUnit * 1.5 // for right side drawer indicator
                        inPortrait: initialPage.inPortrait
                        onPressed: {
                            if (text == "DEL") {
                                inputManager.backspace();
                            } else if (text == "=") {
                                inputManager.equal();
                                resultFadeOutAnimation.start();
                            } else {
                                inputManager.append(text);
                            }
                        }
                        onClear: inputManager.clear()
                    }

                    // fast drop shadow
                    RectangularGlow {
                        visible: inPortrait
                        anchors.rightMargin: 1
                        anchors.fill: drawerIndicator
                        glowRadius: 4
                        spread: 0.2
                        color: initialPage.dropShadowColor
                    }

                    Rectangle {
                        id: drawerIndicator
                        visible: inPortrait
                        z: 1
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Kirigami.Units.gridUnit
                        x: parent.width - this.width

                        Kirigami.Theme.colorSet: Kirigami.Theme.View
                        Kirigami.Theme.inherit: false
                        color: Kirigami.Theme.backgroundColor

                        Rectangle {
                            anchors.centerIn: parent
                            height: parent.height / 20
                            width: parent.width / 4
                            radius: 3
                            color: Kirigami.Theme.textColor
                        }
                    }

                    Controls.Drawer {
                        id: functionDrawer
                        parent: initialPage
                        y: initialPage.height - inputPad.height
                        height: inputPad.height
                        width: initialPage.width * 0.8
                        visible: inPortrait
                        dragMargin: drawerIndicator.width
                        edge: Qt.RightEdge
                        dim: false
                        onXChanged: drawerIndicator.x = this.x - drawerIndicator.width + drawerIndicator.radius;
                        opacity: 1 // for plasma style

                        property bool firstOpen: true
                        onOpened: {
                            // HACK: don't open drawer when application starts
                            // there doesn't seem to be another way to do this...
                            if (firstOpen) {
                                close();
                                firstOpen = false;
                            }
                        }

                        FunctionPad {
                            anchors.fill: parent
                            anchors.bottom: parent.Bottom
                            anchors.leftMargin: Kirigami.Units.largeSpacing
                            anchors.rightMargin: Kirigami.Units.largeSpacing
                            anchors.topMargin: Kirigami.Units.largeSpacing
                            anchors.bottomMargin: parent.height / 4
                            onPressed: inputManager.append(text)
                        }
                        // for plasma style
                        background: Rectangle {
                            Kirigami.Theme.colorSet: Kirigami.Theme.View
                            color: Kirigami.Theme.backgroundColor
                            anchors.fill: parent
                        }
                    }
                }
                Item {
                    Layout.alignment:  Qt.AlignRight
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    visible: !inPortrait
                    FunctionPad {
                        anchors.fill: parent
                        anchors.bottom: parent.Bottom
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        anchors.rightMargin: Kirigami.Units.largeSpacing
                        anchors.topMargin: Kirigami.Units.largeSpacing
                        anchors.bottomMargin: parent.height / 4
                        onPressed: inputManager.append(text)
                    }
                }
            }
        }
    }

}
