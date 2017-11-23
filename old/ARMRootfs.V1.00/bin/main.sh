#!/bin/sh

#export MYVAR="apple"
echo "Current Dir: $PWD"

env

/bin/sh  proc1.ARM.run 

export LIBPATH=/usr/local/lib

