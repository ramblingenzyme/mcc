%option noyywrap

%{
#include "parser.h"
#include <stdio.h>
#include <string.h>
%}

WHITE [ \t]+
NAME [a-z]+
STDHEADER <[a-z\.]+>
USRHEADER \"[a-z\.]+\"

%%
PROGRAM		return START;
END			return END;

FILE		return STARTFILE;
ENDFILE		return ENDFILE;

MAIN		return STARTMAIN;
ENDMAIN		return ENDMAIN;

INCLUDE		return INCLUDE;
ENDINCLUDE	return ENDINCLUDE;

CLASS		return CLASS;
ENDCLASS	return ENDCLASS;

PUBLIC		return PUBLIC;
ENDPUBLIC	return ENDPUBLIC;
PRIVATE		return PRIVATE;
ENDPRIVATE	return ENDPRIVATE;

FUNCTION	return FUNCTION;
ENDFUNCTION	return ENDFUNCTION;
DATA		return DATA;

","			return COMMA;
"("			return LPAR;
")"			return RPAR;


{NAME}		{ yylval.str_val = strdup(yytext); return IDENTIFIER; }
{STDHEADER}	{ yylval.str_val = strdup(yytext); return STDHEADER; }
{USRHEADER}	{ yylval.str_val = strdup(yytext); return USRHEADER; }
{WHITE}		;
\n			{ yylineno++; }
.			{ printf("Unrecognized token%s!\n", yytext); exit(1); }
%%

