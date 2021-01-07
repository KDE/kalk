/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "typemodel.h"
#include "unitmodel.h"
#include <KLocalizedContext>
#include <KLocalizedString>
#include <kunitconversion/value.h>
TypeModel::TypeModel()
{
}

QVariant TypeModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role)
    return i18n((unitsType.at(index.row())).toLatin1());
}

int TypeModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return unitsType.size();
}
QHash<int, QByteArray> TypeModel::roleNames() const
{
    return {{Qt::DisplayRole, "name"}};
}

void TypeModel::currentIndex(int index)
{
    emit categoryChanged(unitsType.at(index));
};
const std::array<QString, 25> TypeModel::unitsType = {"Acceleration",
                                                      "Angle",
                                                      "Area",
                                                      "Binary Data",
                                                      "Currency",
                                                      "Density",
                                                      "Electrical Current",
                                                      "Electrical Resistance",
                                                      "Energy",
                                                      "Force",
                                                      "Frequency",
                                                      "Fuel Efficiency",
                                                      "Length",
                                                      "Mass",
                                                      "Permeability",
                                                      "Power",
                                                      "Pressure",
                                                      "Temperature",
                                                      "Thermal Conductivity",
                                                      "Thermal Flux",
                                                      "Thermal Generation",
                                                      "Time",
                                                      "Velocity",
                                                      "Volume",
                                                      "Voltage"};
