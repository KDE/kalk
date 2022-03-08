/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QApplication>
#include <QDebug>
#include <QObject>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlContext>
#include <QQuickStyle>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "about.h"
#include "historymanager.h"
#include "mathengine.h"
#include "inputmanager.h"
#include "unitmodel.h"
#include "version.h"

int main(int argc, char *argv[])
{
    // set default style
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
    // if using org.kde.desktop, ensure we use kde style if possible
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORMTHEME")) {
        qputenv("QT_QPA_PLATFORMTHEME", "kde");
    }

    QCommandLineParser parser;

    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    KLocalizedString::setApplicationDomain("kalk");
    parser.addVersionOption();
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.rootContext()->setContextProperty(QStringLiteral("historyManager"), HistoryManager::inst());
    engine.rootContext()->setContextProperty(QStringLiteral("inputManager"), InputManager::inst());
    engine.rootContext()->setContextProperty(QStringLiteral("unitModel"), UnitModel::inst());
    
    KAboutData aboutData(QStringLiteral("kalk"), 
                         i18n("Calculator"), 
                         QStringLiteral(KALK_VERSION_STRING), 
                         i18n("Calculator in Kirigami"), 
                         KAboutLicense::GPL, 
                         i18n("© 2020-2021 KDE Community"));
    KAboutData::setApplicationData(aboutData);

    parser.process(app);

    qmlRegisterSingletonInstance("org.kde.kalk", 1, 0, "AboutType", &AboutType::instance());

#ifdef QT_DEBUG
    engine.rootContext()->setContextProperty(QStringLiteral("debug"), true);
#else
    engine.rootContext()->setContextProperty(QStringLiteral("debug"), false);
#endif
    // load main ui
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
