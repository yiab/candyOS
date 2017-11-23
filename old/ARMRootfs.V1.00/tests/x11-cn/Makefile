
GCC = gcc #arm-none-linux-gnueabi-gcc
PREFIX=/usr
CFLAGS = -g -O2 -Wall
CFLAGS_ME = $(shell pkg-config x11 freetype2 xft fontconfig --cflags)

LIBS_ME = $(shell pkg-config x11 freetype2 xft fontconfig --libs)

VERSION = 2.1.0

all: x11-cn

x11-cn: x11-cn.c
	${GCC} -o x11-cn x11-cn.c ${CFLAGS} ${CFLAGS_ME} ${LIBS_ME} ${LDFLAGS}

clean:
	-rm -f x11-cn *~


