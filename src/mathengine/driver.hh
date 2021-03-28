/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#ifndef DRIVER_HH
#define DRIVER_HH
#include "parser.hh"
#include <map>
#include <string>
// Give Flex the prototype of yylex we want ...
#define YY_DECL yy::parser::symbol_type yylex(driver &drv)
// ... and declare it for the parser's sake.
YY_DECL;

// Conducting the whole scanning and parsing of Calc++.
class driver
{
public:
    driver();
    std::map<std::string, int> variables;

    KNumber result;

    int parse(const std::string expr);
    // Whether to generate parser debug traces.
    bool trace_parsing;

    // Handling the scanner.
    void scan_begin(std::string s);
    // Whether to generate scanner debug traces.
    bool trace_scanning;
    // The token's location used by the scanner.
    yy::location location;
    bool syntaxError = false;
};
#endif // ! DRIVER_HH
