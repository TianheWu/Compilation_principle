%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "parse.h"
extern char *yytext;
void yyerror(char *s);
int yylex();
ast_node *root;
%}

%debug

%locations

%union {
    int intval;
    double doubleval;
    char *strval;
    struct ast_node *node;
}

%expect 1

%token WHILE
%token IF
%token THEN
%token ELSE
%token DO

%token <strval> IDN

%token <intval> INT8
%token <intval> INT10
%token <intval> INT16

%token <doubleval> FLOAT8
%token <doubleval> FLOAT10
%token <doubleval> FLOAT16

%left '<' '>'
%left '+' '-'
%left '*' '/'

%type <node> P L S SP C CP E T F

%start P

%%

P   :   L               {$$ = create_ast_node(1, NULL, $1, NULL); root = $$;}
    |   L P             {$$ = create_ast_node(2, $1, NULL, $2); root = $$;}
    ;

L   :   S ';'           {$$ = create_ast_node(3, NULL, $1, NULL);}
    ;

S   :   IDN '=' E               {$$ = create_ast_node_for_IDN(4, $1, NULL, $3, NULL);}
    |   IF C THEN SP            {$$ = create_ast_node(5, $2, NULL, $4);}
    |   WHILE C DO S            {$$ = create_ast_node(6, $2, NULL, $4);}
    |   '{' P '}'               {$$ = create_ast_node(7, NULL, $2, NULL);}
    ;

SP  :   S               {$$ = create_ast_node(8, NULL, $1, NULL);}
    |   S ELSE S        {$$ = create_ast_node(9, $1, NULL, $3);}
    ;

C   :   E CP            {$$ = create_ast_node(10, $1, NULL, $2);}
    ;

CP  :   '>' E           {$$ = create_ast_node(11, NULL, $2, NULL);}
    |   '<' E           {$$ = create_ast_node(12, NULL, $2, NULL);}
    |   '=' E           {$$ = create_ast_node(13, NULL, $2, NULL);}
    ;

E   :   T               {$$ = create_ast_node(14, NULL, $1, NULL);}
    |   E '+' T         {$$ = create_ast_node(15, $1, NULL, $3);}
    |   E '-' T         {$$ = create_ast_node(16, $1, NULL, $3);}
    ;

T   :   F               {$$ = create_ast_node(17, NULL, $1, NULL);}
    |   T '*' F         {$$ = create_ast_node(18, $1, NULL, $3);}
    |   T '/' F         {$$ = create_ast_node(19, $1, NULL, $3);}
    ;

F   :   '(' E ')'       {$$ = create_ast_node(20, NULL, $2, NULL);}
    |   IDN             {$$ = create_IDN_node(21, $1);}
    |   INT8            {$$ = create_num_node(22, $1);}
    |   INT10           {$$ = create_num_node(23, $1);}
    |   INT16           {$$ = create_num_node(24, $1);}
    |   FLOAT8          {$$ = create_num_node(25, $1);}
    |   FLOAT10         {$$ = create_num_node(26, $1);}
    |   FLOAT16         {$$ = create_num_node(27, $1);}
    ;

%%

int main(int argc, const char *args[]) {
    extern FILE *yyin;

	if(argc > 1 && (yyin = fopen(args[1], "r")) == NULL) {
		fprintf(stderr, "can not open %s\n", args[1]);
		exit(1);
	}

	if(yyparse()) {
		exit(-1);
	}

    FILE * f;
    f = fopen("out.txt", "w+");
    print_grammar_tree(root, f);
    return 0;
}

void yyerror(char *s) {
    extern int yylineno;
    extern YYLTYPE yylloc;
    //extern char yytext [];
    int errflag = 1;
    int start = yylloc.first_column;
    int end = yylloc.last_column;
    int i;
    printf("Unexpected '%s' \n",yytext);
    fprintf(stderr, "Error: %s on Line: %d:c%d to %d:c%d\n\n", s, yylineno, start, yylineno, end);
}