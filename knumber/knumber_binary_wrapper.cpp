/*
 * SPDX-FileCopyrightText: 2021-2022 Rohan Asokan <rohan.asokan@students.iiit.ac.in>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "knumber_binary_wrapper.h"
#include "knumber.h"
#include <QString>
#include <QRegularExpression>
#include <QLatin1String>
#include <QDebug>

// Constructors and Destructors

BinaryNumber::BinaryNumber(const BinaryNumber& other) {
    m_number = other.toKNum();
}

BinaryNumber::BinaryNumber(const KNumber &num) {
    m_number = num;
}

BinaryNumber::BinaryNumber(const QString &s) : m_number(KNumber("UNDEFINED_ERROR")) {
    const QRegularExpression binary_regex("^[01]+.[01]+|^[01]+");

    if (binary_regex.match(s).hasMatch()) {
        m_number = KNumber(0);
        int seperator_loc = s.indexOf('.');
        if (seperator_loc == -1) seperator_loc = s.length();

        KNumber multiplier(1);
        KNumber base(2);

        // Integer Part Calculations
        for (int idx = seperator_loc - 1; idx >= 0; idx--) {
            m_number += (KNumber(s.at(idx)) * multiplier);
            multiplier *= base;
        }

        // multiplier = base;
        // // Fractional Part Calculations
        // for (int idx = seperator_loc + 1; idx < s.length(); idx++) {
        //     m_number += (KNumber(s.at(idx)) / base);
        //     multiplier *= base;
        // }
    }
}

// Converters

QString BinaryNumber::toDec() const {
    return m_number.toQString();
}

KNumber BinaryNumber::toKNum() const {
    return m_number;
}

// Operators

BinaryNumber &BinaryNumber::operator=(const BinaryNumber &rhs) {
    (*this).m_number = rhs.toKNum();
    return *this;
}

BinaryNumber operator+(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res += rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator-(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res -= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator*(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res *= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator/(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res /= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator&(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res &= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator|(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res |= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator^(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res ^= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator<<(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res <<= rhs.toKNum();
    return BinaryNumber(res);
}

BinaryNumber operator>>(const BinaryNumber &lhs, const BinaryNumber &rhs) {
    KNumber res(lhs.toKNum());
    res >>= rhs.toKNum();
    return BinaryNumber(res);
}
