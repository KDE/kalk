/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include <KAboutData>
#include <KLocalizedQmlContext>
#include <KLocalizedString>

#include "version.h"

using namespace Qt::StringLiterals;

#ifdef Q_OS_ANDROID
Q_DECL_EXPORT
#endif
int main(int argc, char *argv[])
{
    QCommandLineParser parser;

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));
#else
    QApplication app(argc, argv);
    // set default style and icon theme
    QIcon::setFallbackThemeName(QStringLiteral("breeze"));
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
    // if using org.kde.desktop, ensure we use kde style if possible
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORMTHEME")) {
        qputenv("QT_QPA_PLATFORMTHEME", "kde");
    }
#endif
    QQmlApplicationEngine engine;
    KLocalizedString::setApplicationDomain(QByteArrayLiteral("kalk"));
    parser.addVersionOption();
    KLocalization::setupLocalizedContext(&engine);

    KAboutData aboutData(QStringLiteral("kalk"),
                         i18n("Calculator"),
                         QStringLiteral(KALK_VERSION_STRING),
                         i18n("Calculator for Plasma"),
                         KAboutLicense::GPL,
                         i18n("© 2020-2024 KDE Community"));
    aboutData.setBugAddress("https://bugs.kde.org/describecomponents.cgi?product=kalk");
    KAboutData::setApplicationData(aboutData);

    parser.process(app);

    // load main ui
    engine.loadFromModule(u"org.kde.kalk"_s, u"Main"_s);

    // required for X11
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.kalk")));

    return app.exec();
}
