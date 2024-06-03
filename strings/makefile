CC = gcc
AS = as
CFLAGS = -Wall -O0 -g -m64
LDFLAGS = -no-pie -lm -g

all: main

main: main.o b64.o hamming.o
	$(CC) $(LDFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c $<

b64.o: b64.c
	$(CC) $(CFLAGS) -c $<

hamming.o: hamming.s
	$(AS) --64 -o $@ $<

clean:
	rm -f *.o main

.PHONY: all clean