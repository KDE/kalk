/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@Students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>

class QalculateEngine;

class InputManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString expression READ expression NOTIFY expressionChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString binaryResult READ binaryResult NOTIFY binaryResultChanged)
    Q_PROPERTY(QString hexResult READ hexResult NOTIFY hexResultChanged)
    Q_PROPERTY(bool moveFromResult READ moveFromResult NOTIFY resultChanged)
    Q_PROPERTY(int cursorPosition READ getCursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_PROPERTY(bool binaryMode READ binaryMode WRITE setBinaryMode)
    Q_PROPERTY(bool canUndo READ canUndo NOTIFY canUndoChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY canRedoChanged)
    Q_PROPERTY(int historyIndex READ historyIndex WRITE setHistoryIndex)

public:
    static InputManager *inst();
    const QString &expression() const;
    const QString &result() const;
    const QString &binaryResult() const;
    const QString &hexResult() const;
    bool moveFromResult() const;
    int getCursorPosition() const;
    void setCursorPosition(int position);
    Q_INVOKABLE int idealCursorPosition(int position, int arrow = 0) const;
    Q_INVOKABLE void append(const QString &subexpression, const QString &component = QString(), bool update = true);
    Q_INVOKABLE void backspace();
    Q_INVOKABLE void equal();
    Q_INVOKABLE void clear(bool save = true);
    Q_INVOKABLE void setHistoryIndex(const int &index);
    int historyIndex() const;
    Q_INVOKABLE void fromHistory(QString input, bool fromResult = false);
    void store();
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    bool canUndo();
    bool canRedo();
    void setBinaryMode(bool active);
    bool binaryMode();
    Q_INVOKABLE void pasteValue(QString value);
    Q_INVOKABLE void storeCopiedValue(const QString &value, bool partial = false);
    QString formatNumbers(const QString &text);
    void replaceWithSuperscript(QString &text);
    void addNumberSeparators(QString &number);
    void calculate(bool exact = false, const int minExp = -1);
    void calculateAndUpdate(bool exact = false, const int minExp = -1);

Q_SIGNALS:
    void expressionChanged();
    void resultChanged();
    void binaryResultChanged();
    void hexResultChanged();
    void cursorPositionChanged();
    void canUndoChanged();
    void canRedoChanged();

private:
    InputManager();
    bool m_moveFromResult = false; // clear expression on none operator input
    size_t m_inputPosition = 0;
    std::vector<std::pair<QString, QString>> m_input;
    QString m_output;
    QString m_expression;
    QString m_result;
    QString m_binaryResult;
    QString m_hexResult;
    bool m_isBinaryMode = false; // Changes the parser based on this variable
    QString m_groupSeparator;
    QString m_decimalPoint;
    std::vector<std::vector<std::pair<QString, QString>>> m_undoStack;
    size_t m_undoPos = 0;
    QalculateEngine *m_engine;
    bool m_isApproximate;
    QString formatApproximate(QString &input, QString &result);
    std::vector<QString> parseParts(const QString &text) const;
    int m_historyIndex;
};
