/*
 * SPDX-FileCopyrightText: 2023 Michael Lang <criticaltemp@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>

constexpr QStringView FRACTION_SLASH = u"\u2044";
constexpr QStringView HAIR_SPACE = u"\u200A";
constexpr QStringView ZERO_WIDTH_SPACE = u"\u200B";
constexpr QStringView LEFT = u"\u200C"; // ZERO WIDTH NON-JOINER
constexpr QStringView RIGHT = u"\u200D"; // ZERO WIDTH JOINER

class QalculateEngine : public QObject
{
    Q_OBJECT
public:
    static QalculateEngine *inst();

    QString lastResult() const
    {
        return m_result;
    }

    QString
    evaluate(QString expression, bool *isApproximate = nullptr, const int baseEval = 10, const int basePrint = 10, bool exact = false, const int minExp = -1);

private:
    QalculateEngine();
    QString m_result;
};
