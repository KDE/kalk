/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "inputmanager.h"
#include "historymanager.h"
#include "mathengine.h"
#include <QDebug>
#include <QLocale>

InputManager::InputManager()
{

    KNumber::setDefaultFloatOutput(true);

    QLocale locale;
    m_groupSeparator = locale.groupSeparator();
    m_decimalPoint = locale.decimalPoint();
}

InputManager *InputManager::inst()
{
    static InputManager singleton;
    return &singleton;
}

const QString &InputManager::expression() const
{
    return m_expression;
}
void InputManager::setExpression(const QString &expression)
{
    m_expression = expression;
}

const QString &InputManager::result() const
{
    return m_result;
}

const QString &InputManager::binaryResult() const
{
    return m_binaryResult;
}

const QString &InputManager::hexResult() const
{
    return m_hexResult;
}

bool InputManager::moveFromResult() const
{
    return m_moveFromResult;
}

void InputManager::append(const QString &subexpression)
{
    // if expression was from result and input is numeric, clear expression
    if(m_moveFromResult && subexpression.size() == 1)
    {
        if(subexpression.at(0).isDigit() || subexpression.at(0) == QLatin1Char('.'))
        {
            m_input.clear();
            if (m_stack.size()) {
                m_stack.pop_back();
            }
        }
    }
    m_moveFromResult = false;

    // Call the corresponding parser based on the type of expression.
    MathEngine * engineInstance = MathEngine::inst();
    if (m_isBinaryMode) {
        engineInstance->parseBinaryExpression(m_input + subexpression);
    } else {
        engineInstance->parse(m_input + subexpression);
    }

    if(!MathEngine::inst()->error())
    {
        m_stack.push_back(subexpression.size());
        KNumber result = MathEngine::inst()->result();
        m_output = result.toQString();
        m_binaryResult = result.toBinaryString(0);
        m_hexResult = result.toHexString(0);
        m_input += subexpression;
        m_expression = formatNumbers(m_input);
        m_result = formatNumbers(m_output);
        Q_EMIT resultChanged();
        Q_EMIT binaryResultChanged();
        Q_EMIT hexResultChanged();
        Q_EMIT expressionChanged();
    }
}

void InputManager::backspace()
{
    if(!m_stack.empty())
    {
        m_input.chop(m_stack.back());
        m_stack.pop_back();
        m_expression = formatNumbers(m_input);
        Q_EMIT expressionChanged();

        if (m_input.length() == 0) {
            clear();
            return;
        }

        // Call the corresponding parser based on the type of expression.
        MathEngine * engineInstance = MathEngine::inst();
        if (m_isBinaryMode) {
            engineInstance->parseBinaryExpression(m_input);
        } else {
            engineInstance->parse(m_input);
        }

        if(!MathEngine::inst()->error())
        {
            KNumber result = MathEngine::inst()->result();
            m_output = result.toQString();
            m_binaryResult = result.toBinaryString(0);
            m_hexResult = result.toHexString(0);
            m_result = formatNumbers(m_output);
            Q_EMIT resultChanged();
            Q_EMIT binaryResultChanged();
            Q_EMIT hexResultChanged();
        }
    }
}

void InputManager::equal()
{
    HistoryManager::inst()->addHistory(m_expression + QStringLiteral(" = ") + m_result);

    m_input = m_output;
    m_output.clear();
    m_expression = m_result;
    m_result.clear();
    m_binaryResult.clear();
    m_hexResult.clear();
    m_stack.clear();
    m_stack.push_back(m_input.size());

    m_moveFromResult = true;
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
    Q_EMIT binaryResultChanged();
    Q_EMIT hexResultChanged();
}

void InputManager::clear()
{
    m_input.clear();
    m_output.clear();
    m_expression.clear();
    m_result.clear();
    m_binaryResult.clear();
    m_hexResult.clear();
    m_stack.clear();
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
    Q_EMIT binaryResultChanged();
    Q_EMIT hexResultChanged();
}

void InputManager::fromHistory(const QString &result)
{
    m_input = result;
    m_input.remove(m_groupSeparator);
    m_output.clear();
    m_expression = result;
    m_result.clear();
    m_binaryResult.clear();
    m_hexResult.clear();
    m_stack.clear();
    m_stack.push_back(m_input.size());

    m_moveFromResult = true;
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
    Q_EMIT binaryResultChanged();
    Q_EMIT hexResultChanged();
}

void InputManager::setBinaryMode(bool active) {
    m_isBinaryMode = active;
    clear();
}
bool InputManager::binaryMode()
{
    return m_isBinaryMode;
}

QString InputManager::formatNumbers(const QString &text)
{
    QString formatted;
    QString number;
    for (const auto ch : text) {
        if (ch.isDigit() || ch == m_decimalPoint) {
            number.append(ch);
        } else {
            if (!number.isEmpty()) {
                addNumberSeparators(number);
                formatted.append(number);
                number.clear();
            }
            formatted.append(ch);
        }
    }

    if (!number.isEmpty()) {
        addNumberSeparators(number);
        formatted.append(number);
    }

    return formatted;
}

void InputManager::addNumberSeparators(QString &number)
{
    const int idx = number.indexOf(m_decimalPoint);

    if (idx >= 0 && idx < number.size() - 3) {
        QString left = number.left(idx);
        QString right = number.right(number.size() - idx);
        left.replace(QRegularExpression(QStringLiteral(R"(\B(?=(\d{3})+(?!\d)))")), m_groupSeparator);
        number = left + right;
    } else if (number.size() > 3) {
        number.replace(QRegularExpression(QStringLiteral(R"(\B(?=(\d{3})+(?!\d)))")), m_groupSeparator);
    }
}
