
#pragma once
#include <stdio.h>
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

noh *create_noh(enum noh_type, int children);
void add_noh(noh noh_target, enum noh_type);

void print(noh *root);
void print_rec(FILE *f, noh *root);

