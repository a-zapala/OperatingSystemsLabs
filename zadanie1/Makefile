attack:
	nasm -f elf64 -o attack.o attack.asm
	ld --fatal-warnings -o attack attack.o

clean:
	rm -f attack attack.o
