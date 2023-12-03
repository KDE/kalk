/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2020 cahfofpai
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0
import org.kde.kirigami 2.13 as Kirigami

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
                page: "qrc:/qml/CalculationPage.qml"
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("Converter")
                icon.name: "gtk-convert"
                page: "qrc:/qml/UnitConverter.qml"
                pagePool: mainPagePool
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("Programmer")
                icon.name: "format-text-code"
                pagePool: mainPagePool
                page: "qrc:/qml/BinaryCalculator.qml"
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("Settings")
                icon.name: "settings-configure"
                pagePool: mainPagePool
                page: "qrc:/qml/SettingsPage.qml"
                onTriggered: pageAnimation(pageItem())
            },
            Kirigami.PagePoolAction {
                text: i18n("About")
                icon.name: "help-about"
                page: "qrc:/qml/AboutPage.qml"
                pagePool: mainPagePool
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
                    
                    let page = mainPagePool.loadPage("qrc:/qml/CalculationPage.qml");
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    pageAnimation(page);
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
                    
                    let page = mainPagePool.loadPage("qrc:/qml/UnitConverter.qml");
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    pageAnimation(page);
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
                    
                    let page = mainPagePool.loadPage("qrc:/qml/BinaryCalculator.qml");
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    pageAnimation(page);
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

                    let page = mainPagePool.loadPage("qrc:/qml/SettingsPage.qml");
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    pageAnimation(page);
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
                    
                    let page = mainPagePool.loadPage("qrc:/qml/AboutPage.qml")
                    while (pageStack.depth > 0) pageStack.pop();
                    pageStack.push(page);
                    pageAnimation(page);
                    drawer.close();
                }
            }
        }
    }

    pageStack.initialPage: mainPagePool.loadPage("qrc:/qml/CalculationPage.qml")
}
