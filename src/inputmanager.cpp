/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "inputmanager.h"
#include "historymanager.h"
#include "qalculateengine.h"

#include <QLocale>
#include <QRegularExpression>

constexpr QStringView ZERO_WIDTH_SPACE = u"\u200B";

InputManager::InputManager()
    : m_engine(QalculateEngine::inst())
{
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

int InputManager::idealCursorPosition(int position, int arrow) const
{
    // position cursor ahead of group separator
    if (position > 1 && position < m_expression.size()) {
        if (m_expression.at(position - 1) == m_groupSeparator) {
            arrow == -1 ? position-- : position++;
            return position;
        }
    }

    // position cursor ahead of zero width space
    if (position > 1 && position < m_expression.size()) {
        if (m_expression.at(position - 1) == ZERO_WIDTH_SPACE.toString()) {
            arrow == -1 ? position-- : position++;
            return position;
        }
    }

    // position cursor around functions not between
    QRegularExpression re(QStringLiteral(R"([^\d+−\-×÷!%π∫√∛ˆ,\^()ˆ⁰¹²³⁴⁵⁶⁷⁸⁹ ]{2,})"));
    QRegularExpressionMatch match = re.match(m_expression.mid(position - 1, 2));
    if (match.hasMatch()) {
        if (position == m_expression.size()) {
            // at end, do nothing
        } else if (m_expression.at(position - 1) == m_expression.at(position)) {
            // same char, do nothing
        } else {
            // check nearest left
            int posLeft = position - 1;
            while (posLeft >= 0) {
                if (m_expression.at(posLeft).isDigit() || m_expression.at(posLeft).isSymbol() || m_expression.at(posLeft) == QLatin1Char('(')) {
                    posLeft++;
                    break;
                } else if (posLeft == 0) {
                    break;
                } else {
                    posLeft--;
                }
            }

            // check nearest right
            int posRight = position + 1;
            while (posRight < m_expression.size()) {
                if (m_expression.at(posRight).isDigit() || m_expression.at(posRight).isSymbol() || m_expression.at(posRight) == QLatin1Char('(')) {
                    break;
                }
                posRight++;
            }

            // prefer the closest side
            if (arrow != 1 && (position - posLeft < posRight - position || arrow == -1)) {
                position -= position - posLeft;
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

    QString temp = subexpression;
    temp.remove(m_groupSeparator);

    // auto parentheses
    if (temp == QStringLiteral("(  )")) {
        temp = QStringLiteral("(");

        if (m_input.size() > 0 && m_input.at(m_inputPosition - 1) != QLatin1Char('(')) {
            QStringView left = m_input.left(m_inputPosition);
            if (left.count(QStringLiteral("(")) > left.count(QStringLiteral(")"))) {
                temp = QStringLiteral(")");
            }
        }
    }

    // prevent invalid duplicate operators
    if (QStringLiteral("+×*÷/").contains(temp) && m_inputPosition > 0 && m_input.size() > 0 && m_input.at(m_inputPosition - 1) == temp) {
        return;
    }

    m_input.insert(m_inputPosition, temp);
    m_inputPosition += temp.size();

    calculate();

    store();
}

void InputManager::backspace()
{
    if (m_inputPosition < 1) {
        return;
    }

    // delete entire function
    if (m_input.size() > 2) {
        int posBack = m_inputPosition - 2;
        while (posBack >= 0) {
            if (m_input.at(posBack).isDigit() || m_input.at(posBack).isSymbol() || m_input.at(posBack).isPunct() || m_input.at(posBack).isSpace()
                || m_input.at(posBack + 1) == m_input.at(posBack)) {
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

    calculate();

    store();
}

void InputManager::equal()
{
    if (m_output.isEmpty()) {
        // if the output is empty, either the input is empty or user has pressed equal twice
        return;
    }
    HistoryManager::inst()->addHistory(m_expression + QStringLiteral(" = ") + m_result);

    QString savedResult = m_isBinaryMode ? m_binaryResult : m_result;

    if (m_isApproximate) {
        // Show fraction representation of result
        calculate(true);
        m_input = QStringLiteral("(") + m_output + QStringLiteral(")");
    } else {
        m_input = m_output;
        m_result.clear();
        Q_EMIT resultChanged();
    }

    m_output.clear();
    m_expression = savedResult;
    m_binaryResult.clear();
    m_hexResult.clear();

    m_moveFromResult = true;
    m_inputPosition = m_input.size();
    Q_EMIT expressionChanged();
    Q_EMIT binaryResultChanged();
    Q_EMIT hexResultChanged();

    store();
}

void InputManager::clear(bool save)
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

    if (save) {
        store();
    }
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

void InputManager::store()
{
    if (m_undoStack.size() > m_undoPos) {
        m_undoStack.resize(m_undoPos);
        m_undoStack.shrink_to_fit();
    }

    m_undoStack.push_back(m_input);
    m_undoPos++;

    Q_EMIT canUndoChanged();
    Q_EMIT canRedoChanged();
}

void InputManager::undo()
{
    if (m_undoPos <= 0) {
        return;
    }

    m_undoPos--;
    if (m_undoPos >= 1) {
        m_input = m_undoStack.at(m_undoPos - 1);
        m_inputPosition += m_input.size() - m_undoStack.at(m_undoPos).size();
    } else {
        m_input = QString();
    }

    if (m_inputPosition > m_input.size()) {
        m_inputPosition = m_input.size();
    }

    calculate();

    Q_EMIT canUndoChanged();
    Q_EMIT canRedoChanged();
}

void InputManager::redo()
{
    if (m_undoPos >= m_undoStack.size()) {
        return;
    }

    m_inputPosition += m_undoStack.at(m_undoPos).size() - m_input.size();
    m_input = m_undoStack.at(m_undoPos);
    m_undoPos++;

    if (m_inputPosition > m_input.size()) {
        m_inputPosition = m_input.size();
    }

    calculate();

    Q_EMIT canUndoChanged();
    Q_EMIT canRedoChanged();
}

bool InputManager::canUndo()
{
    return m_undoPos > 0;
}

bool InputManager::canRedo()
{
    return m_undoPos < m_undoStack.size();
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
    QString temp = text;

    // show exponents as superscripts
    if (temp.contains(QStringLiteral("^"))) {
        QRegularExpression re(QStringLiteral(R"((?<base>\d*\.?\d+\!?|\))?(?<exponent>\^-?[\d.]+(?!\!)))"));
        QRegularExpressionMatchIterator i = re.globalMatch(temp);
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            QString base = match.captured(QStringLiteral("base"));
            QString exponent = match.captured(QStringLiteral("exponent"));
            if (!base.isEmpty()) {
                exponent.replace(QStringLiteral("^"), ZERO_WIDTH_SPACE.toString());
            }
            replaceWithSuperscript(exponent);

            // replace only the first occurence
            size_t index = temp.indexOf(match.captured(0));
            temp.replace(index, match.captured(0).size(), base + exponent);
        }
    }

    QString formatted;
    QString number;
    for (const auto ch : temp) {
        if (ch.isDigit() || ch == m_decimalPoint || ch == FRACTION_SLASH.toString()) {
            number.append(ch);
        } else {
            // do not add number separators if contains fraction
            if (!number.isEmpty()) {
                if (!number.contains(FRACTION_SLASH.toString())) {
                    addNumberSeparators(number);
                }
                formatted.append(number);
                number.clear();
            }
            formatted.append(ch);
        }
    }

    // do not add number separators if contains fraction
    if (!number.isEmpty()) {
        if (!number.contains(FRACTION_SLASH.toString())) {
            addNumberSeparators(number);
        }
        formatted.append(number);
    }

    formatted.replace(QStringLiteral("log10"), QStringLiteral("log₁₀"));
    formatted.replace(QStringLiteral("log2"), QStringLiteral("log₂"));

    return formatted;
}

void InputManager::replaceWithSuperscript(QString &text)
{
    text.replace(QStringLiteral("^"), QStringLiteral("ˆ"));
    text.replace(QStringLiteral("0"), QStringLiteral("⁰"));
    text.replace(QStringLiteral("1"), QStringLiteral("¹"));
    text.replace(QStringLiteral("2"), QStringLiteral("²"));
    text.replace(QStringLiteral("3"), QStringLiteral("³"));
    text.replace(QStringLiteral("4"), QStringLiteral("⁴"));
    text.replace(QStringLiteral("5"), QStringLiteral("⁵"));
    text.replace(QStringLiteral("6"), QStringLiteral("⁶"));
    text.replace(QStringLiteral("7"), QStringLiteral("⁷"));
    text.replace(QStringLiteral("8"), QStringLiteral("⁸"));
    text.replace(QStringLiteral("9"), QStringLiteral("⁹"));
    text.replace(QStringLiteral("−"), QStringLiteral("⁻"));
    text.replace(QStringLiteral("-"), QStringLiteral("⁻"));
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

void InputManager::calculate(bool exact, const int minExp)
{
    if (m_input.length() == 0) {
        clear(false);
        return;
    }

    m_expression = m_isBinaryMode ? m_input : formatNumbers(m_input);
    Q_EMIT expressionChanged();

    QString input = m_input.trimmed();
    m_isApproximate = false;
    if (m_isBinaryMode) {
        m_output = m_engine->evaluate(input, &m_isApproximate, 2, 10, exact, minExp);
        m_binaryResult = m_engine->evaluate(input, &m_isApproximate, 2, 2, exact, minExp);
        m_hexResult = m_engine->evaluate(input, &m_isApproximate, 2, 16, exact, minExp);
        Q_EMIT binaryResultChanged();
        Q_EMIT hexResultChanged();
    } else {
        m_output = m_engine->evaluate(input, &m_isApproximate, 10, 10, exact, minExp);
    }

    m_result = formatNumbers(m_output);
    Q_EMIT resultChanged();
}

#include "moc_inputmanager.cpp"
