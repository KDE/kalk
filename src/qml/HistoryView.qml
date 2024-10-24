/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020 cahfofpai
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates as Delegates
import org.kde.kalk

Kirigami.ScrollablePage {
    id: page
    title: i18n("History")

    property int historyIndex

    Connections {
        target: pageStack
        function onCurrentItemChanged () {
            const index = listView.atYEnd ? 0 : listView.indexAt(listView.contentX, listView.contentY)
            InputManager.setHistoryIndex(index);
        }
    }

    actions: Kirigami.Action {
        icon.name: "edit-clear-history"
        text: i18n("Clear history")
        onTriggered: promptDialog.open()
    }

    ListView {
        id: listView

        property int flexPointSize: Math.min(Kirigami.Theme.defaultFont.pointSize * 2, Math.max(width / 30, 7))

        Component.onCompleted: {
            if (page.historyIndex && page.historyIndex < listView.count) {
                positionViewAtIndex(page.historyIndex, ListView.Beginning)
            } else {
                positionViewAtEnd()
            }
        }

        currentIndex: -1
        model: HistoryManager
        delegate: Delegates.RoundedItemDelegate {
            id: historyDelegate

            required property int index
            required property var model

            highlighted: false

            contentItem: RowLayout {
                id: item
                spacing: Kirigami.Units.smallSpacing

                property var parts: model.display.split("=")

                Button {
                    Layout.maximumWidth: listView.width / 2.5
                    Layout.alignment:  Qt.AlignLeft
                    focusPolicy: Qt.NoFocus
                    flat: true
                    onClicked: {
                        InputManager.fromHistory(item.parts[0].trim());
                        if (applicationWindow().pageStack.visibleItems.length === 1) {
                            applicationWindow().pageStack.pop();
                        }
                    }
                    contentItem: Label {
                        font {
                            pointSize: listView.flexPointSize
                            weight: Font.Light
                        }
                        text: item.parts[0].trim()
                        elide: Text.ElideRight
                    }

                    ToolTip.visible: contentItem.truncated && hovered
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.text: contentItem.text
                }

                Label {
                    Layout.alignment:  Qt.AlignLeft
                    font {
                        pointSize: listView.flexPointSize
                        weight: Font.Light
                    }
                    text: "="
                }

                Button {
                    Layout.fillWidth: true
                    Layout.alignment:  Qt.AlignLeft
                    focusPolicy: Qt.NoFocus
                    flat: true
                    onClicked: {
                        InputManager.fromHistory(item.parts[1].trim());
                        if (applicationWindow().pageStack.visibleItems.length === 1) {
                            applicationWindow().pageStack.pop();
                        }
                    }
                    contentItem: Label {
                        font {
                            pointSize: listView.flexPointSize
                            weight: Font.Light
                        }
                        text: item.parts[1].trim()
                        elide: Text.ElideRight
                    }

                    ToolTip.visible: contentItem.truncated && hovered
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.text: contentItem.text
                }

                Button {
                    Layout.alignment:  Qt.AlignRight
                    icon.name: "delete"
                    onClicked: HistoryManager.deleteFromHistory(model.index);
                    focusPolicy: Qt.NoFocus
                    flat: true
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            text: i18n("History is empty")
            visible: listView.count === 0
            width: parent.width - Kirigami.Units.gridUnit * 4
        }
    }

    Kirigami.PromptDialog {
        id: promptDialog
        title: i18nc("Delete all items from a list", "Clear All History?")
        subtitle: i18nc("Deleted items cannot be recovered", "This is permanent and cannot be undone")
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: HistoryManager.clearHistory();
        onRejected: close()
    }
}
