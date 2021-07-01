%{
 
#include "simple.h"
unsigned int lineno=1;
bool error_lexical=false;
 
%}
 
%option noyywrap
 
nombre 0|[1-9][[:digit:]]*
variable_identificateur A|B|C|D|E


 
%%
 
{nombre} {
        sscanf(yytext, "%ld", &yylval.nombre);
        return TOK_NOMBRE;
}

"BEGIN"      {return TOK_BEGIN;}
 
"FIN."      {return TOK_FIN;}

"afficher"      {return TOK_AFFICHER;}
 
":="             {return TOK_AFFECT;}
 
"+"             {return TOK_UNION;}
 
"-"             {return TOK_DIFF;}
 
"*"             {return TOK_INTER;}
 
"("             {return TOK_PARG;}
 
")"             {return TOK_PARD;}

"{"             {return TOK_PG;}
 
"}"             {return TOK_PD;}
 
";"             {return TOK_FINSTR;}

","             {return TOK_VER;}
 
"\n"            {lineno++;}
 
{variable_identificateur} {
        yylval.texte = yytext;
        return TOK_VARB;
}
 

 
" "|"\t" {}
 
. {
        fprintf(stderr,"\tERREUR : Lexeme inconnu a la ligne %d. Il s'agit de %s et comporte %d lettre(s)\n",lineno,yytext,yyleng);
        error_lexical=true;
        return yytext[0];
}
 
%%