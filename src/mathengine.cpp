/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "mathengine.h"
#include <QDebug>
#include <QRegularExpression>
#include <QStringList>

void MathEngine::parse(QString expr)
{
    m_driver.parse(expr.toStdString());
    m_result = QString::number(m_driver.result);
    emit resultChanged();
}

QStringList getRegexMatches(QString expr, QString regex, int *counter) {
    QRegularExpression re(regex);
    QRegularExpressionMatch regexMatch;
    QRegularExpressionMatchIterator it = re.globalMatch(expr);
    QStringList matches;
    while (it.hasNext()) {
        regexMatch = it.next();
        QString match = regexMatch.captured(1);
        matches << match;
        (*counter)++;
    }
    return matches;
}

void MathEngine::parseBinaryExpression(QString expr)
{
    m_error = true;
    qDebug() << expr;

    int numbersPresent = 0;
    int operatorsPresent = 0;
    // Match for the numbers and binary operators
    QStringList numbers = getRegexMatches(expr, bitRegex, &numbersPresent);
    QStringList operators = getRegexMatches(expr, binaryOperatorRegex, &operatorsPresent);

    // Erroraneous Parses return here itself
    if (
        (operatorsPresent != 0 && numbersPresent == 0) ||
        (operatorsPresent > 1) ||
        (numbersPresent > 2)
    ) {
        return;
    } else {
        m_error = false;
    }

    if (expressionSyntaxRegex1.match(expr).hasMatch()) {
        qDebug() << "Expression valid to calculate";
    }
}
