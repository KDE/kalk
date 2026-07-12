/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "unitmodel.h"
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QDebug>

UnitModel::UnitModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(this, &UnitModel::unitIndexChanged, this, &UnitModel::calculateResult);
    connect(this, &UnitModel::valueChanged, this, &UnitModel::calculateResult);

    const auto units = KUnitConversion::Converter().category(std::get<1>(categoryAndEnum.at(m_currentIndex))).units();

    m_unitIDs.resize(units.size());
    std::transform(units.begin(), units.end(), m_unitIDs.begin(), [](const KUnitConversion::Unit &unit) {
        return unit.id();
    });

    m_units.reserve(units.size());
    for (const auto &unit : units) {
        m_units.push_back(unit.symbol());
    }
}

UnitModel::~UnitModel() = default;

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
    if (i < 0 || i > static_cast<int>(categoryAndEnum.size()))
        return;
    if (m_currentIndex != i) {
        m_units.clear();
        m_currentIndex = i;
        m_value.clear();
        m_fromUnitIndex = 0;
        m_toUnitIndex = 1;

        const auto units = KUnitConversion::Converter().category(std::get<1>(categoryAndEnum.at(m_currentIndex))).units();

        m_unitIDs.resize(units.size());
        std::transform(units.begin(), units.end(), m_unitIDs.begin(), [](const KUnitConversion::Unit &unit) {
            return unit.id();
        });

        m_units.reserve(units.size());
        for (const auto &unit : units) {
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
    if (m_value.size()) {
        auto units = KUnitConversion::Converter().category(std::get<1>(categoryAndEnum.at(m_currentIndex))).units();

        if (m_fromUnitIndex < 0 || m_toUnitIndex < 0 || m_fromUnitIndex > units.size() || m_toUnitIndex > units.size())
            return;

        auto from = KUnitConversion::Value(m_value.toDouble(), units.at(m_fromUnitIndex));
        m_result = KUnitConversion::Converter().convert(from, units.at(m_toUnitIndex)).toString();
        qDebug() << m_result;
    } else {
        m_result.clear();
    }
    Q_EMIT resultChanged();
}
const std::vector<std::tuple<QString, KUnitConversion::CategoryId>> UnitModel::categoryAndEnum = {
    {i18nc("@item:inlistbox Category for unit conversion", "Acceleration"), KUnitConversion::AccelerationCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Angle"), KUnitConversion::AngleCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Area"), KUnitConversion::AreaCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Binary Data"), KUnitConversion::BinaryDataCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Currency"), KUnitConversion::CurrencyCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Density"), KUnitConversion::DensityCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Electrical Current"), KUnitConversion::ElectricalCurrentCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Electrical Resistance"), KUnitConversion::ElectricalResistanceCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Energy"), KUnitConversion::EnergyCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Force"), KUnitConversion::ForceCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Frequency"), KUnitConversion::FrequencyCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Fuel Efficiency"), KUnitConversion::FuelEfficiencyCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Length"), KUnitConversion::LengthCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Mass"), KUnitConversion::MassCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Permeability"), KUnitConversion::PermeabilityCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Power"), KUnitConversion::PowerCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Pressure"), KUnitConversion::PressureCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Temperature"), KUnitConversion::TemperatureCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Thermal Conductivity"), KUnitConversion::ThermalConductivityCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Thermal Flux"), KUnitConversion::ThermalFluxCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Thermal Generation"), KUnitConversion::ThermalGenerationCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Time"), KUnitConversion::TimeCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Velocity"), KUnitConversion::VelocityCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Volume"), KUnitConversion::VolumeCategory},
    {i18nc("@item:inlistbox Category for unit conversion", "Voltage"), KUnitConversion::VoltageCategory}};

#include "moc_unitmodel.cpp"
