/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "mathengine.h"

void MathEngine::parse(QString expr)
{
    m_driver.parse(expr.toStdString());
    m_result = QString::number(m_driver.result);
    emit resultChanged();
}
