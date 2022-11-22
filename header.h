
#pragma once
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
// header.h

enum noh_type {PROGRAM,
	ASSIGN, SUM, MINUS, MULTI,
	DIVIDE, PRINT, POW,
	PAREN, STMT, INTEGER, FLOAT,
	IDENT, GENERIC, EQUAL,
  	NOT_EQUAL, GREATER_THAN, LESS_THAN,
  	GREATER_THAN_OR_EQUAL, LESS_THAN_OR_EQUAL, 
  	CONDITIONAL, LOGICAL_AND, LOGICAL_OR, LOOP};

static const char *noh_type_names[] = {
    "program", "=", "+", "-", "*", "/",
    "print", "^", "()", "stmt", "int",
    "float", "ident", "generic", "equal","not_equal",
    "greater_than", "less_than",
    "greater_than_or_equal", "less_than_or_equal",
    "conditional", "logical_and",
    "logical_or", "loop"
    };
    
typedef struct {
	int intv;
	double dblv;
	char *ident;
} token_args;

typedef struct {
	char *nome;
	int token;
	bool exists;
} simbolo;

static int error_count = 0;

static int simbolo_qtd = 0;

static simbolo tsimbolos[100];

simbolo *simbolo_novo(char *nome, int token);

bool simbolo_existe(char *nome);

void debug();
	    
struct noh {
	int id;
	enum noh_type type;
	int childcount;

	double dblv;
	int intv;
	
	char *name;
	
	

	struct noh *children[1];
};
typedef struct noh noh;


typedef void (*visitor_action)(noh **root, noh *no);	

void check_declared_vars(noh **root, noh *no);
void visitor_leaf_first(noh **root, visitor_action act);
void visitor_leaf_root(noh **root, visitor_action act);
void code_generate(noh **root, noh *no);
noh *create_noh(enum noh_type, int children);
void add_noh(noh noh_target, enum noh_type);

void print(noh *root);
void print_rec(FILE *f, noh *root);

