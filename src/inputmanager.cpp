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
constexpr QStringView LEFT = u"\u200C"; // ZERO WIDTH NON-JOINER
constexpr QStringView RIGHT = u"\u200D"; // ZERO WIDTH JOINER

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
    // position cursor around encoded expressions
    int prevLeft = m_expression.lastIndexOf(LEFT.at(0), position - 1);
    int nextRight = m_expression.indexOf(RIGHT.at(0), position);
    if (position >= 0 && prevLeft >= 0 && nextRight >= 0) {
        const int nextLeft = m_expression.indexOf(LEFT.at(0), position);
        const int prevRight = m_expression.lastIndexOf(RIGHT.at(0), position - 1);

        if (prevLeft > prevRight || (nextRight > nextLeft && nextLeft < position)) {
            nextRight++;
            const int spaces = m_expression.mid(position, nextRight - position).count(ZERO_WIDTH_SPACE.at(0));

            if (arrow == -1 || (position - prevLeft < nextRight - position - spaces && arrow != 1)) {
                position = prevLeft;
            } else {
                position = nextRight;
            }

            return position;
        }
    }

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
                if (m_expression.at(posLeft).isDigit() || m_expression.at(posLeft).isSymbol() || m_expression.at(posLeft) == QLatin1Char('(')
                    || m_expression.at(posLeft) == RIGHT.at(0)) {
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
                if (m_expression.at(posRight).isDigit() || m_expression.at(posRight).isSymbol() || m_expression.at(posRight) == QLatin1Char('(')
                    || m_expression.at(posRight) == LEFT.at(0)) {
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

int InputManager::addAdjacentParentheses(const int &side, QString &temp)
{
    bool add = false;
    bool left = side == -1;
    const QChar part = left ? temp.at(0) : temp.at(temp.size() - 1);
    const QChar end = left ? m_input.at(m_inputPosition - 1) : m_input.at(m_inputPosition);
    if (left) {
        add = (m_input.size() > 0 && ((end == RIGHT.at(0) && (part.isDigit() || part == LEFT.at(0))) || (end.isDigit() && part == LEFT.at(0))));

    } else {
        add = (m_inputPosition < m_input.size() && ((end == LEFT.at(0) && (part.isDigit() || part == RIGHT.at(0))) || (end.isDigit() && part == RIGHT.at(0))));
    }

    if (!add) {
        return 0;
    }

    temp = left ? QStringLiteral(")") + temp : temp + QStringLiteral("(");
    int pos = left ? m_inputPosition - 1 : m_inputPosition;
    const int adj = left ? 1 : 0;

    if (m_input.at(pos).isDigit()) {
        while ((pos >= 0 && pos < m_input.size()) && m_input.at(pos).isDigit()) {
            pos = left ? pos - 1 : pos + 1;
        }

        m_input.insert(pos + adj, left ? QLatin1Char('(') : QLatin1Char(')'));
    } else {
        int countLeft = left ? 0 : 1;
        int countRight = left ? 1 : 0;

        while ((pos >= 0 && pos < m_input.size()) && countLeft != countRight) {
            if (m_input.at(pos) == LEFT.at(0)) {
                countLeft++;
            } else if (m_input.at(pos) == RIGHT.at(0)) {
                countRight++;
            }
            pos = left ? pos - 1 : pos + 1;
        }

        m_input.insert(pos + adj, left ? QLatin1Char('(') : QLatin1Char(')'));
    }

    if (left) {
        m_inputPosition++;
        return 0;
    } else {
        return 1;
    }
}

void InputManager::append(const QString &subexpression)
{
    if (m_inputPosition >= m_input.size()) {
        m_inputPosition = m_input.size();
    }

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
    } else if (temp == QStringLiteral("rand()")) {
        bool isAprox = false;
        temp = m_engine->evaluate(temp, &isAprox);
    }

    // prevent invalid duplicate operators
    if (QStringLiteral("+×*÷/").contains(temp) && m_inputPosition > 0 && m_input.size() > 0 && m_input.at(m_inputPosition - 1) == temp) {
        return;
    }

    // detect if aproximate value was pasted
    if (temp.contains(QStringLiteral("…"))) {
        // add leading/ending component parts if missing
        if (temp.at(temp.size() - 1) == QStringLiteral("…")) {
            temp = temp + RIGHT.toString();
        }
        if (temp.count(LEFT.at(0)) < temp.count(RIGHT.at(0))) {
            temp = LEFT.toString() + temp;
        }

        // attempt to lookup original input from encode stack
        for (const auto &item : m_encodeStack) {
            if (temp.contains(item.second)) {
                temp.replace(item.second, item.first);
            }
        }

        // lookup original input from history if not found in encode stack
        if (temp.contains(QStringLiteral("…"))) {
            QList<QString> history = HistoryManager::inst()->getHistory();
            for (const auto &item : history) {
                QStringList parts = item.split(QLatin1Char('='));
                if (parts.size() > 3 && temp.contains(parts.at(3))) {
                    addComponents(parts.at(2), parts.at(3));
                    temp.replace(parts.at(3), parts.at(2));
                }
            }
        }
    }

    // add parentheses around left/right sides of component if appending a digit or another component adjacent to it
    addAdjacentParentheses(-1, temp);
    int posAdjust = addAdjacentParentheses(1, temp);

    m_input.insert(m_inputPosition, temp);
    m_inputPosition += temp.size() - posAdjust;

    calculate();

    store();
}

void InputManager::backspace()
{
    if (m_inputPosition < 1) {
        return;
    }

    if (m_input.size() > 2) {
        int posBack = m_inputPosition - 2;

        // delete entire component
        if (m_input.at(posBack + 1) == RIGHT.at(0)) {
            int countRight = 1;
            int countLeft = 0;
            while (posBack >= 0 && countRight != countLeft) {
                if (m_input.at(posBack) == RIGHT.at(0)) {
                    countRight++;
                } else if (m_input.at(posBack) == LEFT.at(0)) {
                    countLeft++;
                }
                posBack--;
            }
        } else {
            // delete entire function
            while (posBack >= 0) {
                if (m_input.at(posBack).isDigit() || m_input.at(posBack).isSymbol() || m_input.at(posBack).isPunct() || m_input.at(posBack).isSpace()
                    || m_input.at(posBack + 1) == m_input.at(posBack) || m_input.at(posBack) == RIGHT.at(0)) {
                    break;
                }
                posBack--;
            }
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

    const QString savedResult = m_isBinaryMode ? m_binaryResult : m_result;
    const QString equals = QStringLiteral("=");

    if (m_isApproximate) {
        const QString aprox = QStringLiteral("…");
        QString expression = m_output.left(9) + aprox;

        double outputNumeric = m_output.toDouble();
        if (outputNumeric == 0.0) {
            expression = m_output.left(6) + aprox + m_output.right(3);
        } else if (outputNumeric >= 10000000 || outputNumeric < 0.0001) {
            // get pure Exponential Notation for very large and very small numbers
            calculate(false, 1);
            expression = m_output;
            expression.replace(6, m_output.indexOf(QStringLiteral("E")) - 6, aprox);
        }

        const QString spacer = ZERO_WIDTH_SPACE.toString();
        const size_t maxSize = std::max(m_input.size(), expression.size());
        const QString input = LEFT.toString() + m_input + spacer.repeated(maxSize - m_input.size()) + RIGHT.toString();
        expression = LEFT.toString() + expression.insert(expression.indexOf(aprox), spacer.repeated(maxSize - expression.size())) + RIGHT.toString();
        addComponents(input, expression);

        // save the display values along with the original input
        HistoryManager::inst()->addHistory(m_expression + equals + m_result + equals + input + equals + expression);
        m_input = input;

        // show fraction representation of result
        calculate(true);
    } else {
        double outputNumeric = m_output.toDouble();
        if (outputNumeric != 0.0 && (outputNumeric >= 10000000 || outputNumeric < 0.0001)) {
            // get pure Exponential Notation for very large and very small numbers
            calculate(false, 1);
            HistoryManager::inst()->addHistory(m_expression + equals + m_result + equals + m_input + equals + m_output);
        } else {
            HistoryManager::inst()->addHistory(m_expression + equals + m_result + equals + m_input);
        }

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

void InputManager::setHistoryIndex(const int &index)
{
    m_historyIndex = index;
}

int InputManager::historyIndex() const
{
    return m_historyIndex;
}

void InputManager::fromHistory(bool isResult, const QString &input, const QString &expression)
{
    if (input.isEmpty() || input.indexOf(LEFT.at(0)) < 0) {
        append(expression);
        return;
    }

    if (isResult) {
        addComponents(input, expression);
        append(input);
        return;
    }

    QString value = input;

    // remove outer left/right ends if input is composed of multiple components
    if (value.count(LEFT.at(0)) > 1 && value.at(0) == LEFT.at(0) && value.at(value.size() - 1) == RIGHT.at(0)) {
        value = value.mid(1, value.size() - 2);
    }

    // parse and add individual components
    const std::vector<QString> inputs = parseComponents(value);
    const std::vector<QString> expressions = parseComponents(expression);
    if (expressions.size() > 0 && inputs.size() > 0) {
        for (size_t n = 0; n < std::min(inputs.size(), expressions.size()); n++) {
            addComponents(inputs.at(n), expressions.at(n));
        }
        append(value);
    } else {
        append(expression);
    }
}

std::vector<QString> InputManager::parseComponents(const QString &text) const
{
    int countLeft = 0;
    int countRight = 0;
    QString item;
    std::vector<QString> components;

    for (const auto ch : text) {
        if (ch == LEFT.at(0)) {
            countLeft++;
        } else if (ch == RIGHT.at(0)) {
            countRight++;
        }

        if (countLeft > 0) {
            item.append(ch);

            if (countLeft == countRight) {
                components.push_back(item);
                item.clear();
                countLeft = 0;
                countRight = 0;
            }
        }
    }

    return components;
}

void InputManager::addComponents(const QString &input, const QString &expression)
{
    if (std::find_if(m_encodeStack.begin(),
                     m_encodeStack.end(),
                     [&](const auto &item) {
                         return item.first == input;
                     })
        == m_encodeStack.cend()) {
        m_encodeStack.push_back(std::make_pair(input, expression));
    }
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

QString InputManager::encodeExpression(const QString &input) const
{
    QString expression = input;
    const std::vector<QString> inputs = parseComponents(input);

    // replace only first occurence of each component in expression
    for (auto component : inputs) {
        for (auto item : m_encodeStack) {
            if (component == item.first) {
                expression.replace(expression.indexOf(component), item.first.size(), item.second);
                break;
            }
        }
    }

    return expression;
}

QString InputManager::formatNumbers(const QString &text)
{
    QString temp = text;

    // show exponents as superscripts
    if (temp.contains(QStringLiteral("^"))) {
        QRegularExpression re(QStringLiteral(R"((?<base>\w+|\)|!|π|%)?(?<exponent>\^-?[\d.]+(?!\!)))"));
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

    m_expression = m_isBinaryMode ? m_input : formatNumbers(encodeExpression(m_input));
    Q_EMIT expressionChanged();

    QString input = m_input.trimmed();
    input.replace(ZERO_WIDTH_SPACE.toString(), QString());
    input.replace(LEFT.at(0), QLatin1Char('('));
    input.replace(RIGHT.at(0), QLatin1Char(')'));

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
