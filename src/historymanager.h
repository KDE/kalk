/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QAbstractListModel>
#include <QObject>

class HistoryManager : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString expression WRITE addHistory)
public:
    static HistoryManager *inst()
    {
        static HistoryManager singleton;
        return &singleton;
    }
    int rowCount(const QModelIndex &parent) const override
    {
        Q_UNUSED(parent)
        return m_historyList.count();
    };
    QVariant data(const QModelIndex &index, int role) const override
    {
        Q_UNUSED(index)
        Q_UNUSED(role)
        return m_historyList.at(index.row());
    };
    void addHistory(const QString &string)
    {
        m_historyList.append(string);
        this->save();
        Q_EMIT layoutChanged();
    };
    Q_INVOKABLE void clearHistory();

private:
    QList<QString> m_historyList;
    void save();
    HistoryManager();
};
