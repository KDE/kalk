/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#pragma once
#include <stack>
#include <QObject>

class InputManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString expression READ expression WRITE setExpression NOTIFY expressionChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
public:
    static InputManager *inst();
    const QString &expression() const;
    void setExpression(const QString &expression);
    const QString &result() const;
    Q_INVOKABLE void append(const QString &subexpression);
    Q_INVOKABLE void backspace();
    Q_INVOKABLE void equal();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void fromHistory(const QString &result);
Q_SIGNALS:
    void expressionChanged();
    void resultChanged();
private:
    InputManager();
    bool m_moveFromResult = false; // clear expression on none operator input
    std::stack<int, std::vector<int>> m_stack; // track subexpression length for removal later
    QString m_expression;
    QString m_result;
};

