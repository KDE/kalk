#! /bin/sh
# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
$XGETTEXT `find . -name \*.qml -o -name \*.cpp` -o $podir/kalk.pot
