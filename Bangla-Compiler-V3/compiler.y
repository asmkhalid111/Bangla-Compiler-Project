%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

typedef struct {
    char name[32];
    int value;
} Variable;

Variable symtab[100];
int symcount = 0;

int get_var(const char* name) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i].name, name) == 0)
            return symtab[i].value;
    }
    printf("\033[1;31mError: Undefined variable %s\033[0m\n", name);
    return 0;
}

void set_var(const char* name, int value) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i].name, name) == 0) {
            symtab[i].value = value;
            return;
        }
    }
    strcpy(symtab[symcount].name, name);
    symtab[symcount].value = value;
    symcount++;
}
%}

%union {
    int num;
    char* str;
}

%token SET TO SHOW INPUT WHEN DO OTHERWISE DONE LOOP
%token <num> NUMBER
%token <str> STRING ID

%token PLUS MINUS MULTIPLY DIVIDE
%token LT GT EQ NEQ
%token SEMICOLON

%type <num> expr

%left PLUS MINUS
%left MULTIPLY DIVIDE
%left LT GT EQ NEQ

%%

program:
    program stmt
    | /* empty */
    ;

stmt:
      SET ID TO expr SEMICOLON          { set_var($2, $4); }
    | SET ID TO INPUT SEMICOLON         {
                                          int val;
                                          printf("\033[1;34mEnter value for %s: \033[0m", $2);
                                          scanf("%d", &val);
                                          set_var($2, val);
                                        }
    | SHOW expr SEMICOLON               { printf("\033[1;32m%d\033[0m\n", $2); }
    | SHOW STRING SEMICOLON             { printf("\033[1;36m%s\033[0m\n", $2); }
    | WHEN expr DO stmt OTHERWISE stmt DONE {
                                              if ($2) {
                                                  // Execute the true branch
                                              } else {
                                                  // Execute the false branch
                                              }
                                            }
    | LOOP expr DO stmt DONE             {
                                          while ($2) {
                                              // Run loop body
                                          }
                                        }
;

expr:
      expr PLUS expr             { $$ = $1 + $3; }
    | expr MINUS expr            { $$ = $1 - $3; }
    | expr MULTIPLY expr         { $$ = $1 * $3; }
    | expr DIVIDE expr           { $$ = $1 / $3; }
    | expr LT expr               { $$ = $1 < $3; }
    | expr GT expr               { $$ = $1 > $3; }
    | expr EQ expr               { $$ = $1 == $3; }
    | expr NEQ expr              { $$ = $1 != $3; }
    | NUMBER                     { $$ = $1; }
    | ID                         { $$ = get_var($1); }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "\033[1;31mParse error: %s\033[0m\n", s);
}

int main(int argc, char **argv) {
    printf("\033[1;33m---Welcome to Our Mini Compiler---\033[0m\n");
    printf("\033[1;35mType your code below (end with Ctrl+D):\033[0m\n");

    if (argc > 1) {
        extern FILE *yyin;
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error opening file");
            return 1;
        }
    }

    yyparse();
    return 0;
}
