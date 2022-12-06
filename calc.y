%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "header.h"

int yyerror(const char *s);
int yylex (void);

//#define YYERROR_VERBOSE 1
extern int yylineno;


	

%}

%union {
	token_args args;
	struct noh *no;
}

%define parse.error verbose

%token TOK_PRINT	
%token <args> TOK_IDENT TOK_INTEGER TOK_FLOAT
%token TOK_LITERAL
%token TOKEN_OR TOKEN_AND TOKEN_IF TOKEN_IF_ELSE TOKEN_WHILE 
%token TOKEN_EQUAL TOKEN_GREATER_THAN_OR_EQUAL TOKEN_LESS_THAN_OR_EQUAL TOKEN_NOT_EQUAL

%type <no> program stmts stmt atribuicao aritmetica
%type <no> term term2 factor
%type <no> if while logicalFactor logicalExpression logicalExpressionTerm

%start program

%%



program : stmts {
          noh *program = create_noh (PROGRAM, 1);
          program -> children[0] = $1;

          // Chamada da árvore abstrata
      	print(program);
      	debug();
          // Chamada da verificação semântica
          visitor_leaf_first(&program, check_declared_vars);
          visitor_leaf_first(&program, code_generate);
          // Chamada da geração de código
        }
        ;

stmts : stmts stmt {
          noh *origin = $1;

          origin = realloc (origin, sizeof(noh) + sizeof(noh*) * origin->childcount);
          
          origin->children[origin->childcount] = $2;
          
          origin->childcount++;

          $$ = origin;
      }  
      | stmt {
          $$ = create_noh (STMT, 1);
          $$ -> children[0] = $1;
      }
      ;
      
stmt : atribuicao {
          $$ = $1;
     }
     | TOK_PRINT aritmetica { 
          $$ = create_noh (PRINT, 1);
          $$ -> children[0] = $2;
     }
     // | //Declaração função
     // | //Declaração laços
     | while {
          $$ = $1;
     }
     | if {
          $$ = $1;
     }
     ;

atribuicao : TOK_IDENT '=' aritmetica { 
               $$ = create_noh (ASSIGN, 2);
               $$ -> children[0] = create_noh (IDENT, 0);
               $$ -> children[0] -> name = $1.ident;
               $$ -> children[1] = $3;
           }
           ;

if: TOKEN_IF '(' logicalExpression ')' '{' stmt '}' {
               $$ = create_noh (CONDITIONAL, 2);
               $$ -> children[0] = $3;
               $$ -> children[1] = $6;
          }
          |
          TOKEN_IF '(' logicalExpression ')' '{' stmt '}' TOKEN_IF_ELSE '{' stmt '}' {
               $$ = create_noh (CONDITIONAL, 3);
               $$ -> children[0] = $3;
               $$ -> children[1] = $6;
               $$ -> children[2] = $10;
          }
          ;

while: TOKEN_WHILE '(' logicalExpression ')' '{' stmt '}' {
               $$ = create_noh (LOOP, 2);
               $$ -> children[0] = $3;
               $$ -> children[1] = $6;
          }
          ;

logicalExpression: logicalExpression TOKEN_OR logicalExpressionTerm {
                    $$ = create_noh (LOGICAL_OR, 2);
                    $$ -> children[0] = $1;
                    $$ -> children[1] = $3;
                 }
                 | logicalExpressionTerm {
                    $$ = $1;
                 }
                 ;

logicalExpressionTerm: logicalExpressionTerm TOKEN_AND logicalFactor {
                    $$ = create_noh (LOGICAL_AND, 2);
                    $$ -> children[0] = $1;
                    $$ -> children[1] = $3;
                 }
                 | logicalFactor {
                    $$ = $1;
                 }
                 ;

logicalFactor: '(' logicalExpression ')' {
               $$ = $2;
             }
             | aritmetica '>' aritmetica {
               $$ = create_noh (GREATER_THAN, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
             }
             | aritmetica '<' aritmetica {
               $$ = create_noh (LESS_THAN, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
             }
             | aritmetica TOKEN_EQUAL aritmetica {
               $$ = create_noh (EQUAL, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
             }
             | aritmetica TOKEN_NOT_EQUAL aritmetica {
               $$ = create_noh (NOT_EQUAL, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
             }
             | aritmetica TOKEN_LESS_THAN_OR_EQUAL aritmetica {
               $$ = create_noh (LESS_THAN_OR_EQUAL, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
             }
             | aritmetica TOKEN_GREATER_THAN_OR_EQUAL aritmetica {
               $$ = create_noh (GREATER_THAN_OR_EQUAL, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
             }
             ;

aritmetica : aritmetica '+' term { 
               $$ = create_noh (SUM, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
           }    
           | aritmetica '-' term { 
               $$ = create_noh (MINUS, 2);
               $$ -> children[0] = $1;
               $$ -> children[1] = $3;
           }    
           | term {
               $$ = $1;
               
           }
           ;

term : term '*' term2 { 
          $$ = create_noh (MULTI, 2);
          $$ -> children[0] = $1;
          $$ -> children[1] = $3;
     }
     | term '/' term2 { 
          $$ = create_noh (DIVIDE, 2);
          $$ -> children[0] = $1;
          $$ -> children[1] = $3;
     } 
     | term2 {
          $$ = $1;
     }
     ;

term2 : term2 '^' factor { 
          $$ = create_noh (POW, 2);
          $$ -> children[0] = $1;
          $$ -> children[1] = $3;
     }
     | factor {
          $$ = $1;
     }
     ;

factor : '(' aritmetica ')' { 
          $$ = $2;
       }
       | TOK_IDENT {
          $$ = create_noh (IDENT, 0);
          $$ -> name = $1.ident;
          if (!simbolo_existe($1.ident))
          	simbolo_novo($1.ident, TOK_IDENT);
       }
       | TOK_INTEGER  {
          $$ = create_noh (INTEGER, 0);
          $$ -> intv = $1.intv;
       }
       | TOK_FLOAT {
          $$ = create_noh (FLOAT, 0);
          $$ -> dblv = $1.dblv;
       };

%%

/*simbolo *simbolo_novo(char *nome, int token) {
	tsimbolos[simbolo_qtd].nome = nome;
	tsimbolos[simbolo_qtd].token = token;
	tsimbolos[simbolo_qtd].exists = false;
	simbolo *result = &tsimbolos[simbolo_qtd];
	simbolo_qtd++;
	return result;
}

bool simbolo_existe(char *nome) {
	// busca linear, não eficiente
	for(int i = 0; i < simbolo_qtd; i++) {
		if (strcmp(tsimbolos[i].nome, nome) == 0)
			return true;
	}
	return false;
}

void debug() {
	printf("Simbolos:\n");
	for(int i = 0; i < simbolo_qtd; i++) {
		printf("\t%s\n", tsimbolos[i].nome);
	}
}
*/
int yyerror(const char *s) {
printf("Erro na linha %d: %s\n", yylineno, s);
	return 1;
}


