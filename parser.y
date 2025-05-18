%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Forward declaration
struct Node;

// AST node definitions
typedef struct Node {
    char type[20];
    void* data;
} Node;

typedef struct AssignNode {
    char* id;
    Node* expr;
} AssignNode;

typedef struct PrintNode {
    Node* expr;
} PrintNode;

typedef struct NumberNode {
    int value;
} NumberNode;

typedef struct IdNode {
    char* id;
} IdNode;

typedef struct BinaryOpNode {
    char* op;
    Node* left;
    Node* right;
} BinaryOpNode;

// Global AST storage
#define MAX_NODES 100
Node* ast[MAX_NODES];
int ast_size = 0;

// Simple symbol table for variables
#define MAX_VARS 100
struct Var {
    char* id;
    int value;
};
struct Var symbol_table[MAX_VARS];
int var_count = 0;

// Look up a variable’s value
int lookup_var(char* id) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(symbol_table[i].id, id) == 0) {
            return symbol_table[i].value;
        }
    }
    fprintf(stderr, "Error: Undefined variable %s\n", id);
    exit(1);
}

// Store a variable’s value
void store_var(char* id, int value) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(symbol_table[i].id, id) == 0) {  // Removed extra )
            symbol_table[i].value = value;
            return;
        }
    }
    symbol_table[var_count].id = strdup(id);
    symbol_table[var_count].value = value;
    var_count++;
}

// AST creation functions
Node* new_node(const char* type, void* data) {
    Node* node = (Node*)malloc(sizeof(Node));
    strncpy(node->type, type, 20);
    node->data = data;
    return node;
}

Node* new_assign_node(char* id, Node* expr) {
    AssignNode* data = (AssignNode*)malloc(sizeof(AssignNode));
    data->id = id;
    data->expr = expr;
    return new_node("Assign", data);
}

Node* new_print_node(Node* expr) {
    PrintNode* data = (PrintNode*)malloc(sizeof(PrintNode));
    data->expr = expr;
    return new_node("Print", data);
}

Node* new_number_node(int value) {
    NumberNode* data = (NumberNode*)malloc(sizeof(NumberNode));
    data->value = value;
    return new_node("Number", data);
}

Node* new_id_node(char* id) {
    IdNode* data = (IdNode*)malloc(sizeof(IdNode));
    data->id = id;
    return new_node("Id", data);
}

Node* new_binary_op_node(char* op, Node* left, Node* right) {
    BinaryOpNode* data = (BinaryOpNode*)malloc(sizeof(BinaryOpNode));
    data->op = op;
    data->left = left;
    data->right = right;
    return new_node("BinaryOp", data);
}

// Evaluate an expression node
int evaluate(Node* node) {
    if (strcmp(node->type, "Number") == 0) {
        NumberNode* data = (NumberNode*)node->data;
        return data->value;
    } else if (strcmp(node->type, "Id") == 0) {
        IdNode* data = (IdNode*)node->data;
        return lookup_var(data->id);
    } else if (strcmp(node->type, "BinaryOp") == 0) {
        BinaryOpNode* data = (BinaryOpNode*)node->data;
        int left = evaluate(data->left);
        int right = evaluate(data->right);
        if (strcmp(data->op, "+") == 0) return left + right;
        if (strcmp(data->op, "-") == 0) return left - right;
    }
    fprintf(stderr, "Error: Unknown node type %s\n", node->type);
    exit(1);
}

// Traverse the AST and execute statements
void traverse_ast() {
    for (int i = 0; i < ast_size; i++) {
        Node* node = ast[i];
        if (strcmp(node->type, "Assign") == 0) {
            AssignNode* data = (AssignNode*)node->data;
            int value = evaluate(data->expr);
            store_var(data->id, value);
        } else if (strcmp(node->type, "Print") == 0) {
            PrintNode* data = (PrintNode*)node->data;
            int value = evaluate(data->expr);
            printf("%d\n", value);
        }
    }
}

extern int yylex();
void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}
%}

%union {
    int num;
    char* str;
    struct Node* node;
}

%token <str> ID
%token <num> NUMBER
%token LET PRINT EQUALS SEMICOLON LPAREN RPAREN PLUS MINUS

%type <node> program statement expr

%left PLUS MINUS

%start program

%%

program: statement_list { }
       ;

statement_list: statement { ast[ast_size++] = $1; }
              | statement_list statement { ast[ast_size++] = $2; }
              ;

statement: LET ID EQUALS expr SEMICOLON { $$ = new_assign_node($2, $4); }
         | PRINT LPAREN expr RPAREN SEMICOLON { $$ = new_print_node($3); }
         ;

expr: NUMBER { $$ = new_number_node($1); }
    | ID { $$ = new_id_node($1); }
    | expr PLUS expr { $$ = new_binary_op_node("+", $1, $3); }
    | expr MINUS expr { $$ = new_binary_op_node("-", $1, $3); }
    ;

%%

int main() {
    yyparse();
    printf("Parsed %d statements\n", ast_size);
    traverse_ast();  // Execute the AST
    return 0;
}