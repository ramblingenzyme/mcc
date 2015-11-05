%option noyywrap

%{
#include "parser.h"
#include <stdio.h>
#include <string.h>
%}

WHITE [ \t]+
NAME [a-zA-Z_\*:&]+
STDHEADER <[a-zA-Z\.]+>
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

const		return CONST;

function	return FUNCTION;
data		return DATA;


"("			return LPAR;
")"			return RPAR;
","			return COMMA;


{STDHEADER}	{ yylval.str_val = strdup(yytext); return STDHEADER; }
{QSTRING}	{ yylval.str_val = strdup(yytext); return QSTRING;   }
{NAME}		{ yylval.str_val = strdup(yytext); return IDENTIFIER;}
{WHITE}		;
\n			{ yylineno++; }
.			{ printf("Unrecognized token%s!\n", yytext); exit(1); }
%%

