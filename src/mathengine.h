/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#ifndef MATHENGINE_H
#define MATHENGINE_H
#include "mathengine/driver.hh"
#include <QObject>
class MathEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(bool error READ error NOTIFY resultChanged)
public:
    static MathEngine *inst()
    {
        static MathEngine singleton;
        return &singleton;
    }
    Q_INVOKABLE void parse(QString expr);
    QString result()
    {
        return m_result;
    };
    bool error()
    {
        return m_Driver.syntaxError;
    };
signals:
    void resultChanged();

private:
    MathEngine(){};
    driver m_driver;
    QString m_result;
};

#endif
