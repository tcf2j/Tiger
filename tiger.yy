
%debug
%verbose
%{
#include <iostream>
#include "ErrorMsg.h"
#include <FlexLexer.h>

int yylex(void);		/* function prototype */
void yyerror(char *s);	//called by the parser whenever an eror occurs

%}

%union {
	int		ival;	//integer value of INT token
	string* sval;	//pointer to name of IDENTIFIER or value of STRING	
					//I have to use pointers since C++ does not support 
					//string object as the union member
}

/* TOKENs and their associated data type */
%token <sval> ID STRING
%token <ival> INT

%token 
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK 
  LBRACE RBRACE DOT 
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF 
  BREAK NIL
  FUNCTION VAR TYPE 

/* add your own predence level of operators here */ 

%start program

%%

/* This is a skeleton grammar file, meant to illustrate what kind of
 * declarations are necessary above the %% mark.  Students are expected
 *  to replace the two dummy productions below with an actual grammar. 
 */
input	:
		|	input line	
		;
line	:	NEWLINE
		|	exp NEWLINE	{ count = 0; }
		|	error NEWLINE
		;
exp		:	STRING
		|	INT
		|	NIL
		|	lvalue
		|	exp AND exp
		|	exp OR exp
		| 	exp GE exp
		| 	exp LE exp
		| 	exp EQ exp
		| 	exp NEQ exp
		| 	exp GT exp
		| 	exp LT exp	
		| 	LPAREN exp RPAREN
		| 	lvalue ASSIGN exp
		| 	ID LPAREN exprlist RPAREN
		| 	LPAREN exprseq RPAREN

		| 	IF exp THEN exp
		| 	IF exp THEN exp ELSE exp
		| 	WHILE exp DO exp
		| 	FOR ID ASSIGN exp TO exp DO exp
		| 	BREAK
		| 	LET declarationlist IN exprseq END
		| 	error
		;

exprseq:	exp
		|	exprseq SEMICOLON exp
		;
exprlist:
		|	exp
		|	exprlist COMMA exp
		;
fieldlist:
		 |	ID EQ exp
		 | fieldlist COMMA ID EQ exp

lvalue	:	ID
		|	lvalue DOT ID
		;

declarationlist:	declaration
				|	declarationlist declaration
				|	error
				;
declaration :	typedeclaration
			|	variabledeclaration
			|	functiondeclaration
			;

typedeclaration:	TYPE typeid EQ type
type:	typeid
	|	typefields
	;
typefields:	
			|	typefield
			|	typefields COMMA typefield
			;
typefield:	ID COLON typeid
		;
typeid	:	INT
		|	STRING
		|	ID
		;
variabledeclaration	:	VAR ID ASSIGN exp
					|	VAR ID COLON typeid ASSIGN exp
					;

functiondeclaration:	FUNCTION ID LPAREN typefields RPAREN EQ exp
					|	FUNCTION ID LPAREN typefields RPAREN COLON typeid EQ exp
					;

input	:	exp
%%
extern yyFlexLexer	lexer;
int yylex(void)
{
	return lexer.yylex();
}

void yyerror(char *s)
{
	extern int	linenum;			//line no of current matched token
	extern int	colnum;
	extern void error(int, int, std::string);

	error(linenum, colnum, s);
}

