
%{
	#include <stdio.h>
	#include "header.h"
	#include "calc.tab.h"
%}

%option yylineno

D	[0-9]
L	[a-zA-Z_]

%% 

[ \t\r\n]			{}
"print"				{ return TOK_PRINT; }
"PRINT"				{ return PRINT; }

"and"           { return TOKEN_AND; } /* Operadores lógicos */
"or"            { return TOKEN_OR;  } /* Operadores lógicos */


"if"            { return TOKEN_IF;  } /* Condicional */
"else"          { return TOKEN_IF_ELSE;  } /* Condicional */
"while"          { return TOKEN_WHILE;  } /* Condicional */

"=="						{ return TOKEN_EQUAL; } /* Operadores lógicos */
">"							{ return '>';  } /* Operadores lógicos */
"<"							{ return '<';  } /* Operadores lógicos */
">="						{ return TOKEN_GREATER_THAN_OR_EQUAL; } /* Operadores lógicos */
"<="						{ return TOKEN_LESS_THAN_OR_EQUAL; } /* Operadores lógicos */
"!="						{ return TOKEN_NOT_EQUAL; } /* Operadores lógicos */

"="					{ return '=';  }
"*"					{ return '*'; }
"/"					{ return '/'; }
"+"					{ return '+'; }
"-"					{ return '-'; }
"("					{ return '('; }
")"					{ return ')'; }
"^"					{ return '^'; }
"{"						  { return '{'; }
"}"						  { return '}'; }

{D}+				{ yylval.args.intv = atoi(yytext); return TOK_INTEGER; }
{D}+\.{D}+			{ yylval.args.dblv = atof(yytext); return TOK_FLOAT; }
{L}({L}|{D})*		{ yylval.args.ident = strndup(yytext, yyleng); return TOK_IDENT; }
 /* [a-zA-Z_][a-zA-Z0-9_]* {} */


 /* comentário */
.					{ printf("Invalid caracter: %c.\n", yytext[0]); }

%%

int yywrap() {
	return 1;
}

int main(int argc, char *argv[]) {
	
	if (argc <= 1) {
		printf("%s [file]\n", argv[0]);
		return 1;
	}

	FILE *f = fopen(argv[1], "r");
	yyin = f;
	yyparse();
	fclose(f);
	return 0;
}

