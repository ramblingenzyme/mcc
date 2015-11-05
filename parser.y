%{
	#include "parser.h"
	#include <stdio.h>
	#include <string.h>
	#include <ctype.h>

	extern FILE *yyin;
	extern int yylineno;
	extern char* yytext;

	char namespace[16];
	char filename[3][32], *buffer;
	FILE *source, *header;
	int indentlevel = 0;
	int in_class = 0;

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
%token <ival> PUBLIC PRIVATE INCLUDE NAMESPACES CONST 
%token <ival> DATA FUNCTION COMMA LPAR RPAR

%token <str_val> IDENTIFIER STDHEADER USRHEADER QSTRING

%%

program: START files END;

files:
	files file
	| file;

file: 
	STARTFILE IDENTIFIER 				{
												for (int i = 0; i < 3; i++)
													strcpy(filename[i], $2);

												strcat(filename[0], ".h");
												header = fopen(filename[0], "w");

												strcat(filename[1], ".cpp");
												source = fopen(filename[1], "w");

												for (int i = 0; i < strlen(filename[2]); i++)
													filename[2][i] = toupper(filename[2][i]);

												strcat(filename[2], "_H");
												fprintf(header, "#ifndef %s\n#define %s\n\n", filename[2], filename[2]);
											}

	includes								{
		  										fprintf(source, "#include \"%s\"\n\n", filename[0]);
		  										fprintf(header, "\n");
		  									}
	contents ENDFILE						{
												fprintf(header, "#endif\n");
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
includes:
	INCLUDE includelist;

includelist: 
	includelist COMMA include
	| include;

include: /* empty */
	| STDHEADER								{ fprintf(header, "#include %s\n", $1); }
	| QSTRING								{ fprintf(header, "#include %s\n", $1); };

contents: /* empty */
	| contents content
	| content
	
content: 
	class
	| function
	| data;

class:
	CLASS IDENTIFIER						{
												strcpy(namespace, $2);
												strcat(namespace, "::");
												indent_level(header);
												fprintf(header, "class %s {\n", $2);
												
												in_class = 1;
												indentlevel += 1;
												
											}
	 domain	classmembers { indentlevel -=1; } 
	 domain	classmembers { indentlevel -=1; } 
	 
	 ENDCLASS								{
												indentlevel -= 1;
												indent_level(header);
												fprintf(header, "};\n");
												strcpy(namespace, "");
											};

domain: /* empty */
	| PUBLIC 								{
												indent_level(header);
												fprintf(header, "public:\n");
												indentlevel += 1;
											}
	| PRIVATE 								{
												indent_level(header);
												fprintf(header, "private:\n");
												indentlevel += 1;
											}

classmembers: /* empty */
	| classmembers classmember
	| classmember;

classmember: 
	function
	| data;

function:
	FUNCTION CONST IDENTIFIER IDENTIFIER	{
												indent_level(header);

												fprintf(header, "const %s %s(", $3, $4);
												fprintf(source, "const %s %s%s(", $3, namespace, $4);
											}
	LPAR argumentslist RPAR					{ 
												fprintf(header, ");\n");

												fprintf(source, ") {\n\n}\n\n");
											}
	| FUNCTION IDENTIFIER IDENTIFIER		{
												indent_level(header);

												fprintf(header, "%s %s(", $2, $3);
												fprintf(source, "%s %s%s(", $2, namespace, $3);
											}
	LPAR argumentslist RPAR					{
												fprintf(header, ");\n");
												fprintf(source, ") {\n\n}\n\n");
											};

argumentslist: /* empty */
	| argumentslist COMMA						{
												fprintf(header, ", ");
												fprintf(source, ", ");
											}
	argument
	| argument;

argument:
	CONST IDENTIFIER IDENTIFIER				{
												fprintf(header, "const %s", $2);
												fprintf(source, "const %s %s", $2, $3);
											}
	| IDENTIFIER IDENTIFIER					{
												fprintf(header, "%s", $1);
												fprintf(source, "%s %s", $1, $2);
											};

data: 
	DATA IDENTIFIER IDENTIFIER				{
												if (in_class) {
													indent_level(header);
													fprintf(header, "%s %s;\n", $2, $3);
												} else { 
													fprintf(source, "%s %s;\n", $2, $3);
												}
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
