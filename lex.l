%{
#include "grammar.tab.h"
%}

%%

[a-z][a-z0-9]*: { yylval.sval = strdup(yytext);  return LABEL; }

mov { return MOV; }

ban { return BAN; }

sum { return SUM; }

res { return RES; }

mul { return MUL; }

div { return DIV; }

and { return AND; }

or { return OR; }

\n {return '\n';}

r[0-9]+ { yylval.ival = atoi(yytext+1); return REGISTER; }

#[0-9a-f]+ { yylval.ival = (int)strtol(yytext+1, NULL, 16); return NUMBER; }

@[0-9a-f]+ { yylval.ival = (int)strtol(yytext+1, NULL, 16); return ADDRESS; }

.
