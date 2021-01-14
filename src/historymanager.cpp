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
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/kalk");
    if (!dir.exists())
        dir.mkpath(".");
    QFile file(dir.path() + "/history.json");
    if (file.exists()) {
        file.open(QIODevice::ReadOnly);
        QJsonDocument doc(QJsonDocument::fromJson(file.readAll()));
        auto array = doc.array();
        for (const auto &record : qAsConst(array)) {
            historyList.append(record.toString());
        }
        file.close();
    }
}

void HistoryManager::clearHistory()
{
    historyList.clear();
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/kalk");
    QFile file(dir.path() + "history.json");
    file.remove();
    emit layoutChanged();
    this->save();
}

void HistoryManager::save()
{
    QJsonDocument doc;
    QJsonArray array;
    for (const auto &record : qAsConst(historyList)) {
        array.append(record);
    }
    doc.setArray(array);
    QString url = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    QFile file(url + "/kalk/history.json");
    file.open(QIODevice::WriteOnly);
    file.write(doc.toJson(QJsonDocument::Compact));
    file.close();
    qDebug() << "save" << file.fileName();
}
