%{
	#include "parser.h"
	#include <stdio.h>
	#include <string.h>

	extern FILE *yyin;
	extern int yylineno;
	extern char* yytext;

	char namespace[40];
	char *filename[2];
	FILE *source, *header;

	int yylex();
	int yyerror(const char *p) {
		printf("Error: %s\n", p);
		printf("Near %s\n", yytext);
	}
%}

%union {
	int ival;
	char* str_val;
};

%token <ival> START END STARTFILE ENDFILE CLASS ENDCLASS
%token <ival> STARTMAIN ENDMAIN
%token <ival> PUBLIC ENDPUBLIC PRIVATE ENDPRIVATE INCLUDE ENDINCLUDE
%token <ival> DATA ENDDATA FUNCTION ENDFUNCTION

%token <ival> LPAR RPAR COMMA SEMICOLON LBRAC RBRAC
%token <str_val> IDENTIFIER STDHEADER USRHEADER



%%

program: START files END;

files:
	files file
	| file;

file: STARTFILE IDENTIFIER					{
												filename[0] = strdup($2);
												filename[1] = strdup($2);
												strcat(filename[0], ".h");
												header = fopen(filename[0], "w");

												strcat(filename[1], ".cpp");
												source = fopen(filename[1], "w");
											}

	includes								{
		  										fprintf(source, "#include \"%s\"\n\n", filename[0]);
		  									}
	namespaces
	contents ENDFILE						{
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

includes: INCLUDE includelist;

includelist: 
	includelist COMMA header
	| header;

header:
	STDHEADER								{ fprintf(header, "#include %s\n", $1); }
	| USRHEADER								{ fprintf(header, "#include %s\n", $1); };

namespaces: NAMESPACES namespacelist;

namespacelist:
	namespacelist COMMA IDENTIFIER			{ fprintf(source, "using namespace %s;\n", $3); }
	| IDENTIFIER							{ fprintf(source, "using namespace %s;\n", $1); };

contents: 

/*classes:
	classes class
	| class;

class:
	CLASS IDENTIFIER						{ namespace = $2 }
	classmembers ENDCLASS;
*/

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
