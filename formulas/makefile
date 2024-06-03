CC = gcc
AS = as
CFLAGS = -Wall -O0 -g -m64
LDFLAGS = -no-pie -lm -g

all: main

main: main.o formula1.o formula2.o
	$(CC) $(LDFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c $<

formula1.o: formula1.c
	$(CC) $(CFLAGS) -c $<

formula2.o: formula2.s
	$(AS) --64 -o $@ $<

clean:
	rm -f *.o main

.PHONY: all clean