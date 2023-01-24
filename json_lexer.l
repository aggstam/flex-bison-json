/* -------------------------------------------------------------------------*/
/*                                                                          */
/* This Flex program produces the corresponding C code to validate          */
/* the syntax of provided JSON file.                                        */
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
#include <stdlib.h>
#include <string.h>
%}

D [0-9]
REAL {D}+\.{D}*
newline \n|\x0A|\x0D\x0A

/* The lexer returns the ASCII code of the character found! */
/* Since the lexer returns tokens as integers, in the case of a single character, */
/* we do not need to specify a new token as in the case of keywords above. */
/* We simply return the ASCII code itself. */

%%
"true"      {return T_true;}
"false"     {return T_false;}
"null"      {return T_null;}
")"         {return ')';}
"("         {return '(';}
"{"         {return '{';}
"}"         {return '}';}
":"         {return ':';}
","         {return ',';}
"["         {return '[';}
"]"         {return ']';}
"array"     {yylval.entity.type = type_array; return T_type;}
"int"       {yylval.entity.type = type_integer; return T_type;}
"float"     {yylval.entity.type = type_real; return T_type;}
"object"    {yylval.entity.type = type_object; return T_type;}
"string"    {yylval.entity.type = type_string; return T_type;}
"const"     {yylval.entity.type = type_constant; return T_type;}
{D}+        {strcpy(yylval.entity.name,yytext); yylval.entity.type = type_integer; return T_number;}
{REAL}      {strcpy(yylval.entity.name,yytext); yylval.entity.type = type_real; return T_number;}
\"([^"])*\" {strcpy(yylval.str,yytext); return T_string;}
{newline}   {line++;}
[ \t]       { /* nothing to be done when space or a tab is found!*/ }
. {
    /* A simple error message! */
    printf("Lexical Analysis: Unexpected String! :: %s  in line %d. \n", yytext, line);
    int c;
    while((c = yylex()) != ',' && c != '}' && c != ']' && c != ')');
    return c;
}
%%
