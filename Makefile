all: flex bison compile

flex: lex.l
	flex lex.l
bison: grammar.y
	bison -d grammar.y

compile: lex.yy.c grammar.tab.c assembler.c assembler.h
	cc grammar.tab.c lex.yy.c assembler.c -lfl -o asm 
