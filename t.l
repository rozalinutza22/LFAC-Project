%{
#include <stdio.h>
#include "t.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool" {yylval.string = strdup(yytext);return TYPE;}
"begin_progr" {return BGIN;}
"end_progr" {return END;}
"true"|"false" {yylval.bool_val = strdup(yytext); return BOOL;}
"constant" {return CONST;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"class" {return CLASS;}
"public"|"private"|"protected" {yylval.string = strdup(yytext); return CLASS_SPECIFIERS;}
"<" {return LESS;}
"==" {return EQ;}
"!=" {return NEQ;}
"<=" {return LESSEQ;}
">" {return GR;}
">=" {return GREQ;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return ASTERISK;}
"/" {return DIV;}
"%" {return MOD;}
"&" {return AND;}
"|" {return OR;}
"!" {return NEG;}
"return" {return RETURN;}
"Eval" {return Eval;}
"TypeOf" {return TypeOf;}
\'.\' { yylval.charval = yytext[1]; return CHR;}
[a-zA-Z][a-zA-Z0-9]* {yylval.string = strdup(yytext); return ID;}
[0-9]+"."[0-9]+ {char* temp = strdup(yytext); yylval.float_val = atof(temp); return FLT;}
":=" {return ASSIGN;}
0|[1-9]+ {yylval.val = atoi(yytext); return NR;}
"{" {return LEFT_BRACKET;}
"}" {return RIGHT_BRACKET;}
'[a-zA-Z0-9]*' {yylval.string = strdup(yytext); return TEXT;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
