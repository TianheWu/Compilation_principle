all: scanner
	./scanner in.txt out.txt

scanner: parse.tab.c lex.yy.c
	gcc -o $@ parse.tab.c lex.yy.c -lm

lex.yy.c: scanner.l
	flex scanner.l

parse.tab.c parse.tab.h: parse.y parse.h
	bison -vd parse.y

clean:
	rm -f parse.tab.c parse.tab.h parse.output scanner lex.yy.c