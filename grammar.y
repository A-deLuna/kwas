%{
#include <stdio.h>
#include "assembler.h"
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
%token <ival> BAN
%token <ival> SUM
%token <ival> RES
%token <ival> MUL
%token <ival> DIV
%token <ival> AND
%token <ival> OR
%token <ival> NOT
%token <ival> SHR
%token <ival> SHL
%token <ival> NOP
%token <ival> CMP
%token <ival> SLT
%token <ival> SMA
%token <ival> SME
%token <ival> SIC
%token <ival> INC
%token <ival> DEC

%type <ival> register
%type <ival> number_8_bit
%type <ival> number_4_bit
%type <ival> address_8_bit
%type <ival> regreg_regnum8

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
        | ban
        | sum
        | res
        | mul
        | div
        | and
        | or
        | not
        | shr
        | shl
        | nop
        ;

mov     : MOV regreg_regnum8 {write(concat(0, $2));}
        | MOV register address_8_bit {printf("0x1%x%02x\n", (($2 << 2) |  3), $3);}
        | MOV address_8_bit register {printf("0x1%x%02x\n", ((12) |  $3), $2);}
        ;

ban     : BAN number_4_bit {printf("0x2%x\n", $2);}
        ;

sum     : SUM regreg_regnum8 { write(concat(3, $2));}
res     : RES regreg_regnum8 { write(concat(4, $2));}
mul     : MUL regreg_regnum8 { write(concat(5, $2));}
div     : DIV regreg_regnum8 { write(concat(6, $2));}
and     : AND regreg_regnum8 { write(concat(7, $2));}
or      : OR  regreg_regnum8 { write(concat(8, $2));}

not     : NOT register { write(concat(9, 0|$2));}
shr     : SHR register { write(concat(9, 4|$2));}
shl     : SHL register { write(concat(9, 8|$2));}

nop     : NOP {wb(0x9f);}

regreg_regnum8 : register register { $$ = regreg($1, $2);}
               | register number_8_bit { $$ = registers_number8(regreg($1, 3), $2);}
               ;



register : REGISTER { if($1 < -1 || $1 > 2) yyerror("invalid register number");}
         ;

number_8_bit : NUMBER {if($1 > 0xff) yyerror("number must be 8 bit");}
             ;

number_4_bit : NUMBER {if($1 > 0xf) yyerror("number must be 4 bit");}
             ;

address_8_bit : ADDRESS {if($1 > 0xff) yyerror("address must be 8 bit");}
              ;
%%

void yyerror (char const *s) {
  fprintf(stderr, "%s\n", s);
}

int main() {
  yyparse();
}

