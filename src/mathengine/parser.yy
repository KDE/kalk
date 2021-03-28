/*
 * This file is part of Kalk
 *
 * Copyright (C) 2020 Han Young <hanyoung@protonmail.com>
 *
 * $BEGIN_LICENSE:GPL3+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 */
%skeleton "lalr1.cc" // -*- C++ -*-
%require "3.0"
%defines

%define api.token.raw

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires {
  # include <string>
  # include <knumber.h>
  class driver;
}

// The parsing context.
%param { driver& drv }

%locations

%define parse.trace
%define parse.error verbose
%define parse.lac full

%code {
# include "driver.hh"
}

%define api.token.prefix {TOK_}
%token
  MINUS   "-"
  PLUS    "+"
  STAR    "*"
  SLASH   "/"
  LPAREN  "("
  RPAREN  ")"
  POWER   "^"
  SIN     "SIN"
  COS     "COS"
  TAN     "TAN"
  LOG     "LOG"
  LOG10   "LOG10"
  LOG2    "LOG2"
  SQUAREROOT    "SQUAREROOT"
  PERCENTAGE    "%"
  ASIN     "ASIN"
  ACOS     "ACOS"
  ATAN     "ATAN"
  ABS       "ABS"
;

%token <KNumber> NUMBER "number"
%nterm <KNumber> exp
%nterm <KNumber> factor

%printer { yyo << $$.toQString().toStdString(); } <*>;

%%
%start unit;
unit: exp  { drv.result = $1; };

%left "+" "-";
%left "*" "/";
exp:
  factor
| exp "+" exp   { $$ = $1 + $3; }
| exp "-" exp   { $$ = $1 - $3; }
| exp exp       { $$ = $1 * $2; }
| exp "*" exp   { $$ = $1 * $3; }
| exp "/" exp   { $$ = $1 / $3; }
| exp "^" factor   { $$ = pow($1, $3); }
| exp "^"   { $$ = $1; }
| "SIN" "(" exp     { $$ = sin($3); }
| "SIN" "(" exp ")" { $$ = sin($3); }
| "COS" "(" exp     { $$ = cos($3); }
| "COS" "(" exp ")" { $$ = cos($3); }
| "TAN" "(" exp     { $$ = tan($3); }
| "TAN" "(" exp ")" { $$ = tan($3); }
| "LOG" "(" exp     { $$ = ln($3); }
| "LOG" "(" exp ")" { $$ = ln($3); }
| "LOG10" "(" exp   { $$ = log10($3); }
| "LOG10" "(" exp ")" { $$ = log10($3); }
| "LOG2" "(" exp    { $$ = log2($3); }
| "LOG2" "(" exp ")" { $$ = log2($3); }
| "SQUAREROOT" "(" exp   { $$ = sqrt($3); }
| "SQUAREROOT" "(" exp ")"  { $$ = sqrt($3); }
| "ASIN" "(" exp     { $$ = asin($3); }
| "ASIN" "(" exp ")" { $$ = asin($3); }
| "ACOS" "(" exp     { $$ = acos($3); }
| "ACOS" "(" exp ")" { $$ = acos($3); }
| "ATAN" "(" exp     { $$ = atan($3); }
| "ATAN" "(" exp ")" { $$ = atan($3); }
| "ABS" "(" exp { $$ = abs($3); }
| "ABS" "(" exp ")" { $$ = abs($3);}
;

factor: "(" exp ")" { $$ = $2; }
| "(" exp      { $$ = $2; }
| "number"
| "-" "number" { $$ = -$2; }
| "+" "number" { $$ = $2; }
| factor "%" { $$ = $1 / KNumber(100); }
;
    
%%

void
yy::parser::error (const location_type& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
  if(m != "syntax error, unexpected end of file")
    drv.syntaxError = true;
}
