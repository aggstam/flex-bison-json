/* -------------------------------------------------------------------------*/
/*                                                                          */
/* This Flex program produces the corresponding C code to execute           */
/* semantic analysis of provided JSON file.                                 */
/*                                                                          */
/* Author: Aggelos Stamatiou, June 2017                                     */
/*                                                                          */
/* This source code is free software: you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by     */
/* the Free Software Foundation, either version 3 of the License, or        */
/* (at your option) any later version.                                      */
/*                                                                          */
/* This software is distributed in the hope that it will be useful,         */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            */
/* GNU General Public License for more details.                             */
/*                                                                          */
/* You should have received a copy of the GNU General Public License        */
/* along with this source code. If not, see <http://www.gnu.org/licenses/>. */
/* -------------------------------------------------------------------------*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "jsonValidator.h"

int yylex();
int yyerror(const char* msg);
int line = 1;
%}

%union{
    char  str[250];
    int   num;
    float numf;
    struct {
        jsonType type;
        char name[250];
        int len;
    } entity;
}

/* Output informative error messages (bison Option) */
%define parse.error verbose

/* Token declarations */
%token <entity> T_type
%token <str> T_string
%token <entity> T_number
%token T_true
%token T_false
%token T_null
%token '('
%token ')'
%token '{'
%token '}'
%token ':'
%token ','
%token '['
%token ']'

/* Type declarations */
%type<entity> array
%type<entity> elements
%type<entity> value

%%
json:
    {
        initSymbolTable();
    } 
    pair_declarations
    object
    ;

pair_declarations:
    |'(' T_string T_type ')' {
        if (!addvar($2, $3.type, 1)) {
            printf("Entity:: %s on line %d. ", $2, line);
            yyerror("Entity already defined. Discarting.");
        }
    }
    pair_declarations
    |'(' T_string T_type T_number ')' {
        $4.len = atoi($4.name);
        if(!addvar($2, $3.type, $4.len)) {
            printf("Entity:: %s on line %d. ",$2,line);
            yyerror("Entity already defined Discarting.");
        }
    }
    pair_declarations
    ;

object:
    '{'/* empty */'}'
    |'{'members'}'
    ;

members:
    pair 
    |pair ',' members
    |error ',' members
    ;

pair:
    T_string ':' value {
        if(!lookup($1)) {
            printf("Entity %s has not been declared. ", $1);
            yyerror("Missing Declation!");
        } else if(lookup_type($1) != $3.type) {
            if($3.type == type_integer) {
                printf("Entity (%s : int) Expected Type %s. ", $1, nameOfType(lookup_type($1)));
            } else if($3.type == type_real) {
                printf("Entity (%s : real) Expected Type %s. ", $1, nameOfType(lookup_type($1)));
            } else{
                printf("Entity (%s : %s) Expected Type %s. ", $1, $3.name, nameOfType(lookup_type($1)));
            }
            yyerror("Type Missmatch!");
        } else if($3.type == type_array && lookup_length($1) != $3.len) {
            printf("Entity (%s : array) Expected Length %d, not %d. ", $1, lookup_length($1), $3.len);
            yyerror("Length Missmatch!");
        }
    }
    ;

array:
    '['/* empty */']' {$$.len = 0;}
    |'['elements']' {$$.len = $2.len;}
    ;

elements:
    value {$$.len = 1;}
    |value ',' elements {$$.len = 1 + $3.len;}
    |error ',' elements {$$.len = 1 + $3.len;}
    ;

value:
    T_string {$$.type = type_string;strcpy($$.name,$1);;}
    |T_number {$$.type = $1.type;strcpy($$.name,$1.name);}
    |object {$$.type = type_object;strcpy($$.name,"object");}
    |array {$$.type = type_array;strcpy($$.name,"array");$$.len = $1.len;}
    |T_true {$$.type = type_constant;strcpy($$.name,"true");}
    |T_false {$$.type = type_constant;strcpy($$.name,"false");}
    |T_null {$$.type = type_constant;strcpy($$.name,"null");}
    ;
%%

/* Line that includes the lexical analyser */
#include "json_lexer.c"

/* The usual yyerror, + line number indication. The variable line is defined in the lexical analyser.*/
int yyerror(const char* msg) {
   printf("ERROR in line %d: %s.\n", line, msg);
}

int main (int argc, char** argv) {
    ++argv, --argc; /* skip over program name */
    if ( argc > 0 ) {
        yyin = fopen( argv[0], "r" );
    } else {
        yyin = stdin;
    }

    int res = yyparse();
    printf("Total Syntax Errors found %d \n", yynerrs);

    return 0;
}
