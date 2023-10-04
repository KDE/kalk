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

Kirigami.ScrollablePage {
    title: i18n("History")

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        text: i18n("History is empty")
        visible: listView.count === 0
    }
    actions: Kirigami.Action {
        icon.name: "edit-clear-history"
        text: i18n("Clear history")
        onTriggered: historyManager.clearHistory();
    }

ListView {
    id: listView

        currentIndex: -1

        property int flexPointSize: Math.min(Kirigami.Theme.defaultFont.pointSize * 1.5, Math.max(width / 20, 5))

        Layout.fillWidth: true
        model: historyManager
        delegate: Kirigami.AbstractListItem {
            highlighted: false
            onClicked:{
                inputManager.fromHistory(model.display.split('=')[1]);
                pageStack.pop()
            }
            Label {
                font.pointSize: listView.flexPointSize
                font.weight: Font.Light
                text: model.display
                wrapMode: Text.Wrap
            }
        }
    }
}
