all: mcc

mcc: parser.c scanner.c
	gcc parser.c scanner.c -o mcc

parser.c: parser.y
	bison -d parser.y -o parser.c

scanner.c: parser.c scanner.lex
	flex -o scanner.c scanner.lex

clean:
	rm parser.c parser.h scanner.c
