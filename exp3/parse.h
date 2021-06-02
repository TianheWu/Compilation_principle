#include "backpatch.h"

#define TYPE_IDN 0
#define TYPE_NUM 1
#define TYPE_TEMP 5
#define TYPE_TAC 6
#define TYPE_LIST 10

typedef struct ast_node
{
    int pattern;

    double num;
    char idn[20];
    int temp;
    int tac_line;

    struct ast_node *l;
    struct ast_node *m;
    struct ast_node *r;

    list_node *true_list;
    list_node *false_list;
    list_node *next_list;

    /**
     * > | < | =
     */
    char relop;

    // see defination of "parse.h"
    int type;

} ast_node;

char *print_product(int pattern)
{
    char *s;
    s = (char *)malloc(30);
    switch (pattern)
    {
    case 1:
        strcpy(s, "P -> L");
        break;
    case 2:
        strcpy(s, "P -> LP");
        break;
    case 3:
        strcpy(s, "L -> S;");
        break;
    case 4:
        strcpy(s, "S -> id = E     id = ");
        break;
    case 5:
        strcpy(s, "S -> if C then S'");
        break;
    case 6:
        strcpy(s, "S -> while C do S");
        break;
    case 7:
        strcpy(s, "S -> {P}");
        break;
    case 8:
        strcpy(s, "S' -> S");
        break;
    case 9:
        strcpy(s, "S' -> S else S");
        break;
    case 10:
        strcpy(s, "C -> EC'");
        break;
    case 11:
        strcpy(s, "C' -> > E");
        break;
    case 12:
        strcpy(s, "C' -> < E");
        break;
    case 13:
        strcpy(s, "C' -> = E");
        break;
    case 14:
        strcpy(s, "E -> T");
        break;
    case 15:
        strcpy(s, "E -> E + T");
        break;
    case 16:
        strcpy(s, "E -> E - T");
        break;
    case 17:
        strcpy(s, "T -> F");
        break;
    case 18:
        strcpy(s, "T -> T * F");
        break;
    case 19:
        strcpy(s, "T -> T / F");
        break;
    case 20:
        strcpy(s, "F -> ( E )");
        break;
    case 21:
        strcpy(s, "F -> id     id = ");
        break;
    case 22:
        strcpy(s, "F -> int8     int8 = ");
        break;
    case 23:
        strcpy(s, "F -> int10     int10 = ");
        break;
    case 24:
        strcpy(s, "F -> int16     int16 = ");
        break;
    case 25:
        strcpy(s, "F -> float8     float8 = ");
        break;
    case 26:
        strcpy(s, "F -> float10     float10 = ");
        break;
    case 27:
        strcpy(s, "F -> float16     float16 = ");
        break;
    default:
        strcpy(s, "UNDEFINED");
        break;
    }
    return s;
}

ast_node *create_num_node(int pattern, double num)
{
    ast_node *res;
    res = (ast_node *)malloc(sizeof(ast_node));
    res->pattern = pattern;
    res->num = num;
    memset(res->idn, 0, sizeof(res->idn));
    res->l = NULL;
    res->m = NULL;
    res->r = NULL;
    return res;
}

ast_node *create_IDN_node(int pattern, char *idn)
{
    ast_node *res;
    res = (ast_node *)malloc(sizeof(ast_node));
    res->pattern = pattern;
    strcpy(res->idn, idn);
    res->l = NULL;
    res->m = NULL;
    res->r = NULL;
    return res;
}

ast_node *create_ast_node(int pattern, ast_node *l, ast_node *m, ast_node *r)
{
    ast_node *res;
    res = (ast_node *)malloc(sizeof(ast_node));
    res->pattern = pattern;
    res->num = -1;
    memset(res->idn, 0, sizeof(res->idn));
    res->l = l;
    res->m = m;
    res->r = r;
    return res;
}

ast_node *create_ast_node_for_IDN(int pattern, char *idn, ast_node *l, ast_node *m, ast_node *r)
{
    ast_node *res;
    res = (ast_node *)malloc(sizeof(ast_node));
    res->pattern = pattern;
    res->num = -1;
    strcpy(res->idn, idn);
    res->l = l;
    res->m = m;
    res->r = r;
    return res;
}

void print_grammar_tree(ast_node *node, FILE *file)
{
    if (node == NULL)
    {
        return;
    }
    char *production = print_product(node->pattern);
    fprintf(file, "%s", production);
    if (node->pattern >= 22 && node->pattern <= 24)
        fprintf(file, "%d", (int)node->num);
    if (node->pattern >= 25 && node->pattern <= 27)
        fprintf(file, "%f", node->num);
    if (strlen(node->idn) > 0)
        fprintf(file, "%s", node->idn);
    fprintf(file, "\n");

    if (node->l != NULL)
        print_grammar_tree(node->l, file);
    if (node->m != NULL)
        print_grammar_tree(node->m, file);
    if (node->r != NULL)
        print_grammar_tree(node->r, file);
}