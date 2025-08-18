%{
#include "compiler.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap

%%

[ \t\n]+               ; // ignore whitespace
"set"                 return SET;
"to"                  return TO;
"show"                return SHOW;
"input"               return INPUT;
"when"                return WHEN;
"do"                  return DO;
"otherwise"           return OTHERWISE;
"done"                return DONE;
"loop"                return LOOP;

\"[^\"]*\"            { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = '\0'; return STRING; }

[0-9]+                { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }

"+"                   return PLUS;
"-"                   return MINUS;
"*"                   return MULTIPLY;
"/"                   return DIVIDE;
"<"                   return LT;
">"                   return GT;
"=="                  return EQ;
"!="                  return NEQ;
";"                   return SEMICOLON;

.                     return yytext[0];

%%
