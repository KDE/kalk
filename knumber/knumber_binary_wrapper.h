/*
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <QString>
#include "knumber.h"

class BinaryNumber {
public:
    // construction/destruction
    BinaryNumber();
    explicit BinaryNumber(const QString &s);
    explicit BinaryNumber(const KNumber &num);
    BinaryNumber(const BinaryNumber &other);
    // ~BinaryNumber();
public:
	// assignment
	BinaryNumber &operator=(const BinaryNumber &rhs);
public:
    // Unary operators
    // KNumber &operator~();
public:
    // Converters
    QString toHex() const;
    QString toOct() const;
    QString toBin() const;
    QString toDec() const;
    KNumber toKNum() const;
private:
    KNumber m_number;
};

BinaryNumber operator+(const BinaryNumber &lhs, const BinaryNumber &rhs);
BinaryNumber operator-(const BinaryNumber &lhs, const BinaryNumber &rhs);
BinaryNumber operator*(const BinaryNumber &lhs, const BinaryNumber &rhs);
BinaryNumber operator/(const BinaryNumber &lhs, const BinaryNumber &rhs);

BinaryNumber operator&(const BinaryNumber &lhs, const BinaryNumber &rhs);
BinaryNumber operator|(const BinaryNumber &lhs, const BinaryNumber &rhs);
BinaryNumber operator^(const BinaryNumber &lhs, const BinaryNumber &rhs);

BinaryNumber operator<<(const BinaryNumber &lhs, const BinaryNumber &rhs);
BinaryNumber operator>>(const BinaryNumber &lhs, const BinaryNumber &rhs);
