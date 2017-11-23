
GCC = gcc # arm-none-linux-gnueabi-gcc
PREFIX=/usr
CFLAGS = -g -O2 -Wall
CFLAGS_ME = $(shell pkg-config x11 --cflags)

LIBS_ME = $(shell pkg-config x11 --libs)

VERSION = 2.1.0

all: x11-simple

x11-simple: x11-simple.c
	${GCC} -o x11-simple x11-simple.c ${CFLAGS} ${CFLAGS_ME} ${LIBS_ME} ${LDFLAGS}

clean:
	-rm -f x11-simple *~


