CC = gcc
NASM = nasm
CFLAGS = -Wall -O0 -g -m64
LDFLAGS = -no-pie -lm -g
NASMFLAGS = -f elf64 -g -F dwarf

all: main

main: main.o b64.o hamming.o
	$(CC) $(LDFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c $<

b64.o: b64.c
	$(CC) $(CFLAGS) -c $<

hamming.o: hamming.s
	$(NASM) $(NASMFLAGS) -o $@ $<

clean:
	rm -f *.o main

.PHONY: all clean
