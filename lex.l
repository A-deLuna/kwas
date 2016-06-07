%{
#include "grammar.tab.h"
%}
%option yylineno
%%

(mov|MOV) { return MOV; }

(ban|BAN) { return BAN; }

(sum|SUM) { return SUM; }

(res|RES) { return RES; }

(mul|MUL) { return MUL; }

(div|DIV) { return DIV; }

(and|AND) { return AND; }

(or|OR) { return OR; }

(not|NOT) { return NOT; }

(shr|SHR) { return SHR; }

(shl|SHL) { return SHL; }

(nop|NOP) { return NOP; }

(cmp|CMP) { return CMP; }

(slt|SLT) { return SLT; }

(sma|SMA) { return SMA; }

(sme|SME) { return SME; }

(sic|SIC) { return SIC; }

(inc|INC) { return INC; }

(dec|DEC) { return DEC; }

(proc|PROC) { return PROC; }

(ret|RET) { return RET; }

[:,\n] {return *yytext;}

@[rR][0-9]+ {yylval.ival = atoi(yytext+2); return INDIRECT_REGISTER;}

[rR][0-9]+ { yylval.ival = atoi(yytext+1); return REGISTER; }

#[0-9a-fA-F]+ { yylval.ival = (int)strtol(yytext+1, NULL, 16); return NUMBER; }

@[0-9a-fA-F]+ { yylval.ival = (int)strtol(yytext+1, NULL, 16); return ADDRESS; }

[a-zA-F][a-zA-F0-9]* { yylval.sval = strdup(yytext);  return STRING; }

.
