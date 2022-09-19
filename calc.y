%{
#include <stdio.h>

int yyerror(const char *s);
int yylex (void);

//#define YYERROR_VERBOSE 1
extern int yylineno;
%}

%define parse.error verbose

%token TOK_PRINT TOK_IDENT
%token TOK_INTEGER TOK_FLOAT
%token TOK_LITERAL
%start program

%%

program : stmts {}
        ;

stmts : stmt stmts
      | stmt
	  ;

stmt : atribuicao
     | TOK_PRINT aritmetica
     ;

atribuicao : TOK_IDENT '=' aritmetica
           ;

aritmetica : aritmetica '+' term
		   | aritmetica '-' term
           | term
		   ;

term : term '*' term2
     | term '/' term2
     | term2
	 ;

term2 : term2 '^' factor
      | factor
	  ;

factor : '(' aritmetica ')'
       | TOK_IDENT
	   | TOK_INTEGER
	   | TOK_FLOAT
	   ;


%%

int yyerror(const char *s) {
printf("Erro na linha %d: %s\n", yylineno, s);
	return 1;
}


