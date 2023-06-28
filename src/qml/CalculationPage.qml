/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.15 as Kirigami

Kirigami.Page {
    id: initialPage
    title: i18n("Calculator")
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    actions: [
        Kirigami.Action {
            text: i18n("History")
            icon.name: "shallow-history"
            onTriggered: {
                if (applicationWindow().pageStack.depth > 1) {
                    applicationWindow().pageStack.pop();
                }
                else {
                    applicationWindow().pageStack.push("qrc:/qml/HistoryView.qml");
                };
                functionDrawer.close();
            }
        }
    ]

    property int yTranslate: 0
    property real mainOpacity: 1

    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    readonly property bool inPortrait: initialPage.width < initialPage.height
    property int keypadHeight: initialPage.height * 0.7
    property int screenHeight: initialPage.height - initialPage.keypadHeight

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
          case Qt.Key_Comma:
              inputManager.append(","); break;
          case Qt.Key_Equal:
          case Qt.Key_Return:
          case Qt.Key_Enter:
              inputManager.equal();
              expressionRow.focus = false;
              break;
          case Qt.Key_Left:
              expressionRow.focus = true;
              const idealPosLeft = inputManager.idealCursorPosition(expressionRow.cursorPosition - 1);
              if (expressionRow.cursorPosition === idealPosLeft) {
                  expressionRow.cursorPosition -= 2;
              } else if (expressionRow.cursorPosition === idealPosLeft - 1) {
                  expressionRow.cursorPosition -= 3;
              } else {
                  expressionRow.cursorPosition -= 1;
              }
              break;
          case Qt.Key_Right:
              expressionRow.focus = true;
              if (expressionRow.cursorPosition === inputManager.idealCursorPosition(expressionRow.cursorPosition + 1)) {
                  expressionRow.cursorPosition += 3;
              } else {
                  expressionRow.cursorPosition += 1;
              }
              break;
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

        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }

    Item {
        anchors.fill: parent
        opacity: mainOpacity
        transform: Translate { y: yTranslate }

        // top panel drop shadow
        Kirigami.ShadowedRectangle {
            opacity: mainOpacity
            shadow.size: 4
            anchors.fill: topPanelBackground
            anchors.topMargin: 1
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
                Layout.preferredHeight: initialPage.screenHeight

                property int flexPointSize: Math.max(Math.min(height / 4, width / 16), Kirigami.Theme.defaultFont.pointSize)

                TextEdit {
                    id: textEdit
                    visible: false
                }

                // input row
                Flickable {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.leftMargin: Kirigami.Units.largeSpacing * 2
                    anchors.rightMargin: Kirigami.Units.largeSpacing * 2

                    height: contentHeight
                    width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, contentWidth)

                    contentHeight: expressionRow.height
                    contentWidth: expressionRow.width
                    flickableDirection: Flickable.HorizontalFlick

                    Controls.TextArea {
                        id: expressionRow
                        activeFocusOnPress: false
                        font.pointSize: outputScreen.flexPointSize
                        font.weight: Font.Light
                        text: inputManager.expression
                        color: Kirigami.Theme.disabledTextColor
                        background: Rectangle { color: "transparent" }
                        padding: 0
                        selectByMouse: false
                        textFormat: Text.PlainText

                        property string lastText
                        onTextChanged: {
                            if (text !== inputManager.expression) {
                                const pasteText = text.replace(/,/g, "");
                                inputManager.clear();
                                inputManager.append(pasteText);
                            } else {
                                cursorPosition = inputManager.cursorPosition;
                            }
                        }
                        onCursorPositionChanged: {
                            if (lastText === text && selectedText === "") {
                                const pos = inputManager.idealCursorPosition(cursorPosition); // this only calculate the postion, doesn't modify inputManager in anyway
                                cursorPosition = pos;
                                inputManager.cursorPosition = pos;
                            } else {
                                lastText = text;
                            }
                        }
                        onPressed: {
                            focus = true;
                            result.focus = false;
                            result.deselect();
                        }
                        onPressAndHold: {
                            // use textEdit as a proxy to select
                            // replace separators with letters so are treated a single words
                            // replace symbols with spaces
                            textEdit.text = inputManager.expression.replace(/[,\.\(\)]/g, "n").replace(/[\+\-×÷%\!\^]/g, " ");
                            textEdit.cursorPosition = cursorPosition;
                            textEdit.selectWord();
                            select(textEdit.selectionStart, textEdit.selectionEnd);
                        }

                        Keys.onPressed: {
                            event.accepted = false;
                            initialPage.Keys.pressed(event);
                        }
                    }
                    onContentWidthChanged: {
                        if (contentWidth > width) {
                            // keep flickable at start if coming from result
                            if (inputManager.moveFromResult) {
                                contentX = 0;
                            } else if (inputManager.cursorPosition < expressionRow.positionAt(contentX + width, height / 2)) {
                                // do nothing
                            } else {
                                contentX = contentWidth - width;
                            }
                        }
                    }
                }

                // answer row
                Flickable {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.leftMargin: Kirigami.Units.largeSpacing * 2
                    anchors.rightMargin: Kirigami.Units.largeSpacing * 2

                    height: contentHeight
                    width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, contentWidth)

                    contentHeight: result.height
                    contentWidth: result.width
                    flickableDirection: Flickable.HorizontalFlick

                    Controls.TextArea {
                        id: result
                        activeFocusOnPress: false
                        font.pointSize: Math.round(outputScreen.flexPointSize * 1.5)
                        font.weight: Font.Light
                        text: inputManager.result
                        background: Rectangle { color: "transparent" }
                        padding: 0
                        selectByMouse: false
                        textFormat: Text.PlainText
                        readOnly: true

                        onTextChanged: resultFadeInAnimation.start()
                        onPressed: {
                            focus = false
                            expressionRow.focus = false
                        }
                        onPressAndHold: selectAll()

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
                    }
                }

                TapHandler {
                    onTapped: {
                        expressionRow.focus = false
                        result.focus = false
                        result.deselect()
                    }
                }
            }

            // keypad area
            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                onWidthChanged: {
                    if (!functionDrawer.opened && inPortrait)
                        drawerIndicator.x = this.width - drawerIndicator.width + drawerIndicator.radius;
                }

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
                                expressionRow.focus = false;
                                resultFadeOutAnimation.start();
                            } else {
                                inputManager.append(text);
                            }
                        }
                        onClear: inputManager.clear()
                    }

                    // fast drop shadow
                    Kirigami.ShadowedRectangle {
                        visible: inPortrait
                        anchors.rightMargin: 1
                        anchors.fill: drawerIndicator
                        shadow.size: 4
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
                        x: initialPage.width // BUG: We can not stop drawer from covering history, when window is in landscape mode, by making its x to edge of initial page instead, as according to QT docs 'It is not possible to set the x-coordinate (or horizontal margins) of a drawer at the left or right window edge'
                        height: inputPad.height
                        width: initialPage.width * 0.8
                        interactive: inPortrait
                        dragMargin: drawerIndicator.width
                        edge: Qt.RightEdge
                        dim: false
                        onXChanged: drawerIndicator.x = this.x - drawerIndicator.width + drawerIndicator.radius;
                        opacity: 1 // for plasma style

                        FunctionPad {
                            anchors.fill: parent
                            anchors.bottom: parent.Bottom
                            anchors.leftMargin: Kirigami.Units.largeSpacing
                            anchors.rightMargin: Kirigami.Units.largeSpacing
                            anchors.topMargin: Kirigami.Units.largeSpacing
                            anchors.bottomMargin: parent.height / 4
                            onPressed: {
                                inputManager.append(text)
                                functionDrawer.close()
                            }
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
