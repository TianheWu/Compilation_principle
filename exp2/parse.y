%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "parse.h"
extern char *yytext;
void yyerror(char *s);
int yylex();
struct astNode *root;
%}

%debug

%locations

%union {
    int intval;
    double doubleval;
    char *strval;
    struct astNode *node;
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

P   :   L               {$$ = createAstNode(1, NULL, $1, NULL); root = $$;}
    |   L P             {$$ = createAstNode(2, $1, NULL, $2); root = $$;}
    ;

L   :   S ';'           {$$ = createAstNode(3, NULL, $1, NULL);}
    ;

S   :   IDN '=' E               {$$ = createAstNodeForIdn(4, $1, NULL, $3, NULL);}
    |   IF C THEN SP            {$$ = createAstNode(5, $2, NULL, $4);}
    |   WHILE C DO S            {$$ = createAstNode(6, $2, NULL, $4);}
    |   '{' P '}'               {$$ = createAstNode(7, NULL, $2, NULL);}
    ;

SP  :   S               {$$ = createAstNode(8, NULL, $1, NULL);}
    |   S ELSE S        {$$ = createAstNode(9, $1, NULL, $3);}
    ;

C   :   E CP            {$$ = createAstNode(10, $1, NULL, $2);}
    ;

CP  :   '>' E           {$$ = createAstNode(11, NULL, $2, NULL);}
    |   '<' E           {$$ = createAstNode(12, NULL, $2, NULL);}
    |   '=' E           {$$ = createAstNode(13, NULL, $2, NULL);}
    ;

E   :   T               {$$ = createAstNode(14, NULL, $1, NULL);}
    |   E '+' T         {$$ = createAstNode(15, $1, NULL, $3);}
    |   E '-' T         {$$ = createAstNode(16, $1, NULL, $3);}
    ;

T   :   F               {$$ = createAstNode(17, NULL, $1, NULL);}
    |   T '*' F         {$$ = createAstNode(18, $1, NULL, $3);}
    |   T '/' F         {$$ = createAstNode(19, $1, NULL, $3);}
    ;

F   :   '(' E ')'       {$$ = createAstNode(20, NULL, $2, NULL);}
    |   IDN             {$$ = createIdnNode(21, $1);}
    |   INT8            {$$ = createNumNode(22, $1);}
    |   INT10           {$$ = createNumNode(23, $1);}
    |   INT16           {$$ = createNumNode(24, $1);}
    |   FLOAT8          {$$ = createNumNode(25, $1);}
    |   FLOAT10         {$$ = createNumNode(26, $1);}
    |   FLOAT16         {$$ = createNumNode(27, $1);}
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
	printGrammarTree(root, f);
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