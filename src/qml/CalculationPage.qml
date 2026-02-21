/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

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
            shortcut: "Ctrl+H"
            onTriggered: {
                if (applicationWindow().pageStack.depth > 1) {
                    applicationWindow().pageStack.pop();
                }
                else {
                    let page = mainPagePool.loadPage(Qt.resolvedUrl("HistoryView.qml"));
                    applicationWindow().pageStack.push(page, { historyIndex: InputManager.historyIndex });
                };
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-undo-symbolic"
            text: i18n("Undo")
            shortcut: "Ctrl+Z"
            enabled: InputManager.canUndo
            onTriggered: {
                InputManager.undo();
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-redo-symbolic"
            text: i18n("Redo")
            shortcut: "Ctrl+Shift+Z"
            enabled: InputManager.canRedo
            onTriggered: {
                InputManager.redo();
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-cut"
            text: i18n("Cut")
            shortcut: "ctrl+X"
            enabled: expressionRow.selectedText
            onTriggered: {
                cut();
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-copy"
            text: i18n("Copy")
            shortcut: "ctrl+C"
            enabled: expressionRow.text || result.text
            onTriggered: {
                copy();
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-paste"
            text: i18n("Paste")
            shortcut: "ctrl+V"
            onTriggered: {
                paste();
                outputScreen.forceActiveFocus();
            }
        }
    ]

    property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.15)
    readonly property bool inPortrait: initialPage.width < initialPage.height
    property int keypadHeight: initialPage.height * 0.8
    property int screenHeight: initialPage.height - initialPage.keypadHeight

    function cut() {
        if (expressionRow.selectedText) {
            const pos = expressionRow.cursorPosition - expressionRow.selectedText.length;
            expressionRow.cut();
            expressionRow.cursorPosition = pos;
        }
    }
    function copy() {
        if (expressionRow.selectedText) {
            expressionRow.copy();
        } else if (result.selectedText) {
            result.copy();
        } else {
            result.selectAll();
            result.copy();
            result.deselect();
        }
    }
    function paste() {
        expressionRow.paste();
    }

    Keys.onPressed: event => {
        if (event.matches(StandardKey.Undo)) {
            InputManager.undo();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.Redo)) {
            InputManager.redo();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.Cut)) {
            cut();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.Copy)) {
            copy();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.Paste)) {
            paste();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.SelectAll)) {
            if (expressionRow.focus) {
                expressionRow.focus = false;
                expressionRow.selectAll();
            } else {
                result.selectAll();
            }
            event.accepted = true;
            return;
        } else if (event.modifiers && !event.text) {
            event.accepted = true;
            return;
        }

        switch(event.key) {
          case Qt.Key_Escape:
          case Qt.Key_Delete:
              InputManager.clear(false); break;
          case Qt.Key_Backspace:
              InputManager.backspace(); break;
          case Qt.Key_0:
              InputManager.append("0"); break;
          case Qt.Key_1:
              InputManager.append("1"); break;
          case Qt.Key_2:
              InputManager.append("2"); break;
          case Qt.Key_3:
              InputManager.append("3"); break;
          case Qt.Key_4:
              InputManager.append("4"); break;
          case Qt.Key_5:
              InputManager.append("5"); break;
          case Qt.Key_6:
              InputManager.append("6"); break;
          case Qt.Key_7:
              InputManager.append("7"); break;
          case Qt.Key_8:
              InputManager.append("8"); break;
          case Qt.Key_9:
              InputManager.append("9"); break;
          case Qt.Key_Plus:
              InputManager.append("+"); break;
          case Qt.Key_Minus:
              InputManager.append("-"); break;
          case Qt.Key_Asterisk:
              InputManager.append("×"); break;
          case Qt.Key_Slash:
              InputManager.append("÷"); break;
          case Qt.Key_AsciiCircum:
              InputManager.append("^"); break;
          case Qt.Key_Period:
              InputManager.append(Qt.locale().decimalPoint); break;
          case Qt.Key_ParenLeft:
              InputManager.append("("); break;
          case Qt.Key_ParenRight:
              InputManager.append(")"); break;
          case Qt.Key_Comma:
              InputManager.append(","); break;
          case Qt.Key_Equal:
          case Qt.Key_Return:
          case Qt.Key_Enter:
              InputManager.equal();
              expressionRow.focus = false;
              break;
          case Qt.Key_Left:
              expressionRow.focus = true;
              expressionRow.cursorPosition = InputManager.idealCursorPosition(expressionRow.cursorPosition - 1, -1);
              break;
          case Qt.Key_Right:
              expressionRow.focus = true;
              expressionRow.cursorPosition = InputManager.idealCursorPosition(expressionRow.cursorPosition + 1, 1);
              break;
          case Qt.Key_Underscore: break;
          default:
            InputManager.append(event.text);
        }
        event.accepted = true;
    }

    // Changes the current mode of the backend to non-binary
    onIsCurrentPageChanged: {
        if (InputManager.binaryMode)
            InputManager.binaryMode = false
    }

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
    }

    Item {
        anchors.fill: parent

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

        ColumnLayout {
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
                        font.pointSize: outputScreen.flexPointSize * (text.length * outputScreen.flexPointSize * 0.7 > outputScreen.width ? 0.7 : 1)
                        font.weight: Font.ExtraLight
                        text: InputManager.expression
                        background: Rectangle { color: "transparent" }
                        padding: 0
                        selectByMouse: false
                        textFormat: Text.PlainText

                        property string lastText
                        onTextChanged: {
                            if (text !== InputManager.expression) {
                                const value = text;
                                InputManager.clear(false);
                                InputManager.append(value);
                            } else {
                                cursorPosition = InputManager.cursorPosition;
                            }
                        }
                        onCursorPositionChanged: {
                            if (lastText === text && selectedText === "") {
                                const pos = InputManager.idealCursorPosition(cursorPosition); // this only calculates the position, doesn't modify InputManager in any way
                                cursorPosition = pos;
                                InputManager.cursorPosition = pos;
                            } else {
                                lastText = text;
                            }
                        }
                        onPressed: {
                            focus = true;
                            result.focus = false;
                            result.deselect();
                            textEdit.deselect();
                        }
                        onEditingFinished: {
                            if (textEdit.selectedText) {
                                select(textEdit.selectionStart, textEdit.selectionEnd);
                            }
                        }
                        onPressAndHold: {
                            // use textEdit as a proxy to select
                            // replace separators with letters so are treated a single words
                            // replace symbols with spaces
                            textEdit.text = InputManager.expression.replace(/[,\.\(\)]/g, "n").replace(/[\+\-×÷%\!\^]/g, " ");
                            textEdit.cursorPosition = cursorPosition;
                            textEdit.selectWord();
                            select(textEdit.selectionStart, textEdit.selectionEnd);
                        }

                        Keys.onPressed: event => {
                            event.accepted = false;
                            initialPage.Keys.pressed(event);
                        }
                    }
                    onContentWidthChanged: {
                        if (contentWidth > width) {
                            // keep flickable at start if coming from result
                            if (InputManager.moveFromResult) {
                                contentX = 0;
                            } else if (InputManager.cursorPosition < expressionRow.positionAt(contentX + width, height / 2)) {
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
                        font.pointSize: Math.round(outputScreen.flexPointSize) * (text.length * outputScreen.flexPointSize > outputScreen.width ? 0.9 : 1.4)
                        text: InputManager.result
                        background: Rectangle { color: "transparent" }
                        padding: 0
                        selectByMouse: false
                        textFormat: Text.PlainText
                        readOnly: true

                        onTextChanged: resultFadeInAnimation.start()
                        onPressed: {
                            focus = false;
                            expressionRow.focus = false;
                            expressionRow.deselect();
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
                        expressionRow.focus = false;
                        result.focus = false;
                        result.deselect();
                        expressionRow.deselect();
                    }
                }
            }

            // keypad area
            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 0
                onWidthChanged: view.currentIndex = 0

                Item {
                    id: inputPad
                    Layout.fillHeight: true
                    Layout.preferredWidth: inPortrait ? initialPage.width : initialPage.width >= initialPage.height * 1.6 ? initialPage.width * 0.5 : initialPage.width * 0.6
                    Layout.alignment: Qt.AlignLeft

                    Controls.PageIndicator {
                        id: indicator
                        visible: view.interactive
                        anchors.bottom: view.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        count: view.count
                        currentIndex: view.currentIndex

                        TapHandler {
                            onTapped: view.currentIndex = !view.currentIndex
                        }
                    }

                    Controls.SwipeView {
                        id: view
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        anchors.topMargin: inPortrait ? indicator.height + Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
                        currentIndex: 1
                        interactive: inPortrait
                        spacing: Kirigami.Units.smallSpacing

                        NumberPad {
                            id: numberPad
                            inPortrait: initialPage.inPortrait
                            onPressed: text => {
                                if (text == "DEL") {
                                    InputManager.backspace();
                                } else if (text == "=") {
                                    InputManager.equal();
                                    expressionRow.focus = false;
                                } else {
                                    InputManager.append(text);
                                }
                            }
                            onClear: {
                                InputManager.clear();
                                resultFadeOutAnimation.start();
                            }
                        }

                        FunctionPad {
                            onPressed: text => InputManager.append(text)
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
                        anchors.leftMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: Kirigami.Units.smallSpacing
                        anchors.topMargin: Kirigami.Units.largeSpacing
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        onPressed: text => InputManager.append(text)
                    }
                }
            }
        }
    }
}
