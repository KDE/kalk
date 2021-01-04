/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "mathengine.h"

void MathEngine::parse(QString expr)
{
    mDriver.parse(expr.toStdString());
    result_ = QString::number(mDriver.result);
    emit resultChanged();
}
