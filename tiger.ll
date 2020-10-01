%option noyywrap
%option c++

%{
#include <iostream>
#include <string>
#include <sstream>
#include "tokens.h"
#include "ErrorMsg.h"

using std::string;
using std::stringstream;

ErrorMsg			errormsg;	//error handler

int		comment_depth = 0;	// depth of the nested comment
string	value = "";			// the value of current string

int			beginLine=-1;	//beginning line no of a string or comment
int			beginCol=-1;	//beginning column no of a string or comment

int		linenum = 1;		//beginning line no of the current matched token
int		colnum = 1;			//beginning column no of the current matched token
int		tokenCol = 1;		//column no after the current matched token

//the following defines actions that will be taken automatically after 
//each token match. It is used to update colnum and tokenCol automatically.
#define YY_USER_ACTION {colnum = tokenCol; tokenCol=colnum+yyleng;}

int string2int(string);			//convert a string to integer value
void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token
%}

ALPHA		[A-Za-z]
DIGIT		[0-9]
INT			[0-9]+
IDENTIFIER	{ALPHA}(({ALPHA}|{DIGIT}|"_")*)


%x COMMENT
%x STRING_COND

%%
" "				{}
\t				{}
\b				{}
\n				{newline(); }
","  {return COMMA;}
":"  {return COLON;}
";"  {return SEMICOLON;}
"("  {return LPAREN;}
")"  {return RPAREN;}
"["  {return LBRACK;}
"]"  {return RBRACK;}
"{"  {return LBRACE;}
"}"  {return RBRACE;}
"."  {return DOT;}
"+"  {return PLUS;}
"-"  {return MINUS;}
"*"  {return TIMES;}
"/"  {return DIVIDE;}
"="  {return EQ;}
"<>" {return NEQ;}
"<"  {return LT;}
"<=" {return LE;}
">"  {return GT;}
">=" {return GE;}
"&"  {return AND;}
"|"  {return OR;}
":=" {return ASSIGN;}
while {return WHILE;}
for {return FOR;}
to {return TO;}
break {return BREAK;}
let {return LET;}
in {return IN;}
end {return END;}
function {return FUNCTION;}
var {return VAR;}
type {return TYPE;}
array {return ARRAY;}
if {return IF;}
then {return THEN;}
else {return ELSE;}
do {return DO;}
of {return OF;}
nil {return NIL;} 

\" {beginLine = linenum; beginCol = colnum; value=""; BEGIN(STRING_COND);}
<STRING_COND>\\\" {value = value+"\"";}
<STRING_COND>\" {yylval.sval = new string(value); value ="";BEGIN(INITIAL); return STRING; }
<STRING_COND>\\n {value = value+"\n";}
<STRING_COND>\\t {value = value+"\t";}
<STRING_COND>"\\\\" {value = value+"\\";}
<STRING_COND>\\. {error(linenum, colnum, string(YYText()) + " illegal token");value= value+YYText();}
<STRING_COND><<EOF>>	{	/* unclosed string */ error(beginLine, beginCol, "unclosed string");yyterminate();}
<STRING_COND>\n {newline(); error(beginLine, beginCol, "unclosed string");yylval.sval = new string(value); value ="";BEGIN(INITIAL); return STRING;}
<STRING_COND>. {value = value+YYText();}


"/*"			{comment_depth ++;beginLine = linenum; beginCol = colnum; BEGIN(COMMENT);}
<COMMENT>"/*"	{comment_depth ++;}
<COMMENT>[^*/\n]*	{}
<COMMENT>"/"+[^/*\n]*  {}
<COMMENT>"*"+[^*/\n]*	{}
<COMMENT>\n		{newline();}

<COMMENT>"*"+"/"	{
						comment_depth --;
						if ( comment_depth == 0 )
						{
							BEGIN(INITIAL);	
						}
					}
<COMMENT><<EOF>>	{	/* unclosed comments */
						error(beginLine, beginCol, "unclosed comments");
						yyterminate();
					}



{IDENTIFIER} 	{ value = YYText(); yylval.sval = new string(value); return ID; }
{INT}		 	{ yylval.ival = string2int(YYText()); return INT; }

<<EOF>>			{	yyterminate(); }
.				{	error(linenum, colnum, string(YYText()) + " illegal token");}

%%

int string2int( string val )
{
	stringstream	ss(val);
	int				retval;

	ss >> retval;

	return retval;
}

void newline()
{
	linenum ++;
	colnum = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}
