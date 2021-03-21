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

    Kirigami.PagePool {
        id: mainPagePool
    }
    
    // page switch animation
    NumberAnimation {
        id: anim
        from: 0
        to: 1
        duration: Kirigami.Units.longDuration * 2
        easing.type: Easing.InOutQuad
    }
    NumberAnimation {
        id: yAnim
        from: Kirigami.Units.gridUnit * 3
        to: 0
        duration: Kirigami.Units.longDuration * 3
        easing.type: Easing.OutQuint
    }
    
    function pageAnimation(page) {
        // page switch animation
        yAnim.target = page;
        yAnim.properties = "yTranslate";
        anim.target = page;
        anim.properties = "mainOpacity";
        yAnim.restart();
        anim.restart();
    }

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true
        actions: [
            Kirigami.PagePoolAction {
                text: i18n("Calculator")
                iconName: "accessories-calculator"
                pagePool: mainPagePool
                page: "qrc:/qml/CalculationPage.qml"
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("History")
                iconName: "shallow-history"
                page: "qrc:/qml/HistoryView.qml"
                pagePool: mainPagePool
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("Convertor")
                iconName: "gtk-convert"
                page: "qrc:/qml/UnitConverter.qml"
                pagePool: mainPagePool
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("Binary Calculator")
                iconName: "accessories-calculator"
                pagePool: mainPagePool
                page: "qrc:/qml/BinaryCalculator.qml"
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("About")
                iconName: "help-about"
                page: "qrc:/qml/AboutPage.qml"
                pagePool: mainPagePool
                onTriggered: pageAnimation(pageItem())
            }
        ]
    }

    pageStack.initialPage: mainPagePool.loadPage("qrc:/qml/CalculationPage.qml")
}
