/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "inputmanager.h"
#include "mathengine.h"
#include "historymanager.h"
#include <QDebug>


InputManager::InputManager()
{

    KNumber::setDefaultFloatOutput(true);
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

void InputManager::append(const QString &subexpression)
{
    // if expression was from result and input is numeric, clear expression
    if(m_moveFromResult && subexpression.size() == 1)
    {
        if(subexpression.at(0).isDigit() || subexpression.at(0) == QLatin1Char('.'))
        {
            m_expression.clear();
            if (m_stack.size()) {
                m_stack.pop_back();
            }
        }
    }
    m_moveFromResult = false;

    // Call the corresponding parser based on the type of expression.
    MathEngine * engineInstance = MathEngine::inst();
    if (m_isBinaryMode) {
        engineInstance->parseBinaryExpression(m_expression + subexpression);
    } else {
        engineInstance->parse(m_expression + subexpression);
    }

    if(!MathEngine::inst()->error())
    {
        m_stack.push_back(subexpression.size());
        KNumber result = MathEngine::inst()->result();
        m_result = result.toQString();
        m_binaryResult = result.toBinaryString(0);
        m_hexResult = result.toHexString(0);
        m_expression += subexpression;
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
        m_expression.chop(m_stack.back());
        Q_EMIT expressionChanged();

        // Call the corresponding parser based on the type of expression.
        MathEngine * engineInstance = MathEngine::inst();
        if (m_isBinaryMode) {
            engineInstance->parseBinaryExpression(m_expression);
        } else {
            engineInstance->parse(m_expression);
        }
        
        if(!MathEngine::inst()->error())
        {
            KNumber result = MathEngine::inst()->result();
            m_result = result.toQString();
            m_binaryResult = result.toBinaryString(0);
            m_hexResult = result.toHexString(0);
            Q_EMIT resultChanged();
            Q_EMIT binaryResultChanged();
            Q_EMIT hexResultChanged();
        }
    }
}

void InputManager::equal()
{
    HistoryManager::inst()->addHistory(m_expression + QStringLiteral(" = ") + m_result);
    m_expression = m_result;
    m_result.clear();
    m_binaryResult.clear();
    m_hexResult.clear();
    m_stack.clear();
    m_stack.push_back(m_result.size());

    m_moveFromResult = true;
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
    Q_EMIT binaryResultChanged();
    Q_EMIT hexResultChanged();
}

void InputManager::clear()
{
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
    m_expression = result;
    m_result.clear();
    m_binaryResult.clear();
    m_hexResult.clear();
    m_stack.clear();
    m_stack.push_back(result.size());

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
