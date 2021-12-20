/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan
 * <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include "mathengine/driver.hh"
#include <QObject>
#include <QRegularExpression>
#include <QStringList>
#include <knumber.h>

class MathEngine : public QObject {
  Q_OBJECT
  Q_PROPERTY(KNumber result READ result NOTIFY resultChanged)
  Q_PROPERTY(bool error READ error NOTIFY resultChanged)

public:
    static MathEngine *inst() {
        static MathEngine singleton;
        return &singleton;
    }
    Q_INVOKABLE void parse(QString expr);
    Q_INVOKABLE void parseBinaryExpression(QString expr);
    KNumber result() { return m_result; };
    bool error() { return m_error; };

Q_SIGNALS:
    void resultChanged();

private:
    MathEngine(){};
    driver m_driver;
    KNumber m_result;
    bool m_error;

    const QString bitRegex = QStringLiteral("[01]+");
    const QString binaryOperatorRegex = QStringLiteral("[\\+\\-\\*\\/&\\|\\^]|<{2}|>{2}");
        
    QRegularExpression expressionSyntaxRegex1 = QRegularExpression(QStringLiteral("([01]+)([\\+\\-\\*\\/&\\|~\\^]|<{2}|>{2})([01]+)"));
    QStringList operatorsList = {
        QStringLiteral("+"), 
        QStringLiteral("-"), 
        QStringLiteral("*"), 
        QStringLiteral("/"), 
        QStringLiteral("&"), 
        QStringLiteral("|"), 
        QStringLiteral("^"), 
        QStringLiteral("<<"), 
        QStringLiteral(">>")
    };
    
    QStringList getRegexMatches(const QString &expr, const QString &regex, int *counter) const;
};
