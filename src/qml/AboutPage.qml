/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
Kirigami.AboutPage {
    id: aboutPage
    
    property real mainOpacity: 1
    property int yTranslate: 0
    opacity: mainOpacity
    
    visible: false
    title: i18n("About")
    aboutData: kalkAboutData
}
