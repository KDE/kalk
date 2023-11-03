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

Kirigami.ScrollablePage {
    title: i18n("History")

    actions: Kirigami.Action {
        icon.name: "edit-clear-history"
        text: i18n("Clear history")
        onTriggered: historyManager.clearHistory();
    }

    ListView {
        id: listView

        currentIndex: -1

        model: historyManager
        delegate: Delegates.RoundedItemDelegate {
            id: historyDelegate

            required property int index
            required property var model

            highlighted: false
            onClicked: {
                inputManager.fromHistory(model.display.split('=')[1]);
                pageStack.pop()
            }
            text: historyDelegate.model.display
            contentItem: Label {
                font {
                    weight: Font.Light
                }
                text: historyDelegate.model.display
                wrapMode: Text.Wrap
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            text: i18n("History is empty")
            visible: listView.count === 0
            width: parent.width - Kirigami.Units.gridUnit * 4
        }
    }
}
