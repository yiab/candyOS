
GCC = gcc #arm-none-linux-gnueabi-gcc
PREFIX=/usr
CFLAGS = -g -O2 -Wall
CFLAGS_ME = $(shell pkg-config cairo gtk+-2.0 --cflags)

LIBS_ME = $(shell pkg-config cairo gtk+-2.0 --libs)

VERSION = 2.1.0

all: cairo-test

cairo-test: cairo-test.c
	${GCC} -o cairo-test cairo-test.c ${CFLAGS} ${CFLAGS_ME} ${LIBS_ME} ${LDFLAGS}

clean:
	-rm -f cairo-test *~


