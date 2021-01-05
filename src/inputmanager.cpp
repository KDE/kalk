/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "inputmanager.h"
#include "mathengine.h"
#include "historymanager.h"
InputManager::InputManager()
{
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

void InputManager::append(const QString &subexpression)
{
    MathEngine::inst()->parse(m_expression + subexpression);
    if(!MathEngine::inst()->error())
    {
        m_stack.push(subexpression.size());
        m_result = MathEngine::inst()->result();
        m_expression += subexpression;
        Q_EMIT resultChanged();
        Q_EMIT expressionChanged();
    }
}

void InputManager::backspace()
{
    if(m_stack.size())
    {
        m_expression.chop(m_stack.top());
        Q_EMIT expressionChanged();
        MathEngine::inst()->parse(m_expression);
        if(!MathEngine::inst()->error())
        {
            m_result = MathEngine::inst()->result();
            Q_EMIT resultChanged();
        }
    }
}

void InputManager::equal()
{
    HistoryManager::inst()->addHistory(m_expression + QStringLiteral(" = ") + m_result);
    m_expression = m_result;
    m_result.clear();
    m_stack = {}; // clear the stack
    m_stack.push(m_result.size());
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
}

void InputManager::clear()
{
    m_expression.clear();
    m_result.clear();
    m_stack = {};
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
}

void InputManager::fromHistory(const QString &result)
{
    m_expression = result;
    m_result.clear();
    m_stack = {};
    m_stack.push(result.size());
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
}
