/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@Students.iiit.ac.in>
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
    Q_PROPERTY(QString binaryResult READ binaryResult NOTIFY binaryResultChanged)
    Q_PROPERTY(QString hexResult READ hexResult NOTIFY hexResultChanged)
    Q_PROPERTY(bool binaryMode READ binaryMode WRITE setBinaryMode)

public:
    static InputManager *inst();
    const QString &expression() const;
    void setExpression(const QString &expression);
    const QString &result() const;
    const QString &binaryResult() const;
    const QString &hexResult() const;
    Q_INVOKABLE void append(const QString &subexpression);
    Q_INVOKABLE void backspace();
    Q_INVOKABLE void equal();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void fromHistory(const QString &result);
    void setBinaryMode(bool active);
    bool binaryMode();

Q_SIGNALS:
    void expressionChanged();
    void resultChanged();
    void binaryResultChanged();
    void hexResultChanged();
private:
    InputManager();
    bool m_moveFromResult = false; // clear expression on none operator input
    std::vector<int> m_stack; // track subexpression length for removal later
    QString m_expression;
    QString m_result;
    QString m_binaryResult;
    QString m_hexResult;
    bool m_isBinaryMode = false; // Changes the parser based on this variable
};

