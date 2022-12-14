/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020 cahfofpai
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.12 as Kirigami

Kirigami.ScrollablePage {
    title: i18n("History")
    width: 0
    
    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        text: i18n("History is empty")
        visible: listView.count == 0
    }
    actions {
        main: Kirigami.Action {
            iconName: "edit-clear-history"
            text: i18n("Clear history")
            onTriggered: historyManager.clearHistory();
        }
    }

    ListView {
        id: listView
        
        currentIndex: -1
        
        Layout.fillWidth: true
        model: historyManager
        delegate: Kirigami.AbstractListItem {
            highlighted: false
            onClicked:{
                inputManager.fromHistory(model.display.split('=')[1]);
                pageStack.pop()
            }
            Label {
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2
                font.weight: Font.Light
                text: model.display
                wrapMode: Text.Wrap
            }
        }
    }
}
