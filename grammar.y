%{
#include <stdio.h>
#include "assembler.h"
extern int yylex(void);
extern FILE * yyin;
void yyerror (char const *);
extern int pass;
extern int yylineno;
extern char* yytext;
%}

%union {
  int ival;
  char *sval;
}

%token <ival> MOV
%token <sval> STRING
%token <ival> REGISTER
%token <ival> INDIRECT_REGISTER
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
%token <ival> PROC
%token <ival> RET

%type <ival> register
%type <ival> indirect_register
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
        | STRING ':' {save_label($1); }
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
        | cmp
        | sma
        | slt
        | sme
        | sic
        | inc
        | dec
        ;

mov     : MOV regreg_regnum8 {write(concat(0, $2));}
        | MOV register ',' address_8_bit {write(concat(1, registers_number8(regreg($2, 3), $4)));}
        | MOV address_8_bit ',' register {write(concat(1, registers_number8(regreg(3, $4), $2)));}
        | MOV register ',' indirect_register { write(concat(0xD, regreg($2, $4)));}
        | MOV indirect_register ',' register { write(concat(0xE, regreg($2, $4)));}
        ;

ban     : BAN number_4_bit {wb(0x20 | $2);}
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

inc     : INC register { write(concat(12, 8|$2));}
dec     : DEC register { write(concat(12, 12|$2));}

nop     : NOP {wb(0x9f);}

cmp     : CMP regreg_regnum8 { write(concat(0xa, $2));}

sma     : SMA STRING {wb(0xC0); if(pass == 1) wb(0xff); else wb(find_diff_label($2));}

sme     : SME STRING {wb(0xC1); if(pass == 1) wb(0xff); else wb(find_diff_label($2));}

sic     : SIC STRING {wb(0xC2); if(pass == 1) wb(0xff); else wb(find_diff_label($2));}

slt     : SLT STRING { if(pass == 1) write(0xBfff); else write((0xB000 | find_label($2)));} 

regreg_regnum8 : register ',' register { $$ = regreg($1, $3);}
               | register ',' number_8_bit {  $$ = registers_number8(regreg($1, 3), $3);}
               ;


indirect_register : INDIRECT_REGISTER { if($1 < -1 || $1 > 2) yyerror("invalid register number"); }
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
  fprintf(stderr, "%s at line %d last token %s \n", s ,yylineno, yytext);
}

int main(int argc, char **argv) {
  ++argv, --argc; 
  extern int pc;
  if(argc > 0) {
    yyin = fopen(argv[0], "r");
  }
  else {
    yyin = stdin;
  }
  pass = 1;
  pc = 0;
  printf(" before of first pass\n");
  yyparse();
  printf(" end of first pass\n");
  fclose(yyin);
  if(argc > 0) {
    yyin = fopen(argv[0], "r");
  }
  else {
    yyin = stdin;
  }
  pass = 2;
  pc = 0;
  yyparse();

  write_file();
}

