#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct list_node
{
    struct list_node *next;
    int quad; // the line number of a quad
} list_node;

struct list_node *makelist(int quad)
{
    struct list_node *node;
    node = (list_node *)malloc(sizeof(list_node));
    node->quad = quad;
    return node;
}

struct list_node *merge(list_node *l1, list_node *l2)
{
    struct list_node *l = (list_node *)malloc(sizeof(list_node));
    struct list_node *now = l;
    while (l1)
    {
        struct list_node *tmp = (list_node *)malloc(sizeof(list_node));
        tmp->quad = l1->quad;
        now->next = tmp;
        now = tmp;
        l1 = l1->next;
    }
    while (l2)
    {
        struct list_node *tmp = (list_node *)malloc(sizeof(list_node));
        tmp->quad = l2->quad;
        now->next = tmp;
        now = tmp;
        l2 = l2->next;
    }

    return l->next;
}
