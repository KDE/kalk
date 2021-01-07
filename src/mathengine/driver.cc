/*
 * SPDX-FileCopyrightText: 2020-2021 Han Young <hanyoung@protonmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "driver.hh"
#include "parser.hh"
driver::driver()
    : trace_parsing(false)
    , trace_scanning(false)
{
}
int driver::parse(const std::string expr)
{
    syntaxError = false;
    scan_begin(expr);
    yy::parser parse(*this);
    parse.set_debug_level(trace_parsing);
    int res = parse();
    return res;
}
