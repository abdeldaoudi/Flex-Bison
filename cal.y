%{
 
#include "simple.h"
#include <string.h>
bool error_syntaxical=false;
extern unsigned int lineno;
extern bool error_lexical;
 
%}
 
/* L'union dans Bison est utilisee pour typer nos tokens ainsi que nos non terminaux. Ici nous avons declare une union avec deux types : nombre de type int et texte de type pointeur de char (char*) */
 
%union {
        long nombre;
        char* texte;
}
 
/* Nous avons ici les operateurs, ils sont definis par leur ordre de priorite. Si je definis par exemple la multiplication en premier et l'addition apres, le + l'emportera alors sur le * dans le langage. Les parenthese sont prioritaires avec %right */
 
%left                   TOK_UNION        TOK_DIFF     /* +- */
%left                   TOK_INTER         TOK_DIV         /* /* */
%left                   TOK_VER
%right                  TOK_PARG        TOK_PARD        /* () */
%right                  TOK_PG        TOK_PD        /* {} */


 
/* Nous avons la liste de nos expressions (les non terminaux). Nous les typons tous en texte (pointeur vers une zone de char). */
 
%type<texte>            code
%type<texte>            BEGIN
%type<texte>            FIN
%type<texte>            instruction
%type<texte>            variable_identificateur
%type<texte>            variable_arithmetique
%type<texte>            affectation
%type<texte>            affichage
%type<texte>            expression_arithmetique
%type<texte>            expression_identificateur
%type<texte>            union
%type<texte>            diff
%type<texte>            inter
 
/* Nous avons la liste de nos tokens (les terminaux de notre grammaire) */
 
%token<texte>           TOK_NOMBRE
%token                  TOK_BEGIN        /* BEGIN */
%token                  TOK_FIN        /* FIN. */
%token                  TOK_AFFECT      /* := */
%token                  TOK_FINSTR      /* ; */
%token                  TOK_VER         /* , */
%token                  TOK_POINT         /* . */
%token                  TOK_AFFICHER    /* afficher */
%token                  TOK_SUPPR       /* supprimer */
%token<texte>           TOK_VARE        /* variable arithmetique */
%token<texte>           TOK_VARB        /* variable identificateur */
 
%%
 
/* Nous definissons toutes les regles grammaticales de chaque non terminal de notre langage. Par defaut on commence a definir l'axiome, c'est a dire ici le non terminal code. Si nous le definissons pas en premier nous devons le specifier en option dans Bison avec %start */
 
code:           %empty{}
                |
                code instruction{
                        printf("\033[92m\t\tResultat pour ligne %d: C'est une instruction valide !\n\n\n\n\033[0m",lineno);
                }
                |
                code error{
                        fprintf(stderr,"\033[91m\tERREUR : Erreur de syntaxe a la ligne %d.\n\033[0m",lineno);
                        error_syntaxical=true;
                };
 
instruction:    affectation{
                        printf("\t\tInstruction type Affectation\n");
                }
                |
                affichage{
                         printf("\t\tInstruction type Affichage\n");
                }
                |
                BEGIN{
                         printf("\t\tInstruction type BEGIN\n");
                }
                |
                FIN{
                        printf("\t\tInstruction type FIN\n");
                };
            
 
variable_identificateur: TOK_VARB{
                                printf("\033[33m\t\t\tVariable: \033[0m %s\n",$1);
                                $$=strdup($1);
                        };
                        
                        
variable_arithmetique:  TOK_VARE{
                                printf("\033[33m\t\t\tVariable %s\n\033[0m",$1);
                                $$=strdup($1);
                        };
                    
 
affectation:    variable_identificateur TOK_AFFECT expression_identificateur TOK_FINSTR{
                        /* $1 est la valeur du premier non terminal. Ici c'est la valeur du non terminal variable. $3 est la valeur du 2nd non terminal. */
                        printf("\t\tAffectation sur la variable %s\n",$1);
                }
                |
                variable_identificateur TOK_AFFECT expression_arithmetique TOK_FINSTR{
                        printf("\t\tAffectation sur l'identificateur %s\n",$1);
                };
                

affichage:      TOK_AFFICHER expression_identificateur TOK_FINSTR{
                        printf("\t\tAffichage de la valeur de l'expression %s\n",$2);
                };
                
BEGIN:          TOK_BEGIN  {
                        printf("\033[96m\t\tDemarrage avec BEGIN\033[0m\n");
                };
                
FIN:           TOK_FIN {
                        printf("\033[96m\t\tFermeture avec FIN\033[0m\n");
                };
                
                
 
expression_identificateur:       
                                variable_identificateur{
                                        $$=strdup($1);
                                }
                                |
                                union{
                                }
                                |
                                diff{
                                }
                                |
                                inter{
                                }
                                |
                                TOK_PARG expression_identificateur TOK_PARD{
                                        printf("\t\t\tC'est une expression identificateur entre parentheses\n");
                                        $$=strcat(strcat(strdup("("),strdup($2)),strdup(")"));
                                };
                            
 
expression_arithmetique:       TOK_NOMBRE{
                                        printf("\033[33m\t\t\tNombre :\033[0m %ld\n",$1);
                                        /* Comme le token TOK_NOMBRE est de type entier et que on a type expression_arithmetique comme du texte, il nous faut convertir la valeur en texte. */
                                        int length=snprintf(NULL,0,"%ld",$1);
                                        char* str=malloc(length+1);
                                        snprintf(str,length+1,"%ld",$1);
                                        $$=strdup(str);
                                        free(str);
                                }
                                |
                                variable_arithmetique{
                                        $$=strdup($1);
                                }
                                |
                                expression_arithmetique TOK_VER expression_arithmetique{
                                        $$=strcat(strcat(strdup($1),strdup(",")),strdup($3));
                                }
                                |
                                TOK_VER expression_arithmetique TOK_VER{
                                
                                        $$=strcat(strcat(strdup("{"),strdup($2)),strdup(","));
                                }
                                |
                                TOK_VER expression_arithmetique TOK_PD{
                
                                        $$=strcat(strcat(strdup(","),strdup($2)),strdup("}"));
                                }
                                |
                                TOK_PG expression_arithmetique TOK_PD{
                                       
                                        $$=strcat(strcat(strdup("{"),strdup($2)),strdup("}"));
                                };
                                
    
                               
 
union:  expression_identificateur TOK_UNION expression_identificateur{printf("\t\t\tunion\n");$$=strcat(strcat(strdup($1),strdup("+")),strdup($3));};
diff:   expression_identificateur TOK_DIFF expression_identificateur{printf("\t\t\tdifference\n");$$=strcat(strcat(strdup($1),strdup("-")),strdup($3));};
inter: expression_identificateur TOK_INTER expression_identificateur{printf("\t\t\tintersection\n");$$=strcat(strcat(strdup($1),strdup("*")),strdup($3));};
 
%%
 
/* Dans la fonction main on appelle bien la routine yyparse() qui sera genere par Bison. Cette routine appellera yylex() de notre analyseur lexical. */
 
int main(void){
  
        printf("\033[33m----------------------------------------------------------------------------------------\n\033[0m");
        printf("\033[33m------------------------Debut de l'analyse syntaxique :---------------------------------\n\033[0m");
        printf("\033[33m----------------------------------------------------------------------------------------\n\033[0m");
        
        yyparse();
    
        printf("\033[33m----------------------------------------------------------------------------------------\n\033[33m");
        printf("\033[33m--------------------------------Fin de l'analyse !--------------------------------------\n\033[0m");
        printf("\033[33m----------------------------------------------------------------------------------------\n\033[0m");
        printf("Resultat :\n");
        if(error_lexical){
                printf("\033[91m\t-- Echec : Certains lexemes ne font pas partie du lexique du langage ! --\n\033[0m");
                printf("\033[91m\t-- Echec a l'analyse lexicale --\n\033[0m");
        }
        else{
                printf("\033[92m\t-- Succes a l'analyse lexicale ! --\n\033[0m");
        }
        if(error_syntaxical){
                printf("\033[91m\t-- Echec : Certaines phrases sont syntaxiquement incorrectes ! --\n\033[0m");
                printf("\033[91m\t-- Echec : Certaines phrases sont syntaxiquement incorrectes ! --\n\033[0m");
                printf("\033[91m\t-- Echec a l'analyse syntaxique --\n\033[0m");
        }
        else{
                printf("\033[92m\t-- Succes a l'analyse syntaxique ! --\n\033[0m");
        }
        return EXIT_SUCCESS;
}
void yyerror(char *s) {
        fprintf(stderr, "Erreur de syntaxe a la ligne %d: %s\n", lineno, s);
}
