%option noyywrap yylineno
%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "parse.tab.h"
void yyerror(char *s, ...);
int yycolumn = 1;
int htoi(char s[]);
int otoi(char *p);
char* itoa(int num,char *str);
char* ftoa(float num,char *str);
double aotof(char *p);
double ahtof(char *p);

#define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno;            \
        yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
        yycolumn += yyleng;

%}

DIGIT	[0-9]
LETTER	[A-Za-z]
HEX		[0-9a-f]

IDN		{LETTER}({LETTER}|{DIGIT})*([_.]({LETTER}|{DIGIT})+)?
INT8	00|0[1-7][0-7]*
INT10	0|([1-9]{DIGIT}*)
INT16	(0x|0X){HEX}+
REAL8	0[0-7]+([.][0-7]+)?
REAL10	(0|[1-9]{DIGIT}*)([.]{DIGIT}+)?
REAL16	(0x|0X){HEX}+([.]{HEX}+)?
MARK	[+]|[-]|[*]|[/]|[>]|[<]|[=]|[(]|[)]|[;]|[{]|[}]

%%

while		{return WHILE;}
if			{return IF;}
then		{return THEN;}
else		{return ELSE;}
do			{return DO;}
{MARK}		{return yytext[0];}
{IDN}		{yylval.str_val = strdup(yytext); return IDN;}
{INT10}	    {yylval.int_val = atoi(yytext); return INT10;}
{INT8}		{yylval.int_val = otoi(yytext); return INT8;}
{INT16}	    {yylval.int_val = htoi(yytext); return INT16;}
{REAL10}	{yylval.double_val = atof(yytext); return REAL10;}
{REAL8}	    {yylval.double_val = aotof(yytext); return REAL8;}
{REAL16}	{yylval.double_val = ahtof(yytext); return REAL16;}

.			{;}
\n          {}


%%

char* itoa(int num,char *str)
{
    int i = 0;
    if(num<0) {
        num = -num;
        str[i++] = '-';
    }
    do {
        str[i++] = num%10+48;
        num /= 10;
    } while(num);
    str[i] = '\0';
    int j = 0;
    if(str[0]=='-') {
        j = 1;
        ++i;
    }
    for(;j < i/2; j++) {
        str[j] = str[j] + str[i-1-j];
        str[i-1-j] = str[j] - str[i-1-j];
        str[j] = str[j] - str[i-1-j];
    }
    return str;
}

char* ftoa(float num,char *str)
{
    int i = 0;
    if(num<0) {
        num = -num;
        str[i++] = '-';
    }
    do {
		num *= 10;
		int tmp=floor(num);
		num -= tmp;
        str[i++] = tmp%10+48;
    } while(num>0);
    str[i] = '\0';
    int j = 0;
    if(str[0]=='-') {
        j = 1;
        ++i;
    }
    return str;
}


double aotof(char *p) {
    int fcount = 0;
    int i = 0;
    int f = 0;
    while (*p != '.') {
        i = i * 8 + *p -'0';
        p ++;
    }
    p ++;
    while (*p != '\0') {
        f = f * 8 + *p - '0';
        p ++;
        fcount ++;
    }
    for (int j = 0; j < fcount; j ++) {
        f *= 1000 / 8;
    }
    char s[100];
    sprintf(s, "%d.%0*d", i, fcount*3, f);
    return atof(s);
}

double ahtof(char *p){
    int fcount = 0;
    int i = 0;
    float f = 0;
	while (*p!='x') p ++;
	p ++;
    while (*p != '.') {
		int tmp;
		if ( *p <= '9') tmp = *p - '0';
		else tmp = 10 + *p - 'a';
        i = i * 16 + tmp;
        p ++;
    }
    p++;
    while (*p != '\0') {
		int tmp;
		if ( *p <= '9') tmp = *p - '0';
		else tmp = 10 + *p - 'a';
        f = f * 16 + tmp;
        p ++;
        fcount ++;
    }
    for (int j = 0; j < fcount; j ++) {
        f *= 0.0625;
    }
    char si[100];
    char sf[100];
    char s[100];
    itoa(i, si);
	ftoa(f, sf);
    strcat(si, ".");
    strcpy(s, si);
    strcat(s, sf);
    return atof(s);
}

int otoi(char *p)
{   
	int n;
    n= *p-'0';
    p++;
    while(*p!='\0') {
    	n=n*8+*p-'0';
    	p++;
    }
    return n;
}

int htoi(char s[])
{
    int i=2;
    int n=0;
    for(;s[i]!='\0';++i)
    {
        if(s[i]>'9')
        {
            n=16*n+(10+s[i]-'a');
        }
        else
        {
            n=16*n+(s[i]-'0');
        }
    }
    return n;
}
