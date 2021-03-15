/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
Item {
    id: numberPad
    property bool inPortrait: true
    signal pressed(string text)
    signal clear()
    property bool pureNumber: false

    PortraitPad {
        visible: inPortrait
        anchors.fill: parent
        pureNumber: numberPad.pureNumber
        onPressed: {
            numberPad.pressed(text);
        }
        onClear: {
            numberPad.clear();
        }
    }

    LandScapePad {
        visible: !inPortrait
        anchors.fill: parent
        pureNumber: numberPad.pureNumber
        onPressed: {
            numberPad.pressed(text);
        }
        onClear: {
            numberPad.clear();
        }
    }

}
