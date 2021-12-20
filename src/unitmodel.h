/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <kunitconversion/unit.h>
#include <kunitconversion/converter.h>
#include <tuple>

class UnitModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList typeList READ typeList NOTIFY typeListChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(int fromUnitIndex READ fromUnitIndex WRITE setFromUnitIndex NOTIFY unitIndexChanged)
    Q_PROPERTY(int toUnitIndex READ toUnitIndex WRITE setToUnitIndex NOTIFY unitIndexChanged)
public:
    static UnitModel *inst()
    {
        static UnitModel singleton;
        return &singleton;
    }
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    const QString &value() const
    {
        return m_value;
    }
    void setValue(QString value);
    const QString &result() const
    {
        return m_result;
    }
    int currentIndex() const
    {
        return m_currentIndex;
    }
    int fromUnitIndex() const
    {
        return m_fromUnitIndex;
    }
    int toUnitIndex() const
    {
        return m_toUnitIndex;
    }
    const QStringList &typeList() const
    {
        return m_units;
    }
    void setCurrentIndex(int i);
    void setFromUnitIndex(int i);
    void setToUnitIndex(int i);
    
Q_SIGNALS:
    void typeListChanged();
    void valueChanged();
    void resultChanged();
    void currentIndexChanged();
    void unitIndexChanged();

private Q_SLOTS:
    void calculateResult();

private:
    UnitModel();
    int m_currentIndex = 0;
    int m_fromUnitIndex = 0;
    int m_toUnitIndex = 1;
    QString m_value, m_result;
    QStringList m_units;
    std::vector<KUnitConversion::UnitId> m_unitIDs;
    static const std::vector<std::tuple<QString, KUnitConversion::CategoryId>> categoryAndEnum;
};
