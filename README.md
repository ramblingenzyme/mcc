#mcc
Meta C/C++ compiler

This project provides a method of generating a C/C++ project's files by specifiying it's structure in a text file.
This is achieved through a combination of flex and bison, to create a scanner and parser for the text format.
Examples will be added eventually, as well as documentation. Hopefully.

#Dependencies
* flex/lex
* bison/yacc

#INSTALL/TESTING:
using `make all` will create a binary that can be used with the files in the test folder.
`mcc project.mcc` will generate the project specified in the file.

#TODO:
* Header guards | Done
* Classes
  * Namespaces
  * constructors/destructors
* Functions
  * better format for them in input files
* Structs?
* Enums?
