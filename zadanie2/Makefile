euron: euronmain.o euron.o
	gcc -pthread -o euron euronmain.o euron.o
euron.o: euron_w.asm
	nasm -DN=2 -f elf64 -o euron.o euron.asm
euronmain.o: euronmain.c
	gcc -c -DN=2 -Wall euronmain.c
clean:
	rm  *.o
