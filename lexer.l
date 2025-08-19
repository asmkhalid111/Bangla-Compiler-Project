%{
#include "compiler.tab.h"
#include <string.h>
#include <stdlib.h>

// Helper function to convert a string of Bangla numerals to an integer
int bangla_to_int(const char* str) {
    // First, check if the string contains standard English digits.
    if (str[0] >= '0' && str[0] <= '9') {
        return atoi(str);
    }

    // Otherwise, process as a Bangla numeral string.
    int result = 0;
    // Each Bangla numeral is 3 bytes long in UTF-8.
    for (int i = 0; str[i] != '\0'; i += 3) {
        // We only need to check the last byte of the 3-byte sequence,
        // as they are sequential from 0xA6 (for ০) to 0xAF (for ৯).
        unsigned char last_byte = str[i+2];
        if (last_byte >= 0xA6 && last_byte <= 0xAF) {
            result = result * 10 + (last_byte - 0xA6);
        }
    }
    return result;
}

%}

%option noyywrap

%%

[ \t\r\n]+                        { /* ignore whitespace, including carriage return */ }
"//".* { /* ignore comments */ }

"let"|"রাখো"                      { return LET; }
"print"|"দেখাও"                   { return PRINT; }
"input"|"ইনপুট"                   { return GET_INPUT; }
"if"|"যদি"                        { return IF; }
"elseif"|"নতুবা যদি"             { return ELSEIF; }
"else"|"নতুবা"                    { return ELSE; }
"while"|"যতক্ষণ"                  { return WHILE; }
"break"|"বিরতি"                   { return BREAK; } // New break token

\"[^\"]*\"                        { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = '\0'; return STRING; }
[0-9]+|[০-৯]+                     { yylval.num = bangla_to_int(yytext); return NUMBER; }
[a-zA-Zঅ-৺_][a-zA-Z0-9অ-৺_]* { yylval.str = strdup(yytext); return ID; }


"="                               { return EQUALS; }
"{"                               { return LBRACE; } // Left Brace
"}"                               { return RBRACE; } // Right Brace
"+"                               { return PLUS; }
"-"                               { return MINUS; }
"*"                               { return MULTIPLY; }
"/"                               { return DIVIDE; }
"<"                               { return LT; }
">"                               { return GT; }
"=="                              { return EQ; }
"!="                              { return NEQ; }
";"                               { return SEMICOLON; }

.                                 { return yytext[0]; }

%%
