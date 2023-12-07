/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "inputmanager.h"
#include "historymanager.h"
#include "kalkconfig.h"
#include "qalculateengine.h"

#include <QRegularExpression>

InputManager::InputManager()
    : m_engine(QalculateEngine::inst())
{
    m_groupSeparator = m_locale.groupSeparator();

    // change non breaking space into classic space, because UI converts it to classic space
    if (m_groupSeparator == QString(QChar(160))) {
        m_groupSeparator = QLatin1Char(32);
    }
    m_groupSeparator.prepend(ZERO_WIDTH_SPACE.at(0));
    m_decimalPoint = m_locale.decimalPoint();
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
    if (m_moveFromResult) {
        return m_expression.size();
    }

    int position = 0;

    for (size_t index = 0; index < m_inputPosition; ++index) {
        position += m_input.at(index).second.isEmpty() ? m_input.at(index).first.size() : m_input.at(index).second.size();
    }

    int i = 0;
    while (i < position && i < m_expression.size() - 1) {
        if (m_expression.at(i) == m_groupSeparator.at(0) && m_expression.at(i + 1) == m_groupSeparator.at(1)) {
            position += 2;
        }
        i++;
    }

    return position;
}

void InputManager::setCursorPosition(int position)
{
    if (m_moveFromResult) {
        return;
    }

    m_inputPosition = m_input.size();
    position -= m_expression.left(position).count(m_groupSeparator) * 2;

    for (size_t index = 0; index < m_input.size(); ++index) {
        if (position == 0) {
            m_inputPosition = index;
            break;
        }

        position -= m_input.at(index).second.isEmpty() ? m_input.at(index).first.size() : m_input.at(index).second.size();
    }
}

int InputManager::idealCursorPosition(int position, int arrow) const
{
    if (m_moveFromResult) {
        return m_expression.size();
    }

    if (position < 0) {
        position = 0;
    } else if (position > m_expression.size()) {
        position = m_expression.size();
    }

    int posPrev = 0;
    int posNext = 0;
    posNext += m_expression.left(position).count(m_groupSeparator) * 2;
    for (auto text : m_input) {
        posNext += (text.second.isEmpty() ? text.first.size() : text.second.size());

        if (posNext <= position) {
            posPrev = posNext;
        }

        if (posNext >= position) {
            // prefer the closest prev/next position
            if (arrow != 1 && (position - posPrev < posNext - position || arrow == -1)) {
                position = posPrev;
            } else {
                position = posNext;
            }

            break;
        }
    }

    // position cursor ahead of group separator parts
    if (position > 1 && position < m_expression.size() - 1) {
        if (m_expression.at(position - 1) == m_groupSeparator.at(0) && m_expression.at(position) == m_groupSeparator.at(1)) {
            return arrow == -1 ? position - 1 : position + 2;
        }
        if (m_expression.at(position - 2) == m_groupSeparator.at(0) && m_expression.at(position - 1) == m_groupSeparator.at(1)) {
            return arrow == -1 ? position - 2 : position + 1;
        }
    }

    // // position cursor ahead of zero width space
    if (position > 1 && position < m_expression.size()) {
        if (m_expression.at(position - 1) == ZERO_WIDTH_SPACE.toString()) {
            return arrow == -1 ? position - 1 : position + 1;
        }
    }

    return position;
}

void InputManager::append(QString subexpression, const QString &component, bool update)
{
    // if expression was from result and input is numeric, clear expression
    if (m_moveFromResult && subexpression.size() == 1 && m_inputPosition == m_input.size()) {
        if (subexpression.at(0).isDigit() || subexpression.at(0) == m_decimalPoint) {
            m_input.clear();
            m_inputPosition = 0;
        }
    }
    m_moveFromResult = false;

    // auto parentheses
    if (subexpression == QStringLiteral("(  )")) {
        subexpression = QStringLiteral("(");

        if (m_input.size() > 0 && m_input.at(m_inputPosition - 1).first.at(m_input.at(m_inputPosition - 1).first.size() - 1) != QLatin1Char('(')) {
            int countLeft = 0;
            int countRight = 0;
            for (size_t index = 0; index < m_inputPosition; ++index) {
                countLeft += m_input.at(index).first.count(QLatin1Char('('));
                countRight += m_input.at(index).first.count(QLatin1Char(')'));
            }

            if (countLeft > countRight) {
                subexpression = QStringLiteral(")");
            }
        }
    } else if (subexpression == QStringLiteral("rand()")) {
        bool isAprox = false;
        subexpression = m_engine->evaluate(subexpression, &isAprox);
    }

    // prevent invalid duplicate operators
    if (QStringLiteral("+×*÷/^").contains(subexpression.at(0)) && m_inputPosition > 0 && m_input.size() > 0) {
        if (m_input.at(m_inputPosition - 1).first.at(m_input.at(m_inputPosition - 1).first.size() - 1) == subexpression.at(0)) {
            return;
        }
    }

    // add parentheses around left/right sides of component if appending a digit or another component adjacent to it
    if (m_input.size() > 0 && m_inputPosition > 0) {
        const QChar part = subexpression.at(0);
        const QChar end = m_input.at(m_inputPosition - 1).first.at(m_input.at(m_inputPosition - 1).first.size() - 1);
        if ((end == RIGHT.at(0) && (part.isDigit() || part == LEFT.at(0))) || (end.isDigit() && part == LEFT.at(0))) {
            m_input.insert(std::next(m_input.cbegin(), m_inputPosition - 1), std::make_pair(QStringLiteral("("), QString()));
            m_inputPosition++;
            m_input.insert(std::next(m_input.cbegin(), m_inputPosition), std::make_pair(QStringLiteral(")"), QString()));
            m_inputPosition++;
        }
    }
    if (m_inputPosition < m_input.size()) {
        const QChar part = subexpression.at(subexpression.size() - 1);
        const QChar end = m_input.at(m_inputPosition).first.at(0);
        if ((end == LEFT.at(0) && (part.isDigit() || part == RIGHT.at(0))) || (end.isDigit() && part == RIGHT.at(0))) {
            m_input.insert(std::next(m_input.cbegin(), m_inputPosition + 1), std::make_pair(QStringLiteral(")"), QString()));
            m_input.insert(std::next(m_input.cbegin(), m_inputPosition), std::make_pair(QStringLiteral("("), QString()));
        }
    }

    auto it = std::next(m_input.cbegin(), m_inputPosition);
    if (it > m_input.cend()) {
        return;
    }
    m_input.insert(it, std::make_pair(subexpression, component));
    m_inputPosition++;

    if (update) {
        store();
        calculateAndUpdate();
    }
}

void InputManager::backspace()
{
    auto it = std::next(m_input.cbegin(), m_inputPosition - 1);
    if (it < m_input.cbegin()) {
        return;
    }
    m_input.erase(it);
    m_inputPosition--;
    store();
    calculateAndUpdate();
}

void InputManager::equal()
{
    if (m_output.isEmpty()) {
        // if the output is empty, either the input is empty or user has pressed equal twice
        return;
    }

    QString output = m_output;
    const QString result = m_isBinaryMode ? m_binaryResult : m_result;
    const bool isApproximate = m_isApproximate;
    const double value = m_locale.toDouble(m_output.at(0) == QStringLiteral("−") ? QStringView(m_output).sliced(1, m_output.size() - 2) : m_output);

    // get exact representation
    QString exactResult;
    if (isApproximate || (value != 0.0 && value < 1.0)) {
        calculate(true);
        exactResult = formatNumbers(m_output);
    }

    QString input;
    for (const auto &text : m_input) {
        input.append(text.first);
    }

    m_input.clear();
    m_inputPosition = 0;
    m_result.clear();

    HistoryManager::inst()->addHistory(m_expression + QStringLiteral(" = ") + result + QStringLiteral(" = ") + input);

    if (isApproximate) {
        append(LEFT.toString() + input + RIGHT.toString(), formatApproximate(input, output), false);

        // do not show exact result if approximation is just an exceeding of precision
        calculate(false, 1);
        if (m_output != output) {
            m_result = exactResult;
        }
    } else {
        for (const auto &text : output) {
            append(text, QString(), false);
        }

        if (value != 0.0 && value < 1.0) {
            m_result = exactResult;
        }
    }

    m_output.clear();
    m_expression = result;
    m_binaryResult.clear();
    m_hexResult.clear();

    m_moveFromResult = true;
    Q_EMIT expressionChanged();
    Q_EMIT resultChanged();
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

void InputManager::fromHistory(QString input, bool fromResult)
{
    if (fromResult) {
        bool isApproximate = false;
        QString output = m_engine->evaluate(input, &isApproximate, 10, 10, false);

        if (isApproximate) {
            append(LEFT.toString() + input + RIGHT.toString(), formatApproximate(input, output));
        } else {
            if (output.isEmpty()) {
                output = input;
            }

            for (const auto &ch : output) {
                append(ch, QString(), false);
            }

            store();
            calculateAndUpdate();
        }

        return;
    }

    const std::vector<QString> parts = parseParts(input);
    for (const auto &part : parts) {
        if (part.at(0) == LEFT.at(0)) {
            bool isApproximate = false;
            QString output = m_engine->evaluate(part, &isApproximate, 10, 10, false);
            append(part, formatApproximate(part, output), false);
        } else {
            append(part, QString(), false);
        }
    }

    store();
    calculateAndUpdate();
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
        m_input.clear();
    }

    if (m_inputPosition > m_input.size()) {
        m_inputPosition = m_input.size();
    }

    calculateAndUpdate();

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

    calculateAndUpdate();

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

std::vector<QString> InputManager::parseParts(const QString &text) const
{
    int countLeft = 0;
    int countRight = 0;
    QString part;
    std::vector<QString> parts;

    for (const auto &ch : text) {
        if (ch == LEFT.at(0)) {
            countLeft++;
        } else if (ch == RIGHT.at(0)) {
            countRight++;
        }

        if (countLeft > 0) {
            part.append(ch);

            if (countLeft == countRight) {
                parts.push_back(part);
                part.clear();
                countLeft = 0;
                countRight = 0;
            }
        } else {
            parts.push_back(ch);
        }
    }

    return parts;
}

void InputManager::pasteValue(QString text)
{
    // add leading/ending component parts if missing
    if (text.contains(QStringLiteral("…"))) {
        if (text.at(text.size() - 1) == QStringLiteral("…")) {
            text.append(RIGHT.toString());
        }
        if (text.count(LEFT.at(0)) < text.count(RIGHT.at(0))) {
            text.prepend(LEFT.toString());
        }
    }

    std::vector<std::pair<QString, QString>> savedInput = m_input;
    clear(false);
    text.remove(m_groupSeparator);

    const std::vector<QString> parts = parseParts(text);
    const std::vector<QString> values = parseParts(KalkConfig::self()->lastCopiedValue());
    const std::vector<QString> inputs = parseParts(KalkConfig::self()->lastCopiedInput());

    for (auto part : parts) {
        if (part.at(0) == LEFT.at(0)) {
            size_t index = 0;
            for (const auto &item : savedInput) {
                if (item.second == part) {
                    append(item.first, item.second, false);
                    break;
                }
                index++;
            }

            if (index < savedInput.size()) {
                continue;
            }

            index = 0;
            for (const auto &value : values) {
                if (value == part) {
                    if (index < inputs.size()) {
                        append(inputs.at(index), value, false);
                    }
                    break;
                }
                index++;
            }

            if (index < values.size()) {
                continue;
            }

            part.remove(QStringLiteral("…"));
            part.remove(LEFT.at(0));
            part.remove(RIGHT.at(0));

            for (const auto &ch : part) {
                append(ch, QString(), false);
            }
        } else {
            append(part, QString(), false);
        }
    }

    calculateAndUpdate();
}

void InputManager::storeCopiedValue(const QString &value, bool partial)
{
    bool hasApproximate = false;
    for (const auto &text : m_input) {
        if (!text.second.isEmpty()) {
            hasApproximate = true;
            break;
        }
    }

    if (!hasApproximate) {
        return;
    }

    KalkConfig::self()->setLastCopiedValue(value);

    QString input;
    if (partial) {
        for (const auto &text : m_input) {
            if (text.second == value) {
                input = text.first;
                break;
            }
        }

        if (input.isEmpty()) {
            input = value;
        }
    } else {
        for (const auto &text : m_input) {
            input.append(text.first);
        }
    }

    KalkConfig::self()->setLastCopiedInput(input);
    KalkConfig::self()->save();
}

QString InputManager::formatApproximate(const QString &input, const QString &result)
{
    const double value = m_locale.toDouble(result.at(0) == QStringLiteral("−") ? QStringView(result).sliced(1, result.size() - 2) : result);
    QString approximate;

    if (value == 0.0) {
        approximate = result.left(6) + QStringLiteral("…") + result.right(3);
    } else if (value >= 10000000 || value < 0.0001) {
        // get pure Exponential Notation for very large and very small numbers
        bool isApproximate = false;
        approximate = m_engine->evaluate(input, &isApproximate, 10, 10, false, 1);
        approximate.replace(6, approximate.indexOf(QStringLiteral("E")) - 6, QStringLiteral("…"));
    } else {
        approximate = result.left(8) + QStringLiteral("…");
    }

    return LEFT.toString() + approximate + RIGHT.toString();
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
    if (m_input.size() == 0) {
        clear(false);
        return;
    }

    QString input;
    for (const auto &text : m_input) {
        input.append(text.first);
    }

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
}

void InputManager::calculateAndUpdate(bool exact, const int minExp)
{
    if (m_input.size() == 0) {
        clear(false);
        return;
    }

    m_expression.clear();
    for (const auto &text : m_input) {
        m_expression.append(text.second.isEmpty() ? text.first : text.second);
    }

    if (!m_isBinaryMode) {
        m_expression = formatNumbers(m_expression);
    }
    Q_EMIT expressionChanged();

    calculate(exact, minExp);

    m_result = formatNumbers(m_output);
    Q_EMIT resultChanged();
}

#include "moc_inputmanager.cpp"
