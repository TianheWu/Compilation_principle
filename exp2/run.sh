flex scanner.l
bison -vd parse.y
gcc -o scann y.tab.c lex.yy.c -lm