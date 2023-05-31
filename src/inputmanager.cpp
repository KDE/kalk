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

    // change non breaking space into classic space, because UI converts it to classic space
    if (m_groupSeparator == QString(QChar(160))) {
        m_groupSeparator = QLatin1Char(32);
    }
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

int InputManager::getCursorPosition() const
{
    int position = m_inputPosition;

    // account for group separators in expression
    int i = 0;
    while (i < position && i < m_expression.size()) {
        if (m_expression.at(i) == m_groupSeparator) {
            position++;
        }
        i++;
    }
    return position;
}

void InputManager::setCursorPosition(int position)
{
    m_inputPosition = position;

    int i = 0;
    while (i < position && i < m_expression.size()) {
        if (m_expression.at(i) == m_groupSeparator) {
            m_inputPosition--;
        }
        i++;
    }
}

int InputManager::idealCursorPosition(int position) const
{
    // position cursor ahead of group separator
    if (position > 1 && position < m_expression.size()) {
        if (m_expression.at(position - 1) == m_groupSeparator) {
            position++;
            return position;
        }
    }

    // position cursor around functions not between
    QRegularExpression re(QStringLiteral(R"([^\d\+−×÷\!,\^\(\) ]{2,})"));
    QRegularExpressionMatch match = re.match(m_expression.mid(position - 1, 2));
    if (match.hasMatch()) {
        if (position == m_expression.size()) {
            // at end, do nothing
        } else if (m_expression.at(position - 1) == m_expression.at(position)) {
            // same char, do nothing
        } else {
            // check nearest left
            int posLeft = position - 1;
            while (posLeft > 0) {
                if (m_expression.at(posLeft).isDigit()) {
                    break;
                }
                posLeft--;
            }

            // check nearest right
            int posRight = position + 1;
            while (posRight < m_expression.size()) {
                if (m_expression.at(posRight).isDigit()) {
                    break;
                }
                posRight++;
            }

            // prefer the closest side
            if (position - posLeft < posRight - position) {
                position -= position - posLeft - 1;
            } else {
                position += posRight - position;
            }

            return position;
        }
    }

    return position;
}

void InputManager::append(const QString &subexpression)
{
    // if expression was from result and input is numeric, clear expression
    if (m_moveFromResult && subexpression.size() == 1 && m_inputPosition == m_input.size()) {
        if(subexpression.at(0).isDigit() || subexpression.at(0) == QLatin1Char('.'))
        {
            m_input.clear();
        }
    }
    m_moveFromResult = false;

    QString temp = m_input;
    temp.insert(m_inputPosition, subexpression);
    temp.remove(m_groupSeparator);

    // Call the corresponding parser based on the type of expression.
    MathEngine * engineInstance = MathEngine::inst();
    if (m_isBinaryMode) {
        engineInstance->parseBinaryExpression(temp);
    } else {
        engineInstance->parse(temp);
    }

    if (!MathEngine::inst()->error()) {
        KNumber result = MathEngine::inst()->result();
        m_output = result.toQString();
        m_binaryResult = result.toBinaryString(0);
        m_hexResult = result.toHexString(0);
        m_input = temp;
        m_inputPosition += subexpression.size();
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
    if (m_inputPosition > 0) {
        // delete entire function
        QRegularExpression re(QStringLiteral(R"([^\d\+−×÷\!,\^ ]{2,})"));
        QRegularExpressionMatch match = re.match(m_input.mid(m_inputPosition - 2, 2));
        if (match.hasMatch()) {
            // check backwards
            int posBack = m_inputPosition - 2;
            while (posBack >= 0) {
                if (m_input.at(posBack).isDigit() || m_input.at(posBack) == QStringLiteral("(")) {
                    break;
                } else if (posBack > 0 && m_input.at(posBack - 1) == m_input.at(posBack)) {
                    posBack--;
                    break;
                }
                posBack--;
            }

            const int diff = m_inputPosition - posBack;
            m_input.remove(m_inputPosition - diff + 1, diff - 1);
            m_inputPosition = m_inputPosition - diff + 1;
        } else {
            m_input.remove(m_inputPosition - 1, 1);
            m_inputPosition--;
        }

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

    m_moveFromResult = true;
    m_inputPosition = m_input.size();
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

    m_inputPosition = 0;
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

    m_moveFromResult = true;
    m_inputPosition = m_input.size();
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

    formatted.replace(QStringLiteral("log10"), QStringLiteral("log₁₀"));
    formatted.replace(QStringLiteral("log2"), QStringLiteral("log₂"));

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
