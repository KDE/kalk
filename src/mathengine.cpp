/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "mathengine.h"
#include <QDebug>
#include <QRegularExpression>

void MathEngine::parse(QString expr)
{
    qDebug() << "Parse Numbers " << expr;
    m_driver.parse(expr.toStdString());
    m_result = QString::number(m_driver.result);
    emit resultChanged();
}

void MathEngine::parseBinaryExpression(QString expr)
{
    qDebug() << expr;
    bool isNumberPresent = false;

    // Match for the numbers
    regexMatcher.setPattern(bitRegex);
    match = regexMatcher.match(expr);
    isNumberPresent = match.hasMatch();
    qDebug() << (isNumberPresent ? "Bits Matched" : "No Bits");

    // Match for operators
    regexMatcher.setPattern(operatorRegex);
    match = regexMatcher.match(expr);
    qDebug() << (match.hasMatch() ? "Operator Matched" : "No operators");
}
