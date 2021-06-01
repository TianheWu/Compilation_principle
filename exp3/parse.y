%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "parse.h"

const int MAX_TAC_CNTS = 100;
const int MAX_TAC_LENGTH = 1000;

// the string currently scanned
extern char *yytext;

void yyerror(char *s);
int yylex();
ast_node *root;


void print_get_tac_last_pos_code(FILE* f);

// get_tac_last_pos_tac() is a function to get_tac_last_poserate the TAC code and storage it to get_tac_last_pos_str[next_tac], then next_tac plus.
void get_tac_last_pos_tac(ast_node* result, char op, ast_node* arg1, ast_node* arg2, int extra);

// the place to save TAC
char *get_tac_last_pos_str[MAX_TAC_CNTS];

// create a new temporary variable for ast_node and set node type to temp
ast_node* new_temp(ast_node* node);

// means the next line number of tac
int next_tac = 0;

// the starting line number
int start_tac = 100;

// give the variable a name to specific TAC
void allocate_var_name(ast_node *node);

// function means the valid pointer that is able to add string fo a TAC
char* get_tac_last_pos();

// numbers of temporary variables
int temp_cnts = 0;

// backpatch all lines in list
void backpatch(struct list_node* p, int quad);

%}

%debug

%locations

%union {
    int int_val;
    double double_val;
    char* str_val;
    struct ast_node* node;
}

%expect 1

%token WHILE
%token IF
%token THEN
%token ELSE
%token DO

%token <str_val> IDN

%token <int_val> INT8
%token <int_val> INT10
%token <int_val> INT16

%token <double_val> FLOAT8
%token <double_val> FLOAT10
%token <double_val> FLOAT16

%left '<' '>'
%left '+' '-'
%left '*' '/'

%type <node> P L S SP C CP E T F
%type <int_val> LABEL

%start P

%%

P: L            { $$ = create_ast_node(1, NULL, $1, NULL); root = $$;}
 | L P          { $$ = create_ast_node(2, $1, NULL, $2); root = $$;}
 ;

L: S ';' LABEL       { $$ = create_ast_node(3, NULL, $1, NULL); backpatch($1->nextlist,$3);}
 ;

S: IDN '=' E            { $$ = create_ast_node_for_IDN(4, $1, NULL, $3, NULL); get_tac_last_pos_tac($$,'=',$3,NULL,0);}
 | IDN error '=' E      { yyerrok; }
 | IDN '=' error E      { yyerrok; }
 | IDN error            { yyerrok; }
 | error '=' error      { yyerrok; }
 | IF C THEN LABEL SP       { $$ = create_ast_node(5, $2, NULL, $5); 
                          backpatch($2->truelist,$4); 
                          $$->nextlist=merge($2->falselist,$5->nextlist); 
                          if($5->type==6)  backpatch($2->falselist,$5->quad);}
 | IF error C THEN SP    { yyerrok; }
 | IF C error THEN SP    { yyerrok; }
 | IF C THEN error SP    { yyerrok; }
 | IF error THEN SP      { yyerrok; }
 | WHILE LABEL C DO LABEL S         { $$ = create_ast_node(6, $3, NULL, $6); backpatch($6->nextlist,$2); backpatch($3->truelist,$5); $$->nextlist=merge($$->nextlist,$3->falselist); get_tac_last_pos(NULL,'9',NULL,NULL,$2);}
 | WHILE error LABEL C DO LABEL S       { yyerrok; }
 | WHILE LABEL C error DO LABEL S       { yyerrok; }
 | WHILE LABEL C error DO error LABEL S     { yyerrok; }
 | '{' P '}'            { $$ = create_ast_node(7, NULL, $2, NULL); }
 | IF C LABEL SP	{ printf("expected 'then' before '%s' ",yytext); yyerror("missing THEN"); }
 | IF C F	{ printf("expected 'then' before '%s' ",yytext);yyerror("missing THEN"); }
 | WHILE LABEL C LABEL S	{ printf("expected 'do' before '%s' \n",yytext); yyerror("missing DO");}
 | WHILE LABEL C E	{ printf("expected 'do' before '%s' \n",yytext); yyerror("missing DO");}
 | DO	{ printf("WHILE statement not detected before 'do' \n");yyerror("missing WHILE");}
 
 ;

SP: S           { $$ = create_ast_node(8, NULL, $1, NULL); $$->nextlist=$1->nextlist;$$->truelist=$1->truelist;$$->falselist=$1->falselist;}
  | S LABEL ELSE LABEL S    { $$ = create_ast_node(9, $1, NULL, $5); get_tac_last_pos_tac(NULL,'0',NULL,NULL,9); $$->nextlist=merge(makelist($2),$5->nextlist); $$->quad=$4; $$->type=6; }
  ;

C: E CP         { $$ = create_ast_node(10, $1, NULL, $2); 
                  $$ -> truelist = makelist(nextquad); 
                  $$ -> falselist = makelist(nextquad+1);
                  get_tac_last_pos_tac(NULL,$2->relop,$1,$2,1); 
                  get_tac_last_pos_tac(NULL,'0',NULL,NULL,9); }

 | E error CP   { yyerrok; }
 | error CP     { yyerrok; }
  
 ;

CP: '>' E       { $$ = create_ast_node(11, NULL, $2, NULL); $$ -> relop = '>';}
  | '<' E       { $$ = create_ast_node(12, NULL, $2, NULL); $$ -> relop = '<';}
  | '=' E       { $$ = create_ast_node(13, NULL, $2, NULL); $$ -> relop = '=';}
  | '>' error E { yyerrok; }
  | '<' error E { yyerrok; }
  | '=' error E { yyerrok; }
  ;

E: T            { $$ = create_ast_node(14, NULL, $1, NULL); $$ -> type = $1 ->type;}
  | E '+' T     { $$ = create_ast_node(15, $1, NULL, $3);  $$ = new_temp($$); get_tac_last_pos_tac($$,'+',$1,$3,0);}
  | E '-' T     { $$ = create_ast_node(16, $1, NULL, $3);  $$ = new_temp($$); get_tac_last_pos_tac($$,'-',$1,$3,0);}
  | E '+' error T { yyerrok; }
  | E '-' error T { yyerrok; }
  ;

T: F            { $$ = create_ast_node(17, NULL, $1, NULL); $$ -> type = $1 ->type;}
  | T '*' F     { $$ = create_ast_node(18, $1, NULL, $3);  $$ = new_temp($$); get_tac_last_pos_tac($$,'*',$1,$3,0);}
  | T '/' F     { $$ = create_ast_node(19, $1, NULL, $3);  $$ = new_temp($$); get_tac_last_pos_tac($$,'/',$1,$3,0);}
  | T '*' error F { yyerrok; }
  | T '/' error F { yyerrok; }
  ;

F: '(' E ')'    { $$ = create_ast_node(20, NULL, $2, NULL); }
  | IDN         { $$ = create_IDN_node(21, $1); }
  | INT8        { $$ = create_num_node(22, $1); }
  | INT10       { $$ = create_num_node(23, $1); }
  | INT16       { $$ = create_num_node(24, $1); }
  | FLOAT8      { $$ = create_num_node(25, $1); }
  | FLOAT10     { $$ = create_num_node(26, $1); }
  | FLOAT16     { $$ = create_num_node(27, $1); }
  | '('E error  { yyerrok; }
  ;

LABEL: %empty       { $$ = next_tac; }
  ;

%%

int main(int argc, const char *args[]) 
{
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

void yyerror(char *s) 
{
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

void print_get_tac_last_pos_code(FILE* f) 
{
    fprintf(f,"\n");

    for(int i = 0; i < next_tac; i++){
        fprintf(f,"%s\n", get_tac_last_pos_str[i]);
    }
}

void get_tac_last_pos_tac(ast_node* result, char op, ast_node* arg1, ast_node* arg2, int extra) 
{

    get_tac_last_pos_str[next_tac] = (char *)malloc(sizeof(char) * MAX_TAC_LENGTH);

    sprintf(get_tac_last_pos,"%d:\t", next_tac + start_tac);

    if(op == '9')
    {
        sprintf(get_tac_last_pos,"goto %d", extra + start_tac);
    }
    else if(extra == 0)
    {
        allocate_var_name(result);
        sprintf(get_tac_last_pos, " := ");
        if(op == '=')
        {
            allocate_var_name(arg1);
        }
        else
        {
            allocate_var_name(arg1);
            sprintf(get_tac_last_pos,"%c",op);
            allocate_var_name(arg2);
        }
    }
    else if(extra == 1)
    {
        sprintf(get_tac_last_pos, "if ");
        allocate_var_name(arg1);
        sprintf(get_tac_last_pos, " %c ", op);
        allocate_var_name(arg2);
        sprintf(get_tac_last_pos, " goto ");
    }
    else if(extra == 9)
    {
        sprintf(get_tac_last_pos,"goto ");
    }
    next_tac++;
}

void allocate_var_name(ast_node* node) 
{
    switch(node -> type){
        case TYPE_IDN:
            sprintf(get_tac_last_pos, "%s", node -> idn);
            break;
        case TYPE_NUM:
            sprintf(get_tac_last_pos, "%g", node -> num);
            break;
        case TYPE_TEMP:
            sprintf(get_tac_last_pos, "t%d", node -> temp);
            break;
        default:
            break;
    }
}

char* get_tac_last_pos() 
{
    return get_tac_last_pos_str[next_tac] + strlen(get_tac_last_pos_str[next_tac]);
}

void backpatch(list_node* p, int quad){
    while(p){
        sprintf(gen_str[p->quad]+strlen(gen_str[p->quad]),"%d",quad+startquad);
        p=p->next;
    }
}

ast_node* newtemp(ast_node* node){
  temp_cnts++;
  node -> temp = temp_cnts;
  node -> type = TYPE_TEMP;
  return node;
}