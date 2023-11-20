/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects

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
                    applicationWindow().pageStack.push("qrc:/qml/HistoryView.qml");
                };
                functionDrawer.close();
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-undo-symbolic"
            text: i18n("Undo")
            shortcut: "Ctrl+Z"
            enabled: inputManager.canUndo
            onTriggered: {
                inputManager.undo();
                outputScreen.forceActiveFocus();
            }
        },
        Kirigami.Action {
            icon.name: "edit-redo-symbolic"
            text: i18n("Redo")
            shortcut: "Ctrl+Shift+Z"
            enabled: inputManager.canRedo
            onTriggered: {
                inputManager.redo();
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

    property int yTranslate: 0
    property real mainOpacity: 1

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
            inputManager.undo();
            event.accepted = true;
            return;
        } else if (event.matches(StandardKey.Redo)) {
            inputManager.redo();
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
          case Qt.Key_Delete:
              if (expressionRow.cursorPosition < expressionRow.length) {
                  expressionRow.cursorPosition = inputManager.idealCursorPosition(expressionRow.cursorPosition + 1, 1);
                  inputManager.backspace();
              }
              break;
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
              expressionRow.cursorPosition = inputManager.idealCursorPosition(expressionRow.cursorPosition - 1, -1);
              break;
          case Qt.Key_Right:
              expressionRow.focus = true;
              expressionRow.cursorPosition = inputManager.idealCursorPosition(expressionRow.cursorPosition + 1, 1);
              break;
          case Qt.Key_Underscore: break;
          default:
            inputManager.append(event.text);
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
                                const value = text;
                                inputManager.clear(false);
                                inputManager.append(value);
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
                            textEdit.text = inputManager.expression.replace(/[,\.\(\)]/g, "n").replace(/[\+\-×÷%\!\^]/g, " ");
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
                        font.pointSize: Math.round(outputScreen.flexPointSize) * (text.length * outputScreen.flexPointSize > outputScreen.width ? 0.9 : 1.4)
                        font.weight: Font.Light
                        text: inputManager.result
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
                spacing: Kirigami.Units.gridUnit

                onWidthChanged: {
                    if (!functionDrawer.opened && inPortrait)
                        drawerIndicator.x = this.width - drawerIndicator.width + drawerIndicator.radius;
                }

                Item {
                    property string expression: ""
                    id: inputPad
                    Layout.fillHeight: true
                    Layout.preferredWidth: inPortrait ? initialPage.width : initialPage.width * 0.6
                    Layout.alignment: Qt.AlignLeft

                    NumberPad {
                        id: numberPad
                        anchors.fill: parent
                        anchors.topMargin: Kirigami.Units.largeSpacing
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        anchors.leftMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: inPortrait ? Kirigami.Units.gridUnit * 1.5 : 0 // for right side drawer indicator
                        inPortrait: initialPage.inPortrait
                        onPressed: text => {
                            if (text == "DEL") {
                                inputManager.backspace();
                            } else if (text == "=") {
                                inputManager.equal();
                                expressionRow.focus = false;
                            } else {
                                inputManager.append(text);
                            }
                        }
                        onClear: {
                            inputManager.clear();
                            resultFadeOutAnimation.start();
                        }
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
                        visible: inPortrait || functionDrawer.opened
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
                        interactive: inPortrait || opened
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
                            anchors.bottomMargin: Kirigami.Units.largeSpacing * 4
                            onPressed: text => {
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
                        anchors.leftMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: Kirigami.Units.smallSpacing
                        anchors.topMargin: Kirigami.Units.largeSpacing
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        onPressed: text => inputManager.append(text)
                    }
                }
            }
        }
    }
}
