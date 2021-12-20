
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
    InputManager::inst()->clear();
}

void InputManagerTest::testAddition()
{
    InputManager::inst()->append(QStringLiteral("4"));
    InputManager::inst()->append(QStringLiteral("+"));
    InputManager::inst()->append(QStringLiteral("2"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("6"));
    InputManager::inst()->equal();
    InputManager::inst()->append(QStringLiteral("+"));
    InputManager::inst()->append(QStringLiteral("3"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("9"));
}

void InputManagerTest::testMultiplication()
{
    InputManager::inst()->append(QStringLiteral("4"));
    InputManager::inst()->append(QStringLiteral("*"));
    InputManager::inst()->append(QStringLiteral("2"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("8"));
    InputManager::inst()->equal();
    InputManager::inst()->append(QStringLiteral("*"));
    InputManager::inst()->append(QStringLiteral("7"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("56"));
}

void InputManagerTest::testDivision()
{
    InputManager::inst()->append(QStringLiteral("70"));
    InputManager::inst()->append(QStringLiteral("÷"));
    InputManager::inst()->append(QStringLiteral("5"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("14"));
    InputManager::inst()->equal();
    InputManager::inst()->append(QStringLiteral("*"));
    InputManager::inst()->append(QStringLiteral("5"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("70"));
}

void InputManagerTest::testNonIntegerDivision()
{
    InputManager::inst()->append(QStringLiteral("70"));
    InputManager::inst()->append(QStringLiteral("÷"));
    InputManager::inst()->append(QStringLiteral("9"));
    if (QStringLiteral(LANG) == QStringLiteral("C")) {
        QVERIFY(InputManager::inst()->result().startsWith(QStringLiteral("7.77777")));
    } else {
        QVERIFY(InputManager::inst()->result().startsWith(QStringLiteral("7,77777")));
    }
    InputManager::inst()->equal();
    InputManager::inst()->append(QStringLiteral("*"));
    InputManager::inst()->append(QStringLiteral("9"));
    QCOMPARE(InputManager::inst()->result(), QStringLiteral("70"));
}

QTEST_GUILESS_MAIN(InputManagerTest)

#include "inputmanagertest.moc"
