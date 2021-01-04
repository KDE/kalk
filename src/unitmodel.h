/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#ifndef MYUNITMODEL_H
#define MYUNITMODEL_H // this took me hours to debug, UNITMODEL is defined by kunitconversio

#include <QAbstractListModel>
#include <QObject>
#include <kunitconversion/unit.h>
#include <unordered_map>

class UnitModel : public QAbstractListModel
{
    Q_OBJECT
public:
    UnitModel();
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QString getRet(double val, int fromTypeIndex, int toTypeIndex); // use int index because text may be localized
    Q_INVOKABLE QStringList search(QString keyword, int field);                 // 0 for from search field, 1 for to search field
public slots:
    void changeUnit(QString type);

private:
    QList<KUnitConversion::Unit> m_units;
    QVector<QString> m_displayString;
    QVector<KUnitConversion::UnitId> m_fromUnitID;
    QVector<KUnitConversion::UnitId> m_toUnitID;
    static const std::unordered_map<QString, int> categoryToEnum;
};
#endif // UNITMODEL_H
