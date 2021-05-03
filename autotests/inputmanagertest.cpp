
#include <QTest>

#include "inputmanager.h"

class InputManagerTest : public QObject
{
    Q_OBJECT

private slots:
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
    if (QString(LANG) != "C") {
        if (QLocale().language() != QLocale::German) {
            qWarning() << "Please enable the" << LANG << "locale on your system";
            exit(0);
        }
    }
    InputManager::inst()->clear();
}

void InputManagerTest::testAddition()
{
    InputManager::inst()->append("4");
    InputManager::inst()->append("+");
    InputManager::inst()->append("2");
    QCOMPARE(InputManager::inst()->result(), "6");
    InputManager::inst()->equal();
    InputManager::inst()->append("+");
    InputManager::inst()->append("3");
    QCOMPARE(InputManager::inst()->result(), "9");
}

void InputManagerTest::testMultiplication()
{
    InputManager::inst()->append("4");
    InputManager::inst()->append("*");
    InputManager::inst()->append("2");
    QCOMPARE(InputManager::inst()->result(), "8");
    InputManager::inst()->equal();
    InputManager::inst()->append("*");
    InputManager::inst()->append("7");
    QCOMPARE(InputManager::inst()->result(), "56");
}

void InputManagerTest::testDivision()
{
    InputManager::inst()->append("70");
    InputManager::inst()->append("÷");
    InputManager::inst()->append("5");
    QCOMPARE(InputManager::inst()->result(), "14");
    InputManager::inst()->equal();
    InputManager::inst()->append("*");
    InputManager::inst()->append("5");
    QCOMPARE(InputManager::inst()->result(), "70");
}

void InputManagerTest::testNonIntegerDivision()
{
    InputManager::inst()->append("70");
    InputManager::inst()->append("÷");
    InputManager::inst()->append("9");
    if (QString(LANG) == "C") {
        QVERIFY(InputManager::inst()->result().startsWith("7.77777"));
    } else {
        QVERIFY(InputManager::inst()->result().startsWith("7,77777"));
    }
    InputManager::inst()->equal();
    InputManager::inst()->append("*");
    InputManager::inst()->append("9");
    QCOMPARE(InputManager::inst()->result(), "70");
}

QTEST_GUILESS_MAIN(InputManagerTest)

#include "inputmanagertest.moc"
