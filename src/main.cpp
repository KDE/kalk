/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QApplication>
#include <QDebug>
#include <QObject>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "historymanager.h"
#include "mathengine.h"
#include "inputmanager.h"
#include "unitmodel.h"
int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    KLocalizedString::setApplicationDomain("kalk");
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.rootContext()->setContextProperty("historyManager", HistoryManager::inst());
    engine.rootContext()->setContextProperty("inputManager", InputManager::inst());
    engine.rootContext()->setContextProperty("unitModel", UnitModel::inst());
    KAboutData aboutData("kalk", i18n("Calculator"), "0.1", i18n("Calculator in Kirigami"), KAboutLicense::GPL, i18n("© 2020 KDE Community"));
    KAboutData::setApplicationData(aboutData);

#ifdef QT_DEBUG
    engine.rootContext()->setContextProperty(QStringLiteral("debug"), true);
#else
    engine.rootContext()->setContextProperty(QStringLiteral("debug"), false);
#endif
    // load main ui
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
