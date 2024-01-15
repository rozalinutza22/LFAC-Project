#!/bin/bash

bison -d t.y
lex t.l
g++ IdList.cpp lex.yy.c  t.tab.c -std=c++11 -o t
./t input
