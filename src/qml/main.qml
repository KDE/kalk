/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020 cahfofpai
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1 as Controls
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0
import org.kde.kirigami 2.13 as Kirigami

Kirigami.ApplicationWindow {
    id: root
    title: 'Kalk'
    visible: true
    height: Kirigami.Units.gridUnit * 30
    width: Kirigami.Units.gridUnit * 20
    readonly property int columnWidth: Kirigami.Units.gridUnit * 13
    wideScreen: width > columnWidth * 3
    Component.onCompleted: {
        pageStack.globalToolBar.canContainHandles = true;
    }

    function switchToPage(page) {
        while (pageStack.depth > 0) pageStack.pop();
        pageStack.push(page);
    }

    Kirigami.PagePool {
        id: mainPagePool
    }

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true
        actions: [
            Kirigami.PagePoolAction {
                text: i18n("Calculator")
                iconName: "accessories-calculator"
                pagePool: mainPagePool
                page: "qrc:/qml/CalculationPage.qml"
            },
            Kirigami.PagePoolAction {
                text: i18n("History")
                iconName: "shallow-history"
                page: "qrc:/qml/HistoryView.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                text: i18n("Convertor")
                iconName: "gtk-convert"
                page: "qrc:/qml/UnitConverter.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                text: i18n("About")
                iconName: "help-about"
                page: "qrc:/qml/AboutPage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                text: i18n("Binary Calculator")
                iconName: "accessories-calculator"
                pagePool: mainPagePool
                page: "qrc:/qml/BinaryCalculator.qml"
            }
        ]
    }

    pageStack.initialPage: mainPagePool.loadPage("qrc:/qml/CalculationPage.qml")
}
