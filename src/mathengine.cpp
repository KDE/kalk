/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan
 * <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "mathengine.h"
#include <QDebug>
#include <QRegularExpression>
#include <QStringList>
#include <knumber.h>

void MathEngine::parse(QString expr) {
  m_driver.parse(expr.toStdString());
  m_result = m_driver.result;
  m_error = m_driver.syntaxError;
  if (m_error && (expr == QStringLiteral("-") || expr == QStringLiteral("+"))) {
      m_result = KNumber::Zero;
      m_error = false;
  }
  Q_EMIT resultChanged();
}

QStringList MathEngine::getRegexMatches(const QString &expr,
                                        const QString &regex,
                                        int *counter) const {
    QRegularExpression re(regex);
    QRegularExpressionMatch regexMatch;
    QRegularExpressionMatchIterator it = re.globalMatch(expr);
    QStringList matches;
    while (it.hasNext()) {
        regexMatch = it.next();
        QString match = regexMatch.captured(0);
        matches << match;
        (*counter)++;
    }
    return matches;
}

void MathEngine::parseBinaryExpression(QString expr) {
    m_error = true;
    // qDebug() << "Current Epxression (mathengine.cpp): " << expr;

    int numbersPresent = 0;
    int operatorsPresent = 0;
    // Match for the numbers and binary operators
    QStringList numbers = getRegexMatches(expr, bitRegex, &numbersPresent);
    QStringList operators =
        getRegexMatches(expr, binaryOperatorRegex, &operatorsPresent);

    // Erroraneous Parses return here itself
    if ((operatorsPresent != 0 && numbersPresent == 0) ||
        (operatorsPresent > 1) || (numbersPresent > 2)) {
        return;
    } else {
        m_error = false;
        if (operatorsPresent == 0 && numbersPresent == 1) {
            m_result = KNumber::binaryFromString(numbers[0]);
            Q_EMIT resultChanged();
        }
    }

    // Binary Operator Syntax
    if (expressionSyntaxRegex1.match(expr).hasMatch()) {
        KNumber result(0);
        switch (operatorsList.indexOf(operators[0])) {
            case 0: // +
                result = KNumber::binaryFromString(numbers[0]) +
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 1: // -
                result = KNumber::binaryFromString(numbers[0]) -
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 2: // *
                result = KNumber::binaryFromString(numbers[0]) *
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 3: // /
                result = KNumber::binaryFromString(numbers[0]) /
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 4: // &
                result = KNumber::binaryFromString(numbers[0]) &
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 5: // |
                result = KNumber::binaryFromString(numbers[0]) |
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 6: // ^
                result = KNumber::binaryFromString(numbers[0]) ^
                        KNumber::binaryFromString(numbers[1]);
                break;
            case 7: // <<
                result = KNumber::binaryFromString(numbers[0])
                        << KNumber::binaryFromString(numbers[1]);
                break;
            case 8: // >>
                result = KNumber::binaryFromString(numbers[0]) >>
                        KNumber::binaryFromString(numbers[1]);
                break;
            default: // error
                m_error = true;
        };
        m_result = result;
        Q_EMIT resultChanged();
    }
}
