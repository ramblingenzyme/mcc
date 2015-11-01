%{
	#include "parser.h"
	#include <stdio.h>
	#include <string.h>
	#include <ctype.h>

	extern FILE *yyin;
	extern int yylineno;
	extern char* yytext;

	char namespace[40];
	char *filename[3];
	FILE *source, *header;
	int indentlevel = 0;

	int yylex();
	int yyerror(const char *p) {
		printf("Error: %s\n", p);
		printf("Near %s\n", yytext);
		printf("Line: %d\n", yylineno);
	}

	int indent_level(FILE *output) {
		for (int i = 0; i < indentlevel; i++)
			fprintf(output, "\t");
	}	

%}

%union {
	int ival;
	char* str_val;
};

%token <ival> START END STARTFILE ENDFILE
%token <ival> STARTMAIN ENDMAIN CLASS ENDCLASS
%token <ival> PUBLIC PRIVATE INCLUDE NAMESPACES
%token <ival> DATA FUNCTION 

%token <ival> LPAR RPAR COMMA
%token <str_val> IDENTIFIER STDHEADER USRHEADER QSTRING
%token <str_val> FUNCNAME

%%

program: START files END;

files:
	files file
	| file;

file: STARTFILE IDENTIFIER 				{
												for (int i = 0; i < 3; i++)
													filename[i] = strdup($2);

												strcat(filename[0], ".h");
												header = fopen(filename[0], "w");

												strcat(filename[1], ".cpp");
												source = fopen(filename[1], "w");

												for (int i = 0; i < strlen(filename[2]); i++)
													filename[2][i] = toupper(filename[2][i]);

												strcat(filename[2], "_H");
												fprintf(header, "#ifndef %s\n#define %s\n", filename[2], filename[2]);
											}

	includes								{
		  										fprintf(source, "#include \"%s\"\n\n", filename[0]);
		  									}
	contents ENDFILE						{
												fprintf(header, "#endif");
												fclose(source);
												fclose(header);
											}
	| STARTMAIN								{
												header = fopen("main.cpp", "w");
												source = header;
											}
	includes contents ENDMAIN				{
												fclose(header);
											};

/* include headers */
includes: INCLUDE includelist;

includelist: 
	includelist COMMA include
	| include;

include:
	STDHEADER								{ fprintf(header, "#include %s\n", $1); }
	| QSTRING								{ fprintf(header, "#include %s\n", $1); };

contents:
	contents content
	| content
	
content: 
	/* class */
	function
	| data;

/* class: */
	/* CLASS IDENTIFIER						{ */
	/* 											namespace = $2; */
	/* 											strcat(namespace, "::"); */
	/* 											indentlevel += 1; */
	/* 										} */
	/* classmembers ENDCLASS					{ */
	/* 											strcpy(namespace, ""); */
	/* 											indentlevel -= 1; */
	/* 										} */

function: FUNCTION IDENTIFIER FUNCNAME 	{ 
												indent_level(header);
												fprintf(header, "%s %s;\n", $2, $3);
												indent_level(source);
												fprintf(source, "%s %s%s", $2, namespace, $3);
												fprintf(source, "{\n\n}");
											};

data: DATA QSTRING 						{
												indent_level(header);
												fprintf(header, "%s", $2);
											};

%%

/* Main and stuff here */

int main (int argc, char** argv) {
	FILE* input;
	if (argc > 1) {
		input = fopen(argv[1], "r");
	}
	
	if (input == NULL) {
		printf("Could not open %s\n", argv[1]);
		return 0;
	}

	yyin = input;
	yyparse();

	return 0;
}
