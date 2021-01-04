/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.13 as Kirigami

Kirigami.ScrollablePage {
    id: root
    title: i18n("Units Converter")

    Kirigami.CardsListView {
        id: typeView
        Loader {
            id: unitConvertorLoader
            source: "qrc:/qml/UnitConversion.qml"
        }
        topMargin: Kirigami.Units.gridUnit
        model: typeModel
        delegate: Kirigami.AbstractCard {
            id: listItem
            contentItem: Text {
                text: name
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    typeModel.currentIndex(index);
                    unitConvertorLoader.item["title"] = name;
                    applicationWindow().pageStack.layers.push(unitConvertorLoader.item);
                }
                onEntered: {
                    listItem.highlighted = true;
                }
                onExited: {
                    listItem.highlighted = false;
                }
            }
        }
    }
}
