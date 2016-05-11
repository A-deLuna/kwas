%{
#include <stdio.h>
extern int yylex(void);
void yyerror (char const *);
%}

%union {
	int ival;
	char *sval;
}

%token <ival> MOV
%token <sval> LABEL
%token <ival> REGISTER
%token <ival> NUMBER
%token <ival> ADDRESS

%type <ival> register
%type <ival> number
%type <ival> address

%%

asmfile : lines;

lines   : %empty
	| lines line '\n'
	;

line    : label
	| label command
	;

label   : %empty
	| LABEL
	;

command : mov
        ;

mov	: MOV register register {printf("0x0%x\n", (($2 << 2) |  $3));}
	| MOV register number {printf("0x0%x%02x\n", (($2 << 2) |  3), $3);}
	| MOV register address {printf("0x1%x%02x\n", (($2 << 2) |  3), $3);}
	| MOV address register {printf("0x1%x%02x\n", ((12) |  $3), $2);}
        ;

register: REGISTER { if($1 < -1 || $1 > 2) yyerror("invalid register number");}
	;

number : NUMBER {if($1 > 255) yyerror("number must be 8 bit");}
       ;

address : ADDRESS {if($1 > 255) yyerror("address must be 8 bit");}
	;
%%

void yyerror (char const *s) {
  fprintf(stderr, "%s\n", s);
}

int main() {
  yyparse();
}

