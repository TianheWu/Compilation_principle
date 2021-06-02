all: exp_1
	./exp_1

exp_1 : lex.yy.c
	gcc -o exp_1 lex.yy.c -lm

lex.yy.c : exp_1.l
	lex exp_1.l 

clean:
	rm -f lex.yy.c exp_1