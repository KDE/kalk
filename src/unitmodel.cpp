/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "unitmodel.h"
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QDebug>
UnitModel::UnitModel()
{
    connect(this, &UnitModel::unitIndexChanged, this, &UnitModel::calculateResult);
    connect(this, &UnitModel::valueChanged, this, &UnitModel::calculateResult);

    const auto units = KUnitConversion::Converter().category(std::get<1>(categoryAndEnum.at(m_currentIndex))).units();

    m_unitIDs.resize(units.size());
    std::transform(units.begin(), units.end(), m_unitIDs.begin(),
        [](const KUnitConversion::Unit &unit){ return unit.id(); });

    m_units.reserve(units.size());
    for(const auto &unit : units)
    {
        m_units.push_back(unit.symbol());
    }
}
QVariant UnitModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role)
    if (index.row() >= 0 && index.row() < static_cast<int>(categoryAndEnum.size()))
        return std::get<0>(categoryAndEnum.at(index.row()));
    else
        return QVariant();
}

int UnitModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(categoryAndEnum.size());
}
QHash<int, QByteArray> UnitModel::roleNames() const
{
    return {{Qt::DisplayRole, "name"}};
}
void UnitModel::setValue(QString value)
{
    m_value = std::move(value);
    Q_EMIT valueChanged();
}
void UnitModel::setCurrentIndex(int i)
{
    if(i < 0 || i > static_cast<int>(categoryAndEnum.size()))
        return;
    if(m_currentIndex != i)
    {
        m_units.clear();
        m_currentIndex = i;
        m_value.clear();
        m_fromUnitIndex = 0;
        m_toUnitIndex = 1;

        const auto units = KUnitConversion::Converter().category(std::get<1>(categoryAndEnum.at(m_currentIndex))).units();

        m_unitIDs.resize(units.size());
        std::transform(units.begin(), units.end(), m_unitIDs.begin(),
            [](const KUnitConversion::Unit &unit){ return unit.id(); });

        m_units.reserve(units.size());
        for(const auto &unit : units)
        {
            m_units.push_back(unit.symbol());
        }

        calculateResult();
        Q_EMIT currentIndexChanged();
        Q_EMIT unitIndexChanged();
        Q_EMIT typeListChanged();
        Q_EMIT valueChanged();
    }
}
void UnitModel::setFromUnitIndex(int i)
{
    m_fromUnitIndex = i;
    calculateResult();
}
void UnitModel::setToUnitIndex(int i)
{
    m_toUnitIndex = i;
    calculateResult();
}
void UnitModel::calculateResult()
{
    if(m_value.size())
    {
        auto units = KUnitConversion::Converter().category(std::get<1>(categoryAndEnum.at(m_currentIndex))).units();

        if(m_fromUnitIndex < 0 || m_toUnitIndex < 0 || m_fromUnitIndex > units.size() || m_toUnitIndex > units.size())
            return;

        auto from = KUnitConversion::Value(m_value.toDouble(), units.at(m_fromUnitIndex));
        m_result = KUnitConversion::Converter().convert(from,units.at(m_toUnitIndex)).toString();
        qDebug() << m_result;
    } else
    {
        m_result.clear();
    }
    Q_EMIT resultChanged();
}
const std::vector<std::tuple<QString, KUnitConversion::CategoryId>> UnitModel::categoryAndEnum =
{{QStringLiteral("Acceleration"), KUnitConversion::AccelerationCategory},
 {QStringLiteral("Angle"), KUnitConversion::AngleCategory},
 {QStringLiteral("Area"), KUnitConversion::AreaCategory},
 {QStringLiteral("Binary Data"), KUnitConversion::BinaryDataCategory},
 {QStringLiteral("Currency"), KUnitConversion::CurrencyCategory},
 {QStringLiteral("Density"), KUnitConversion::DensityCategory},
 {QStringLiteral("Electrical Current"), KUnitConversion::ElectricalCurrentCategory},
 {QStringLiteral("Electrical Resistance"), KUnitConversion::ElectricalResistanceCategory},
 {QStringLiteral("Energy"), KUnitConversion::EnergyCategory},
 {QStringLiteral("Force"), KUnitConversion::ForceCategory},
 {QStringLiteral("Frequency"), KUnitConversion::FrequencyCategory},
 {QStringLiteral("Fuel Efficiency"), KUnitConversion::FuelEfficiencyCategory},
 {QStringLiteral("Length"), KUnitConversion::LengthCategory},
 {QStringLiteral("Mass"), KUnitConversion::MassCategory},
 {QStringLiteral("Permeability"), KUnitConversion::PermeabilityCategory},
 {QStringLiteral("Power"), KUnitConversion::PowerCategory},
 {QStringLiteral("Pressure"), KUnitConversion::PressureCategory},
 {QStringLiteral("Temperature"), KUnitConversion::TemperatureCategory},
 {QStringLiteral("Thermal Conductivity"), KUnitConversion::ThermalConductivityCategory},
 {QStringLiteral("Thermal Flux"), KUnitConversion::ThermalFluxCategory},
 {QStringLiteral("Thermal Generation"), KUnitConversion::ThermalGenerationCategory},
 {QStringLiteral("Time"), KUnitConversion::TimeCategory},
 {QStringLiteral("Velocity"), KUnitConversion::VelocityCategory},
 {QStringLiteral("Volume"), KUnitConversion::VolumeCategory},
 {QStringLiteral("Voltage"), KUnitConversion::VoltageCategory}};
