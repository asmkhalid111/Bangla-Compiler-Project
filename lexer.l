%{
#include <stdio.h>
#include "parser.tab.h"
%}

%option noyywrap
%option utf8

%%

"লেট"           { return LET; }
"প্রিন্ট"        { return PRINT; }
[অ-৺]+          { yylval.str = strdup(yytext); return ID; }
[০-৯]+          { yylval.num = atoi(yytext); return NUMBER; }
"="             { return EQUALS; }
";"             { return SEMICOLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
[ \t\n]         ; /* Ignore whitespace */
.               { fprintf(stderr, "Invalid character: %s\n", yytext); }

%%

int yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}