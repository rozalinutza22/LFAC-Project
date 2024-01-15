%{
#include <iostream>
#include <cstring>
#include <vector>
#include <fstream>
#include "IdList.h"

// ofstream fout("symbol_table.txt");

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yylex();
void yyerror(const char * s);
class IdList ids;

char math_operator[100];
char comp_operator[100];
char bool_operator[100];
char function_name[100];
char class_name[100]; 

%}
%union {
     char* string;
     char charval;
     float float_val;
     int val;
     bool bool_val;
     class exps* expresii;
     class call_list_prm* prms;
}

%token  BGIN END ASSIGN IF ELSE RETURN WHILE CLASS LESS EQ NEQ LESSEQ GR GREQ PLUS MINUS ASTERISK DIV MOD AND OR NEG Eval TypeOf LEFT_BRACKET RIGHT_BRACKET CONST 
%token<string> ID TYPE TEXT
%token<charval> CHR
%token<val>NR
%token<float_val>FLT
%token<bool_val>BOOL
%token<string>CLASS_SPECIFIERS

%type<expresii>expression
%type<prms>call_list
// %type<expresii>identifier
%type<val>MATH_OPERATORS
%type<val>CMP_OPERATORS
%type<val>BOOL_OPERATORS

%start progr
%%
progr: declarations block {printf("The programme is correct!\n");}
     ;

declarations :  decl ';'
	      |  declarations decl ';'
	      ;

decl       :  TYPE ID { if(!ids.existsVar($2)) {
                          ids.addVar($1,$2);
                          ids.isNotConst($2);
                          ids.setGlobal($2);
                         }else {
                              printf("Variabila %s a fost deja declarata!\n", $2);
                              yyerror("-> ");
                              exit(1);
                         }
                      }

           | ID '('')' 

           {
               if (ids.existsFunc($1) == false) {
                    printf("Functia %s nu exista!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
           }

           | ID '(' call_list ')' 

           {
               if (ids.existsFunc($1) == false) {
                    printf("Functia %s nu exista!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
           }

           | CONST TYPE ID ASSIGN NR {  if(!ids.existsVar($3)) {
                                          ids.addVar($2, $3);
                                          ids.addVarIntValue($3,$5);
                                          ids.nowIsConst($3);
                                          ids.setGlobal($3);
                                         }else {
                                             printf("Variabila %s a fost deja declarata!\n", $3);
                                             yyerror("-> ");
                                             exit(1);
                                        }

                                     }

           | CONST TYPE ID ASSIGN FLT { if(!ids.existsVar($3)) {
                                          ids.addVar($2, $3);
                                          ids.addVarFloatValue($3,$5);
                                          ids.nowIsConst($3);
                                          ids.setGlobal($3);
                                         }else {
                                             printf("Variabila %s a fost deja declarata!\n", $3);
                                             yyerror("-> ");
                                             exit(1);
                                        }
                                      }

           | CONST TYPE ID ASSIGN BOOL { if(!ids.existsVar($3)) {
                                          ids.addVar($2, $3);
                                          ids.addVarBoolValue($3,$5);
                                          ids.nowIsConst($3);
                                          ids.setGlobal($3);
                                         }else {
                                             printf("Variabila %s a fost deja declarata!\n", $3);
                                             yyerror("-> ");
                                             exit(1);
                                        }
                                       }

           | CONST TYPE ID ASSIGN CHR { if(!ids.existsVar($3)) {
                                          ids.addVar($2, $3);
                                          ids.addVarCharValue($3,$5);
                                          ids.nowIsConst($3);
                                          ids.setGlobal($3);
                                         }else {
                                             printf("Variabila %s a fost deja declarata!\n", $3);
                                             yyerror("-> ");
                                             exit(1);
                                        }

                                      }

           | CONST TYPE ID ASSIGN TEXT {  if(!ids.existsVar($3)) {
                                          ids.addVar($2,$3);
                                          ids.addVarStringValue($3,$5);
                                          ids.nowIsConst($3);
                                          ids.setGlobal($3);
                                         }else {
                                             printf("Variabila %s a fost deja declarata!\n", $3);
                                             yyerror("-> ");
                                             exit(1);
                                        }

                                       }

               /*functii+clase+vectori */

           | ID '^' ID

                 {
                    if (!ids.existsVar($1)) {
                         printf("Identificatorul %s nu exista!\n", $1);
                         yyerror("-> ");
                         exit(1);
                     }

                     if (!ids.existsVar($3)) {
                         printf("Identificatorul %s nu exista!\n", $3);
                         yyerror("-> ");
                         exit(1);
                     }

                     if (ids.getVarClassName($1) == ids.getVarClassName($3)) {

                         if (ids.getPrivacy($3) == "public") {
                              printf("Campul %s a fost accesat cu succes!\n", $3);
                         }else {
                              cout << "Campul " << $3 << " nu poate fi accesat deoarece are tipul " << ids.getPrivacy($3) << endl;
                              yyerror("-> ");
                              exit(1);
                         }
                     }else {
                         printf("%s si %s nu fac parte din aceeasi clasa!\n", $1, $3);
                         yyerror("-> ");
                         exit(1);
                     }
                 }


           | TYPE ID '(' ')' lb list_global RETURN ID ';' rb //$2 ARE ACELASI TIP CU $8 
           {   
               if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2))
               {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if (!ids.existsVar($8)) {
                    printf("Variabila %s nu a fost declarata!\n", $8);
                    yyerror("-> ");
                    exit(1);
               }

               if(ids.sameTypeFuncVar($2,$8) == false){
                    cout << "Functia " << $2 << " are tipul " << $1 << ", dar returneaza tipul " << ids.getType($8) << endl;
                    yyerror("-> ");
                    exit(1);
               }else{
                    if (strcmp($1, "int") == 0) {
                         ids.addFuncIntValue($2, ids.getVarIntValue($8));
                    }else if (strcmp($1, "float") == 0) {
                         ids.addFuncFloatValue($2, ids.getVarFloatValue($8));
                    }else if (strcmp($1, "bool") == 0) {
                         ids.addFuncBoolValue($2, ids.getVarBoolValue($8));
                    }else if (strcmp($1, "char") == 0) {
                         ids.addFuncCharValue($2, ids.getVarCharValue($8));
                    }else if (strcmp($1, "string") == 0) {
                         ids.addFuncStringValue($2, ids.getVarStringValue($8));
                    }
               }
           }

           | TYPE ID '(' ')' lb list_global RETURN FLT ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if(strcmp($1,"float") != 0){ 
                    printf("Functia este declarata cu tipul %s, dar returneaza float.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    if (strcmp($1, "float") == 0) {
                         ids.addFuncFloatValue($2, $8);
                    }
               }
           }

           | TYPE ID '(' ')' lb list_global RETURN NR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"int") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza int.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
               
               ids.addFuncIntValue($2, $8);
           }

           | TYPE ID '(' ')' lb list_global RETURN BOOL ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if(strcmp($1,"bool") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza bool.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncBoolValue($2, $8);
               }
           }

           | TYPE ID '(' ')' lb list_global RETURN CHR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if(strcmp($1,"char") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza char.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
               else{
                    ids.addFuncCharValue($2, $8);
               }
           }

           | TYPE ID '(' ')' lb list_global RETURN TEXT rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if(strcmp($1,"string") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza string.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
               else{
                    ids.addFuncStringValuePlain($2, $8);
               }
           }

           | TYPE ID '(' ')' lb RETURN ID ';' rb //$2 ARE ACELASI TIP CU $8
           
           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               // if(!ids.existsVar($2) && !ids.existsFunc($2)) {
               //      ids.addVarFunc($1, $2);
               // }else{
               //      printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
               //      yyerror("-> ");
               //      exit(1);
               // }

               if (!ids.existsVar($7)) {
                    printf("Variabila %s nu a fost declarata!\n", $7);
                    yyerror("-> ");
                    exit(1);
               }

               if(ids.sameTypeFuncVar($2,$7) == false){
                    cout << "Functia " << $2 << " are tipul " << $1 << ", dar returneaza tipul " << ids.getType($7) << endl;
                    yyerror("-> ");
                    exit(1);
               }else{
                    if (strcmp($1, "int") == 0) {
                         ids.addFuncIntValue($2, ids.getVarIntValue($7));
                    }else if (strcmp($1, "float") == 0) {
                         ids.addFuncFloatValue($2, ids.getVarFloatValue($7));
                    }else if (strcmp($1, "bool") == 0) {
                         ids.addFuncBoolValue($2, ids.getVarBoolValue($7));
                    }else if (strcmp($1, "char") == 0) {
                         ids.addFuncCharValue($2, ids.getVarCharValue($7));
                    }else if (strcmp($1, "string") == 0) {
                         ids.addFuncStringValue($2, ids.getVarStringSValue($7));
                    }
               }
           }
          

           | TYPE ID '(' ')' lb RETURN FLT ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"float") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza float.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncFloatValue($2, $7);
               }
           }

           | TYPE ID '(' ')' lb RETURN NR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"int") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza int.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncIntValue($2, $7);
               }
           }


           | TYPE ID '(' ')' lb RETURN BOOL ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"bool") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza bool.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncBoolValue($2, $7);
               }
           }

           | TYPE ID '(' ')' lb RETURN CHR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"char") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza char.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncCharValue($2, $7);
               }
           }

           | TYPE ID '(' ')' lb RETURN TEXT ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, false);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"string") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza string.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncStringValuePlain($2, $7);
               }
           }

           | TYPE ID '(' list_param ')' lb list_global RETURN ID ';' rb 

           {  
               if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if (!ids.existsVar($9)) {
                    printf("Variabila %s nu a fost declarata!\n", $9);
                    yyerror("-> ");
                    exit(1);
               }

               if(ids.sameTypeFuncVar($2,$9) == false){
                    printf("Functia %s are tipul %s, dar returneaza tipul %s\n", $2, $1, $9);
                    yyerror("-> ");
                    exit(1);
               }else{
                    if (strcmp($1, "int") == 0) {
                         ids.addFuncIntValue($2, ids.getVarIntValue($9));
                    }else if (strcmp($1, "float") == 0) {
                         ids.addFuncFloatValue($2, ids.getVarFloatValue($9));
                    }else if (strcmp($1, "bool") == 0) {
                         ids.addFuncBoolValue($2, ids.getVarBoolValue($9));
                    }else if (strcmp($1, "char") == 0) {
                         ids.addFuncCharValue($2, ids.getVarCharValue($9));
                    }else if (strcmp($1, "string") == 0) {
                         ids.addFuncStringValue($2, ids.getVarStringSValue($9));
                    }
               }
           }

           | TYPE ID '(' list_param ')' lb list_global RETURN NR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"int") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza int.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncIntValue($2, $9);
               }
           }

           | TYPE ID '(' list_param ')' lb list_global RETURN FLT ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"float") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza float.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncFloatValue($2, $9);
               }
           }

           | TYPE ID '(' list_param ')' lb list_global RETURN BOOL ';' rb

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"bool") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza bool.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncBoolValue($2, $9);
               }
           }

           | TYPE ID '(' list_param ')' lb list_global RETURN CHR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"char") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza char.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncCharValue($2, $9);
               }
           }

           | TYPE ID '(' list_param ')' lb list_global RETURN TEXT ';' rb  

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"string") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza string.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncStringValuePlain($2, $9);
               }
           }

           | TYPE ID '(' list_param ')' lb RETURN ID ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }

               if (!ids.existsVar($8)) {
                    printf("Variabila %s nu a fost declarata!\n", $8);
                    yyerror("-> ");
                    exit(1);
               }

               if(ids.sameTypeFuncVar($2,$8) == false){
                    printf("Functia %s are tipul %s, dar returneaza tipul %s\n", $2, $1, $8);
                    yyerror("-> ");
                    exit(1);
               }else{
                    if (strcmp($1, "int") == 0) {
                         ids.addFuncIntValue($2, ids.getVarIntValue($8));
                    }else if (strcmp($1, "float") == 0) {
                         ids.addFuncFloatValue($2, ids.getVarFloatValue($8));
                    }else if (strcmp($1, "bool") == 0) {
                         ids.addFuncBoolValue($2, ids.getVarBoolValue($8));
                    }else if (strcmp($1, "char") == 0) {
                         ids.addFuncCharValue($2, ids.getVarCharValue($8));
                    }else if (strcmp($1, "string") == 0) {
                         ids.addFuncStringValue($2, ids.getVarStringSValue($8));
                    }
               }
           }

           | TYPE ID '(' list_param ')' lb RETURN NR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"int") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza int.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncIntValue($2, $8);
               }
           }


           | TYPE ID '(' list_param ')' lb RETURN FLT ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"float") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza float.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncFloatValue($2, $8);
               }
           }

           | TYPE ID '(' list_param ')' lb RETURN BOOL ';' rb

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"bool") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza bool.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncBoolValue($2, $8);
               }
           }

           | TYPE ID '(' list_param ')' lb RETURN CHR ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"char") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza char.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncCharValue($2, $8);
               }
           }


           | TYPE ID '(' list_param ')' lb RETURN TEXT ';' rb 

           {   if(!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addVarFunc($1, $2);
                    ids.setFuncHasParams($2, true);
               }else if (ids.existsVar($2) || ids.existsFunc($2)) {
                    printf("Numele %s asignat functiei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }


               if(strcmp($1,"string") != 0){
                    printf("Functia este declarata cu tipul %s, dar returneaza string.\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else{
                    ids.addFuncStringValuePlain($2, $8);
               }
           }

          | CLASS ID lb class_elements rb
           
          {
               if (!ids.existsVar($2) && !ids.existsFunc($2) && !ids.existsclsVar($2)) {
                    ids.addclsVar($2);
               }else if (ids.existsVar($2) || ids.existsFunc($2) || ids.existsclsVar($2)) {
                    printf("Numele %s asignat clasei a fost deja folosit.\n", $2);
                    yyerror("-> ");
                    exit(1);
               }
          }


           | TYPE ARRAY ID 

           {
               if (!ids.existsVar($3) && !ids.existsFunc($3) && !ids.existsclsVar($3)) {
                    ids.addVar($1, $3);
                    ids.setGlobal($3);
               }else if (ids.existsVar($3) || ids.existsFunc($3) || ids.existsclsVar($3)) {
                    printf("Numele %s asignat tabloului a fost deja folosit.\n", $3);
                    yyerror("-> ");
                    exit(1);
               }   
           }

           | CLASS ID ID // class masina a;

           {
               if (ids.existsclsVar($2)) {
                    ids.addVar("none", $3);
                    ids.addVarClassName($3, $2);
                    ids.setVarFuncName($3, "none");

               }else {
                    cout << "Nu exista clasa " << $2 << endl;
                    yyerror("->");
                    exit(1);
               }
           }

           ;

ARRAY : '[' NR ']'
      | ARRAY '[' NR ']'
      ;


lb : LEFT_BRACKET 
   ;
rb : RIGHT_BRACKET 
   ;

list_param : param 
            | list_param ','  param
            ;

param : ';' ID TYPE ID 
     {
          if (!ids.existsVar($4) && !ids.existsFunc($4) && !ids.existsclsVar($4)) { // $2 = functie
               ids.addVar($3, $4);
               ids.setVarFuncName($4, $2);
               ids.addVarTypeParam($4, $3);
               ids.pushParam($2, $3, $4);
               ids.isParam($4);    
          }else if (ids.existsVar($4) || ids.existsFunc($4) || ids.existsclsVar($4)) {
               printf("Variabila %s este deja folosita in alt context.\n", $4);
               yyerror("-> ");
               exit(1);
          }   
     }

      | ID '(' list_param ')'  

      | ID '(' ')' 
      ;  

list_global :  statement_global ';'
     | list_global statement_global ';'
     ;

statement_global : ID ASSIGN ID {  if ((ids.existsVar($1)) && ids.existsVar($3)) {
                                        if (ids.isConst($1) == 1) {
                                             printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                             yyerror("-> ");
                                             exit(1);
                                        }

                                        if (ids.sameType($1, $3)) {
                                             ids.getValueFromVar($1, $3);
                                        }else {
                                             printf("Variabilele %s si %s nu au acelasi tip!\n", $1, $3);
                                             yyerror("-> ");
                                             exit(1);
                                        }
                                   }else if (!ids.existsVar($1)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   }else if (!ids.existsVar($3)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $3);
                                        yyerror("-> ");
                                        exit(1);
                                   } 
                              }

                 | ID ASSIGN BOOL { if (ids.existsVar($1) && ids.getType($1) == "bool")
                                        ids.addVarBoolValue($1, $3);
                                   else if (ids.existsVar($1) && ids.getType($1) != "bool") {
                                        printf("Variabila %s nu este de tip bool!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   }else if (!ids.existsVar($1)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   } 
                              }

                 | ID ASSIGN FLT { if ((ids.existsVar($1)) && ids.getType($1) == "float")
                                        ids.addVarFloatValue($1, $3);
                                   else if ((ids.existsVar($1)) && ids.getType($1) != "float") {
                                        printf("Variabila %s nu este de tip float!\n", $1);
                                        yyerror("-> ");
                                        exit(1);    
                                   }else if (!ids.existsVar($1)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   } 
                              }

                 | ID ASSIGN NR {  if (ids.existsVar($1) && ids.getType($1) == "int") {
                                        ids.addVarIntValue($1, $3);
                                   }else if (ids.existsVar($1) && ids.getType($1) != "int") {
                                        printf("Variabila %s nu este de tip int!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   }else if (!ids.existsVar($1)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   } 
                              }

                 | ID ASSIGN CHR { if (ids.existsVar($1) && ids.getType($1) == "char") {
                                        ids.addVarCharValue($1, $3);
                                        cout << "Caracterul: " << $3 << endl;
                                   }else if (ids.existsVar($1) && ids.getType($1) != "char") {
                                        printf("Variabila %s nu este de tip char!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   }else if (!ids.existsVar($1)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   } 
                              }

                 | ID ASSIGN TEXT { if (ids.existsVar($1) && ids.getType($1) == "string")
                                        ids.addVarStringValue($1, $3);
                                   else if (ids.existsVar($1) && ids.getType($1) != "string") {
                                        printf("Variabila %s nu este de tip string!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   }else if (!ids.existsVar($1)) {
                                        printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                        yyerror("-> ");
                                        exit(1);
                                   } 
                              }

                    /*functii*/
                 | ID ASSIGN '{' list_identifiers_int '}' // if id = vector de int
                 | ID ASSIGN '{' list_identifiers_bool '}' // if id = vector de bool

                 | ID '^' ID

                 {
                    if (!ids.existsVar($1)) {
                         printf("Identificatorul %s nu exista!\n", $1);
                         yyerror("-> ");
                         exit(1);
                     }

                     if (!ids.existsVar($3)) {
                         printf("Identificatorul %s nu exista!\n", $3);
                         yyerror("-> ");
                         exit(1);
                     }

                     if (ids.getVarClassName($1) == ids.getVarClassName($3)) {

                         if (ids.getPrivacy($3) == "public") {
                              printf("Campul %s a fost accesat cu succes!\n", $3);
                         }else {
                              cout << "Campul " << $3 << " nu poate fi accesat deoarece are tipul " << ids.getPrivacy($3) << ' ' << endl;
                              yyerror("-> ");
                              exit(1);
                         }
                     }else {
                         printf("%s si %s nu fac parte din aceeasi clasa!\n", $1, $3);
                         yyerror("-> ");
                         exit(1);
                     }
                 }

                 | ID '(' call_list ')' 

                 {
                    if (ids.existsFunc($1) == false) {
                         printf("Functia %s nu exista!\n", $1);
                         yyerror("-> ");
                         exit(1);
                    }else if (ids.existsFunc($1)) {
                         if (ids.funcHasParams($1) == false) {
                              cout << "Functia " << $1 << " nu are parametri!" << endl;
                              yyerror("->");
                              exit(1);
                         }else if (ids.funcHasParams($1) == true) {
                              if ($3->getParamType() == ids.getVarTypeForParams($1)) {
                                   cout << "Functia " << $1 << " a fost apelata corect!" << endl;
                              }else {
                                   cout << "Functia " << $1 << " nu a fost apelata corect!" << endl;
                                   yyerror("->");
                                   exit(1);
                              }

                                   $3->printParams();
                                   cout << endl;
                         }
                    }
                 }

                 | ID ASSIGN expression

                {
                    if (ids.existsVar($1)) {
                         if (ids.getType($1) == $3->getExpType()) {
                              if (ids.getType($1) == "int") {
                                   ids.addVarIntValue($1, $3->getExpIntValue());
                              }else if (ids.getType($1) == "float") {
                                   ids.addVarFloatValue($1, $3->getExpFloatValue());
                              }else if (ids.getType($1) == "bool") {
                                   ids.addVarBoolValue($1, $3->getExpBoolValue());
                              }
                         }

                    }else if (!ids.existsVar($1)) {
                         cout << "Variabila " << $1 << " nu exista!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }

                 | ID '('')' 

                 {
                    if (ids.existsFunc($1) == false) {
                         printf("Functia %s nu exista!\n", $1);
                         yyerror("-> ");
                         exit(1);
                    }else if (ids.existsFunc($1)) {
                         if (ids.funcHasParams($1) == true) {
                              cout << "Functia " << $1 << " are parametri!" << endl;
                              yyerror("->");
                              exit(1);
                         }
                    }
                 }

                 | Eval '(' expression ')' 

                 {
                    if ($3->getExpType() == "int") {
                         cout << "Valoarea expresiei este: " << $3->getExpIntValue() << endl;
                    }else if ($3->getExpType() == "float") {
                         cout << "Valoarea expresiei este: " << $3->getExpFloatValue() << endl;
                    }if ($3->getExpType() == "bool") {
                         cout << "Valoarea expresiei este: " << $3->getExpBoolValue() << endl;
                    }
                 }


                 | Eval '(' NR ')' {printf("Valoarea expresiei este: %d\n", $3);}
                 | Eval '(' BOOL ')' {cout << "Valoarea expresiei este: " << $3;}
                 | Eval '(' FLT ')' {cout << "Valoarea expresiei este: " << $3;}
                 | Eval '(' ID ')' 
                         {  
                              if (!ids.existsVar($3) && !ids.existsFunc($3)) {
                                   printf("Identificatorul %s nu exista!\n", $3);
                                   yyerror("-> ");
                                   exit(1);
                              }  

                              if (ids.existsVar($3)) {
                                   if (ids.getType($3) == "int") {
                                        cout << "Valoarea expresiei este: " << ids.getVarIntValue($3) << endl;
                                   }else if (ids.getType($3) == "float") {
                                        cout << "Valoarea expresiei este: " << ids.getVarFloatValue($3) << endl;
                                   }else if (ids.getType($3) == "bool") {
                                        cout << "Valoarea expresiei este: " << ids.getVarBoolValue($3) << endl;
                                   }
                              }else if (ids.existsFunc($3)) {
                                   if (ids.getFuncType($3) == "int") {
                                        cout << "Valoarea expresiei este: " << ids.getVarIntValue($3) << endl;
                                   }else if (ids.getFuncType($3) == "float") {
                                        cout << "Valoarea expresiei este: " << ids.getVarFloatValue($3) << endl;
                                   }else if (ids.getFuncType($3) == "bool") {
                                        cout << "Valoarea expresiei este: " << ids.getVarBoolValue($3) << endl;
                                   }
                              }
                         }

                 | TypeOf '(' expression ')'

                 {
                    cout << "Tipul expresiei este: " << $3->getExpType() << endl;
                 }

                 | TypeOf '(' BOOL ')' {cout << "Tipul expresiei este bool" << endl;}

                 | TypeOf '(' ID ')' 
                    {  
                              if (!ids.existsVar($3) && !ids.existsFunc($3)) {
                                   printf("Identificatorul %s nu exista!\n", $3);
                                   yyerror("-> ");
                                   exit(1);
                              }  

                              if (ids.existsVar($3)) {
                                   if (ids.getType($3) == "int") {
                                        cout << "Tipul expresiei este: " << ids.getType($3) << endl;
                                   }else if (ids.getType($3) == "float") {
                                        cout << "Tipul expresiei este: " << ids.getType($3) << endl;
                                   }else if (ids.getType($3) == "bool") {
                                        cout << "Tipul expresiei este: " << ids.getType($3) << endl;
                                   }
                              }else if (ids.existsFunc($3)) {
                                   if (ids.getFuncType($3) == "int") {
                                        cout << "Tipul expresiei este: " << ids.getFuncType($3) << endl;
                                   }else if (ids.getFuncType($3) == "float") {
                                        cout << "Tipul expresiei este: " << ids.getFuncType($3) << endl;
                                   }else if (ids.getFuncType($3) == "bool") {
                                        cout << "Tipul expresiei este: " << ids.getFuncType($3) << endl;
                                   }
                              }
                         }

                 | TypeOf '(' NR ')' {cout << "Tipul expresiei este int" << endl;}
                 | TypeOf '(' FLT ')' {cout << "Tipul expresiei de float" << endl;}

                 | IF '(' expression  ')' lb list rb
                 | IF '(' expression  ')' lb list rb ELSE lb list rb
                 | WHILE '(' expression  ')' lb list rb

                 | ID TYPE ID { if(!ids.existsVar($3)) {
                               ids.addVar($2,$3);
                               ids.isNotConst($3);
                               string result = string($1);
                               ids.setVarFuncName($3, result);
                            }else {
                               printf("Variabila %s a fost deja declarata!\n", $2);
                               yyerror("-> ");
                               exit(1);
                           }
                      }
                 ;

block : BGIN list END 
     ;

list :  statement ';'
     | list statement ';'
     ;

statement: ID ASSIGN ID {  if ((ids.existsVar($1)) && ids.existsVar($3)) {
                              if (ids.isConst($1) == 1) {
                                   printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }

                              if (ids.sameType($1, $3)) {
                                   ids.getValueFromVar($1, $3);
                              }else {
                                   printf("Variabilele %s si %s nu au acelasi tip!\n", $1, $3);
                                   yyerror("-> ");
                                   exit(1);
                              }
                           }else if (!ids.existsVar($1)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                          }else if (!ids.existsVar($3)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $3);
                                   yyerror("-> ");
                                   exit(1);
                              }  

                         }
         | ID ASSIGN FLT {    if (ids.isConst($1) == 1) {
                                   printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }

                              if ((ids.existsVar($1)) && ids.getType($1) == "float")
                                 ids.addVarFloatValue($1, $3);
                              else if ((ids.existsVar($1)) && ids.getType($1) != "float") {
                                   printf("Variabila %s nu este de tip float!\n", $1);
                                   yyerror("-> ");
                                   exit(1);    
                              }else if (!ids.existsVar($1)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              } 
                         }

         | ID ASSIGN NR {     if (ids.isConst($1) == 1) {
                                   printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }

                              if (ids.existsVar($1) && ids.getType($1) == "int")
                                 ids.addVarIntValue($1, $3);
                              else if (ids.existsVar($1) && ids.getType($1) != "int") {
                                   printf("Variabila %s nu este de tip int!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }else if (!ids.existsVar($1)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              } 
                        }

         | ID ASSIGN BOOL {   if (ids.isConst($1) == 1) {
                                   printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }
          
                              if (ids.existsVar($1) && ids.getType($1) == "bool")
                                 ids.addVarBoolValue($1, $3);
                              else if (ids.existsVar($1) && ids.getType($1) != "bool") {
                                   printf("Variabila %s nu este de tip bool!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }else if (!ids.existsVar($1)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              } 
                         }

         | ID ASSIGN CHR  {   if (ids.isConst($1) == 1) {
                                   printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }
          
                              if (ids.existsVar($1) && ids.getType($1) == "char")
                                  ids.addVarCharValue($1, $3);
                              else if (ids.existsVar($1) && ids.getType($1) != "char") {
                                   printf("Variabila %s nu este de tip char!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }else if (!ids.existsVar($1)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              } 
                         }

         | ID ASSIGN TEXT {   if (ids.isConst($1) == 1) {
                                   printf("Variabila %s este constanta, nu ii puteti schimba valoarea!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }
          
                              if (ids.existsVar($1) && ids.getType($1) == "string")
                                 ids.addVarStringValue($1, $3);
                              else if (ids.existsVar($1) && ids.getType($1) != "string") {
                                   printf("Variabila %s nu este de tip string!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              }else if (!ids.existsVar($1)) {
                                   printf("Variabila %s nu a fost declarata inainte de utilizare!\n", $1);
                                   yyerror("-> ");
                                   exit(1);
                              } 
                         }
               

           /*functii*/    
         | ID ASSIGN '{' list_identifiers_int '}' // if id = vector de int
         | ID ASSIGN '{' list_identifiers_bool '}' // if id = vector de bool      
         | ID '^' ID // accesare membri clasa


         {
               if (!ids.existsVar($1)) {
                    printf("Identificatorul %s nu exista!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }

               if (!ids.existsVar($3)) {
                    printf("Identificatorul %s nu exista!\n", $3);
                    yyerror("-> ");
                    exit(1);
               }

               if (ids.getVarClassName($1) == ids.getVarClassName($3)) {

                    if (ids.getPrivacy($3) == "public") {
                         printf("Campul %s a fost accesat cu succes!\n", $3);
                    }else {
                         cout << "Campul " << $3 << " nu poate fi accesat deoarece are tipul " << ids.getPrivacy($3) << ' ' << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else {
                    printf("%s si %s nu fac parte din aceeasi clasa!\n", $1, $3);
                    yyerror("-> ");
                    exit(1);
               }
          }

         | ID '(' call_list ')' 

          {
               if (ids.existsFunc($1) == false) {
                    printf("Functia %s nu exista!\n", $1);
                    yyerror("->");
                    exit(1);
               }else if (ids.existsFunc($1)) {
                    if (ids.funcHasParams($1) == false) {
                         cout << "Functia " << $1 << " nu are parametri!" << endl;
                         yyerror("->");
                         exit(1);
                    }else if (ids.funcHasParams($1) == true) {
                         if ($3->getParamType() == ids.getVarTypeForParams($1)) {
                              cout << "Functia " << $1 << " a fost apelata corect!" << endl;
                         }else {
                              cout << "Functia " << $1 << " nu a fost apelata corect!" << endl;
                              yyerror("->");
                              exit(1);
                         }

                         $3->printParams();
                         cout << endl;
                    }
               }
          }

         | ID ASSIGN expression

         {
               if (ids.existsVar($1)) {
                    if (ids.getType($1) == $3->getExpType()) {
                         if (ids.getType($1) == "int") {
                              ids.addVarIntValue($1, $3->getExpIntValue());
                         }else if (ids.getType($1) == "float") {
                              ids.addVarFloatValue($1, $3->getExpFloatValue());
                         }else if (ids.getType($1) == "bool") {
                              ids.addVarBoolValue($1, $3->getExpBoolValue());
                         }
                    }

               }else if (!ids.existsVar($1)) {
                    cout << "Variabila " << $1 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }
         }

         | ID '('')' 

          {
               if (ids.existsFunc($1) == false) {
                    printf("Functia %s nu exista!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }else if (ids.existsFunc($1)) {
                    if (ids.funcHasParams($1) == 1) {
                         cout << "Ati apelat functia gresit, adaugati parametrii corespunzatori!" << endl; 
                         yyerror("->");
                         exit(1);
                    }
               }
          }

         | Eval '(' expression ')' 

         {
               if ($3->getExpType() == "int") {
                    cout << "Valoarea expresiei este: " << $3->getExpIntValue() << endl;
               }else if ($3->getExpType() == "float") {
                    cout << "Valoarea expresiei este: " << $3->getExpFloatValue() << endl;
               }else if ($3->getExpType() == "bool") {
                    cout << "Valoarea expresiei este: " << $3->getExpBoolValue() << endl;
               }
               
         }

         | Eval '(' NR ')' {printf("Valoarea expresiei este: %d\n", $3);}
         | Eval '(' BOOL ')' {cout << "Valoarea expresiei este: " << boolalpha << $3 << endl;}
         | Eval '(' FLT ')' {cout << "Valoarea expresiei este: " << $3 << endl;}
         | Eval '(' ID ')' {  
                              if (!ids.existsVar($3) && !ids.existsFunc($3)) {
                                   printf("Identificatorul %s nu exista!\n", $3);
                                   yyerror("-> ");
                                   exit(1);
                              }  

                              if (ids.existsVar($3)) {
                                   if (ids.getType($3) == "int") {
                                        cout << "Valoarea expresiei este: " << ids.getVarIntValue($3) << endl;
                                   }else if (ids.getType($3) == "float") {
                                        cout << "Valoarea expresiei este: " << ids.getVarFloatValue($3) << endl;
                                   }else if (ids.getType($3) == "bool") {
                                        cout << "Valoarea expresiei este: " << ids.getVarBoolValue($3) << endl;
                                   }
                              }else if (ids.existsFunc($3)) {
                                   if (ids.getFuncType($3) == "int") {
                                        cout << "Valoarea expresiei este: " << ids.getVarIntValue($3) << endl;
                                   }else if (ids.getFuncType($3) == "float") {
                                        cout << "Valoarea expresiei este: " << ids.getVarFloatValue($3) << endl;
                                   }else if (ids.getFuncType($3) == "bool") {
                                        cout << "Valoarea expresiei este: " << ids.getVarBoolValue($3) << endl;
                                   }
                              }
                         }

         | TypeOf '(' expression ')'  
         
         {
               cout << "Tipul expresiei este: " << $3->getExpType() << endl;
         } 

         | TypeOf '(' BOOL ')' {cout << "Tipul expresiei este: bool" << endl;}

         | TypeOf '(' ID ')' {  
                              if (!ids.existsVar($3) && !ids.existsFunc($3)) {
                                   printf("Identificatorul %s nu exista!\n", $3);
                                   yyerror("-> ");
                                   exit(1);
                              }  

                              if (ids.existsVar($3)) {
                                   if (ids.getType($3) == "int") {
                                        cout << "Tipul expresiei este: " << ids.getType($3) << endl;
                                   }else if (ids.getType($3) == "float") {
                                        cout << "Tipul expresiei este: " << ids.getType($3) << endl;
                                   }else if (ids.getType($3) == "bool") {
                                        cout << "Tipul expresiei este: " << ids.getType($3) << endl;
                                   }
                              }else if (ids.existsFunc($3)) {
                                   if (ids.getFuncType($3) == "int") {
                                        cout << "Tipul expresiei este: " << ids.getFuncType($3) << endl;
                                   }else if (ids.getFuncType($3) == "float") {
                                        cout << "Tipul expresiei este: " << ids.getFuncType($3) << endl;
                                   }else if (ids.getFuncType($3) == "bool") {
                                        cout << "Tipul expresiei este: " << ids.getFuncType($3) << endl;
                                   }
                              }
                         }

         | TypeOf '(' NR ')' {cout << "Tipul expresiei este int" << endl;}

         | TypeOf '(' FLT ')' {cout << "Tipul expresiei este float" << endl;}

         | IF '(' expression  ')' lb list rb // ?
         | IF '(' expression  ')' lb list rb ELSE lb list rb // ?
         | WHILE '(' expression  ')' lb list rb // ?

         | ID '&' ID

                 {
                    if (!ids.existsVar($1)) {
                         printf("Identificatorul %s nu exista!\n", $1);
                         yyerror("-> ");
                         exit(1);
                     }

                     if (!ids.existsVar($3)) {
                         printf("Identificatorul %s nu exista!\n", $3);
                         yyerror("-> ");
                         exit(1);
                     }

                     if (ids.getVarClassName($1) == ids.getVarClassName($3)) {

                         if (ids.getPrivacy($3) == "public") {
                              printf("Campul %s a fost accesat cu succes!\n", $3);
                         }else {
                              cout << "Campul " << $3 << " nu poate fi accesat deoarece are tipul " << ids.getPrivacy($3) << endl;
                              yyerror("-> ");
                              exit(1);
                         }
                     }else {
                         printf("%s si %s nu fac parte din aceeasi clasa!\n", $1, $3);
                         yyerror("-> ");
                         exit(1);
                     }
                 }
         
         ;

call_list  : NR 

           {
               $$ = new call_list_prm("int");
           }

           | ID 

           {
               if (!ids.existsVar($1)) {
                    cout << "Variabila " << $1 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }else if (ids.existsVar($1)) {
                    string res = ids.getType($1);
                    $$ = new call_list_prm(res);
               }
               
           }

           | FLT

           {
               $$ = new call_list_prm("float");
           }

           | CHR

           {
               $$ = new call_list_prm("char");
           }

           | TEXT

           {
               $$ = new call_list_prm("string");
           }

           | BOOL

           {
               $$ = new call_list_prm("bool");
           }

           | call_list ',' ID

           {
               string res = ids.getType($3);
               $$ = new call_list_prm(res);

           }

           
           | call_list ',' NR

           {
               $$ = new call_list_prm("int");
           }

           | call_list ',' FLT

           {
               $$ = new call_list_prm("float");
           }

           | call_list ',' CHR

           {
               $$ = new call_list_prm("char");
           }

           | call_list ',' TEXT

           {
               $$ = new call_list_prm("string");
           }


           | call_list ',' BOOL

           {
               $$ = new call_list_prm("bool");
           }

           ;

class_element : ID CLASS_SPECIFIERS TYPE ID '(' list_param_class ')' lb list RETURN NR ';' rb // modific functions.className

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    //nu exista, adaugam functia normal si setam className = $1
                    ids.addVarFunc($3, $4);
                    ids.setFuncClassName($4, $1);
                    ids.addFuncIntValue($4, $11);
                    ids.setFuncHasParams($4, true);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID '(' ')' lb list RETURN NR ';' rb 

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    //nu exista, adaugam functia normal si setam className = $1
                    ids.addVarFunc($3, $4);
                    ids.setFuncClassName($4, $1);
                    ids.addFuncIntValue($4, $10);
                    ids.setFuncHasParams($4, false);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID '(' ')' lb list RETURN FLT ';' rb 

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    //nu exista, adaugam functia normal si setam className = $1
                    ids.addVarFunc($3, $4);
                    ids.setFuncClassName($4, $1);
                    ids.addFuncFloatValue($4, $10);
                    ids.setFuncHasParams($4, false);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID '(' ')' lb list RETURN CHR ';' rb 

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    //nu exista, adaugam functia normal si setam className = $1
                    ids.addVarFunc($3, $4);
                    ids.setFuncClassName($4, $1);
                    ids.addFuncCharValue($4, $10);
                    ids.setFuncHasParams($4, false);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID '(' ')' lb list RETURN BOOL ';' rb 

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    //nu exista, adaugam functia normal si setam className = $1
                    ids.addVarFunc($3, $4);
                    ids.setFuncClassName($4, $1);
                    ids.addFuncBoolValue($4, $10);
                    ids.setFuncHasParams($4, false);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID '(' ')' lb list RETURN TEXT ';' rb 

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    //nu exista, adaugam functia normal si setam className = $1
                    ids.addVarFunc($3, $4);
                    ids.setFuncClassName($4, $1);
                    ids.addFuncStringValue($4, $10);
                    ids.setFuncHasParams($4, false);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID ASSIGN NR // className=class_name;

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    if (strcmp($3, "int") != 0) {
                         printf("Variabila %s este de tip %s, nu i se poate asigna tipul int!\n", $4, $3);
                         yyerror("-> ");
                         exit(1);
                    }

                    ids.addVar($3, $4);
                    ids.setPrivacy($4, $2);
                    ids.addVarClassName($4, $1);
                    ids.addVarIntValue($4, $6);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID ASSIGN BOOL 

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    if (strcmp($3, "bool") != 0) {
                         printf("Variabila %s este de tip %s, nu i se poate asigna tipul bool!\n", $4, $3);
                         yyerror("-> ");
                         exit(1);
                    }

                    ids.addVar($3, $4);
                    ids.setPrivacy($4, $2);
                    ids.addVarClassName($4, $1);
                    ids.addVarBoolValue($4, $6);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID ASSIGN FLT

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    if (strcmp($3, "float") != 0) {
                         printf("Variabila %s este de tip %s, nu i se poate asigna tipul float!\n", $4, $3);
                         yyerror("-> ");
                         exit(1);
                    }

                    ids.addVar($3, $4);
                    ids.setPrivacy($4, $2);
                    ids.addVarClassName($4, $1);
                    ids.addVarFloatValue($4, $6);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID ASSIGN CHR

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    if (strcmp($3, "char") != 0) {
                         printf("Variabila %s este de tip %s, nu i se poate asigna tipul char!\n", $4, $3);
                         yyerror("-> ");
                         exit(1);
                    }

                    ids.addVar($3, $4);
                    ids.setPrivacy($4, $2);
                    ids.addVarClassName($4, $1);
                    ids.addVarCharValue($4, $6);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }

          | ID CLASS_SPECIFIERS TYPE ID ASSIGN TEXT

          {
               if (!ids.existsVar($4) && !ids.existsclsVar($4) && !ids.existsFunc($4)) {
                    if (strcmp($3, "string") != 0) {
                         printf("Variabila %s este de tip %s, nu i se poate asigna tipul string!\n", $4, $3);
                         yyerror("-> ");
                         exit(1);
                    }

                    ids.addVar($3, $4);
                    ids.setPrivacy($4, $2);
                    ids.addVarClassName($4, $1);
                    ids.addVarStringValue($4, $6);
               }else if (ids.existsVar($4) || ids.existsclsVar($4) || ids.existsFunc($4)) {
                    printf("Variabila %s este deja folosita in alt context!\n", $1);
                    yyerror("-> ");
                    exit(1);
               }
          }
          ;
          
class_elements : class_element ';'
          | class_elements class_element ';'
          ;

list_param_class : param_class 
            | list_param_class ','  param_class
            ;

param_class : ';' ID TYPE ID 
     {
          if (!ids.existsVar($4) && !ids.existsFunc($4) && !ids.existsclsVar($4)) { // $2 = functie
               ids.addVar($3, $4);
               ids.setVarFuncName($4, $2);
               ids.setVarClassName($4, ids.getClassName($2));
               ids.addVarTypeParam($4, $3);
               ids.pushParam($2, $3, $4);
               ids.isParam($4);    
          }else if (ids.existsVar($4) || ids.existsFunc($4) || ids.existsclsVar($4)) {
               printf("Variabila %s este deja folosita in alt context.\n", $4);
               yyerror("-> ");
               exit(1);
          }   

     }

      | ID '(' list_param ')'  

      | ID '(' ')' 
      ; 

MATH_OPERATORS : PLUS { $$ = 0;}
	          | MINUS { $$ = 1; }
	          | ASTERISK { $$ = 2; }
	          | DIV { $$ = 3; }
               | MOD { $$ = 4; }
	          ;

BOOL_OPERATORS : AND { $$ = 5 ; }
	          | OR { $$ = 6 ; }
               | NEG { $$ = 7; }
	          ;

CMP_OPERATORS : LESS { $$ = 8; }
	         | LESSEQ { $$ = 9; }
	         | GR { $$ = 10; }
	         | GREQ { $$ = 11; }
              | NEQ { $$ = 12; }
              | EQ { $$ = 13; }
              ;

expression : ID MATH_OPERATORS ID

           {
               if (ids.existsVar($1) && ids.existsVar($3)) {
                    if (ids.sameType($1, $3)) {

                         if (ids.getType($1) == "int") {
                              $$ = new exps("int");
                              int v1 = ids.getVarIntValue($1);
                              int v2 = ids.getVarIntValue($3);
                              int value1 = ids.compute_int_math(v1, $2, v2);
                              $$->setExpIntValue(value1);
                         }else if (ids.getType($1) == "float") {
                              $$ = new exps("float");
                              float x1 = ids.getVarFloatValue($1);
                              float x2 = ids.getVarFloatValue($3);
                              float value2 = ids.compute_float_math(x1, $2, x2);

                              $$->setExpFloatValue(value2);
                         }else if (ids.getType($1) == "bool") {
                              cout << "Operatiile aritmetice nu pot fi aplicate pe variabile de tip bool!" << endl;
                              yyerror("->");
                              exit(1);
                         }
                    }
               }else {
                    cout << "Variabila nedeclarata!";
                    yyerror("->");
                    exit(1);
               }
           }

           | ID CMP_OPERATORS ID

           {
               if (ids.existsVar($1) && ids.existsVar($3)) {
                    if (ids.sameType($1, $3)) {

                         if (ids.getType($1) == "bool") {
                              cout << "Nu se poate efectua operatia pe variabile de tip bool!" << endl;
                              yyerror("->");
                              exit(1);
                         }if (ids.getType($1) == "int") {
                              $$ = new exps("int");
                              int v1 = ids.getVarIntValue($1);
                              int v2 = ids.getVarIntValue($3);
                              bool value1 = ids.compute_int_cmp(v1, $2, v2);

                              $$->setExpBoolValue(value1);
                         }else if (ids.getType($1) == "float") {
                              $$ = new exps("float");
                              float x1 = ids.getVarFloatValue($1);
                              float x2 = ids.getVarFloatValue($3);
                              bool value2 = ids.compute_float_cmp(x1, $2, x2);

                              $$->setExpBoolValue(value2);
                         }
                    }else {
                         cout << "Variabilele " << $1 << " si " << $3 << " nu au acelasi tip!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else {
                    cout << "Variabilele nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }
           }

           | ID BOOL_OPERATORS ID

           {
               if (ids.existsVar($1) && ids.existsVar($3)) {
                    if (ids.sameType($1, $3)) {
                         if (ids.getType($1) == "bool") {
                              $$ = new exps("bool");

                              bool var1 = ids.getVarBoolValue($1);
                              bool var2 = ids.getVarBoolValue($3);
                              bool value3 = ids.compute_bool_value(var1, $2, var2);
                              $$->setExpBoolValue(value3);

                         }else if (ids.getType($1) != "bool") {
                              cout << "Operatia nu se poate aplica pe variabile de tip " << ids.getType($1) << endl;
                              yyerror("->");
                              exit(1);
                         }

                    }else {
                         cout << "Variabilele nu au acelasi tip!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else {
                    cout << "Variabila nu exista!" << endl;
                    yyerror("->");
                    exit(1); 
               }

           }

           | ID MATH_OPERATORS NR

           {
               if (ids.existsVar($1)) {
                    if (ids.getType($1) == "int") {
                         $$ = new exps("int");

                         int v1 = ids.getVarIntValue($1);
                         int value1 = ids.compute_int_math(v1, $2, $3);
                         $$->setExpIntValue(value1);
          
                    }else {
                         cout << "Variabila " << $1 << " nu este de tip int!";
                         yyerror("->");
                         exit(1);
                    }

               }else {
                    cout << "Variabila " << $1 << " nu exista";
                    yyerror("->");
                    exit(1);
               }
           }

           | ID CMP_OPERATORS NR

           {
               if (ids.existsVar($1)) {
                    if (ids.getType($1) == "int") {
                         $$ = new exps("int");

                         int v1 = ids.getVarIntValue($1);
                         bool value1 = ids.compute_int_cmp(v1, $2, $3);
                         $$->setExpBoolValue(value1);
          
                    }else {
                         cout << "Variabila " << $1 << " nu este de tip int!";
                         yyerror("->");
                         exit(1);
                    }

               }else {
                    cout << "Variabila " << $1 << " nu exista";
                    yyerror("->");
                    exit(1);
               }
           }

           | ID MATH_OPERATORS FLT

           {
               if (ids.existsVar($1)) {
                    if (ids.getType($1) == "float") {
                         $$ = new exps("float");

                         float v1 = ids.getVarFloatValue($1);
                         float value1 = ids.compute_float_math(v1, $2, $3);
                         $$->setExpFloatValue(value1);
          
                    }else {
                         cout << "Variabila " << $1 << " nu este de tip float!";
                         yyerror("->");
                         exit(1);
                    }

               }else {
                    cout << "Variabila " << $1 << " nu exista";
                    yyerror("->");
                    exit(1);
               }
           }

           | ID CMP_OPERATORS FLT

           {
               if (ids.existsVar($1)) {
                    if (ids.getType($1) == "float") {
                         $$ = new exps("float");

                         float v1 = ids.getVarFloatValue($1);
                         bool value1 = ids.compute_float_cmp(v1, $2, $3);
                         $$->setExpBoolValue(value1);
          
                    }else {
                         cout << "Variabila " << $1 << " nu este de tip float!";
                         yyerror("->");
                         exit(1);
                    }

               }else {
                    cout << "Variabila " << $1 << " nu exista";
                    yyerror("->");
                    exit(1);
               }
           }

           | ID BOOL_OPERATORS BOOL

           {
               if (ids.existsVar($1)) {
                    if (ids.getType($1) == "bool") {
                         $$ = new exps("bool");

                         bool v1 = ids.getVarBoolValue($1);
                         bool value1 = ids.compute_bool_value(v1, $2, $3);
                         $$->setExpBoolValue(value1);
          
                    }else {
                         cout << "Variabila " << $1 << " nu este de tip bool!";
                         yyerror("->");
                         exit(1);
                    }

               }else {
                    cout << "Variabila " << $1 << " nu exista";
                    yyerror("->");
                    exit(1);
               }
           }

           | NR MATH_OPERATORS ID

           {
               if (ids.existsVar($3)) {
                    if (ids.getType($3) == "int") {
                         $$ = new exps("int");

                         int v1 = ids.getVarIntValue($3);
                         int value = ids.compute_int_math($1, $2, v1);

                         $$->setExpIntValue(value);

                    }else {
                         cout << "Variabilele nu au acelasi tip! " << endl;
                         yyerror("->");
                         exit(1);
                    }

               }else {
                    cout << "Variabila " << $3 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }
           }

           | NR CMP_OPERATORS ID

           {
               if (ids.existsVar($3)) {
                    if (ids.getType($3) == "int") {
                         $$ = new exps("int");

                         int v1 = ids.getVarIntValue($3);
                         bool value = ids.compute_int_cmp($1, $2, v1);

                         $$->setExpBoolValue(value);

                    }else {
                         cout << "Variabilele nu au acelasi tip!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else {
                    cout << "Variabila " << $3 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }
           }

           | FLT MATH_OPERATORS ID

           {
               if (ids.existsVar($3)) {
                    if (ids.getType($3) == "float") {
                         $$ = new exps("float");

                         float v1 = ids.getVarFloatValue($3);
                         float value = ids.compute_float_math($1, $2, v1);

                         $$->setExpFloatValue(value);

                    }else {
                         cout << "Variabilele nu au acelasi tip!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else {
                    cout << "Variabila " << $3 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }
           }

           | FLT CMP_OPERATORS ID

           {
               if (ids.existsVar($3)) {
                    if (ids.getType($3) == "float") {
                         $$ = new exps("float");

                         float v1 = ids.getVarFloatValue($3);
                         bool value = ids.compute_float_cmp($1, $2, v1);

                         $$->setExpBoolValue(value);

                    }else {
                         cout << "Variabilele nu au acelasi tip!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else {
                    cout << "Variabila " << $3 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               }
           }

           | NR MATH_OPERATORS NR

           {
               $$ = new exps("int");
               int v1 = $1;
               int v2 = $3;

               int value = ids.compute_int_math(v1, $2, v2);
               $$->setExpIntValue(value);

           }

           | NR CMP_OPERATORS NR

           {
               $$ = new exps("int");
               int v1 = $1;
               int v2 = $3;

               bool value = ids.compute_int_cmp(v1, $2, v2);
               $$->setExpBoolValue(value);
           }

           | FLT MATH_OPERATORS FLT

           {
               $$ = new exps("float");
               float v1 = $1;
               float v2 = $3;

               float value = ids.compute_float_math(v1, $2, v2);
               $$->setExpFloatValue(value);
           }

           | FLT CMP_OPERATORS FLT

           {
               $$ = new exps("float");
               float v1 = $1;
               float v2 = $3;

               bool value = ids.compute_float_cmp(v1, $2, v2);
               $$->setExpBoolValue(value);
           }

           | BOOL BOOL_OPERATORS ID

           {
               if (ids.existsVar($3)) {
                    if (ids.getType($3) == "bool") {
                         $$ = new exps("bool");

                         bool v1 = ids.getVarFloatValue($3);
                         bool value = ids.compute_bool_value($1, $2, v1);

                         $$->setExpBoolValue(value);

                    }else {
                         cout << "Variabilele nu au acelasi tip!" << endl;
                         yyerror("->");
                         exit(1);
                    }
               }else if(!ids.existsVar($3) || !ids.existsFunc($3)){
                    cout << "Variabila " << $3 << " nu exista!" << endl;
                    yyerror("->");
                    exit(1);
               } 
           }

           | BOOL BOOL_OPERATORS BOOL


           {
               $$ = new exps("bool");
               bool v1 = $1;
               bool v2 = $3;

               bool value = ids.compute_bool_value(v1, $2, v2);
               $$->setExpBoolValue(value);
           }
           ;

list_identifiers_int : NR
                 | list_identifiers_int ',' NR 
                 ;

list_identifiers_bool : BOOL
                 | list_identifiers_int ',' BOOL 
                 ;

%%
void yyerror(const char * s){
printf("error: %s at line:%d\n",s,yylineno);
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");
     yyparse();

     // fout << "Variables:" << endl;
     ids.printVars();

     // fout << endl;
     // fout << "Functions:" << endl;
     ids.printFunctions();

     cout << endl;
}
