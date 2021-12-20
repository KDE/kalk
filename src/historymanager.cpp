/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "historymanager.h"
#include <QDebug>
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

HistoryManager::HistoryManager()
{
    // create cache location if it does not exist, and load cache
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/kalk"));
    if (!dir.exists()) {
        dir.mkpath(QStringLiteral("."));
    }
    
    QFile file(dir.path() + QStringLiteral("/history.json"));
    if (file.open(QIODevice::ReadOnly)) {
        QJsonDocument doc(QJsonDocument::fromJson(file.readAll()));
        const auto array = doc.array();
        m_historyList.reserve(array.size());
        for (const auto &record : array) {
            m_historyList.append(record.toString());
        }
    }
}

void HistoryManager::clearHistory()
{
    m_historyList.clear();
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/kalk"));
    QFile file(dir.path() + QStringLiteral("history.json"));
    file.remove();
    Q_EMIT layoutChanged();
    save();
}

void HistoryManager::save()
{
    QJsonDocument doc;
    QJsonArray array;
    for (const auto &record : qAsConst(m_historyList)) {
        array.append(record);
    }
    doc.setArray(array);
    QString url = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    QFile file(url + QStringLiteral("/kalk/history.json"));
    file.open(QIODevice::WriteOnly);
    file.write(doc.toJson(QJsonDocument::Compact));
    qDebug() << "save" << file.fileName();
}
