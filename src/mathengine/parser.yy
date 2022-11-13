// SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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
