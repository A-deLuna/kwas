all: flex bison compile

flex: lex.l
	flex lex.l
bison: grammar.y
	bison -d grammar.y

compile: lex.yy.c
	cc grammar.tab.c lex.yy.c -lfl -o asm
