SRC=src/
TST=test/
BLD=build/


.PHONY: clean all test

all: myc

y.tab.h y.tab.c: $(SRC)lang.y
	bison -v -y -d $<

lex.yy.c:	$(SRC)lang.l y.tab.h
	flex $<

myc: lex.yy.c y.tab.c $(SRC)Table_des_symboles.c $(SRC)Table_des_chaines.c $(SRC)Attribute.c
	gcc -o $@ $^

test: myc
	./$< < $(TST)test.myc
	gcc $(TST)test.h $(TST)test.c -o $(TST)$@

clean:
	rm -f lex.yy.c *.o y.tab.h y.tab.c myc *~ y.output test.* testmyc $(TST)\#* $(TST)test.c $(TST)test.h $(TST)test log
