%option noyywrap

%{
#include "parser.h"
#include <stdio.h>
#include <string.h>
%}

WHITE [ \t]+
NAME [a-zA-Z]+
STDHEADER <[a-zA-Z\.]+>
FUNCNAME [a-zA-Z_]+\([\w,\* ]\)
QSTRING  \"([^"]*)\" 

%%
PROGRAM		return START;
END			return END;

FILE		return STARTFILE;
ENDFILE		return ENDFILE;

MAIN		return STARTMAIN;
ENDMAIN		return ENDMAIN;

include		return INCLUDE;

class		return CLASS;
endclass	return ENDCLASS;

"public:"	return PUBLIC;
"private:"	return PRIVATE;

function	return FUNCTION;
data		return DATA;

","			return COMMA;
"("			return LPAR;
")"			return RPAR;


{STDHEADER}	{ yylval.str_val = strdup(yytext); return STDHEADER; }
{FUNCNAME}	{ yylval.str_val = strdup(yytext); return FUNCNAME;  }
{QSTRING}	{ yylval.str_val = strdup(yytext); return QSTRING;   }
{NAME}		{ yylval.str_val = strdup(yytext); return IDENTIFIER;}
{WHITE}		;
\n			{ yylineno++; }
.			{ printf("Unrecognized token%s!\n", yytext); exit(1); }
%%

