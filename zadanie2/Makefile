euron: euronmain.o euron.o
	gcc -pthread -o euron euronmain.o euron.o
euron.o: euron.asm
	nasm -DN=1000000 -f elf64 -o euron.o euron.asm
euronmain.o: euronmain.c
	gcc -c -DN=2 -Wall euronmain.c
clean:
	rm  *.o
