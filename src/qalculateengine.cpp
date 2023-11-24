/*
 * SPDX-FileCopyrightText: 2023 Michael Lang <criticaltemp@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "qalculateengine.h"

#include <libqalculate/Calculator.h>

#include <QLocale>

#include <KLocalizedString>

QalculateEngine::QalculateEngine()
{
    new Calculator();
    CALCULATOR->terminateThreads();
    CALCULATOR->loadGlobalDefinitions();
    CALCULATOR->loadLocalDefinitions();
    CALCULATOR->loadGlobalCurrencies();
    CALCULATOR->loadExchangeRates();
    CALCULATOR->loadGlobalPrefixes();
    CALCULATOR->loadGlobalUnits();
    CALCULATOR->loadGlobalDataSets();
}

QalculateEngine *QalculateEngine::inst()
{
    static QalculateEngine singleton;
    return &singleton;
}

QString QalculateEngine::evaluate(QString &expression, bool *isApproximate, const int baseEval, const int basePrint, bool exact, const int minExp)
{
    CALCULATOR->abort();

    if (QStringLiteral("+−-×÷/^").contains(expression.right(1))) {
        expression.truncate(expression.size() - 1);
    }

    // do not need to evalulate if the expression is just a number or if expression is incomplete
    if (baseEval == 10 && expression.toDouble() != 0 && !expression.contains(QStringLiteral("E"), Qt::CaseInsensitive)) {
        m_result = QString();
        return m_result;
    } else if (QStringLiteral("(√∛").contains(expression.right(1))) {
        m_result = QString();
        return m_result;
    }

    expression.replace(HAIR_SPACE.toString(), QStringLiteral(" + "));
    expression.replace(QStringLiteral("%%"), QStringLiteral("percentpercent"));

    const bool showAprox = expression.contains(QStringLiteral("∫")) || expression.contains(QStringLiteral("integra"), Qt::CaseInsensitive);

    EvaluationOptions eo;
    eo.auto_post_conversion = POST_CONVERSION_BEST;
    eo.keep_zero_units = false;
    eo.structuring = STRUCTURING_SIMPLIFY;
    eo.mixed_units_conversion = MIXED_UNITS_CONVERSION_NONE;
    eo.approximation = exact ? APPROXIMATION_EXACT : APPROXIMATION_TRY_EXACT;
    eo.parse_options.base = baseEval;
    eo.parse_options.parsing_mode = PARSING_MODE_CONVENTIONAL;
    eo.parse_options.angle_unit = ANGLE_UNIT_NONE;
    eo.parse_options.limit_implicit_multiplication = false;
    eo.parse_options.unknowns_enabled = false;

    PrintOptions po;
    po.base = basePrint;
    po.number_fraction_format = exact ? FRACTION_COMBINED : FRACTION_DECIMAL;
    po.indicate_infinite_series = false;
    po.base_display = BASE_DISPLAY_NORMAL;
    po.interval_display = expression.contains(QStringLiteral("+/-")) ? INTERVAL_DISPLAY_PLUSMINUS : INTERVAL_DISPLAY_SIGNIFICANT_DIGITS;
    po.is_approximate = isApproximate;
    po.use_unicode_signs = true;
    po.binary_bits = baseEval == 2 ? std::max(std::ceil(expression.size() / 4.0) * 4.0, 4.0) : 0;
    po.preserve_precision = false;
    po.min_exp = minExp;
    po.multiplication_sign = MULTIPLICATION_SIGN_X;
    po.division_sign = DIVISION_SIGN_DIVISION_SLASH;
    po.improve_division_multipliers = showAprox;
    po.preserve_format = false;
    po.restrict_to_parent_precision = true;

    CALCULATOR->setPrecision(12);

    std::string input = CALCULATOR->unlocalizeExpression(expression.toStdString(), eo.parse_options);
    std::string parsed;
    std::string result;
    AutomaticFractionFormat fracFormat = exact ? AUTOMATIC_FRACTION_OFF : AUTOMATIC_FRACTION_SINGLE;
    AutomaticApproximation autoAprox = showAprox ? AUTOMATIC_APPROXIMATION_AUTO : AUTOMATIC_APPROXIMATION_SINGLE;
    bool is_comparison = false;
    result = CALCULATOR->calculateAndPrint(input, 2000, eo, po, fracFormat, autoAprox, &parsed, -1, &is_comparison, false);
    m_result = QString::fromStdString(result);
    qDebug() << QString::fromStdString(parsed) << (*isApproximate ? "≈" : "=") << m_result;

    while (CALCULATOR->message()) {
        MessageType mtype = CALCULATOR->message()->type();
        if (mtype != MESSAGE_INFORMATION) {
            QStringView type = mtype == MESSAGE_WARNING ? i18n("warning") : i18n("error");
            qDebug() << type + QStringLiteral(": ") + QString::fromStdString(CALCULATOR->message()->message());
        }
        CALCULATOR->nextMessage();
    }

    if (exact && m_result.contains(QStringLiteral(" ∕ "))) {
        m_result.replace(QStringLiteral(" ∕ "), FRACTION_SLASH.toString());
        m_result.replace(QStringLiteral(" + "), HAIR_SPACE.toString());
    }

    m_result.replace(QLatin1Char('.'), QLocale().decimalPoint(), Qt::CaseInsensitive);

    return m_result;
}