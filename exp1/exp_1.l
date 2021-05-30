%{
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

#define _INT_10 1
#define _INT_8 2
#define _INT_16 3
#define _REAL_10 4
#define _REAL_8 5
#define _REAL_16 6
#define _WHILE 7
#define _IF 8
#define _ELSE 9
#define _THEN 10
#define _DO 11
#define _IDN 12
#define _MARK 13
%}

DIGIT	[0-9]
LETTER	[A-Za-z]
HEX		[0-9a-f]

IDN		{LETTER}({LETTER}|{DIGIT})*([_.]({LETTER}|{DIGIT})+)?
INT_8	00|0[1-7][0-7]*
INT_10	0|([1-9]{DIGIT}*)
INT_16	(0x|0X){HEX}+
REAL_8	0[0-7]+([.][0-7]+)?
REAL_10	(0|[1-9]{DIGIT}*)([.]{DIGIT}+)?
REAL_16	(0x|0X){HEX}+([.]{HEX}+)?
MARK	[+]|[-]|[*]|[/]|[>]|[<]|[=]|[(]|[)]|[;]

%%

while		{return _WHILE;}
if			{return _IF;}
then		{return _THEN;}
else		{return _ELSE;}
do			{return _DO;}
{MARK}		{return _MARK;}
{IDN}		{return _IDN;}
{INT_10}	{return _INT_10;}
{INT_8}		{return _INT_8;}
{INT_16}	{return _INT_16;}
{REAL_10}	{return _REAL_10;}
{REAL_8}	{return _REAL_8;}
{REAL_16}	{return _REAL_16;}
.

%%

char* itoa(int num, char *str) {
    int i = 0;
    if (num < 0) {
        num = -num;
        str[i++] = '-';
    }
    do {
        str[i++] = num % 10 + 48;
        num /= 10;
    } while (num);
    str[i] = '\0';
    int j = 0;
    if (str[0]=='-') {
        j = 1;
        ++i;
    }
    for (; j < i / 2; j++) {
        str[j] = str[j] + str[i - 1 - j];
        str[i - 1 - j] = str[j] - str[i - 1 - j];
        str[j] = str[j] - str[i - 1 - j];
    }
    return str;
}

char* ftoa(float num, char *str)
{
    int i = 0;
    if (num < 0) {
        num = -num;
        str[i++] = '-';
    }
    do {
		num *= 10;
		int tmp = floor(num);
		num -= tmp;
        str[i++] = tmp % 10 + 48;
    } while (num > 0);
    str[i] = '\0';
    int j = 0;
    if (str[0] == '-') {
        j = 1;
        ++i;
    }
    return str;
}


char* fotoa(char *p) {
    int fcount = 0;
    int i = 0;
    int f = 0;
    while (*p != '.') {
        i = i * 8 + *p -'0';
        p++;
    }
    p++;
    while (*p != '\0') {
        f = f * 8 + *p - '0';
        p++;
        fcount++;
    }
    for (int j = 0; j < fcount; j++) {
        f *= 1000 / 8;
		while (f > 17000000) f /= 10;
    }
    char si[100];
    char sf[100];
    char s[100];
    itoa(i, si);
    itoa(f, sf);
    strcat(si, ".");
    strcpy(s, si);
    strcat(s, sf);
    char* ps = s;
    return ps;
}

char* fhtoa(char *p){
    int fcount = 0;
    int i = 0;
    float f = 0;
	while ((*p != 'x') && (*p != 'X')) p ++;
	p ++;
    while (*p != '.') {
		int tmp;
		if ( *p <= '9') tmp = *p - '0';
		else tmp = 10 + *p - 'a';
        i = i * 16 + tmp;
        p++;
    }
    p++;
    while (*p != '\0') {
		int tmp;
		if (*p <= '9') tmp = *p - '0';
		else tmp = 10 + *p - 'a';
        f = f * 16 + tmp;
        p++;
        fcount++;
    }
    for (int j = 0; j < fcount; j++) {
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
    char* ps = s;
    return ps;
}

int otoi(char *p) {   
	int n;
    n= *p - '0';
    p++;
    while(*p != '\0') {
    	n = n * 8 + *p - '0';
    	p++;
    }
    return n;
}

int htoi(char s[]) {
    int i = 2;
    int n = 0;
    for(; s[i] != '\0'; ++i) {
        if (s[i] > '9') {
            n = 16 * n + (10 + s[i] - 'a');
        } else {
            n = 16 * n + (s[i] - '0');
        }
    }
    return n;
}

void print_ans(int fa, FILE* fp) {
    if (fa == _MARK) {
        printf("_\t%s\n", yytext);
        fprintf(fp, "_\t%s\n", yytext);
    }
    else if (fa == _IDN) {
        printf("IDN\t%s\n", yytext);
        fprintf(fp, "IDN\t%s\n", yytext);
    }
    else if (fa == _INT_8) {
        printf("INT8\t%d\n", otoi(yytext));
        fprintf(fp, "INT8\t%d\n", otoi(yytext));
    }
    else if (fa == _INT_10) {
        printf("INT10\t%d\n", atoi(yytext));
        fprintf(fp, "INT10\t%d\n", atoi(yytext));
    }
    else if (fa == _INT_16) {
        printf("INT16\t%d\n", htoi(yytext));
        fprintf(fp, "INT16\t%d\n", htoi(yytext));
    }
    else if (fa == _REAL_8) {
        printf("REAL8\t%s\n", fotoa(yytext));
        fprintf(fp, "REAL8\t%s\n", fotoa(yytext));
    }
    else if (fa == _REAL_10) {
        printf("REAL10\t%g\n", atof(yytext));
        fprintf(fp, "REAL10\t%g\n", atof(yytext));
    }
    else if (fa == _REAL_16) {
        printf("REAL16\t%s\n", fhtoa(yytext));
        fprintf(fp, "REAL16\t%s\n", fhtoa(yytext));
    }
    else if (fa == _IF) {
        printf("_\t%s\n", yytext);
        fprintf(fp, "_\t%s\n", yytext);
    }
    else if (fa == _WHILE) {
        printf("_\t%s\n", yytext);
        fprintf(fp, "_\t%s\n", yytext);
    }
    else if (fa == _DO) {
        printf("_\t%s\n", yytext);
        fprintf(fp, "_\t%s\n", yytext);
    }
    else if (fa == _ELSE) {
        printf("_\t%s\n", yytext);
        fprintf(fp, "_\t%s\n", yytext);
    }
    else if (fa == _THEN) {
        printf("_\t%s\n", yytext);
        fprintf(fp, "_\t%s\n", yytext);
    }
}

int yywrap() {
	return 1;
}

int main() {
    yyin = fopen("input.txt", "r");
    int temp_fa;
    FILE* fp = fopen("chart.txt", "w");
    while (temp_fa = yylex()) {
        print_ans(temp_fa, fp);
    }
    yywrap();
    return 0;
}
