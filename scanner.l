%{
#include <cstdlib>
#include <cstring>
#include <string>
#include "parser.tab.h"
#include "types.h"
#include "listing.h"
static std::string linebuf;
%}

%option noyywrap nodefault

%%

[ \t\r]+                 { linebuf.append(yytext); }
\n                       { appendSource(linebuf); linebuf.clear(); nextLine(); }
\/\/[^\n]*               { linebuf.append(yytext); }

"function"               { linebuf.append(yytext); return FUNCTION; }
"returns"                { linebuf.append(yytext); return RETURNS; }
"begin"                  { linebuf.append(yytext); return BEGIN_; }
"end"                    { linebuf.append(yytext); return END; }
"integer"                { linebuf.append(yytext); yylval.type = INT_TYPE; return T_INTEGER; }
"real"                   { linebuf.append(yytext); yylval.type = REAL_TYPE; return T_REAL; }
"character"              { linebuf.append(yytext); yylval.type = CHAR_TYPE; return T_CHARACTER; }
"list"                   { linebuf.append(yytext); return T_LIST; }
"of"                     { linebuf.append(yytext); return T_OF; }
"is"                     { linebuf.append(yytext); return T_IS; }
"when"                   { linebuf.append(yytext); return T_WHEN; }
"switch"                 { linebuf.append(yytext); return T_SWITCH; }
"case"                   { linebuf.append(yytext); return T_CASE; }
"if"                     { linebuf.append(yytext); return T_IF; }
"then"                   { linebuf.append(yytext); return T_THEN; }
"elsif"                  { linebuf.append(yytext); return T_ELSIF; }
"else"                   { linebuf.append(yytext); return T_ELSE; }
"endif"                  { linebuf.append(yytext); return T_ENDIF; }
"fold"                   { linebuf.append(yytext); return T_FOLD; }
"left"                   { linebuf.append(yytext); return T_LEFT; }
"right"                  { linebuf.append(yytext); return T_RIGHT; }
"endfold"                { linebuf.append(yytext); return T_ENDFOLD; }

"%"                      { linebuf.append(yytext); return REM; }
"^"                      { linebuf.append(yytext); return POW; }
"~"                      { linebuf.append(yytext); return TILDE; }
"+"                      { linebuf.append(yytext); return PLUS; }
"-"                      { linebuf.append(yytext); return MINUS; }
"*"                      { linebuf.append(yytext); return TIMES; }
"/"                      { linebuf.append(yytext); return DIVIDE; }
"="                      { linebuf.append(yytext); return EQ; }
"<"                      { linebuf.append(yytext); return LT; }
","                      { linebuf.append(yytext); return ','; }
":"                      { linebuf.append(yytext); return ':'; }
";"                      { linebuf.append(yytext); return ';'; }
"("                      { linebuf.append(yytext); return '('; }
")"                      { linebuf.append(yytext); return ')'; }
"{"                      { linebuf.append(yytext); return '{'; }
"}"                      { linebuf.append(yytext); return '}'; }
"["                      { linebuf.append(yytext); return '['; }
"]"                      { linebuf.append(yytext); return ']'; }

[0-9]+"."[0-9]+          { linebuf.append(yytext); yylval.dval = atof(yytext); return REAL_LIT; }
[0-9]+                   { linebuf.append(yytext); yylval.ival = atoi(yytext); return INT_LIT; }
\'[^\'\n]\'              { linebuf.append(yytext); yylval.cval = yytext[1]; return CHAR_LIT; }

[A-Za-z][A-Za-z0-9_]*    { linebuf.append(yytext); yylval.sval = strdup(yytext); return IDENT; }

.                        { linebuf.append(yytext); appendError(LEXICAL, std::string("Unrecognized '") + yytext + "'"); }

<<EOF>>                  { if (!linebuf.empty()) { appendSource(linebuf); linebuf.clear(); } return 0; }

%%