%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

// Dummy isatty for MinGW
int isatty(int fd) {
    return 0; // Always return 0 (not a terminal)
}

// Declare yyerror (defined in parser.y)
extern int yyerror(const char* s);
%}

%option noyywrap
%option nounistd

%%

"ধরি"           { printf("Token: LET\n"); return LET; }
"প্রিন্ট"        { printf("Token: PRINT\n"); return PRINT; }
[অ-৺]+|[a-zA-Z]+  { yylval.str = strdup(yytext); printf("Token: ID (%s)\n", yytext); return ID; }
[০-৯]+|[0-9]+   { yylval.num = atoi(yytext); printf("Token: NUMBER (%d)\n", yylval.num); return NUMBER; }
"="             { printf("Token: EQUALS\n"); return EQUALS; }
";"             { printf("Token: SEMICOLON\n"); return SEMICOLON; }
"("             { printf("Token: LPAREN\n"); return LPAREN; }
")"             { printf("Token: RPAREN\n"); return RPAREN; }
"+"             { printf("Token: PLUS\n"); return PLUS; }
"-"             { printf("Token: MINUS\n"); return MINUS; }
[ \t\n]         ; /* Ignore whitespace */
.               { fprintf(stderr, "Invalid character: %s\n", yytext); }

%%