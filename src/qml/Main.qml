/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020 cahfofpai
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform
import Qt.labs.settings
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    title: 'Kalk'
    visible: true
    minimumWidth: 150
    minimumHeight: 200
    width: 300
    height: 450
    readonly property int columnWidth: Kirigami.Units.gridUnit * 13
    wideScreen: width > columnWidth * 3

    pageStack.globalToolBar.canContainHandles: true
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;
    pageStack.popHiddenPages: true

    Kirigami.PagePool {
        id: mainPagePool
    }

    Connections {
        target: InputManager

        function onAddHistory(entry: string): void {
            HistoryManager.addHistory(entry);
        }
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

    globalDrawer: Kirigami.OverlayDrawer {
        id: drawer
        width: 300
        height: root.height
        enabled: Kirigami.Settings.isMobile

        // for desktop menu
        property bool isMenu: true
        property list<QtObject> actions: [
            Kirigami.PagePoolAction {
                text: i18n("Calculator")
                icon.name: "accessories-calculator"
                pagePool: mainPagePool
                page: Qt.resolvedUrl("CalculationPage.qml")
            },
            Kirigami.PagePoolAction {
                text: i18n("Converter")
                icon.name: "gtk-convert"
                page: Qt.resolvedUrl("UnitConverter.qml")
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                text: i18n("Programmer")
                icon.name: "format-text-code"
                pagePool: mainPagePool
                page: Qt.resolvedUrl("BinaryCalculator.qml")
            },
            Kirigami.PagePoolAction {
                text: i18n("Settings")
                icon.name: "settings-configure"
                pagePool: mainPagePool
                page: Qt.resolvedUrl("SettingsPage.qml")
            },
            Kirigami.PagePoolAction {
                text: i18n("About")
                icon.name: "help-about"
                pagePool: mainPagePool
                page: Qt.resolvedUrl("AboutPage.qml")
            }
        ]

        // for mobile sidebar
        handleClosedIcon.source: null
        handleOpenIcon.source: null

        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        contentItem: ColumnLayout {
            id: column
            spacing: 0

            // allows for lazy loading of pages compared to using a binding
            property string currentlyChecked: i18n("Calculator")

            Kirigami.Heading {
                text: i18n("Calculator")
                type: Kirigami.Heading.Secondary
                Layout.margins: Kirigami.Units.gridUnit
            }

            SidebarButton {
                text: i18n("Calculator")
                icon.name: "accessories-calculator"
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                checked: column.currentlyChecked === text
                onClicked: {
                    column.currentlyChecked = text;

                    let page = mainPagePool.loadPage(Qt.resolvedUrl("CalculationPage.qml"));
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    drawer.close();
                }
            }

            SidebarButton {
                text: i18n("Converter")
                icon.name: "gtk-convert"
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                checked: column.currentlyChecked === text
                onClicked: {
                    column.currentlyChecked = text;

                    let page = mainPagePool.loadPage(Qt.resolvedUrl("UnitConverter.qml"));
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    drawer.close();
                }
            }

            SidebarButton {
                text: i18n("Binary Calculator")
                icon.name: "format-text-code"
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                checked: column.currentlyChecked === text
                onClicked: {
                    column.currentlyChecked = text;

                    let page = mainPagePool.loadPage(Qt.resolvedUrl("BinaryCalculator.qml"));
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    drawer.close();
                }
            }

            Item { Layout.fillHeight: true }
            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
            }

            SidebarButton {
                text: i18n("Settings")
                icon.name: "settings-configure"
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                checked: column.currentlyChecked === text
                onClicked: {
                    column.currentlyChecked = text;

                    let page = mainPagePool.loadPage(Qt.resolvedUrl("SettingsPage.qml"));
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    drawer.close();
                }
            }

            SidebarButton {
                text: i18n("About")
                icon.name: "help-about"
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                checked: column.currentlyChecked === text
                onClicked: {
                    column.currentlyChecked = text;
                    let page = mainPagePool.loadPage(Qt.resolvedUrl("AboutPage.qml"));
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    drawer.close();
                }
            }
        }
    }

    pageStack.initialPage: mainPagePool.loadPage(Qt.resolvedUrl("CalculationPage.qml"))
}
