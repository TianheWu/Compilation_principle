struct astNode {
    int pattern;
    double num;
    char idn[20];
    struct astNode *l;
    struct astNode *m;
    struct astNode *r;
};


char* printProduction(int type) {
    char* s;
    s = (char*)malloc(30);
    switch(type) {
        case 1: strcpy(s, "P -> L"); break;
        case 2: strcpy(s, "P -> LP"); break;
        case 3: strcpy(s, "L -> S;"); break;
        case 4: strcpy(s, "S -> id = E     id = "); break;
        case 5: strcpy(s, "S -> if C then S'"); break;
        case 6: strcpy(s, "S -> while C do S"); break;
        case 7: strcpy(s, "S -> {P}"); break;
        case 8: strcpy(s, "S' -> S"); break;
        case 9: strcpy(s, "S' -> S else S"); break;
        case 10: strcpy(s, "C -> EC'"); break;
        case 11: strcpy(s, "C' -> > E"); break;
        case 12: strcpy(s, "C' -> < E"); break;
        case 13: strcpy(s, "C' -> = E"); break;
        case 14: strcpy(s, "E -> T"); break;
        case 15: strcpy(s, "E -> E + T"); break;
        case 16: strcpy(s, "E -> E - T"); break;
        case 17: strcpy(s, "T -> F"); break;
        case 18: strcpy(s, "T -> T * F"); break;
        case 19: strcpy(s, "T -> T / F"); break;
        case 20: strcpy(s, "F -> ( E )"); break;
        case 21: strcpy(s, "F -> id     id = "); break;
        case 22: strcpy(s, "F -> int8     int8 = "); break;
        case 23: strcpy(s, "F -> int10     int10 = "); break;
        case 24: strcpy(s, "F -> int16     int16 = "); break;
        case 25: strcpy(s, "F -> float8     float8 = "); break;
        case 26: strcpy(s, "F -> float10     float10 = "); break;
        case 27: strcpy(s, "F -> float16     float16 = "); break;
        default: strcpy(s, "UNDEFINED");  break;
    }
    return s;
}


struct astNode *createNumNode(int pattern, double num) {
    struct astNode *res;
    res = (struct astNode*)malloc(sizeof (struct astNode));
    res->pattern = pattern;
    res->num = num;
    memset(res->idn, 0, sizeof(res->idn));
    res->l = NULL;
    res->m = NULL;
    res->r = NULL;
    return res;
}


struct astNode *createIdnNode(int pattern, char* idn) {
    struct astNode *res;
    res = (struct astNode*)malloc(sizeof (struct astNode));
    res->pattern = pattern;
    strcpy(res->idn, idn);
    res->l = NULL;
    res->m = NULL;
    res->r = NULL;
    return res;
}


struct astNode *createAstNode(int pattern, struct astNode* l, struct astNode* m, struct astNode* r) {
    struct astNode *res;
    res = (struct astNode*)malloc(sizeof (struct astNode));
    res->pattern = pattern;
    res->num = -1;
    memset(res->idn, 0, sizeof(res->idn));
    res->l = l;
    res->m = m;
    res->r = r;
    return res;
}


struct astNode *createAstNodeForIdn(int pattern, char* idn, struct astNode* l, struct astNode* m, struct astNode* r) {
    struct astNode *res;
    res = (struct astNode*)malloc(sizeof (struct astNode));
    res->pattern = pattern;
    res->num = -1;
    strcpy(res->idn, idn);
    res->l = l;
    res->m = m;
    res->r = r;
    return res;
}


void printGrammarTree(struct astNode* node, FILE* file) {
    if (node == NULL) {
        return;
    }
    char* production = printProduction(node->pattern);
    fprintf(file, "%s", production);
    if (node -> pattern >= 22 && node -> pattern <= 24) fprintf(file, "%d", (int)node -> num);
    if (node -> pattern >= 25 && node -> pattern <= 27) fprintf(file, "%f", node -> num);
    if (strlen(node -> idn) > 0) fprintf(file, "%s", node -> idn);
    fprintf(file, "\n");

    if (node -> l != NULL)
        printGrammarTree(node -> l, file);
    if (node -> m != NULL)
        printGrammarTree(node -> m, file);
    if (node -> r != NULL)
        printGrammarTree(node -> r, file);
}