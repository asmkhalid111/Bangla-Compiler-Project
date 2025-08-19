%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Platform-Specific Includes ---
// Only include windows.h when compiling on a Windows system
#ifdef _WIN32
#include <windows.h>
#endif

// Forward declarations for AST nodes and functions
struct Node;
int evaluate(struct Node* node);
void execute_statement(struct Node* node);

int yylex();
void yyerror(const char *s);

// --- Abstract Syntax Tree (AST) Node Definitions ---
typedef enum {
    NODE_TYPE_ASSIGN, NODE_TYPE_PRINT, NODE_TYPE_IF, NODE_TYPE_WHILE,
    NODE_TYPE_NUMBER, NODE_TYPE_ID, NODE_TYPE_STRING, NODE_TYPE_BINARY_OP,
    NODE_TYPE_STMT_LIST, NODE_TYPE_INPUT // New node type for input
} NodeType;

typedef struct Node {
    NodeType type;
    struct Node *left;  // General purpose left child/operand
    struct Node *right; // General purpose right child/operand
    char* value_str;    // For IDs and STRING literals
    int value_num;      // For NUMBER literals
} Node;

// --- AST Creation Functions ---
Node* create_node(NodeType type, Node* left, Node* right, const char* str_val, int num_val) {
    Node* node = (Node*)malloc(sizeof(Node));
    node->type = type;
    node->left = left;
    node->right = right;
    node->value_str = str_val ? strdup(str_val) : NULL;
    node->value_num = num_val;
    return node;
}

// --- Symbol Table (remains the same) ---
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
    exit(1); // Exit on error
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

// Renamed INPUT to GET_INPUT to avoid conflict with windows.h
%token LET PRINT GET_INPUT IF THEN ELSE ENDIF WHILE ENDWHILE EQUALS
%token <num> NUMBER
%token <str> STRING ID

%token PLUS MINUS MULTIPLY DIVIDE
%token LT GT EQ NEQ
%token SEMICOLON

%type <node> program stmt stmt_list expr

%left PLUS MINUS
%left MULTIPLY DIVIDE
%left LT GT EQ NEQ

%%

program:
    /* A program can be empty or a list of statements */
    stmt_list {
        execute_statement($1);
    }
    | /* empty */                 { $$ = NULL; }
    ;

stmt_list:
    /* A statement list is one statement, or a list followed by one statement */
    stmt                          { $$ = create_node(NODE_TYPE_STMT_LIST, $1, NULL, NULL, 0); }
    | stmt_list stmt              { $$ = create_node(NODE_TYPE_STMT_LIST, $1, $2, NULL, 0); }
    ;

stmt:
      LET ID EQUALS expr SEMICOLON        { $$ = create_node(NODE_TYPE_ASSIGN, $4, NULL, $2, 0); }
    | LET ID EQUALS GET_INPUT SEMICOLON   {
                                            // Create an ASSIGN node where the value is a special INPUT node
                                            Node* input_node = create_node(NODE_TYPE_INPUT, NULL, NULL, $2, 0);
                                            $$ = create_node(NODE_TYPE_ASSIGN, input_node, NULL, $2, 0);
                                          }
    | PRINT expr SEMICOLON                { $$ = create_node(NODE_TYPE_PRINT, $2, NULL, NULL, 0); }
    | PRINT STRING SEMICOLON              { $$ = create_node(NODE_TYPE_PRINT, NULL, NULL, $2, 0); }
    | IF expr THEN stmt_list ELSE stmt_list ENDIF SEMICOLON { $$ = create_node(NODE_TYPE_IF, $2, create_node(NODE_TYPE_STMT_LIST, $4, $6, NULL, 0), NULL, 0); }
    | WHILE expr THEN stmt_list ENDWHILE SEMICOLON { $$ = create_node(NODE_TYPE_WHILE, $2, $4, NULL, 0); }
    ;

expr:
      expr PLUS expr             { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "+", 0); }
    | expr MINUS expr            { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "-", 0); }
    | expr MULTIPLY expr         { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "*", 0); }
    | expr DIVIDE expr           { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "/", 0); }
    | expr LT expr               { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "<", 0); }
    | expr GT expr               { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, ">", 0); }
    | expr EQ expr               { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "==", 0); }
    | expr NEQ expr              { $$ = create_node(NODE_TYPE_BINARY_OP, $1, $3, "!=", 0); }
    | NUMBER                     { $$ = create_node(NODE_TYPE_NUMBER, NULL, NULL, NULL, $1); }
    | ID                         { $$ = create_node(NODE_TYPE_ID, NULL, NULL, $1, 0); }
    ;

%%

// --- AST Traversal and Execution ---

int evaluate(Node* node) {
    if (!node) return 0;

    switch(node->type) {
        case NODE_TYPE_NUMBER: return node->value_num;
        case NODE_TYPE_ID:     return get_var(node->value_str);
        case NODE_TYPE_INPUT: { // Handle input during evaluation
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
    if (!node) return;

    switch(node->type) {
        case NODE_TYPE_STMT_LIST:
            execute_statement(node->left);
            execute_statement(node->right);
            break;
        case NODE_TYPE_ASSIGN:
            set_var(node->value_str, evaluate(node->left));
            break;
        case NODE_TYPE_PRINT:
            if (node->left) { // It's an expression
                printf("\033[1;32m%d\033[0m\n", evaluate(node->left));
            } else { // It's a string
                printf("\033[1;36m%s\033[0m\n", node->value_str);
            }
            break;
        case NODE_TYPE_IF:
            if (evaluate(node->left)) {
                execute_statement(node->right->left); // Execute the "then" block
            } else {
                execute_statement(node->right->right); // Execute the "else" block
            }
            break;
        case NODE_TYPE_WHILE:
            while (evaluate(node->left)) {
                execute_statement(node->right); // Execute the loop body
            }
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
    // Only set the console code page if compiling on Windows
    #ifdef _WIN32
    SetConsoleOutputCP(65001); // 65001 is the code page for UTF-8
    #endif

    printf("\033[1;33m---Welcome to Our Mini Compiler---\033[0m\n");
    printf("\033\033[0m\n");

    if (argc > 1) {
        extern FILE *yyin;
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error opening file");
            return 1;
        }
    }

    yyparse(); // This will now build the AST and then execute it
    return 0;
}
