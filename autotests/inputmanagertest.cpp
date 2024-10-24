// SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QTest>

#include "inputmanager.h"

class InputManagerTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void init();
    void testAddition();
    void testMultiplication();
    void testDivision();
    void testNonIntegerDivision();

private:
    InputManager m_inputManager;
};

#ifndef Q_OS_WIN
void initLocale()
{
    setenv("LC_ALL", LANG, 1);
}

Q_CONSTRUCTOR_FUNCTION(initLocale)
#endif

void InputManagerTest::init()
{
    if (QStringLiteral(LANG) != QStringLiteral("C")) {
        if (QLocale().language() != QLocale::German) {
            qWarning() << "Please enable the" << LANG << "locale on your system";
            exit(0);
        }
    }

    m_inputManager.clear();
}

void InputManagerTest::testAddition()
{
    m_inputManager.append(QStringLiteral("4"));
    m_inputManager.append(QStringLiteral("+"));
    m_inputManager.append(QStringLiteral("2"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("6"));
    m_inputManager.equal();
    m_inputManager.append(QStringLiteral("+"));
    m_inputManager.append(QStringLiteral("3"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("9"));
}

void InputManagerTest::testMultiplication()
{
    m_inputManager.append(QStringLiteral("4"));
    m_inputManager.append(QStringLiteral("*"));
    m_inputManager.append(QStringLiteral("2"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("8"));
    m_inputManager.equal();
    m_inputManager.append(QStringLiteral("*"));
    m_inputManager.append(QStringLiteral("7"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("56"));
}

void InputManagerTest::testDivision()
{
    m_inputManager.append(QStringLiteral("70"));
    m_inputManager.append(QStringLiteral("÷"));
    m_inputManager.append(QStringLiteral("5"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("14"));
    m_inputManager.equal();
    m_inputManager.append(QStringLiteral("*"));
    m_inputManager.append(QStringLiteral("5"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("70"));
}

void InputManagerTest::testNonIntegerDivision()
{
    m_inputManager.append(QStringLiteral("70"));
    m_inputManager.append(QStringLiteral("÷"));
    m_inputManager.append(QStringLiteral("9"));
    if (QStringLiteral(LANG) == QStringLiteral("C")) {
        QVERIFY(m_inputManager.result().startsWith(QStringLiteral("7.77777")));
    } else {
        QVERIFY(m_inputManager.result().startsWith(QStringLiteral("7,77777")));
    }
    m_inputManager.equal();
    m_inputManager.append(QStringLiteral("*"));
    m_inputManager.append(QStringLiteral("9"));
    QCOMPARE(m_inputManager.result(), QStringLiteral("70"));
}

QTEST_GUILESS_MAIN(InputManagerTest)

#include "inputmanagertest.moc"
