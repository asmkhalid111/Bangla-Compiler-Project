%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Platform-Specific Includes ---
#ifdef _WIN32
#include <windows.h>
#endif

// Forward declarations
struct Node;
int evaluate(struct Node* node);
void execute_statement(struct Node* node);
int yylex();
void yyerror(const char *s);

// --- Global flag for break statements ---
int break_flag = 0;

// --- AST Node Definitions ---
typedef enum {
    NODE_TYPE_ASSIGN, NODE_TYPE_PRINT, NODE_TYPE_IF, NODE_TYPE_WHILE,
    NODE_TYPE_NUMBER, NODE_TYPE_ID, NODE_TYPE_STRING, NODE_TYPE_BINARY_OP,
    NODE_TYPE_STMT_LIST, NODE_TYPE_INPUT, NODE_TYPE_BREAK
} NodeType;

typedef struct Node {
    NodeType type;
    struct Node *left;
    struct Node *right;
    char* value_str;
    int value_num;
} Node;

// --- AST Creation Functions ---
Node* create_node(NodeType type, Node* left, Node* right, const char* str_val, int num_val) {
    Node* node = (Node*)malloc(sizeof(Node));
    if (!node) { yyerror("out of memory"); exit(1); }
    node->type = type;
    node->left = left;
    node->right = right;
    node->value_str = str_val ? strdup(str_val) : NULL;
    node->value_num = num_val;
    return node;
}

// --- Symbol Table ---
typedef struct { char name[32]; int value; } Variable;
Variable symtab[100];
int symcount = 0;
int get_var(const char* name) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i].name, name) == 0) return symtab[i].value;
    }
    printf("\033[1;31mError: Undefined variable %s\033[0m\n", name);
    exit(1);
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
    struct Node* node;
}

// Tokens
%token LET PRINT GET_INPUT IF ELSEIF ELSE WHILE EQUALS LBRACE RBRACE BREAK
%token <num> NUMBER
%token <str> STRING ID
%token PLUS MINUS MULTIPLY DIVIDE
%token LT GT EQ NEQ
%token SEMICOLON

%type <node> program stmt stmt_list expr if_stmt

%left PLUS MINUS
%left MULTIPLY DIVIDE
%left LT GT EQ NEQ

%%

program:
    stmt_list { execute_statement($1); }
    | /* empty */ { $$ = NULL; }
    ;

stmt_list:
    stmt { $$ = create_node(NODE_TYPE_STMT_LIST, $1, NULL, NULL, 0); }
    | stmt_list stmt { $$ = create_node(NODE_TYPE_STMT_LIST, $1, $2, NULL, 0); }
    ;

stmt:
      LET ID EQUALS expr SEMICOLON { $$ = create_node(NODE_TYPE_ASSIGN, $4, NULL, $2, 0); }
    | LET ID EQUALS GET_INPUT SEMICOLON {
        Node* input_node = create_node(NODE_TYPE_INPUT, NULL, NULL, $2, 0);
        $$ = create_node(NODE_TYPE_ASSIGN, input_node, NULL, $2, 0);
      }
    | PRINT expr SEMICOLON { $$ = create_node(NODE_TYPE_PRINT, $2, NULL, NULL, 0); }
    | PRINT STRING SEMICOLON { $$ = create_node(NODE_TYPE_PRINT, NULL, NULL, $2, 0); }
    | if_stmt SEMICOLON { $$ = $1; } // An if_stmt followed by a semicolon is a valid statement
    | WHILE expr LBRACE stmt_list RBRACE SEMICOLON { $$ = create_node(NODE_TYPE_WHILE, $2, $4, NULL, 0); }
    | BREAK SEMICOLON { $$ = create_node(NODE_TYPE_BREAK, NULL, NULL, NULL, 0); }
    ;

// New, unambiguous grammar for IF statements (without the semicolon)
if_stmt:
      IF expr LBRACE stmt_list RBRACE { $$ = create_node(NODE_TYPE_IF, $2, create_node(NODE_TYPE_STMT_LIST, $4, NULL, NULL, 0), NULL, 0); }
    | IF expr LBRACE stmt_list RBRACE ELSE if_stmt { $$ = create_node(NODE_TYPE_IF, $2, create_node(NODE_TYPE_STMT_LIST, $4, $7, NULL, 0), NULL, 0); }
    | IF expr LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE { $$ = create_node(NODE_TYPE_IF, $2, create_node(NODE_TYPE_STMT_LIST, $4, $8, NULL, 0), NULL, 0); }
    ;


expr:
      expr PLUS expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "+", 0); }
    | expr MINUS expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "-", 0); }
    | expr MULTIPLY expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "*", 0); }
    | expr DIVIDE expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "/", 0); }
    | expr LT expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "<", 0); }
    | expr GT expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, ">", 0); }
    | expr EQ expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "==", 0); }
    | expr NEQ expr { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "!=", 0); }
    | NUMBER { $$ = create_node(NODE_TYPE_NUMBER, NULL, NULL, NULL, $1); }
    | ID { $$ = create_node(NODE_TYPE_ID, NULL, NULL, $1, 0); }
    ;

%%

// --- AST Traversal and Execution ---
int evaluate(Node* node) {
    if (!node) return 0;
    switch(node->type) {
        case NODE_TYPE_NUMBER: return node->value_num;
        case NODE_TYPE_ID: return get_var(node->value_str);
        case NODE_TYPE_INPUT: {
            int val;
            printf("\033[1;34mEnter value for %s: \033[0m", node->value_str);
            scanf("%d", &val);
            return val;
        }
        case NODE_TYPE_BINARY_OP: {
            int left = evaluate(node->left);
            int right = evaluate(node->right);
            if (strcmp(node->value_str, "+") == 0) return left + right;
            if (strcmp(node->value_str, "-") == 0) return left - right;
            if (strcmp(node->value_str, "*") == 0) return left * right;
            if (strcmp(node->value_str, "/") == 0) return left / right;
            if (strcmp(node->value_str, "<") == 0) return left < right;
            if (strcmp(node->value_str, ">") == 0) return left > right;
            if (strcmp(node->value_str, "==") == 0) return left == right;
            if (strcmp(node->value_str, "!=") == 0) return left != right;
        }
        default: printf("Error: Cannot evaluate node type %d\n", node->type); exit(1);
    }
    return 0;
}

void execute_statement(Node* node) {
    if (!node || break_flag) return;
    switch(node->type) {
        case NODE_TYPE_STMT_LIST:
            execute_statement(node->left);
            if (break_flag) return;
            execute_statement(node->right);
            break;
        case NODE_TYPE_ASSIGN:
            set_var(node->value_str, evaluate(node->left));
            break;
        case NODE_TYPE_PRINT:
            if (node->left) printf("\033[1;32m%d\033[0m\n", evaluate(node->left));
            else printf("\033[1;36m%s\033[0m\n", node->value_str);
            break;
        case NODE_TYPE_IF:
            if (evaluate(node->left)) {
                execute_statement(node->right->left);
            } else {
                execute_statement(node->right->right);
            }
            break;
        case NODE_TYPE_WHILE:
            while (evaluate(node->left)) {
                execute_statement(node->right);
                if (break_flag) {
                    break; // Exit the C while loop
                }
            }
            break_flag = 0; // Reset flag after loop finishes
            break;
        case NODE_TYPE_BREAK:
            break_flag = 1;
            break;
        default:
            printf("Error: Cannot execute node type %d\n", node->type);
            exit(1);
    }
}

// --- Main and Error Functions ---
void yyerror(const char *s) {
    fprintf(stderr, "\033[1;31mParse error: %s\033[0m\n", s);
}

int main(int argc, char **argv) {
    #ifdef _WIN32
    SetConsoleOutputCP(65001);
    #endif
    printf("\033[1;33m---Welcome to Our Mini Compiler---\033[0m\n");
    printf("\033[1;35mType your code below (end with Ctrl-D):\033[0m\n");
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
